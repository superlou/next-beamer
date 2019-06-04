local class = require '30log'

local Clock = class('Clock')

function Clock:init(x, y, width, height, align)
  self.x, self.y = x, y
  self.width, self.height = width, height
  self.font = resource.load_font("Gudea-Bold.ttf")
  self.text = ""
  self.background = resource.create_colored_texture(0.2, 0.4, 0.6, 0.0)
  self.padding = 0.15
  self.align = align or 'center'

  self.font_height = self.height * (1 - 2 * self.padding)
end

function Clock:update(text)
  self.text = text
end

function Clock:draw()
  -- self.background:draw(self.x, self.y,
  --                      self.x + self.width, self.y + self.height)

  local text_width = self.font:width(self.text, self.font_height)
  local x = self.x

  if self.align == 'center' then
    x = x - text_width / 2
  elseif self.align == 'right' then
    x = x - text_width
  end

  self.font:write(x, self.y + self.padding * self.height + 3,
                  self.text,
                  self.font_height,
                  0, 0, 0, 0.5)
  self.font:write(x, self.y + self.padding * self.height,
                  self.text,
                  self.font_height,
                  1, 1, 1, 1)
end

return Clock
