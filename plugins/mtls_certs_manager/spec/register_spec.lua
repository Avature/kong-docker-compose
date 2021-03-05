if os.getenv("LOCAL_LUA_DEBUGGER_VSCODE") == "1" then
  require("lldebugger").start()
end

local helper = require("spec.helper")
assert:register("matcher", "is_json_like", helper.is_json_like)

local load_default_dependencies = function ()
  _G.package.loaded['kong.plugins.mtls_certs_manager.x509_name_helper'] = require('x509_name_helper')
  _G.package.loaded["resty.openssl.x509"    ] = {}
  _G.package.loaded["resty.openssl.x509.csr"] = {}
  _G.package.loaded["resty.openssl.pkey"    ] = {}
  _G.package.loaded["resty.openssl.bn"      ] = {}
  helper.mock_return('resty.openssl.rand', 'bytes', '9999999999999999')
  helper.mock_return('ngx', 'encode_base64', '\"base64_encoded_key\"')
end

describe("mtls_certs_manager register hook feature", function()
  before_each(function()
    helper.clear_runs()
    load_default_dependencies()
  end)

  -- it("should reject already registered instance", function()
  --   helper.mock_return('kong.db.consumers', 'select_by_username', '{instance_name = "test_instance"}')
  --   helper.mock_return('kong.request', 'get_body', '{ instance = { name = "test_instance", description = "test_description"}, csr = "test_csr_string" }')
  --   helper.mock_return('kong.response', 'exit', '{}')

  --   _G.package.loaded['kong.plugins.mtls_certs_manager.base'] = require('base')
  --   local subject = require('register')

  --   local conf = {
  --     ca_private_key_path = "",
  --     ca_certificate_path = "",
  --     ca_private_key_passphrase = "test_passphrase"
  --   }

  --   spy.on(_G.kong.response, "exit")

  --   subject.execute(conf)
  --   assert.spy(_G.kong.response.exit).was_called_with(401, {message = "Instance already exists"})
  -- end)

  -- it("should reject unknown instance with empty csr request", function()
  --   helper.mock_return('kong.db.consumers', 'select_by_username', 'nil')
  --   helper.mock_return('kong.request', 'get_body', '{ instance = { name = "test_instance", description = "test_description"}, csr = "" }')
  --   helper.mock_return('kong.response', 'exit', '{}')

  --   _G.package.loaded['kong.plugins.mtls_certs_manager.base'] = require('base')
  --   local subject = require('register')

  --   local conf = {
  --     ca_private_key_path = "./example_certs/CA-key.pem",
  --     ca_certificate_path = "",
  --     ca_private_key_passphrase = "test_passphrase"
  --   }

  --   spy.on(_G.kong.response, "exit")

  --   subject.execute(conf)
  --   assert.spy(_G.kong.response.exit).was_called_with(400, {message = "CSR Contents are empty"})
  -- end)

  it("should reject unknown instance with nil csr request", function()
    helper.mock_return('kong.db.consumers', 'select_by_username', 'nil')
    helper.mock_return('kong.request', 'get_body', '{ instance = { name = "test_instance", description = "test_description"}, csr = nil }')
    helper.mock_return('kong.response', 'exit', '{}')

    _G.package.loaded['kong.plugins.mtls_certs_manager.base'] = require('base')
    local subject = require('register')

    local conf = {
      ca_private_key_path = "./example_certs/CA-key.pem",
      ca_certificate_path = "",
      ca_private_key_passphrase = "test_passphrase"
    }

    spy.on(_G.kong.response, "exit")

    subject.execute(conf)
    assert.spy(_G.kong.response.exit).was_called_with(400, {message = "CSR Contents are empty"})
  end)

  it("should reject invalid non-empty CSR contents", function()
    helper.mock_return('kong.db.consumers', 'select_by_username', 'nil')
    helper.mock_return('kong.request', 'get_body', '{ instance = { name = "test_instance", description = "test_description"}, csr = "something-invalid-for-csr" }')
    helper.mock_return('kong.response', 'exit', '{}')
    helper.mock_return('resty.openssl.x509.csr', 'new', 'nil, "impossible to parse csr"')

    _G.package.loaded["register"] = nil
    _G.package.loaded['kong.plugins.mtls_certs_manager.base'] = require('base')
    local subject = require('register')

    local conf = {
      ca_private_key_path = "./example_certs/CA-key.pem",
      ca_certificate_path = "",
      ca_private_key_passphrase = "test_passphrase"
    }

    spy.on(_G.kong.response, "exit")

    subject.execute(conf)
    assert.spy(_G.kong.response.exit).was_called_with(400, {message = "Error parsing CSR contents", error_description = "impossible to parse csr"})
  end)

  it("should reject CSR with no subject", function()
    helper.mock_return('kong.db.consumers', 'select_by_username', 'nil')
    helper.mock_return('kong.request', 'get_body', '{ instance = { name = "test_instance", description = "test_description"}, csr = "valid-csr-but-contains-no-subject" }')
    helper.mock_return('kong.response', 'exit', '{}')
    helper.mock_return('parsed_csr_mock', 'get_subject_name', 'nil, "cannot get subject name"')
    helper.mock_return('resty.openssl.x509.csr', 'new', 'parsed_csr_mock, nil')

    _G.package.loaded["register"] = nil
    _G.package.loaded['kong.plugins.mtls_certs_manager.base'] = require('base')
    local subject = require('register')

    local conf = {
      ca_private_key_path = "./example_certs/CA-key.pem",
      ca_certificate_path = "",
      ca_private_key_passphrase = "test_passphrase"
    }

    spy.on(_G.kong.response, "exit")

    subject.execute(conf)
    assert.spy(_G.kong.response.exit).was_called_with(400, {message = "Cannot get subject from CSR", error_description = "cannot get subject name"})
  end)

  -- it("should reject CSR with no public key attached", function()
  --   helper.mock_return('kong.db.consumers', 'select_by_username', 'nil')
  --   helper.mock_return('kong.request', 'get_body', '{ instance = { name = "test_instance", description = "test_description"}, csr = "valid-csr-but-contains-no-pubkey" }')
  --   helper.mock_return('kong.response', 'exit', '{}')
  --   helper.mock_return('parsed_csr_mock', 'get_subject_name', '{}, nil')
  --   helper.mock_return('parsed_csr_mock', 'get_pubkey', 'nil, "invalid public key"')
  --   helper.mock_return('resty.openssl.x509.csr', 'new', 'parsed_csr_mock, nil')

  --   _G.package.loaded["register"] = nil
  --   _G.package.loaded['kong.plugins.mtls_certs_manager.base'] = require('base')
  --   local subject = require('register')

  --   local conf = {
  --     ca_private_key_path = "./example_certs/CA-key.pem",
  --     ca_certificate_path = "",
  --     ca_private_key_passphrase = "test_passphrase"
  --   }

  --   spy.on(_G.kong.response, "exit")

  --   subject.execute(conf)
  --   assert.spy(_G.kong.response.exit).was_called_with(400, {message = "Cannot get public key from CSR", error_description = "invalid public key"})
  -- end)

  -- it("should reject CSR with public key not matching signature", function()
  --   helper.mock_return('kong.db.consumers', 'select_by_username', 'nil')
  --   helper.mock_return('kong.request', 'get_body', '{ instance = { name = "test_instance", description = "test_description"}, csr = "valid-csr-pubkey-not-matches-signature" }')
  --   helper.mock_return('kong.response', 'exit', '{}')
  --   helper.mock_return('parsed_csr_mock', 'get_subject_name', '{}, nil')
  --   helper.mock_return('parsed_csr_mock', 'get_pubkey', '{}, nil')
  --   helper.mock_return('parsed_csr_mock', 'verify', 'nil, "cannot verify the csr with pubkey"')
  --   helper.mock_return('resty.openssl.x509.csr', 'new', 'parsed_csr_mock, nil')

  --   _G.package.loaded["register"] = nil
  --   _G.package.loaded['kong.plugins.mtls_certs_manager.base'] = require('base')
  --   local subject = require('register')

  --   local conf = {
  --     ca_private_key_path = "./example_certs/CA-key.pem",
  --     ca_certificate_path = "",
  --     ca_private_key_passphrase = "test_passphrase"
  --   }

  --   spy.on(_G.kong.response, "exit")

  --   subject.execute(conf)
  --   assert.spy(_G.kong.response.exit).was_called_with(400, {message = "Cannot verify the CSR authenticity", error_description = "cannot verify the csr with pubkey"})
  -- end)

  -- it("should reject instance_name not matching csr subject's common name", function()
  --   helper.mock_return('kong.db.consumers', 'select_by_username', 'nil')
  --   helper.mock_return('kong.request', 'get_body', '{ instance = { name = "this_test_instance_name", description = "test_description"}, csr = "valid-csr-pubkey-not-matches-signature" }')
  --   helper.mock_return('kong.response', 'exit', '{}')
  --   helper.mock_return('parsed_csr_mock', 'get_subject_name', '{}, nil')
  --   helper.mock_return('parsed_csr_mock', 'get_pubkey', '{}, nil')
  --   helper.mock_return('parsed_csr_mock', 'verify', 'true, nil')
  --   helper.mock_return('kong.plugins.mtls_certs_manager.x509_name_helper', 'tostring', '\'C=US, ST=CA, CN=mydomain.com/O="MyOrg, Inc."\'')
  --   helper.mock_return('resty.openssl.x509.csr', 'new', 'parsed_csr_mock, nil')

  --   _G.package.loaded["register"] = nil
  --   _G.package.loaded['kong.plugins.mtls_certs_manager.base'] = require('base')
  --   local subject = require('register')

  --   local conf = {
  --     ca_private_key_path = "./example_certs/CA-key.pem",
  --     ca_certificate_path = "",
  --     ca_private_key_passphrase = "test_passphrase",
  --     common_name_regex = "CN=(.*)/O="
  --   }

  --   spy.on(_G.kong.response, "exit")

  --   subject.execute(conf)
  --   assert.spy(_G.kong.response.exit).was_called_with(401, {message = "Instance name does not match CSR subject's CN", error_description = "distinguished name is: C=US, ST=CA, CN=mydomain.com/O=\"MyOrg, Inc.\" but the instance name given was: this_test_instance_name"})
  -- end)

  -- it("should reject registration because failed in serial number creation", function()
  --   helper.mock_return('kong.db.consumers', 'select_by_username', 'nil')
  --   helper.mock_return('kong.request', 'get_body', '{ instance = { name = "mydomain.com", description = "test_description"}, csr = "valid-csr-pubkey-not-matches-signature" }')
  --   helper.mock_return('kong.response', 'exit', '{}')
  --   helper.mock_return('parsed_csr_mock', 'get_subject_name', '{}, nil')
  --   helper.mock_return('parsed_csr_mock', 'get_pubkey', '{}, nil')
  --   helper.mock_return('resty.openssl.bn', 'from_binary', 'nil, \"Problem creating BN!\"')
  --   helper.mock_return('mocked_file_resource', 'read', '\'contents\'')
  --   helper.mock_return('mocked_file_resource', 'close')
  --   helper.mock_return('io', 'open', 'mocked_file_resource')
  --   helper.mock_return('parsed_csr_mock', 'verify', 'true, nil')
  --   helper.mock_return('kong.plugins.mtls_certs_manager.x509_name_helper', 'tostring', '\'C=US, ST=CA, CN=mydomain.com/O="MyOrg, Inc."\'')
  --   helper.mock_return('resty.openssl.x509.csr', 'new', 'parsed_csr_mock, nil')
  --   helper.mock_return('mocked_crt_object', 'set_subject_name')
  --   helper.mock_return('mocked_crt_object', 'set_pubkey')
  --   helper.mock_return('mocked_crt_object', 'set_not_after')
  --   helper.mock_return('mocked_crt_object', 'set_not_before')
  --   helper.mock_return('ngx', 'time', 1111111)

  --   helper.mock_return('resty.openssl.x509', 'new', 'mocked_crt_object')

  --   _G.package.loaded["register"] = nil
  --   _G.package.loaded['kong.plugins.mtls_certs_manager.base'] = require('base')
  --   local subject = require('register')

  --   local conf = {
  --     ca_private_key_path = "./example_certs/CA-key.pem",
  --     ca_certificate_path = "",
  --     ca_private_key_passphrase = "test_passphrase",
  --     common_name_regex = "CN=(.*)/O=",
  --     days_of_validity = 60
  --   }

  --   spy.on(_G.kong.response, "exit")

  --   subject.execute(conf)
  --   assert.spy(_G.kong.response.exit).was_called_with(400, {message = "Error creating serial number", error_description = "Problem creating BN!"})
  -- end)

  -- it("should reject being unable to load the CA certificate", function()
  --   helper.mock_return('kong.db.consumers', 'select_by_username', 'nil')
  --   helper.mock_return('kong.request', 'get_body', '{ instance = { name = "mydomain.com", description = "test_description"}, csr = "valid-csr-pubkey-not-matches-signature" }')
  --   helper.mock_return('kong.response', 'exit', '{}')
  --   helper.mock_return('parsed_csr_mock', 'get_subject_name', '{}, nil')
  --   helper.mock_return('parsed_csr_mock', 'get_pubkey', '{}, nil')
  --   helper.mock_return('resty.openssl.bn', 'from_binary', '{}, nil')
  --   helper.mock_return('mocked_file_resource', 'read', '\'contents\'')
  --   helper.mock_return('mocked_file_resource', 'close')
  --   helper.mock_return('io', 'open', 'mocked_file_resource')
  --   helper.mock_return('parsed_csr_mock', 'verify', 'true, nil')
  --   helper.mock_return('kong.plugins.mtls_certs_manager.x509_name_helper', 'tostring', '\'C=US, ST=CA, CN=mydomain.com/O="MyOrg, Inc."\'')
  --   helper.mock_return('resty.openssl.x509.csr', 'new', 'parsed_csr_mock, nil')
  --   helper.mock_return('mocked_crt_object', 'set_subject_name')
  --   helper.mock_return('mocked_crt_object', 'set_pubkey')
  --   helper.mock_return('mocked_crt_object', 'set_not_after')
  --   helper.mock_return('mocked_crt_object', 'set_not_before')
  --   helper.mock_return('mocked_crt_object', 'set_serial_number')
  --   helper.mock_return('ngx', 'time', '1111111')
  --   helper.mock_return('resty.openssl.pkey', 'new', '{}')
  --   helper.mock_return('resty.openssl.x509', 'new', 'mocked_crt_object')
  --   helper.mock_return('resty.openssl.x509', 'new', 'nil, "error parsing ca"', 1)

  --   _G.package.loaded["register"] = nil
  --   _G.package.loaded['kong.plugins.mtls_certs_manager.base'] = require('base')
  --   local subject = require('register')

  --   local conf = {
  --     ca_private_key_path = "./example_certs/CA-key.pem",
  --     ca_certificate_path = "",
  --     ca_private_key_passphrase = "test_passphrase",
  --     common_name_regex = "CN=(.*)/O=",
  --     days_of_validity = 60
  --   }

  --   spy.on(_G.kong.response, "exit")

  --   subject.execute(conf)
  --   assert.spy(_G.kong.response.exit).was_called_with(500, {message = "Cannot load CA certificate", error_description = "error parsing ca"})
  -- end)

  -- it("should reject request if cannot verify the certificate", function()
  --   helper.mock_return('kong.db.consumers', 'select_by_username', 'nil')
  --   helper.mock_return('kong.request', 'get_body', '{ instance = { name = "mydomain.com", description = "test_description"}, csr = "valid-csr-pubkey-not-matches-signature" }')
  --   helper.mock_return('kong.response', 'exit', '{}')
  --   helper.mock_return('parsed_csr_mock', 'get_subject_name', '{}, nil')
  --   helper.mock_return('parsed_csr_mock', 'get_pubkey', '{}, nil')
  --   helper.mock_return('resty.openssl.bn', 'from_binary', '{}, nil')
  --   helper.mock_return('mocked_file_resource', 'read', '\'contents\'')
  --   helper.mock_return('mocked_file_resource', 'close')
  --   helper.mock_return('io', 'open', 'mocked_file_resource')
  --   helper.mock_return('parsed_csr_mock', 'verify', 'true, nil')
  --   helper.mock_return('kong.plugins.mtls_certs_manager.x509_name_helper', 'tostring', '\'C=US, ST=CA, CN=mydomain.com/O="MyOrg, Inc."\'')
  --   helper.mock_return('resty.openssl.x509.csr', 'new', 'parsed_csr_mock, nil')
  --   helper.mock_return('mocked_crt_object', 'set_subject_name')
  --   helper.mock_return('mocked_crt_object', 'set_pubkey')
  --   helper.mock_return('mocked_crt_object', 'set_not_after')
  --   helper.mock_return('mocked_crt_object', 'set_not_before')
  --   helper.mock_return('mocked_crt_object', 'set_serial_number')
  --   helper.mock_return('mocked_crt_object', 'set_issuer_name')
  --   helper.mock_return('mocked_crt_object', 'sign')
  --   helper.mock_return('mocked_crt_object', 'verify', 'nil, "impossible to verify output crt"')
  --   helper.mock_return('ca_mocked_crt_object', 'get_pubkey', '{}')
  --   helper.mock_return('ca_mocked_crt_object', 'get_subject_name', '{}')
  --   helper.mock_return('ngx', 'time', '1111111')
  --   helper.mock_return('resty.openssl.pkey', 'new', '{}')
  --   helper.mock_return('resty.openssl.x509', 'new', 'mocked_crt_object')
  --   helper.mock_return('resty.openssl.x509', 'new', 'ca_mocked_crt_object, nil', 1)

  --   _G.package.loaded["register"] = nil
  --   _G.package.loaded['kong.plugins.mtls_certs_manager.base'] = require('base')
  --   local subject = require('register')

  --   local conf = {
  --     ca_private_key_path = "./example_certs/CA-key.pem",
  --     ca_certificate_path = "",
  --     ca_private_key_passphrase = "test_passphrase",
  --     common_name_regex = "CN=(.*)/O=",
  --     days_of_validity = 60
  --   }

  --   spy.on(_G.kong.response, "exit")

  --   subject.execute(conf)
  --   assert.spy(_G.kong.response.exit).was_called_with(500, {message = "Cannot validate generated certificate", error_description = "impossible to verify output crt"})
  -- end)

  -- it("should reject instance creation when consumer dao insert output is nil", function()
  --   helper.mock_return('kong.db.keyauth_credentials', 'insert')
  --   helper.mock_return('kong.db.consumers', 'select_by_username')
  --   helper.mock_return('kong.db.consumers', 'insert')
  --   helper.mock_return('kong.request', 'get_body', '{ instance = { name = "mydomain.com", description = "Super Instance Description To Create !"}, csr = "valid-csr-pubkey-not-matches-signature" }')
  --   helper.mock_return('kong.response', 'exit', '{}')
  --   helper.mock_return('parsed_csr_mock', 'get_subject_name', '{}, nil')
  --   helper.mock_return('parsed_csr_mock', 'get_pubkey', '{}, nil')
  --   helper.mock_return('resty.openssl.bn', 'from_binary', '{}, nil')
  --   helper.mock_return('mocked_file_resource', 'read', '"contents"')
  --   helper.mock_return('mocked_file_resource', 'close')
  --   helper.mock_return('io', 'open', 'mocked_file_resource')
  --   helper.mock_return('parsed_csr_mock', 'verify', 'true, nil')
  --   helper.mock_return('kong.plugins.mtls_certs_manager.x509_name_helper', 'tostring', '\'C=US, ST=CA, CN=mydomain.com/O="MyOrg, Inc."\'')
  --   helper.mock_return('resty.openssl.x509.csr', 'new', 'parsed_csr_mock, nil')
  --   helper.mock_return('mocked_crt_object', 'set_subject_name')
  --   helper.mock_return('mocked_crt_object', 'set_pubkey')
  --   helper.mock_return('mocked_crt_object', 'set_not_after')
  --   helper.mock_return('mocked_crt_object', 'set_not_before')
  --   helper.mock_return('mocked_crt_object', 'set_serial_number')
  --   helper.mock_return('mocked_crt_object', 'sign')
  --   helper.mock_return('mocked_crt_object', 'to_PEM', '"valid crt contents"')
  --   helper.mock_return('mocked_crt_object', 'verify', 'true, nil')
  --   helper.mock_return('mocked_crt_object', 'set_issuer_name')
  --   helper.mock_return('ca_mocked_crt_object', 'get_pubkey', '{}')
  --   helper.mock_return('ca_mocked_crt_object', 'get_subject_name', '{}')
  --   helper.mock_return('ngx', 'time', '1111111')
  --   helper.mock_return('resty.openssl.pkey', 'new', '{}')
  --   helper.mock_return('resty.openssl.x509', 'new', 'mocked_crt_object')
  --   helper.mock_return('resty.openssl.x509', 'new', 'ca_mocked_crt_object, nil', 1)

  --   _G.package.loaded["register"] = nil
  --   _G.package.loaded['kong.plugins.mtls_certs_manager.base'] = require('base')
  --   local subject = require('register')

  --   local conf = {
  --     ca_private_key_path = "./example_certs/CA-key.pem",
  --     ca_certificate_path = "",
  --     ca_private_key_passphrase = "test_passphrase",
  --     common_name_regex = "CN=(.*)/O=",
  --     days_of_validity = 60
  --   }

  --   spy.on(_G.kong.response, "exit")
  --   spy.on(_G.kong.db.consumers, 'insert')
  --   spy.on(_G.kong.db.keyauth_credentials, 'insert')

  --   subject.execute(conf)

  --   assert.spy(_G.kong.response.exit).was_called_with(match.is_json_like(400), match.is_json_like(
  --     {message = "Unable to create consumer", error_description = "Verify instance name and description for invalid characters"}
  --   ))
  --   assert.spy(_G.kong.db.consumers.insert).was_called_with(match.is_table(), match.is_json_like(
  --     {tags = {"instance-admin-client", "description-Super_Instance_Description_To_Create_!"}, username = "mydomain.com"}
  --   ))
  --   assert.spy(_G.kong.db.keyauth_credentials.insert).was_not_called()
  -- end)

  -- it("should accept request and create new instance consumer", function()
  --   helper.mock_return('kong.db.keyauth_credentials', 'insert')
  --   helper.mock_return('kong.db.consumers', 'select_by_username')
  --   helper.mock_return('kong.db.consumers', 'insert', '{id = 5}')
  --   helper.mock_return('kong.request', 'get_body', '{ instance = { name = "mydomain.com", description = "test_description"}, csr = "valid-csr-pubkey-not-matches-signature" }')
  --   helper.mock_return('kong.response', 'exit', '{}')
  --   helper.mock_return('parsed_csr_mock', 'get_subject_name', '{}, nil')
  --   helper.mock_return('parsed_csr_mock', 'get_pubkey', '{}, nil')
  --   helper.mock_return('resty.openssl.bn', 'from_binary', '{}, nil')
  --   helper.mock_return('mocked_file_resource', 'read', '"contents"')
  --   helper.mock_return('mocked_file_resource', 'close')
  --   helper.mock_return('io', 'open', 'mocked_file_resource')
  --   helper.mock_return('parsed_csr_mock', 'verify', 'true, nil')
  --   helper.mock_return('kong.plugins.mtls_certs_manager.x509_name_helper', 'tostring', '\'C=US, ST=CA, CN=mydomain.com/O="MyOrg, Inc."\'')
  --   helper.mock_return('resty.openssl.x509.csr', 'new', 'parsed_csr_mock, nil')
  --   helper.mock_return('mocked_crt_object', 'set_subject_name')
  --   helper.mock_return('mocked_crt_object', 'set_pubkey')
  --   helper.mock_return('mocked_crt_object', 'set_not_after')
  --   helper.mock_return('mocked_crt_object', 'set_not_before')
  --   helper.mock_return('mocked_crt_object', 'set_serial_number')
  --   helper.mock_return('mocked_crt_object', 'sign')
  --   helper.mock_return('mocked_crt_object', 'to_PEM', '"valid crt contents"')
  --   helper.mock_return('mocked_crt_object', 'verify', 'true, nil')
  --   helper.mock_return('mocked_crt_object', 'set_issuer_name')
  --   helper.mock_return('ca_mocked_crt_object', 'get_pubkey', '{}')
  --   helper.mock_return('ca_mocked_crt_object', 'get_subject_name', '{}')
  --   helper.mock_return('ngx', 'time', '1111111')
  --   helper.mock_return('resty.openssl.pkey', 'new', '{}')
  --   helper.mock_return('resty.openssl.x509', 'new', 'mocked_crt_object')
  --   helper.mock_return('resty.openssl.x509', 'new', 'ca_mocked_crt_object, nil', 1)

  --   _G.package.loaded["register"] = nil
  --   _G.package.loaded['kong.plugins.mtls_certs_manager.base'] = require('base')
  --   local subject = require('register')

  --   local conf = {
  --     ca_private_key_path = "./example_certs/CA-key.pem",
  --     ca_certificate_path = "",
  --     ca_private_key_passphrase = "test_passphrase",
  --     common_name_regex = "CN=(.*)/O=",
  --     days_of_validity = 60
  --   }

  --   spy.on(_G.kong.response, "exit")
  --   spy.on(_G.kong.db.consumers, 'insert')
  --   spy.on(_G.kong.db.keyauth_credentials, 'insert')

  --   subject.execute(conf)

  --   assert.spy(_G.kong.response.exit).was_called_with(201, {certificate = "valid crt contents", token = "base64_encoded_key"})
  --   assert.spy(_G.kong.db.consumers.insert).was_called_with(match.is_table(), match.is_json_like(
  --     {tags = {"instance-admin-client", "description-test_description"}, username = "mydomain.com"}
  --   ))
  --   assert.spy(_G.kong.db.keyauth_credentials.insert).was_called_with(match.is_table(), match.is_json_like(
  --     {key = "base64_encoded_key", consumer = {id = 5}}
  --   ))
  -- end)
end)
