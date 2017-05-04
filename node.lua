require 'slide_manager'
Ticker = require 'ticker'

gl.setup(1600, 900)

local video = util.videoplayer("loop.m4v", {["loop"] = true;})
local slide_manager = SlideManager(WIDTH, HEIGHT, 'data_slides.json')
local ticker = Ticker("data_ticker.json", 0, 800, WIDTH, 100)

function node.render()
  gl.clear(0.0, 0.0, 0.0, 1)
  video:draw(0, 0, WIDTH, HEIGHT, 0.4)
  slide_manager:draw()
  ticker:draw()
end
