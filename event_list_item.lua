require 'text_util'
local class = require '30log'

local white_block = resource.load_image('white.png')

local EventListItem = class("EventListItem")

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
  self.font:write(x + 250, y + 10, self.name, 60, 1, 1, 1, alpha * 1)
  self.font:write(x + 1100, y + 10, self.location, 60, 1, 1, 1, alpha * 1)
end

function EventListItem:get_height()
  return self.height
end

return EventListItem
