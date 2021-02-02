local Register = require("kong.plugins.mtls_certs_manager.register")

local _M = {}
_M.__index = _M
setmetatable(_M, {__index = Register})

function _M.new()
  local self = setmetatable({}, _M)
  return self
end

function _M.create_consumer(instance_name, description)
  local consumer = consumers:select_by_username(instance_name)
  return consumer
end

function _M.check_instance_exists(instance_name)
  return true
end

return _M
