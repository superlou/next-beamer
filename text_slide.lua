require 'text_util'
local class = require '30log'
local json = require 'json'

local white_block = resource.load_image('white.png')

TextSlide = class("TextSlide")

function TextSlide:init(width, height, data_filename, font)
  self.font = resource.load_font(font)
  self.size = 50
  self.line_spacing = 1.5
  self.padding = 0.1
  self.width, self.height = width, height
  self.x = -width

  util.file_watch(data_filename, function(content)
    local data = json.decode(content)
    self.title = data.title
    self.body = data.body
    self.lines = wrap_text(self.body, self.font, self.size,
                           self.width * (1 - 2 * self.padding))
  end)
end

function TextSlide:draw()
  write_centered(self.title, 50, self.width / 2, 50, 1, 1, 1, 1)

  self.start_y = 150

  for i, line in ipairs(self.lines) do
    self.font:write(self.width * self.padding,
                    self.start_y + (i - 1) * self.size * self.line_spacing,
                    line,
                    self.size, 1, 1, 1, 1)
  end
end
