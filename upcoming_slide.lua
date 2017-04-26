require 'text_util'
local class = require '30log'
local json = require 'json'

local white_block = resource.load_image('white.png')

UpcomingSlide = class("UpcomingSlide")

function UpcomingSlide:init(width, height, data_filename, font)
  self.font = resource.load_font(font)
  self.width, self.height = width, height
  self.x = -width

  util.file_watch(data_filename, function(content)
    local upcoming_data = json.decode(content)
    self.title = upcoming_data.title
    self.events = upcoming_data.events
  end)
end

function UpcomingSlide:draw()
  write_centered(self.title, 50, self.width / 2, 50, 1, 1, 1, 1)

  local y = 150
  for i, event in ipairs(self.events) do
    draw_schedule_item(self.x, y, event.name, event.start, event.location, self.font)
    y = y + 100
  end

  if self.x < 20 then
    self.x = self.x + 40
  end
end

function draw_schedule_item(x, y, name, start, location, font)
  white_block:draw(x, y, x + WIDTH - 80, y + 80, 0.1)
  font:write(x + 20, y + 10, start, 60, 1, 1, 1, 1)
  font:write(x + 300, y + 10, name, 60, 1, 1, 1, 1)
  font:write(x + 1100, y + 10, location, 60, 1, 1, 1, 1)
end
