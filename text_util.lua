local font = resource.load_font('Roboto-Regular.ttf')

function write_centered(text, size, x_pos, y, r, g, b, a)
  local width = font:width(text, size)
  local x = x_pos - width / 2
  font:write(x, y, text, size, r, g, b, a)
end

function split_newlines(str)
  local t = {}
  local function helper(line)
    table.insert(t, line)
    return ""
  end
  helper((str:gsub("(.-)\r?\n", helper)))
  return t
end

function wrap_text(text, font, size, width)
  local lines = split_newlines(text)

  local wrapped_lines = {}

  for i, line in ipairs(lines) do
    local current_line = ''

    for word in line:gmatch("%S+") do
      if current_line == '' then
          current_line = word
      else
        local check_line = current_line .. ' ' .. word
        local check_width = font:width(check_line, size)

        if check_width < width then
          current_line = check_line
        else
          table.insert(wrapped_lines, current_line)
          current_line = word
        end
      end
    end

    if line ~= '' then
      table.insert(wrapped_lines, current_line)
    end
  end

  return wrapped_lines
end

function size_text_to_width(text, font, width, max_size)
  local text_width = font:width(text, max_size)

  local ratio = width / text_width
  local new_size = math.min(max_size, max_size * ratio)
  local y_offset = (max_size - new_size) / 2

  return new_size, y_offset
end
