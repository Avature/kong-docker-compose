local _M = {}

local _mockery_data = {}

local function split_string(input, split_by)
  local output = {}
  for word in input:gmatch('[^' .. split_by .. '%s]+') do
    table.insert(output, word)
  end
  return output
end

_M.mock_return = function(object_path, method_name, return_what, run_number)
  if run_number == nil then
    run_number = 0
  end
  if return_what == nil then
    return_what = 'nil'
  end
  local object_path_parts = split_string(object_path, '.')
  local last_mocked_object = _G
  table.foreach(object_path_parts, function (_, key)
    if last_mocked_object[key] == nil then
      last_mocked_object[key] = {}
    end
    last_mocked_object = last_mocked_object[key]
  end)
  local method_and_run_key = object_path:gsub("%.", "_") .. '_' .. method_name
  if _mockery_data[method_and_run_key] == nil then
    _mockery_data[method_and_run_key] = {
      executions = 0,
      responses = {}
    }
  end
  _mockery_data[method_and_run_key].responses[run_number] = return_what
  last_mocked_object[method_name] = function()
    local executions = _mockery_data[method_and_run_key].executions
    local output = _mockery_data[method_and_run_key].responses[executions]
    if output == nil then
      output =  _mockery_data[method_and_run_key].responses[0]
    end
    _mockery_data[method_and_run_key].executions = executions + 1
    return loadstring('return ' .. output)()
  end
  _G.package.loaded[object_path] = last_mocked_object
  return last_mocked_object
end

_M.clear_runs = function()
  _mockery_data = {}
end

return _M
