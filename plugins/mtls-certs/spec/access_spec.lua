if os.getenv("LOCAL_LUA_DEBUGGER_VSCODE") == "1" then
  require("lldebugger").start()
end

local helper = require("spec.helper")

it("should reject already registered instance", function()
  helper.mock_return('kong.db.consumers', 'select_by_username', {instance_name = "test_instance"})
  helper.mock_return('kong.request', 'get_body', { instance = { name = "test_instance", description = "test_description"}, csr = "test_csr_string" })
  helper.mock_return('kong.response', 'exit', {})

  _G.package.loaded['kong.plugins.mtls-certs.x509_name_helper'] = require('x509_name_helper')
  _G.package.loaded["resty.openssl.x509"    ] = {}
  _G.package.loaded["resty.openssl.x509.csr"] = {}
  _G.package.loaded["resty.openssl.pkey"    ] = {}
  _G.package.loaded["resty.openssl.bn"      ] = {}

  local subject = require('access')
  local conf = {
    ca_private_key_path = "",
    ca_certificate_path = "",
    ca_private_key_passphrase = "test_passphrase"
  }

  spy.on(_G.kong.response, "exit")

  subject.execute(conf)
  assert.spy(_G.kong.response.exit).was_called_with(401, {message = "Instance already exists"})
end)

it("should reject unknown instance with empty csr request", function()
  helper.mock_return('kong.db.consumers', 'select_by_username', nil)
  helper.mock_return('kong.request', 'get_body', { instance = { name = "test_instance", description = "test_description"}, csr = "" })
  helper.mock_return('kong.response', 'exit', {})

  _G.package.loaded['kong.plugins.mtls-certs.x509_name_helper'] = require('x509_name_helper')
  _G.package.loaded["resty.openssl.x509"    ] = {}
  _G.package.loaded["resty.openssl.x509.csr"] = {}
  _G.package.loaded["resty.openssl.pkey"    ] = {}
  _G.package.loaded["resty.openssl.bn"      ] = {}

  local subject = require('access')
  local conf = {
    ca_private_key_path = "./example_certs/CA-key.pem",
    ca_certificate_path = "",
    ca_private_key_passphrase = "test_passphrase"
  }

  spy.on(_G.kong.response, "exit")

  subject.execute(conf)
  assert.spy(_G.kong.response.exit).was_called_with(400, {message = "CSR Contents are empty"})
end)
