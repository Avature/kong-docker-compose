local access = require("kong.plugins.client_consumer_validator.access")

local ClientConsumerValidator = {
  PRIORITY = 2,
  VERSION = "0.0.1",
}

function ClientConsumerValidator:access(conf)
  return access.execute(conf)
end

return ClientConsumerValidator
