if os.getenv("LOCAL_LUA_DEBUGGER_VSCODE") == "1" then
  require("lldebugger").start()
end

local helper = require("spec.helper")
assert:register("matcher", "is_json_like", helper.is_json_like)

local load_default_dependencies = function ()
  _G.package.loaded['kong.plugins.mtls_certs_manager.x509_name_helper'] = require('x509_name_helper')
  _G.package.loaded["kong.vendor.classic"] = helper.get_extender()
  _G.package.loaded["resty.openssl.x509"    ] = {}
  _G.package.loaded["resty.openssl.x509.csr"] = {}
  _G.package.loaded["resty.openssl.pkey"    ] = {}
  _G.package.loaded["resty.openssl.bn"      ] = {}
  helper.mock_return('resty.openssl.rand', 'bytes', '9999999999999999')
  helper.mock_return('ngx', 'encode_base64', '\"base64_encoded_key\"')
end

local require_renew = function()
  _G.package.loaded["renew"] = nil
  _G.package.loaded["base"] = nil
  _G.package.loaded["kong.plugins.mtls_certs_manager.base"] = require('base')
  return require('renew')
end

describe("mtls_certs_manager renew hook feature", function()
  before_each(function()
    helper.clear_runs()
    load_default_dependencies()
  end)

  it("should accept request and renew the consumers token", function()
    helper.mock_return('kong.db.consumers', 'insert')
    helper.mock_return('kong.db.consumers', 'select_by_username')
    helper.mock_return('kong.db.consumers', 'select_by_username', '{instance_name = "mydomain.com", id = 5}')
    helper.mock_return('kong.db.keyauth_credentials', 'insert')
    helper.mock_return('kong.db.keyauth_credentials', 'delete')
    helper.mock_return('kong.client', 'get_credential', '{ id = "some-valid-id" }')
    helper.mock_return('kong.request', 'get_body', '{ instance = { name = "mydomain.com", description = "test_description"}, csr = "valid-csr-pubkey-not-matches-signature" }')
    helper.mock_return('kong.response', 'exit', '{}')
    helper.mock_return('parsed_csr_mock', 'get_subject_name', '{}, nil')
    helper.mock_return('parsed_csr_mock', 'get_pubkey', '{}, nil')
    helper.mock_return('resty.openssl.bn', 'from_binary', '{}, nil')
    helper.mock_return('mocked_file_resource', 'read', '"contents"')
    helper.mock_return('mocked_file_resource', 'close')
    helper.mock_return('io', 'open', 'mocked_file_resource')
    helper.mock_return('parsed_csr_mock', 'verify', 'true, nil')
    helper.mock_return('kong.plugins.mtls_certs_manager.x509_name_helper', 'tostring', '\'C=US, ST=CA, CN=mydomain.com/O="MyOrg, Inc."\'')
    helper.mock_return('resty.openssl.x509.csr', 'new', 'parsed_csr_mock, nil')
    helper.mock_return('mocked_crt_object', 'set_subject_name')
    helper.mock_return('mocked_crt_object', 'set_pubkey')
    helper.mock_return('mocked_crt_object', 'set_not_after')
    helper.mock_return('mocked_crt_object', 'set_not_before')
    helper.mock_return('mocked_crt_object', 'set_serial_number')
    helper.mock_return('mocked_crt_object', 'sign')
    helper.mock_return('mocked_crt_object', 'to_PEM', '"valid crt contents"')
    helper.mock_return('mocked_crt_object', 'verify', 'true, nil')
    helper.mock_return('mocked_crt_object', 'set_issuer_name')
    helper.mock_return('ca_mocked_crt_object', 'get_pubkey', '{}')
    helper.mock_return('ca_mocked_crt_object', 'get_subject_name', '{}')
    helper.mock_return('ngx', 'time', '1111111')
    helper.mock_return('resty.openssl.pkey', 'new', '{}')
    helper.mock_return('resty.openssl.x509', 'new', 'mocked_crt_object')
    helper.mock_return('resty.openssl.x509', 'new', 'ca_mocked_crt_object, nil', 1)

    local subject = require_renew()

    local conf = {
      ca_private_key_path = "./example_certs/CA-key.pem",
      ca_certificate_path = "",
      ca_private_key_passphrase = "test_passphrase",
      common_name_regex = "CN=(.*)/O=",
      days_of_validity = 60
    }

    spy.on(_G.kong.response, "exit")
    spy.on(_G.kong.db.consumers, 'insert')
    spy.on(_G.kong.db.keyauth_credentials, 'insert')

    subject.execute(conf)

    assert.spy(_G.kong.response.exit).was_called_with(201, {certificate = "valid crt contents", token = "base64_encoded_key"})
    assert.spy(_G.kong.db.consumers.insert).was_not_called()
    assert.spy(_G.kong.db.keyauth_credentials.insert).was_called_with(match.is_table(), match.is_json_like(
      {key = "base64_encoded_key", consumer = {id = 5}}
    ))
  end)
end)
