local typedefs = require "kong.db.schema.typedefs"

return {
  name = "file_log_censored",
  fields = {
    { protocols = typedefs.protocols },
    { config = {
        type = "record",
        fields = {
          { path = {  type = "string",
                      required = true,
                      match = [[^[^*&%%\`]+$]],
                      err = "not a valid filename",
          }, },
          { reopen = { type = "boolean", required = true, default = false }, },
          { censored_fields = { required = false,
                                type = "array",
                                elements = { type = 'string' },
                                default = {},
          }, },
    }, }, },
  }
}
