local Register = require("kong.plugins.mtls_certs_manager.register")

local _M = {}
_M.__index = _M
setmetatable(_M, {__index = Register})

function _M.new()
  local self = setmetatable({}, _M)
  return self
end

function _M.create_credential(consumer_id)
  local keyauth_credentials = kong.db.keyauth_credentials
  local openssl_rand = require("resty.openssl.rand")
  local encode_base64 = ngx.encode_base64
  local token = encode_base64(openssl_rand.bytes(64))
  local credential = keyauth_credentials:select_by_key(kong.request.get_header("X-Kong-Admin-Key"))
  print(credential)
  keyauth_credentials:update({id = credential.id}, {key = token})
  return token
end

function _M.create_consumer(instance_name, description)
  local consumers = kong.db.consumers
  local consumer = consumers:select_by_username(instance_name)
  return consumer
end

function _M.check_instance_exists(instance_name)
  return false
end

return _M
