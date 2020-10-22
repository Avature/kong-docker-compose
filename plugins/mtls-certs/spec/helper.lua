local _M = {}

_G.mocked_values = {}

local function split_string(input, split_by)
  local output = {}
  for word in input:gmatch('[^' .. split_by .. '%s]+') do
    table.insert(output, word)
  end
  return output
end

_M.mock_return = function(object_path, method_name, return_what)
  local object_path_parts = split_string(object_path, '.')
  local last_key = ''
  table.foreach(object_path_parts, function (_, key)
    last_key = last_key .. '.' .. key
    if loadstring("return _G" .. last_key)() == nil then
      loadstring("_G" .. last_key .. " = {}")()
    end
  end)
  local dashed_method_name = object_path:gsub("%.", "_") .. '_' .. method_name
  _G.mocked_values[dashed_method_name] = return_what
  local mocked_function_code = "_G" .. last_key .. "." .. method_name .. " = function() return mocked_values['" .. dashed_method_name .."'] end"
  loadstring(mocked_function_code)()
  return loadstring("return _G." .. object_path)()
end

return _M
