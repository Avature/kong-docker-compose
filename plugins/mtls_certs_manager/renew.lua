local _M = require("kong.plugins.mtls_certs_manager.base")

local encode_base64 = ngx.encode_base64
local keyauth_credentials = kong.db.keyauth_credentials
local openssl_rand = require("resty.openssl.rand")

function _M.create_credential(consumer_id)
  local token = encode_base64(openssl_rand.bytes(64))
  local credential_id = kong.client.get_credential().id
  keyauth_credentials:delete({ id = credential_id })
  keyauth_credentials:insert({ key = token, consumer = { id = consumer_id }})
  return token
end

function _M.requires_consumer_creation()
  return false
end

function _M.execute(conf)
  return _M.doExecute(conf)
end

return _M
