package = "client_consumer_validator"
version = "0.0.1-1"
source = {
  url = "https://github.com/Avature/kong-docker-compose/tree/main/plugins/client_consumer_validator"
}
description = {
  summary = "This plugin searchs the username of the consumer in a header or in a json payload",
  detailed = [[
    This plugin validates payload and headers of a request to assure good intentions
  ]],
  homepage = "https://github.com/Avature/kong-docker-compose",
  license = "MIT/X11"
}
dependencies = {
  "lua >= 5.1",
  "lua-resty-openssl",
  "busted",
}
build = {
  type = 'builtin',
  modules = {}
}
