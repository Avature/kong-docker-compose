package = "mtls_certs_manager"
version = "0.0.1-1"
source = {
  url = "https://github.com/Avature/kong-docker-compose/tree/main/plugins/mtls_certs_manager"
}
description = {
  summary = "This plugin helps Kong manage mTLS certificate administration",
  detailed = [[
    This plugin is a helper for managing mTLS certificates
  ]],
  homepage = "https://github.com/Avature/kong-docker-compose",
  license = "MIT/X11"
}
dependencies = {
  "lua >= 5.1",
  "lua-resty-openssl",
  "busted",
  "luaffi"
}
build = {
  type = 'builtin',
  modules = {}
}
