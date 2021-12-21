local base = require("kong.plugins.mtls_certs_manager.base")
local _M = base:extend()

local keyauth_credentials = kong.db.keyauth_credentials
local consumers = kong.db.consumers

function _M:create_credential(consumer_id)
  local credential_id = kong.client.get_credential().id
  keyauth_credentials:delete({ id = credential_id })
  return self.super:create_credential(consumer_id)
end

function _M:get_consumer(instance_name, description)
  return consumers:select_by_username(instance_name)
end

return _M
