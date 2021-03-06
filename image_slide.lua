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
  end)
end

function ImageSlide:draw()
  self.super:tick()
  local padding = self.padding
  local fade_duration = 0.2
  local time = self.super.active_time

  if time < fade_duration then
    alpha = math.min(time / fade_duration, 1.0)
  elseif time > (self.duration - fade_duration) then
    alpha = math.max((self.duration - time) / fade_duration, 0.0)
  else
    alpha = 1.0
  end


  self.image:draw(self.width * padding, self.height * padding,
                  self.width * (1 - padding), self.height * (1 - padding),
                  alpha)
end

function ImageSlide:reset()
  self.super:reset()
end

function ImageSlide:is_done()
  return (self.super.active_time > self.duration)
end

return ImageSlide
