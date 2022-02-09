package = "file_log_censored"
version = "0.0.1-1"
source = {
  url = "https://github.com/Avature/kong-docker-compose/tree/main/plugins/file_log_censored"
}
description = {
  summary = "This plugin logs the request information excluding configured attributes",
  homepage = "https://github.com/Avature/kong-docker-compose",
  license = "MIT/X11"
}
dependencies = {
  "lua >= 5.1",
  "busted",
  "luaffi",
  "lua-cjson",
  "lua_system_constants",
  "luabitop"
}
build = {
  type = 'builtin',
  modules = {}
}
