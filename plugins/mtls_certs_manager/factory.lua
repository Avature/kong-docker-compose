local access = require("kong.plugins.mtls_certs_manager.access")

local MtlsCertsHandlerFactory = {}

function MtlsCertsHandlerFactory:getInstance(conf)
  return access.new()
end

return MtlsCertsHandlerFactory
