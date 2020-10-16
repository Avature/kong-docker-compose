if os.getenv("LOCAL_LUA_DEBUGGER_VSCODE") == "1" then
  require("lldebugger").start()
end

_G.kong = {
    db = {
        consumers = {
        }
    }
}


local subject = require('access')


it("only run this test #only", function()

    local conf = {
      ca_private_key_path = '',
      ca_certificate_path = '',
      csr_path = './certs/mydomain.com.csr'
    }
    subject.execute(conf)
    print("prueba")
end)
