local register = require("kong.plugins.mtls_certs_manager.register")
local renew = require("kong.plugins.mtls_certs_manager.renew")

local MtlsCertsHandlerFactory = {}
local Roles = {
  ["register_instance"] = register,
  ["renew_instance"] = renew
}

function MtlsCertsHandlerFactory:getRole(conf)
  local role = Roles[conf.plugin_endpoint_usage]
  return role.new()
end

return MtlsCertsHandlerFactory
