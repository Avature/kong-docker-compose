local _M = {}

local consumers = kong.db.consumers
-- local x509 = require("resty.openssl.x509")
local req = require("resty.openssl.x509.csr")
-- local pkey = require("resty.openssl.pkey")

function os.capture(cmd, raw)
  local f = assert(io.popen(cmd, 'r'))
  local s = assert(f:read('*a'))
  local exit_code = f:close()
  if raw then return s end
  s = string.gsub(s, '^%s+', '')
  s = string.gsub(s, '%s+$', '')
  s = string.gsub(s, '[\n\r]+', ' ')
  return s, exit_code
end

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

function _M.execute(conf)
  local private_key_path = conf.ca_private_key_path
  local certificate_path = conf.ca_certificate_path
  local csr_path = conf.csr_path
  local csr_contents = _M.read_file(csr_path)
  local csr_parsed, csr_new_error = req.new(csr_contents, "*")

  if csr_new_error ~= nil then
    return kong.response.exit(500, "Error parsing csr: " .. csr_new_error)
  end

  local ca_key_contents = _M.read_file(private_key_path)
  local ca_parsed_key, new_ca_pkey_error = pkey.new(ca_key_contents, {passphrase="1234"})
  local sign_ok, sign_error = csr_parsed:sign(ca_parsed_key)

  if sign_error ~= nil then
    return kong.response.exit(500, "Error signing csr: " .. sign_error)
  end

  local verify_ok, verify_error = csr_parsed:verify(ca_parsed_key)

  if verify_error ~= nil then
    return kong.response.exit(500, "Error verifying: " .. verify_error)
  end

  local private_key_to_string, error3 = ca_parsed_key:tostring("private")

  local crt_to_string, crt_error = csr_parsed:tostring()

  if crt_error ~= nil then
    return kong.response.exit(500, "Error parsing pkey")
  end



  local subject_name, subject_name_error = csr_parsed:get_subject_name()



  if subject_name_error ~= nil then
    return kong.response.exit(500, "Error with CN: " .. subject_name_error)
  end











  -- local csr_ok, csr_error_2 = parsed_req:sign(ca_parsed_key)


  -- local result, error2 = csr_parsed:get_subject_name()

  -- if error2 ~= nil then
  --   return kong.response.exit(500, "Error getting version: " .. error2)
  -- end
  -- if result == nil then
  --   return kong.response.exit(500, "Error with result nil")
  -- end

  -- if _M.check_instance_exists(instance_name) then
  --   return kong.response.exit(401, "Instance already exists")
  -- end

  -- local parsed_req, csr_error = req.new(csr, "*")
  -- kong.log.err("Error parsing CSR:", csr_error)
  -- local ca_key_contents = _M.read_file(private_key_path)
  -- local ca_parsed_key = pkey.new(ca_key_contents, {passphrase="1234"})
  -- local csr_ok, csr_error_2 = parsed_req:sign(ca_parsed_key)
  -- kong.log.debug("CSR sign OK:", csr_ok)
  -- kong.log.err("Error signing CSR:", csr_error_2)
  -- local result = parsed_req:tostring()

  -- _M.create_consumer(instance_name, instance_description)
  return kong.response.exit(201, "Private Key: " .. private_key_to_string .. " CRT: " .. crt_to_string .. " SUBJECT: " .. subject_name:tostring())
end

return _M
