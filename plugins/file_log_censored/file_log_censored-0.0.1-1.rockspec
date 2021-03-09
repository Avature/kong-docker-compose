package = "file_log_censored"
version = "0.0.1-1"
source = {
  url = "..." -- We don't have one yet
}
description = {
  summary = "This plugin logs the request information excluding configured attributes",
  homepage = "http://...", -- We don't have one yet
  license = "MIT/X11" -- or whatever you like
}
dependencies = {
  "lua >= 5.1",
  "busted"
  -- If you depend on other rocks, add them here
}
build = {
  type = 'builtin',
  modules = {}
}
