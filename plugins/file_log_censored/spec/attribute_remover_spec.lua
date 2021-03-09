if os.getenv("LOCAL_LUA_DEBUGGER_VSCODE") == "1" then
  require("lldebugger").start()
end

describe("file_log_censored attribute remover feature", function()
  it("should remove the attributes specified at the exclusion array from the log message", function()

    local subject = require('attribute_remover')
    local log = {
      request = {
        url = 'https://some-awesome-url.com/kong/rocks',
        headers = {
          ["content-type"] = 'application/json',
          ["x-kong-header"] = 'another-cool-header',
          ["x-kong-api-key"] = 'some-api-key',
          accept = 'application/json'
        }
      }
    }
    local exclusion = {'request.headers.x-kong-api-key'}
    local censored_message = subject.delete_attributes(log, exclusion)
    local expected = {
      request = {
        url = 'https://some-awesome-url.com/kong/rocks',
        headers = {
          ["content-type"] = 'application/json',
          ["x-kong-header"] = 'another-cool-header',
          accept = 'application/json'
        }
      }
    }
    assert.are.same(censored_message, expected)
  end)

  it("should not remove attributes from the log message when no attributes where declared", function()

    local subject = require('attribute_remover')
    local log = {
      request = {
        url = 'https://some-awesome-url.com/kong/rocks',
        headers = {
          ["content-type"] = 'application/json',
          ["x-kong-header"] = 'another-cool-header',
          ["x-kong-api-key"] = 'some-api-key',
          accept = 'application/json'
        }
      }
    }
    local exclusion = {}
    local censored_message = subject.delete_attributes(log, exclusion)
    assert.are.same(log, censored_message)
  end)
end)
