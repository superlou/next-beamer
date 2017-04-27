require 'text_util'
local class = require '30log'
local json = require 'json'
local Slide = require 'slide'

local white_block = resource.load_image('white.png')

local EventListSlide = Slide:extend("EventListSlide")

function EventListSlide:init(width, height, data_filename, font)
  self.super:init()
  self.font = resource.load_font(font)
  self.width, self.height = width, height
  self:reset()

  util.file_watch(data_filename, function(content)
    local event_list = json.decode(content)
    self.title = event_list.title
    self.events = event_list.events
    self.duration = event_list.duration
  end)
end

function EventListSlide:draw()
  self.super:tick()
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

function EventListSlide:reset()
  self.super:reset()
  self.x = -self.width
end

function EventListSlide:is_done()
  return (self.super.active_time > self.duration)
end

return EventListSlide
