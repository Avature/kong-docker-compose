-- FIXME: If the PR: https://github.com/Kong/kong/pull/6930
-- is accepted and merged, we can remove this custom plugin and replace it
-- for the file-log plugin at our startup config

local ffi = require("ffi")
local cjson = require("cjson")
local bit = require("bit")
local lua_system_constants = require("lua_system_constants")
local attribute_remover = require("kong.plugins.file_log_censored.attribute_remover")

local kong = kong

local O_CREAT = lua_system_constants.O_CREAT()
local O_WRONLY = lua_system_constants.O_WRONLY()
local O_APPEND = lua_system_constants.O_APPEND()
local S_IRUSR = lua_system_constants.S_IRUSR()
local S_IWUSR = lua_system_constants.S_IWUSR()
local S_IRGRP = lua_system_constants.S_IRGRP()
local S_IROTH = lua_system_constants.S_IROTH()

local oflags = bit.bor(O_WRONLY, O_CREAT, O_APPEND)
local mode = bit.bor(S_IRUSR, S_IWUSR, S_IRGRP, S_IROTH)

ffi.cdef [[
int write(int fd, const void * ptr, int numbytes);
]]

-- fd tracking utility functions
local file_descriptors = {}

-- Log to a file. Function used as callback from an nginx timer.
-- @param `premature` see OpenResty `ngx.timer.at()`
-- @param `conf`     Configuration table, holds http endpoint details
-- @param `message`  Message to be logged
local function log(conf, message)
  local msg = cjson.encode(message) .. "\n"
  local fd = file_descriptors[conf.path]

  if fd and conf.reopen then
    -- close fd, we do this here, to make sure a previously cached fd also
    -- gets closed upon dynamic changes of the configuration
    ffi.C.close(fd)
    file_descriptors[conf.path] = nil
    fd = nil
  end

  if not fd then
    fd = ffi.C.open(conf.path, oflags, mode)
    if fd < 0 then
      local errno = ffi.errno()
      kong.log.err("Error opening log file: ", ffi.string(ffi.C.strerror(errno)), " configured path: ", conf.path)
    else
      file_descriptors[conf.path] = fd
    end
  end

  ffi.C.write(fd, msg, #msg)
end

local FileLogCensoredHandler = {
  PRIORITY = 9,
  VERSION = "0.0.1",
}

function FileLogCensoredHandler:log(conf)
  local message = kong.log.serialize()
  local censored_message = attribute_remover.delete_attributes(message, conf.censored_fields)
  log(conf, censored_message)
end

return FileLogCensoredHandler
