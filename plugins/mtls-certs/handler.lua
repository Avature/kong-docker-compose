
local access = require("kong.plugins.mtls-certs.access")

local MtlsCertsHandler = {
  PRIORITY = 1,
  VERSION = "0.0.1",
}

function MtlsCertsHandler:access(conf)
  return access.execute(conf)
end

return MtlsCertsHandler
