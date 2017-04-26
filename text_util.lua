local font = resource.load_font('Roboto-Regular.ttf')

function write_centered(text, size, x_pos, y, r, g, b, a)
  local width = font:width(text, size)
  local x = x_pos - width / 2
  font:write(x, y, text, size, r, g, b, a)
end

function wrap_text(text, font, size, width)
  local lines = {}
  local current_line = ''

  for word in text:gmatch("%S+") do
    if current_line == '' then
        current_line = word
    else
      local check_line = current_line .. ' ' .. word
      local check_width = font:width(check_line, size)

      if check_width < width then
        current_line = check_line
      else
        table.insert(lines, current_line)
        current_line = word
      end
    end
  end

  if line ~= '' then
    table.insert(lines, current_line)
  end

  return lines
end
