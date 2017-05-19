require 'text_util'
local class = require '30log'
local json = require 'json'
local Slide = require 'slide'

local white_block = resource.load_image('white.png')

local EventListSlide = Slide:extend("EventListSlide")
local EventListItem = class("EventListItem")

function EventListSlide:init(x, y, width, height, data_filename)
  self.super:init()
  self.x, self.y = x, y
  self.width, self.height = width, height
  self.items = {}
  self:reset()

  util.file_watch(data_filename, function(content)
    local event_list = json.decode(content)
    self.font = resource.load_font(event_list.font)
    self.title = event_list.title
    self.events = event_list.events
    self.duration = event_list.duration

    self.items = {}
    for i, event in ipairs(self.events) do
      self.items[i] = EventListItem(WIDTH, 90,
                                    event.name, event.start, event.location,
                                    self.font)
    end

    self:reset()
  end)
end

function EventListSlide:draw()
  self.super:tick()
  write_centered(self.title, 50, self.width / 2, 50, 1, 1, 1, 1)

  local y = 150
  for i, item in ipairs(self.items) do
    local alpha = math.max(0, math.min(1, self.super.active_time * 2 - i / 10))    
    item:draw(50, y, alpha)
    y = y + 90
  end
end

function EventListSlide:reset()
  self.super:reset()
  self.x = -self.width
end

function EventListSlide:is_done()
  return (self.super.active_time > self.duration)
end

function EventListItem:init(width, height, name, start, location, font)
  self.width, self.height = width, height
  self.name = name
  self.start = start
  self.location = location
  self.font = font
end

function EventListItem:draw(x, y, alpha)
  white_block:draw(x, y, x + self.width - 80, y + 80, alpha * 0.1)
  self.font:write(x + 20, y + 10, self.start, 60, 1, 1, 1, alpha * 1)
  self.font:write(x + 300, y + 10, self.name, 60, 1, 1, 1, alpha * 1)
  self.font:write(x + 1100, y + 10, self.location, 60, 1, 1, 1, alpha * 1)
end

return EventListSlide
