local _M = {}

_M.tostring = function(subject_name)
  local values = {}
  local _next = subject_name.each(subject_name)
  while true do
    local k, v = _next()
    if k then
      table.insert(values, k .. "=" .. v.blob)
    else
      break
    end
  end
  table.sort(values)
  return table.concat(values, "/")
end

return _M
