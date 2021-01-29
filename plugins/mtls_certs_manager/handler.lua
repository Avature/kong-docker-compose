local MtlsCertsHandlerFactory = require("kong.plugins.mtls_certs_manager.factory")

local MtlsCertsHandler = {
  PRIORITY = 1,
  VERSION = "0.0.1",
}

function MtlsCertsHandler:access(conf)
  local instance = MtlsCertsHandlerFactory:getInstance(conf)
  return instance:execute(conf)
end

return MtlsCertsHandler
