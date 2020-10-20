if os.getenv("LOCAL_LUA_DEBUGGER_VSCODE") == "1" then
  require("lldebugger").start()
end

_G.kong = {
    db = {
        consumers = {
        }
    }
}


-- local subject = require('access')


it("only run this test #only", function()

    local dn = "C=US/CN=domain.com/O=MyOrg, Inc./ST=C"
    print(string.match(dn, "CN=(.*)/O="))
end)
