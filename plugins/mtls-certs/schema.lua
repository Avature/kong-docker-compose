local typedefs = require "kong.db.schema.typedefs"

return {
    name = "mtls-certs",
    fields = {
      { consumer = typedefs.no_consumer },
      { protocols = typedefs.protocols_http },
      { config = {
        type = "record",
        fields = {
          { ca_private_key_path = { type = "string", default = "/usr/local/custom/kong/plugins/mtls-certs/certs/CA-key.pem" }, },
          { ca_certificate_path = { type = "string", default = "/usr/local/custom/kong/plugins/mtls-certs/certs/CA-cert.pem" }, },
          { csr_path = { type = "string", default = "/usr/local/custom/kong/plugins/mtls-certs/certs/mydomain.com.csr" }, }
        },
    }, },
  }
}
