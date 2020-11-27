package = "mtls_certs_manager"
version = "0.0.1-1"
source = {
  url = "..." -- We don't have one yet
}
description = {
  summary = "This plugin helps Kong manage mTLS certificate administration",
  detailed = [[
    This plugin is a helper for managing mTLS certificates
  ]],
  homepage = "http://...", -- We don't have one yet
  license = "MIT/X11" -- or whatever you like
}
dependencies = {
  "lua >= 5.1",
  "lua-resty-openssl",
  "busted",
  "luaffi"
  -- If you depend on other rocks, add them here
}
build = {
  type = 'builtin',
  modules = {}
}
