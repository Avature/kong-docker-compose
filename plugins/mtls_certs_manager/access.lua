local base = require("kong.plugins.mtls_certs_manager.base")
local _M = base:extend()

function _M.execute(conf)
  return _M.super.execute(conf)
end

return _M
