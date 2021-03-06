local Object = require("kong.vendor.classic")
local _M = Object:extend()

local name_helper = require("kong.plugins.mtls_certs_manager.x509_name_helper")
local encode_base64 = ngx.encode_base64
local keyauth_credentials = kong.db.keyauth_credentials
local x509 = require("resty.openssl.x509")
local csr = require("resty.openssl.x509.csr")
local pkey = require("resty.openssl.pkey")
local bn = require("resty.openssl.bn")
local openssl_rand = require("resty.openssl.rand")

function _M:read_file(file_name)
  local file_resource = assert(io.open(file_name, "rb"))
  local content = file_resource:read("*all")
  file_resource:close()
  return content
end

function _M:create_credential(consumer_id)
  local token = encode_base64(openssl_rand.bytes(64))
  keyauth_credentials:insert({key = token, consumer = {id = consumer_id}})
  return token
end

function _M:get_consumer(instance_name, description)
  error("This function shoud be implemented")
end

function _M:respond(statusCode, message, errorDescription)
  local output = {
    message = message
  }
  if errorDescription then
    output.error_description = errorDescription
  end
  return kong.response.exit(statusCode, output)
end

function _M:hasValidationErrors()
  -- Add JSON Payload Schema Validation To MTLS
  -- see case https://teg.avature.net/#Case/584763
  return nil, nil
end

function _M:execute(conf)
  local message, code = self:hasValidationErrors()
  if message then
    return self:respond(code, message)
  end
  return self:doExecute(conf)
end

function _M:doExecute(conf)
  local request_body = kong.request.get_body()
  local instance_name = request_body.instance.name
  local instance_description = request_body.instance.description
  local csr_content = request_body.csr
  if not csr_content or csr_content == "" then
    return self:respond(400, "CSR Contents are empty")
  end
  local parsed_csr, err = csr.new(csr_content)
  if err then
    return self:respond(400, "Error parsing CSR contents", tostring(err))
  end
  local subject, err = parsed_csr:get_subject_name()
  if err then
    return self:respond(400, "Cannot get subject from CSR", tostring(err))
  end
  local csr_pubkey, err = parsed_csr:get_pubkey()
  if err then
    return self:respond(400, "Cannot get public key from CSR", tostring(err))
  end
  local csr_verified_ok, err = parsed_csr:verify(csr_pubkey)
  if not csr_verified_ok then
    return self:respond(400, "Cannot verify the CSR authenticity", tostring(err))
  end
  local subject_name = name_helper.tostring(subject)
  local subject_common_name = string.match(subject_name, conf.common_name_regex);
  if subject_common_name ~= instance_name then
    return self:respond(401, "Instance name does not match CSR subject's CN",
      "distinguished name is: " .. subject_name .. " but the instance name given was: " .. instance_name
    )
  end
  local private_key_path = conf.ca_private_key_path
  local certificate_path = conf.ca_certificate_path
  local ca_private_key_content = self:read_file(private_key_path)
  local ca_certificate_content = self:read_file(certificate_path)
  local crt_output = x509.new()
  crt_output:set_subject_name(subject)
  crt_output:set_pubkey(csr_pubkey)
  local seconds_of_validity = conf.days_of_validity * 60 * 60 * 24
  crt_output:set_not_after(ngx.time() + seconds_of_validity)
  crt_output:set_not_before(ngx.time())
  local serial_number, err = bn.from_binary(openssl_rand.bytes(16))
  if err then
    return self:respond(400, "Error creating serial number", tostring(err))
  end
  crt_output:set_serial_number(serial_number)
  local ca_pkey_config = nil
  local ca_passphrase  = conf.ca_private_key_passphrase
  if ca_passphrase ~= nil then
    ca_pkey_config = {  passphrase = ca_passphrase }
  end
  local parsed_private_key = pkey.new(ca_private_key_content, ca_pkey_config)
  local parsed_ca_certificate, err = x509.new(ca_certificate_content)
  if err then
    return self:respond(500, "Cannot load CA certificate", tostring(err))
  end
  crt_output:set_issuer_name(parsed_ca_certificate:get_subject_name())
  crt_output:sign(parsed_private_key)
  local ok, err = crt_output:verify(parsed_ca_certificate:get_pubkey())
  if err or not ok then
    return self:respond(500, "Cannot validate generated certificate", tostring(err))
  end
  local inserted_consumer = self:get_consumer(instance_name, instance_description)
  if inserted_consumer == nil then
    return self:respond(400, 'Unable to create consumer', 'Verify instance name and description for invalid characters')
  end
  local token = self:create_credential(inserted_consumer.id)
  return kong.response.exit(201, {
    certificate = crt_output:to_PEM(),
    token = token
  })
end

return _M
