local _M = {}

local function split_string(input, split_by)
  local output = {}
  for word in input:gmatch('[^' .. split_by .. '%s]+') do
    table.insert(output, word)
  end
  return output
end

_M.mock_return = function(object_path, method_name, return_what)
  if return_what == nil then
    return_what = 'nil'
  end
  local object_path_parts = split_string(object_path, '.')
  local last_key = ''
  table.foreach(object_path_parts, function (_, key)
    last_key = last_key .. '.' .. key
    if loadstring("return _G" .. last_key)() == nil then
      loadstring("_G" .. last_key .. " = {}")()
    end
  end)
  local mocked_function_code = "_G" .. last_key .. "." .. method_name .. " = function() return " .. return_what .. " end"
  loadstring(mocked_function_code)()
  return loadstring("return _G." .. object_path)()
end

return _M
