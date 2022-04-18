local typedefs = require "kong.db.schema.typedefs"

local CONSUMER_IDENTIFIERS = {
  "consumer_id",
  "custom_id",
  "username",
}

local METHODS = {
  "GET",
  "HEAD",
  "PUT",
  "PATCH",
  "POST",
  "DELETE",
  "OPTIONS",
  "TRACE",
  "CONNECT",
}

local rule_element = {
  type = "record",
  fields = {
    { request_path_activation_regex = { type = "string", default = "(.*)" } },
    { search_in_header = { type = "string", default = nil } },
    { search_in_json_payload = { type = "string", default = nil } },
    { expected_consumer_identifier_regex = { type = "string", default = "(.*)" } },
    { methods = {
      type = "array",
      default = {},
      elements = {
        type = "string",
        one_of = METHODS,
    }, }, },
  }
}

local result = {}

for i=1,3 do
  local field = {}
  field['rule_' .. tostring(i)] = rule_element
  table.insert(result, field)
end

return {
  name = "client_consumer_validator",
  fields = {
    { protocols = typedefs.protocols_http },
    { config = {
        type = "record",
        fields = {
          {consumer_identifier = { type = "string", one_of = CONSUMER_IDENTIFIERS}},
          {rules = { type="record", fields = result}}
        }
      },
    },
  },
}
