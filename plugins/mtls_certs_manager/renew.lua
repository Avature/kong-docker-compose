local register = require("kong.plugins.mtls_certs_manager.register")

local Renew = {}

function Renew:new()
  local renew = {}
  setmetatable(register, self)
  self.__index = self
  return renew
end

function Renew:create_consumer(instance_name, description)
  local consumer = consumers:select_by_username(instance_name)
  return consumer
end

function Renew:check_instance_exists(instance_name)
  return false
end

return Renew
