if os.getenv("LOCAL_LUA_DEBUGGER_VSCODE") == "1" then
  require("lldebugger").start()
end

local helper = require("spec.helper")
local dkjson = require("dkjson")
local load_default_dependencies = function ()
  _G.package.loaded['kong.plugins.file_log_censored.attribute_remover'] = require('attribute_remover')
  _G.package.loaded["cjson"] = dkjson
  _G.package.loaded["ffi"] = {}
  _G.package.loaded["bit"] = {}
  _G.package.loaded["lua_system_constants"] = {}
  helper.mock_return('ffi', 'cdef', '{}')
  helper.mock_return('ffi.C', 'open', '1')
  helper.mock_return('ffi.C', 'write', '{}')
  helper.mock_return('bit', 'bor', '{}')
  helper.mock_return('lua_system_constants', 'O_CREAT', '{}')
  helper.mock_return('lua_system_constants', 'O_WRONLY', '{}')
  helper.mock_return('lua_system_constants', 'O_APPEND', '{}')
  helper.mock_return('lua_system_constants', 'S_IRUSR', '{}')
  helper.mock_return('lua_system_constants', 'S_IWUSR', '{}')
  helper.mock_return('lua_system_constants', 'S_IRGRP', '{}')
  helper.mock_return('lua_system_constants', 'S_IROTH', '{}')
end

describe("file_log_censored attribute remover feature", function()
  before_each(function ()
    load_default_dependencies()
  end)

  it("should recieve a censored message at the ffi.C.write function", function()
    local conf = {
      path = "/some-file-name.log",
      reopen = true,
      censored_fields = {'request.headers.x-kong-api-key'}
    }
    local log = [[{
      request = {
        url = 'https://some-awesome-url.com/kong/rocks',
        headers = {
          ["x-kong-header"] = 'another-cool-header',
          ["x-kong-api-key"] = 'some-api-key',
        }
      }
    }]]

    local expected = {
      request = {
        headers = {
          ["x-kong-header"] = 'another-cool-header'
        },
        url = 'https://some-awesome-url.com/kong/rocks'
      }
    }

    local expected_encoded = dkjson.encode(expected)  .. "\n"

    helper.mock_return('kong.log', 'serialize', log)

    spy.on(_G.ffi.C, "write")

    local subject = require("handler")
    subject:log(conf)
    assert.spy(_G.ffi.C.write).was_called_with(1, expected_encoded, #expected_encoded)
  end)
end)
