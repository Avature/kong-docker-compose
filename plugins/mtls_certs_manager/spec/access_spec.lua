if os.getenv("LOCAL_LUA_DEBUGGER_VSCODE") == "1" then
  require("lldebugger").start()
end

local helper = require("spec.helper")

local load_default_dependencies = function ()
  _G.package.loaded['kong.plugins.mtls_certs_manager.x509_name_helper'] = require('x509_name_helper')
  _G.package.loaded["resty.openssl.x509"    ] = {}
  _G.package.loaded["resty.openssl.x509.csr"] = {}
  _G.package.loaded["resty.openssl.pkey"    ] = {}
  _G.package.loaded["resty.openssl.bn"      ] = {}
end

describe("mtls_certs_manager access hook feature", function()
  teardown(function()
    _G.package.loaded['kong.plugins.mtls_certs_manager.x509_name_helper'] = nil
    _G.package.loaded["resty.openssl.x509"    ] = nil
    _G.package.loaded["resty.openssl.x509.csr"] = nil
    _G.package.loaded["resty.openssl.pkey"    ] = nil
    _G.package.loaded["resty.openssl.bn"      ] = nil
  end)

  it("should reject already registered instance", function()
    helper.mock_return('kong.db.consumers', 'select_by_username', '{instance_name = "test_instance"}')
    helper.mock_return('kong.request', 'get_body', '{ instance = { name = "test_instance", description = "test_description"}, csr = "test_csr_string" }')
    helper.mock_return('kong.response', 'exit', '{}')

    load_default_dependencies()
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

  it("should reject unknown instance with empty or nil csr request", function()
    helper.mock_return('kong.db.consumers', 'select_by_username', 'nil')
    helper.mock_return('kong.request', 'get_body', '{ instance = { name = "test_instance", description = "test_description"}, csr = "" }')
    helper.mock_return('kong.response', 'exit', '{}')

    load_default_dependencies()
    local subject = require('access')

    local conf = {
      ca_private_key_path = "./example_certs/CA-key.pem",
      ca_certificate_path = "",
      ca_private_key_passphrase = "test_passphrase"
    }

    spy.on(_G.kong.response, "exit")

    subject.execute(conf)
    assert.spy(_G.kong.response.exit).was_called_with(400, {message = "CSR Contents are empty"})
    helper.mock_return('kong.request', 'get_body', '{ instance = { name = "test_instance", description = "test_description"}, csr = nil }')

    subject.execute(conf)
    assert.spy(_G.kong.response.exit).was_called_with(400, {message = "CSR Contents are empty"})
  end)

  it("should reject invalid non-empty CSR contents", function()
    load_default_dependencies()
    helper.mock_return('kong.db.consumers', 'select_by_username', 'nil')
    helper.mock_return('kong.request', 'get_body', '{ instance = { name = "test_instance", description = "test_description"}, csr = "something-invalid-for-csr" }')
    helper.mock_return('kong.response', 'exit', '{}')
    local csr_mock = helper.mock_return('resty.openssl.x509.csr', 'new', 'nil, "impossible to parse csr"')

    _G.package.loaded["resty.openssl.x509.csr"] = csr_mock
    _G.package.loaded["access"] = nil
    local subject = require('access')

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
    load_default_dependencies()
    helper.mock_return('kong.db.consumers', 'select_by_username', 'nil')
    helper.mock_return('kong.request', 'get_body', '{ instance = { name = "test_instance", description = "test_description"}, csr = "valid-csr-but-contains-no-subject" }')
    helper.mock_return('kong.response', 'exit', '{}')
    helper.mock_return('parsed_csr_mock', 'get_subject_name', 'nil, "cannot get subject name"')
    local csr_mock = helper.mock_return('resty.openssl.x509.csr', 'new', 'parsed_csr_mock, nil')

    _G.package.loaded["resty.openssl.x509.csr"] = csr_mock
    _G.package.loaded["access"] = nil
    local subject = require('access')

    local conf = {
      ca_private_key_path = "./example_certs/CA-key.pem",
      ca_certificate_path = "",
      ca_private_key_passphrase = "test_passphrase"
    }

    spy.on(_G.kong.response, "exit")

    subject.execute(conf)
    assert.spy(_G.kong.response.exit).was_called_with(400, {message = "Cannot get subject from CSR", error_description = "cannot get subject name"})
  end)

  it("should reject CSR with no public key attached", function()
    load_default_dependencies()
    helper.mock_return('kong.db.consumers', 'select_by_username', 'nil')
    helper.mock_return('kong.request', 'get_body', '{ instance = { name = "test_instance", description = "test_description"}, csr = "valid-csr-but-contains-no-pubkey" }')
    helper.mock_return('kong.response', 'exit', '{}')
    helper.mock_return('parsed_csr_mock', 'get_subject_name', '{}, nil')
    helper.mock_return('parsed_csr_mock', 'get_pubkey', 'nil, "invalid public key"')
    local csr_mock = helper.mock_return('resty.openssl.x509.csr', 'new', 'parsed_csr_mock, nil')

    _G.package.loaded["resty.openssl.x509.csr"] = csr_mock
    _G.package.loaded["access"] = nil
    local subject = require('access')

    local conf = {
      ca_private_key_path = "./example_certs/CA-key.pem",
      ca_certificate_path = "",
      ca_private_key_passphrase = "test_passphrase"
    }

    spy.on(_G.kong.response, "exit")

    subject.execute(conf)
    assert.spy(_G.kong.response.exit).was_called_with(400, {message = "Cannot get public key from CSR", error_description = "invalid public key"})
  end)

  it("should reject CSR with public key not matching signature", function()
    load_default_dependencies()
    helper.mock_return('kong.db.consumers', 'select_by_username', 'nil')
    helper.mock_return('kong.request', 'get_body', '{ instance = { name = "test_instance", description = "test_description"}, csr = "valid-csr-pubkey-not-matches-signature" }')
    helper.mock_return('kong.response', 'exit', '{}')
    helper.mock_return('parsed_csr_mock', 'get_subject_name', '{}, nil')
    helper.mock_return('parsed_csr_mock', 'get_pubkey', '{}, nil')
    helper.mock_return('parsed_csr_mock', 'verify', 'nil, "cannot verify the csr with pubkey"')
    local csr_mock = helper.mock_return('resty.openssl.x509.csr', 'new', 'parsed_csr_mock, nil')

    _G.package.loaded["resty.openssl.x509.csr"] = csr_mock
    _G.package.loaded["access"] = nil
    local subject = require('access')

    local conf = {
      ca_private_key_path = "./example_certs/CA-key.pem",
      ca_certificate_path = "",
      ca_private_key_passphrase = "test_passphrase"
    }

    spy.on(_G.kong.response, "exit")

    subject.execute(conf)
    assert.spy(_G.kong.response.exit).was_called_with(400, {message = "Cannot verify the CSR authenticity", error_description = "cannot verify the csr with pubkey"})
  end)

  it("should reject instance_name not matching csr subject's common name", function()
    load_default_dependencies()
    helper.mock_return('kong.db.consumers', 'select_by_username', 'nil')
    helper.mock_return('kong.request', 'get_body', '{ instance = { name = "this_test_instance_name", description = "test_description"}, csr = "valid-csr-pubkey-not-matches-signature" }')
    helper.mock_return('kong.response', 'exit', '{}')
    helper.mock_return('parsed_csr_mock', 'get_subject_name', '{}, nil')
    helper.mock_return('parsed_csr_mock', 'get_pubkey', '{}, nil')
    helper.mock_return('parsed_csr_mock', 'verify', 'true, nil')
    local name_helper_mock = helper.mock_return('kong.plugins.mtls_certs_manager.x509_name_helper', 'tostring', '\'C=US, ST=CA, CN=mydomain.com/O="MyOrg, Inc."\'')
    local csr_mock = helper.mock_return('resty.openssl.x509.csr', 'new', 'parsed_csr_mock, nil')

    _G.package.loaded["resty.openssl.x509.csr"] = csr_mock
    _G.package.loaded['kong.plugins.mtls_certs_manager.x509_name_helper'] = name_helper_mock
    _G.package.loaded["access"] = nil

    local subject = require('access')

    local conf = {
      ca_private_key_path = "./example_certs/CA-key.pem",
      ca_certificate_path = "",
      ca_private_key_passphrase = "test_passphrase",
      common_name_regex = "CN=(.*)/O="
    }

    spy.on(_G.kong.response, "exit")

    subject.execute(conf)
    assert.spy(_G.kong.response.exit).was_called_with(401, {message = "Instance name does not match CSR's subject", error_description = "distinguished name is: C=US, ST=CA, CN=mydomain.com/O=\"MyOrg, Inc.\" but the instance_name given was: this_test_instance_name"})
  end)
end)
