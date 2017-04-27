require 'text_util'
local class = require '30log'
local json = require 'json'

local white_block = resource.load_image('white.png')

UpcomingSlide = class("UpcomingSlide")

function UpcomingSlide:init(width, height, data_filename, font)
  self.framerate = 60
  self.font = resource.load_font(font)
  self.width, self.height = width, height
  self.active_time = 0
  self:reset()

  util.file_watch(data_filename, function(content)
    local upcoming_data = json.decode(content)
    self.title = upcoming_data.title
    self.events = upcoming_data.events
  end)
end

function UpcomingSlide:draw()
  self.active_time = self.active_time + 1 / self.framerate
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

function UpcomingSlide:reset()
  self.x = -self.width
  self.active_time = 0
end

function UpcomingSlide:is_done()
  return (self.active_time > 5)
end
