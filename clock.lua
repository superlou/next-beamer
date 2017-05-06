local class = require '30log'

local Clock = class('Clock')

function Clock:init(x, y, width, height)
  self.x, self.y = x, y
  self.width, self.height = width, height
  self.font = resource.load_font("RobotoCondensed-Regular.ttf")
  self.text = ""
  self.background = resource.create_colored_texture(0.2, 0.4, 0.6, 0.9)
  self.padding = 0.2

  self.font_height = self.height * (1 - 2 * self.padding)
end

function Clock:update(text)
  self.text = text
end

function Clock:draw()
  self.background:draw(self.x, self.y,
                       self.x + self.width, self.y + self.height)

  local text_width = self.font:width(self.text, self.font_height)

  self.font:write(self.x + (self.width - text_width) / 2,
                  self.y + self.padding * self.height,
                  self.text,
                  self.font_height,
                  1, 1, 1, 1)
end

return Clock
