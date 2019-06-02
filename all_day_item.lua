require 'text_util'
require 'color_util'
local class = require '30log'

local AllDayItem = class('AllDayItem')

local background = create_color_resource_hex("#396048")
local shadow = create_color_resource_hex("#005952")
local time_bg_running = create_color_resource_hex("#ce7777")
local time_bg_not_running = create_color_resource_hex("#957774")
local name_bg_running = create_color_resource_hex("#398e6c")
local name_bg_not_running = create_color_resource_hex("#847b79")
local location_bg_running = create_color_resource_hex("#99b57d")
local location_bg_not_running = create_color_resource_hex("#847b79")

local separator_running = resource.load_image("separator_running.png")
local separator_not_running = resource.load_image("separator_not_running.png")

function AllDayItem:init(width, height, name, location, time1, time2, running, font)
  self.font = font
  self.name = name
  self.location = location
  self.w, self.h = width, height
  self.time1, self.time2 = time1, time2
  self.running = running

  self.time_width = 100
  self.separator_width = 27
  self.location_width = 80
  self.name_width = width - self.time_width - self.separator_width - self.location_width
end

function AllDayItem:draw(x, y, alpha)
  local h = self.h
  shadow:draw(x, y, x + self.w, y + h, alpha * 0.8)
  h = h - 3

  local time_bg = time_bg_not_running
  local name_bg = name_bg_not_running
  local location_bg = location_bg_not_running
  local separator = separator_not_running
  local text_alpha = 0.8 * alpha

  if self.running then
    time_bg = time_bg_running
    name_bg = name_bg_running
    location_bg = location_bg_running
    separator = separator_running
    text_alpha = 1.0 * alpha
  end

  local x_pos = x
  time_bg:draw(x_pos, y, x_pos + self.time_width, y + h, alpha)
  draw_text_in_window(self.time1,
                      x_pos, y - 11, self.time_width, h,
                      h, self.font, 1, 1, 1, text_alpha, 10)
  draw_text_in_window(self.time2,
                      x_pos, y + 11, self.time_width, h,
                      h, self.font, 1, 1, 1, text_alpha, 10)
  x_pos = x_pos + self.time_width

  name_bg:draw(x_pos, y, x_pos + self.name_width, y + h, alpha)
  draw_text_in_window(self.name,
                      x_pos, y + 1, self.name_width, h,
                      h, self.font, 1, 1, 1, text_alpha, 10)

  x_pos = x_pos + self.name_width
  separator:draw(x_pos, y, x_pos + self.separator_width, y + h, alpha)

  x_pos = x_pos + self.separator_width
  location_bg:draw(x_pos, y, x_pos + self.location_width, y + h, alpha)
  draw_text_in_window(self.location,
                      x_pos - 5, y + 1, self.location_width, h,
                      h, self.font, 1, 1, 1, text_alpha, 10)
end

return AllDayItem
