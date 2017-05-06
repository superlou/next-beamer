require 'slide_manager'
Ticker = require 'ticker'
Clock = require 'clock'

gl.setup(1600, 900)

local video = util.videoplayer("loop.m4v", {["loop"] = true;})
local slide_manager = SlideManager(WIDTH, HEIGHT, 'data_slides.json')
local ticker = Ticker("data_ticker.json", 0, 800, WIDTH, 100)
local clock = Clock(0, 800, 200, 100)

util.data_mapper{
  ["clock/set"] = function(time)
    clock:update(time)
  end
}

function node.render()
  gl.clear(0.0, 0.0, 0.0, 1)
  video:draw(0, 0, WIDTH, HEIGHT, 0.4)
  slide_manager:draw()
  ticker:draw()
  clock:draw()
end
