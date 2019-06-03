local class = require '30log'
local json = require 'json'
local Slide = require 'slide'

local ImageSlide = Slide:extend("ImageSlide")

function ImageSlide:init(x, y, width, height, data_filename, font)
  self.super:init()
  self.x, self.y = x, y
  self.padding = 0
  self.width, self.height = width, height
  self:reset()
  self.image = nil

  util.file_watch(data_filename, function(content)
    local data = json.decode(content)
    self.duration = data.duration
    self.image = resource.load_image(data.file)
    if data.padding then
      self.padding = data.padding
    end

    self.x1 = self.x + self.width * self.padding
    self.y1 = self.y + self.height * self.padding
    self.x2 = self.x + self.width * (1 - self.padding)
    self.y2 = self.y + self.height * (1 - self.padding)
  end)
end

function ImageSlide:draw()
  self.super:tick()
  local fade_duration = 0.2
  local time = self.super.active_time

  if time < fade_duration then
    alpha = math.min(time / fade_duration, 1.0)
  elseif time > (self.duration - fade_duration) then
    alpha = math.max((self.duration - time) / fade_duration, 0.0)
  else
    alpha = 1.0
  end

  self.image:draw(self.x1, self.y1, self.x2, self.y2, alpha)
end

function ImageSlide:reset()
  self.super:reset()
end

function ImageSlide:is_done()
  return (self.super.active_time > self.duration)
end

return ImageSlide
