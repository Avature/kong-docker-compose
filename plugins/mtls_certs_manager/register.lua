local base = require("kong.plugins.mtls_certs_manager.base")
local _M = setmetatable({}, base)

local consumers = kong.db.consumers
local encode_base64 = ngx.encode_base64
local keyauth_credentials = kong.db.keyauth_credentials
local openssl_rand = require("resty.openssl.rand")

function _M.create_credential(consumer_id)
  local token = encode_base64(openssl_rand.bytes(64))
  keyauth_credentials:insert({key = token, consumer = {id = consumer_id}})
  return token
end

function _M.check_instance_exists(instance_name)
  local consumer = consumers:select_by_username(instance_name)
  return consumer ~= nil
end

function _M.requires_consumer_creation()
  return true
end

function _M.execute(conf)
  local request_body = kong.request.get_body()
  local instance_name = request_body.instance.name
  if _M.check_instance_exists(instance_name) then
    return _M.respond(401, "Instance already exists")
  end
  return _M.doExecute(conf)
end

return _M
