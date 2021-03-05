local MtlsCertsHandlerFactory = {}

local register = require("kong.plugins.mtls_certs_manager.register")
local renew = require("kong.plugins.mtls_certs_manager.renew")

local Roles = {
  ["register_instance"] = register,
  ["renew_instance"] = renew
}

function MtlsCertsHandlerFactory:getRole(conf)
  return register
end

return MtlsCertsHandlerFactory
