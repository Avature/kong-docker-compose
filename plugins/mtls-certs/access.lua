local _M = {}

local consumers = kong.db.consumers
local x509 = require("resty.openssl.x509")
local req = require("resty.openssl.x509.csr")
local pkey = require("resty.openssl.pkey")

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
  local private_key = conf.ca_private_key_path
  local request_body = kong.request.get_body()
  local instance_name = request_body.instance.name
  local instance_description = request_body.instance.description
  local csr = request_body.csr

  if _M.check_instance_exists(instance_name) then
    return kong.response.exit(401, "Instance already exists")
  end

  local parsed_req = req.new(csr)
  local cert = x509.new()
  local ca_key_contents = _M.read_file(private_key)
  local ca_parsed_key = pkey.new(ca_key_contents)
  -- FIXME:
  -- I could not find how to use the csr / req at the time of signing and not only use the private key
  cert:sign(ca_parsed_key)
  local result = cert:tostring()

  _M.create_consumer(instance_name, instance_description)
  return kong.response.exit(201, "Registered instance: " .. parsed_req .. private_key .. result)
end

return _M
