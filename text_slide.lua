require 'text_util'
local class = require '30log'
local json = require 'json'
local Slide = require 'slide'

local white_block = resource.create_colored_texture(1, 1, 1, 1)

local TextSlide = Slide:extend("TextSlide")

function TextSlide:init(x, y, width, height, data_filename)
  self.super:init()
  self.x, self.y = x, y
  self.size = 42
  self.line_spacing = 1.5
  self.padding = 0.05
  self.width, self.height = width, height
  self:reset()

  util.file_watch(data_filename, function(content)
    local data = json.decode(content)
    self.duration = data.duration
    self.font = resource.load_font(data.font)
    self.title = data.title
    self.body = data.body
    self.lines = wrap_text(self.body, self.font, self.size,
                           self.width * (1 - 2 * self.padding))
  end)
end

function TextSlide:draw()
  self.super:tick()
  local x = self.width / 2 + self.x
  local y = self.height * self.padding + self.y
  write_centered(self.title, self.size, x, y, 1, 1, 1, 1)

  self.start_y = y + self.size * 2

  for i, line in ipairs(self.lines) do
    self.font:write(self.width * self.padding + self.x,
                    self.start_y + (i - 1) * self.size * self.line_spacing,
                    line,
                    self.size, 1, 1, 1, 1)
  end
end

function TextSlide:reset()
  self.super:reset()
end

function TextSlide:is_done()
  return (self.super.active_time > self.duration)
end

return TextSlide
