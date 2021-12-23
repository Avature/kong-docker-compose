local _M = {}

local consumer_getter_factory = {
  consumer_id = function(consumer)
    return consumer and gsub(consumer.id, "-", "_")
  end,
  custom_id = function(consumer)
    return consumer and consumer.custom_id
  end,
  username = function(consumer)
    return consumer and consumer.username
  end
}

local function has_value (tab, val)
  for _, value in ipairs(tab) do
      if value == val then
          return true
      end
  end

  return false
end

local function split_string(input, split_by)
  local output = {}
  for word in input:gmatch('[^' .. split_by .. '%s]+') do
    table.insert(output, word)
  end
  return output
end


function _M.consumer_id_is_unmatched(input, consumer_id, pattern)
  return pattern == nil or
    string.match(input, pattern) ~= consumer_id
end

function _M.extract_data_from_payload(body, path)
  local path_parts = split_string(path, '.')
  local last_part = body
  table.foreach(path_parts, function (_, key)
    local number_key = tonumber(key)
    local effective_key =  number_key ~= nil and number_key or tostring(key)
    last_part = last_part[effective_key]
  end)
  return last_part
end

function _M.assert_body(rule, consumer_id)
  return rule.search_in_json_payload and _M.consumer_id_is_unmatched(
    _M.extract_data_from_payload(kong.request.get_body(), rule.search_in_json_payload),
    consumer_id,
    rule.expected_consumer_identifier_regex)
end

function _M.assert_header(rule, consumer_id)
  return rule.search_in_header ~= nil and _M.consumer_id_is_unmatched(
    kong.request.get_header(rule.search_in_header),
    consumer_id,
    rule.expected_consumer_identifier_regex
  )
end

function _M.is_configured_method(rule)
  return has_value(rule.methods, kong.request.get_method())
end

function _M.execute(conf)
  local request_path = kong.request.get_path()
  local get_consumer_id = consumer_getter_factory[conf.consumer_identifier]
  for _, rule in pairs(conf.rules) do
    if _M.is_configured_method(rule) and string.match(request_path, rule.request_path_activation_regex) ~= nil then
      local consumer_id = get_consumer_id(kong.client.get_consumer())
      if _M.assert_header(rule, consumer_id) then
        return kong.response.exit(401, {message = "The request does not have the right headers"})
      end
      if _M.assert_body(rule, consumer_id) then
        return kong.response.exit(401, {message = "The request does not have the right body"})
      end
    end
  end
end

return _M
