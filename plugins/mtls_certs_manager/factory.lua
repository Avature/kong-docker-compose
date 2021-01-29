local register = require("kong.plugins.mtls_certs_manager.register")
local renew = require("kong.plugins.mtls_certs_manager.renew")

local MtlsCertsHandlerFactory = {}

function MtlsCertsHandlerFactory:getInstance(conf)
  local instance = nil
  if conf.is_for_renewal then
    instance = renew.new()
  else
    instance = register.new()
  end
  return instance
end

return MtlsCertsHandlerFactory
