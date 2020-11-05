local access = require("kong.plugins.mtls_certs_manager.access")

local MtlsCertsHandler = {
  PRIORITY = 1,
  VERSION = "0.0.1",
}

function MtlsCertsHandler:access(conf)
  return access.execute(conf)
end

return MtlsCertsHandler
