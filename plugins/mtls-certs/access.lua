local _M = {}

local name_helper = require("kong.plugins.mtls-certs.x509_name_helper")

local consumers = kong.db.consumers
local x509 = require("resty.openssl.x509")
local csr = require("resty.openssl.x509.csr")
local pkey = require("resty.openssl.pkey")
local bn = require("resty.openssl.bn")

function _M.read_file(file)
  local f = assert(io.open(file, "rb"))
  local content = f:read("*all")
  f:close()
  return content
end

function _M.create_consumer(name, description)
  local _tags = {"instance-admin-client"}
  if description ~= nil and description:match("%S") ~= nil then
    table.insert(_tags, "description-" .. description:gsub("%s+", "_"))
  end
  local consumer = {
    username = name,
    tags = _tags
  }
  consumers:insert(consumer)
end

function _M.check_instance_exists(instance_name)
  local consumer = consumers:select_by_username(instance_name)
  return consumer ~= nil
end

function _M.respond(statusCode, message, errorDescription)
  local output = {
    message = message
  }
  if errorDescription then
    output.error_description = errorDescription
  end
  return kong.response.exit(statusCode, output)
end

function _M.execute(conf)
  local request_body = kong.request.get_body()
  local instance_name = request_body.instance.name
  local instance_description = request_body.instance.description
  local csr_content = request_body.csr
  local ca_passphrase  = conf.ca_private_key_passphrase
  if conf.csr_path ~= nil then
    csr_content = _M.read_file(conf.csr_path)
  end
  if _M.check_instance_exists(instance_name) then
    return _M.respond(401, "Instance already exists")
  end
  local private_key_path = conf.ca_private_key_path
  local certificate_path = conf.ca_certificate_path
  local ca_private_key_content = _M.read_file(private_key_path)
  local ca_certificate_content = _M.read_file(certificate_path)
  if not csr_content then
    return _M.respond(400, "CSR Contents are empty")
  end
  local parsed_csr, err = csr.new(csr_content)
  if err then
    return _M.respond(400, "CSR Contents are invalid", err)
  end
  local subject, err = parsed_csr:get_subject_name()
  if err then
    return _M.respond(400, "Cannot get subject from CSR", err)
  end
  local csr_pubkey, err = parsed_csr:get_pubkey()
  if err then
    return _M.respond(400, "Cannot get public key from CSR", err)
  end
  local csr_verified_ok, err = parsed_csr:verify(csr_pubkey)
  if not csr_verified_ok then
    return _M.respond(400, "Cannot get subject from CSR", err)
  end
  local subject_name = name_helper.tostring(subject)
  local subject_common_name = string.match( subject_name, conf.common_name_regex);

  if subject_common_name ~= instance_name then
    return _M.respond(401, "Instance name does not match CSR's subject",
      "distinguished name is: " .. subject_name .. " but the instance_name given was: " .. instance_name
    )
  end
  local crt_output = x509.new()
  crt_output:set_subject_name(subject)
  crt_output:set_pubkey(csr_pubkey)
  local seconds_of_validity = conf.days_of_validity * 60 * 60 * 24
  crt_output:set_not_after(ngx.time() + seconds_of_validity)
  crt_output:set_not_before(ngx.time())
  local serial_number, err = bn.new(ngx.time())
  if err then
    return _M.respond(400, "Error creating serial number", err)
  end
  crt_output:set_serial_number(serial_number)
  local ca_pkey_config = nil
  if ca_passphrase ~= nil then
    ca_pkey_config = {  passphrase = ca_passphrase }
  end
  local parsed_private_key = pkey.new(ca_private_key_content, ca_pkey_config)
  crt_output:sign(parsed_private_key)
  local parsed_ca_certificate, err = x509.new(ca_certificate_content)
  if err then
    return _M.respond(500, "Cannot load CA certificate", err)
  end
  local ok, err = crt_output:verify(parsed_ca_certificate:get_pubkey())
  if err or not ok then
    return _M.respond(500, "Cannot validate generated certificate", tostring(err))
  end
  _M.create_consumer(instance_name, instance_description)

  return _M.respond(201, {
    crt = crt_output:to_PEM()
  })
end

return _M
