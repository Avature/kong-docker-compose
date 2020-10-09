local typedefs = require "kong.db.schema.typedefs"

return {
    name = "mtls-certs",
    fields = {
      { consumer = typedefs.no_consumer },
      { protocols = typedefs.protocols_http },
      { config = {
        type = "record",
        fields = {
          { ca_private_key_path = { type = "string", default = "/opt/kong" }, }
        },
    }, },
  }
}
