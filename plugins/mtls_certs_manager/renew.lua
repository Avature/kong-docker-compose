local Register = require("kong.plugins.mtls_certs_manager.register")

local Renew = {}
Renew.__index = Renew
setmetatable(Renew, {__index = Register})

function Renew:new()
  local self = setmetatable({}, Renew)
  return self
end

function Renew:create_consumer(instance_name, description)
  local consumer = consumers:select_by_username(instance_name)
  return consumer
end

function Renew:check_instance_exists(instance_name)
  return true
end

return Renew
