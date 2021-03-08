local base = require("kong.plugins.mtls_certs_manager.base")
local _M = base:extend()

local consumers = kong.db.consumers
local encode_base64 = ngx.encode_base64
local keyauth_credentials = kong.db.keyauth_credentials
local openssl_rand = require("resty.openssl.rand")

function _M.create_credential(consumer_id)
  local token = encode_base64(openssl_rand.bytes(64))
  keyauth_credentials:insert({key = token, consumer = {id = consumer_id}})
  return token
end

function _M.check_instance_exists(instance_name)
  local consumer = consumers:select_by_username(instance_name)
  return consumer ~= nil
end

function _M.get_consumer(instance_name, description)
  local consumers = kong.db.consumers
  local _tags = {"instance-admin-client"}
  if description ~= nil and description:match("%S") ~= nil then
    table.insert(_tags, "description-" .. description:gsub("%s+", "_"))
  end
  local consumer_data = {
    username = instance_name,
    tags = _tags
  }
  return consumers:insert(consumer_data)
end

function _M.execute(conf)
  local request_body = kong.request.get_body()
  local instance_name = request_body.instance.name
  if _M.check_instance_exists(instance_name) then
    return _M.respond(401, "Instance already exists")
  end
  return _M.super.execute(conf)
end

return _M
