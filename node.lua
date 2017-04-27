require 'slide_manager'

gl.setup(1600, 900)

local video = util.videoplayer("loop.m4v", {["loop"] = true;})
local slide_manager = SlideManager(WIDTH, HEIGHT, 'data_slides.json')

function node.render()
  gl.clear(0.0, 0.0, 0.0, 1)
  video:draw(0, 0, WIDTH, HEIGHT, 0.4)
  slide_manager:draw()
end
