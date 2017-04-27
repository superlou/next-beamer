local class = require '30log'

Slide = class("Slide")

function Slide:init()
  self.framerate = 60
  self.active_time = 0
end

function Slide:reset()
  self.active_time = 0
end

function Slide:tick()
  self.active_time = self.active_time + 1 / self.framerate
end

return Slide
