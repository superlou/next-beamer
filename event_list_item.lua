require 'text_util'
require 'color_util'
local class = require '30log'

local background = create_color_resource_hex("#457a73")
local shadow = create_color_resource_hex("#005952")
local time_background = create_color_resource_hex("#2b635e")

local EventListItem = class("EventListItem")

function EventListItem:init(width, height, name, start, location, font)
  self.width, self.height = width, height
  self.name = name
  self.start = start
  self.location = location
  self.font = font
  self.period = ''
  self.pad = 20
  self.location_width = 120
  self:set_period()
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
  shadow:draw(x, y, x + self.width, y + 73, alpha * 0.8)
  background:draw(x, y, x + self.width, y + 70, alpha)

  local time_background_width = self.pad * 2 + self.font:width(self.start, 50) +
        self.font:width(self.period, 30)

  time_background:draw(x, y, x + time_background_width, y + 70, alpha)

  local start_x = x + self.pad
  local start_width = self.font:write(start_x, y + 10, self.start, 50, 1, 1, 1, alpha)

  local period_x = start_x + 4 + start_width
  local period_width = self.font:write(period_x, y + 30, self.period, 24, 1, 1, 1, alpha)

  self.location_size, self.location_y = size_text_to_width(self.location, self.font, self.location_width, 50)
  local location_x = x + self.width - self.pad - self.location_width
  local r, g, b = hex2rgb("#fff7b3")
  self.font:write(location_x, y + 10 + self.location_y, self.location, self.location_size, r, g, b, alpha)

  local name_width = self.width - self.pad * 5 - start_width - period_width - self.location_width
  self.name_size, self.name_y = size_text_to_width(self.name, self.font, name_width, 50)
  local name_x = period_x + period_width + self.pad * 2
  local name_width = self.font:write(name_x, y + 10 + self.name_y, self.name, self.name_size, 1, 1, 1, alpha)
end

function EventListItem:get_height()
  return self.height
end

return EventListItem
