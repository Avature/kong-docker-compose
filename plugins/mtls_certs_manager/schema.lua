local typedefs = require "kong.db.schema.typedefs"

return {
    name = "mtls_certs_manager",
    fields = {
      { consumer = typedefs.no_consumer },
      { protocols = typedefs.protocols_http },
      { config = {
        type = "record",
        fields = {
          { plugin_endpoint_usage = { type = "string", default = "register_instance", one_of = { "register_instance" } } },
          { ca_private_key_path = { type = "string", default = "/usr/local/custom/kong/plugins/mtls_certs_manager/example_certs/CA-key.pem" }, },
          { ca_private_key_passphrase = { type = "string", default = "1234" }, },
          { ca_certificate_path = { type = "string", default = "/usr/local/custom/kong/plugins/mtls_certs_manager/example_certs/CA-cert.pem" }, },
          { common_name_regex = { type = "string", default = "CN=(.*)/O=" }, },
          { days_of_validity = { type = "integer", default = 60 }, }
          -- ,{ csr_path = { type = "string" } }
        },
    }, },
  }
}
