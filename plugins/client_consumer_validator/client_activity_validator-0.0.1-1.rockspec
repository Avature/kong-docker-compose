package = "client_consumer_validator"
version = "0.0.1-1"
source = {
   url = "..." -- We don't have one yet
}
description = {
   summary = "This plugin searchs the username of the consumer in a header or in a json payload",
   detailed = [[
      This plugin validates payload and headers of a request to assure good intentions
   ]],
   homepage = "http://...", -- We don't have one yet
   license = "MIT/X11" -- or whatever you like
}
dependencies = {
   "lua >= 5.1",
   "lua-resty-openssl",
   "busted",
   -- If you depend on other rocks, add them here
}
build = {
    type = 'builtin',
    modules = {}
}
