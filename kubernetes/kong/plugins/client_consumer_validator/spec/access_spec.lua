if os.getenv("LOCAL_LUA_DEBUGGER_VSCODE") == "1" then
  require("lldebugger").start()
end

local helper = require("spec.helper")
assert:register("matcher", "is_json_like", helper.is_json_like)

describe("client_consumer_validator access hook feature", function()
  before_each(function ()
    helper.mock_return('kong.request', 'get_body', '{}')
    helper.mock_return('kong.request', 'get_header', '"test-username"')
    helper.mock_return('kong.client', 'get_consumer', '{username = "test-usernOme"}')
    helper.mock_return('kong.request', 'get_method', '"POST"')
    helper.mock_return('kong.response', 'exit')
  end)

  it("should not respond 401 in case of the regex not matching and header not matching", function()
    helper.mock_return('kong.request', 'get_path', '"/v1/petuinas"')

    local subject = require('access')
    local conf = {
      consumer_identifier = "username",
      rules = {
        rule_1 = {
          request_path_activation_regex = '/v1/petun(.*)',
          search_in_header = 'X-Custom-header',
          methods = {"POST"}
        }
      }
    }
    spy.on(_G.kong.response, "exit")
    subject.execute(conf)
    assert.spy(_G.kong.response.exit).was_not_called()
  end)

  it("should respond 401 in case of the regex matches and header not matching", function()
    helper.mock_return('kong.request', 'get_path', '"/v1/petunias"')

    local subject = require('access')
    local conf = {
      consumer_identifier = "username",
      rules = {
        rule_1 = {
          request_path_activation_regex = '/v1/petun(.*)',
          search_in_header = 'X-Custom-header',
          methods = {"POST"}
        }
      }
    }
    spy.on(_G.kong.response, "exit")
    subject.execute(conf)
    assert.spy(_G.kong.response.exit).was_called_with(401, match.is_json_like(
      {message="The request does not have the right headers"}
    ))
  end)

  it("should respond 401 in case of the regex matches, header config is nil but the body is not matching", function()
    helper.mock_return('kong.request', 'get_body', '{service = {name = "test-object", value = "other-value", plugins = { {name = "a-plugin-to-test", quantity = 5}}}}')
    helper.mock_return('kong.request', 'get_path', '"/v1/petunias"')
    helper.mock_return('kong.client', 'get_consumer', '{username = "test-username"}')

    local subject = require('access')
    local conf = {
      consumer_identifier = "username",
      rules = {
        rule_1 = {
          request_path_activation_regex = '/v1/petun(.*)',
          search_in_header = nil,
          search_in_json_payload = 'service.plugins.1.quantity',
          methods = {"POST"}
        }
      }
    }
    spy.on(_G.kong.response, "exit")
    subject.execute(conf)
    assert.spy(_G.kong.response.exit).was_called_with(401, match.is_json_like(
      {message="The request does not have the right body"}
    ))
  end)

  it("should reject plugin creation with missing header replace config", function()
    helper.mock_return('kong.request', 'get_body', '{config = {headers = {replace = {"Host:devenv.local.net"}}}}')
    helper.mock_return('kong.request', 'get_path', '"/admin-api/services/0YRF41qFw7l_Fke86jDv1qCVsfV0q78G_iats/plugins/e24fefe6-86b7-4fd7-9401-fdf225312891"')
    helper.mock_return('kong.client', 'get_consumer', '{username = "test-username"}')

    local subject = require('access')
    local conf = {
      consumer_identifier = "username",
      rules = {
        rule_1 = {
          request_path_activation_regex = '/services/(.*)/plugins',
          search_in_header = nil,
          search_in_json_payload = 'config.headers.replace.1',
          expected_consumer_identifier_regex = 'Host:(.*)',
          methods = {"POST"}
        }
      }
    }
    spy.on(_G.kong.response, "exit")
    subject.execute(conf)
    assert.spy(_G.kong.response.exit).was_called_with(401, match.is_json_like(
      {message="The request does not have the right body"}
    ))
  end)

  it("should not reject because all rules are accomplished (2 rules specified)", function()
    helper.mock_return('kong.request', 'get_body', '{config = {headers = {replace = {"Host:devenv.local.net"}}}}')
    helper.mock_return('kong.request', 'get_path', '"/admin-api/services/0YRF41qFw7l_Fke86jDv1qCVsfV0q78G_iats/plugins/e24fefe6-86b7-4fd7-9401-fdf225312891"')
    helper.mock_return('kong.client', 'get_consumer', '{username = "devenv.local.net"}')
    helper.mock_return('kong.request', 'get_header', '"devenv.local.net"')

    local subject = require('access')
    local conf = {
      consumer_identifier = "username",
      rules = {
        rule_1 = {
          request_path_activation_regex = '/services/(.*)/plugins',
          search_in_header = nil,
          search_in_json_payload = 'config.headers.replace.1',
          expected_consumer_identifier_regex = 'Host:(.*)',
          methods = {"POST"}
        },
        rule_2 = {
          request_path_activation_regex = '/services/(.*)/plugins',
          search_in_header = 'X-Custom-Header',
          search_in_json_payload = nil,
          expected_consumer_identifier_regex = '(.*)',
          methods = {"POST"}
        }
      }
    }
    spy.on(_G.kong.response, "exit")
    subject.execute(conf)
    assert.spy(_G.kong.response.exit).was_not_called()
  end)
end)
