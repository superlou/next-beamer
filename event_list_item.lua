require 'text_util'
local class = require '30log'

local white_block = resource.create_colored_texture(1, 1, 1, 1)

local EventListItem = class("EventListItem")

function EventListItem:init(width, height, name, start, location, font)
  self.width, self.height = width, height
  self.name = name
  self.start = start
  self.location = location
  self.font = font
  self.period = ''

  self:set_period()
  self.name_size, self.name_y = size_text_to_width(self.name, self.font, 860, 60)
  self.location_size, self.location_y = size_text_to_width(self.location, self.font, 400, 60)
end

function EventListItem:set_period()
  local found = string.find(self.start, 'PM') or string.find(self.start, 'pm')

  if found then
    self.period = 'PM'
    self.start = string.sub(self.start, 0, found - 2)
  end

  local found = string.find(self.start, 'AM') or string.find(self.start, 'am')

  if found then
    self.period = 'AM'
    self.start = string.sub(self.start, 0, found - 2)
  end
end

function EventListItem:draw(x, y, alpha)
  white_block:draw(x, y, x + self.width - 80, y + 80, alpha * 0.1)
  local width = self.font:write(x + 20, y + 10, self.start, 60, 1, 1, 1, alpha * 1)
  self.font:write(x + 23 + width, y + 12, self.period, 30, 1, 1, 1, alpha * 1)
  self.font:write(x + 210, y + 10 + self.name_y, self.name, self.name_size, 1, 1, 1, alpha * 1)
  self.font:write(x + 1100, y + 10 + self.location_y, self.location, self.location_size, 1, 1, 1, alpha * 1)
end

function EventListItem:get_height()
  return self.height
end

return EventListItem
