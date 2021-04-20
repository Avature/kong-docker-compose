if os.getenv("LOCAL_LUA_DEBUGGER_VSCODE") == "1" then
  require("lldebugger").start()
end

describe("file_log_censored attribute remover feature", function()
  it("should remove the attributes specified at the censored_fields array from the log message", function()

    local subject = require('attribute_remover')
    local log = {
      request = {
        url = 'https://some-awesome-url.com/kong/rocks',
        headers = {
          ["x-kong-header"] = 'another-cool-header',
          ["x-kong-api-key"] = 'some-api-key',
        }
      }
    }
    local censored_fields = {'request.headers.x-kong-api-key'}
    local censored_message = subject.delete_attributes(log, censored_fields)
    local expected = {
      request = {
        url = 'https://some-awesome-url.com/kong/rocks',
        headers = {
          ["x-kong-header"] = 'another-cool-header',
        }
      }
    }
    assert.are.same(censored_message, expected)
  end)

  it("should not remove attributes from the log message when no attributes were declared", function()

    local subject = require('attribute_remover')
    local log = {
      request = {
        url = 'https://some-awesome-url.com/kong/rocks',
        headers = {
          ["x-kong-header"] = 'another-cool-header',
          ["x-kong-api-key"] = 'some-api-key',
        }
      }
    }
    local censored_fields = {}
    local censored_message = subject.delete_attributes(log, censored_fields)
    assert.are.same(log, censored_message)
  end)
end)
