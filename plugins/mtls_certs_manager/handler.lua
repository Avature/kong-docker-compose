local MtlsCertsHandlerFactory = require("kong.plugins.mtls_certs_manager.factory")
local Object = require("kong.plugins.base_plugin")
local MtlsCertsHandler = Object:extend()

local MtlsCertsHandler = {
  PRIORITY = 1,
  VERSION = "0.0.1",
}

function MtlsCertsHandler:access(conf)
  local role = MtlsCertsHandlerFactory:getRole(conf)
  return role:execute(conf)
end

return MtlsCertsHandler
