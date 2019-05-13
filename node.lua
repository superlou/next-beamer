require 'slide_manager'
require 'color_util'
Ticker = require 'ticker'
Clock = require 'clock'
flux = require 'flux'

gl.setup(1600, 900)

local name = sys.get_env("NAME")
if name then
  print("Running with name " .. name)
else
  print("Running with name not set")
end

local slide_manager = SlideManager(460, 0, WIDTH - 460, 800, 'data_slides.json')
local ticker = Ticker("data_ticker.json", 0, 800, WIDTH, 100)
local clock = Clock(0, 280, 200, 100)
clock.text = "88:88"
local logo = resource.load_image("logo.png")

local background = create_color_resource_hex("#599e98")
local left_background = create_color_resource_hex("#107870")

util.data_mapper{
  ["clock/set"] = function(time)
    clock:update(time)
  end
}

function node.render()
  gl.clear(0.0, 0.0, 0.0, 1)
  background:draw(0, 0, 1600, 800, 1)
  left_background:draw(0, 0, 460, 800)
  logo:draw(0, 0, 460, 366)
  slide_manager:draw()
  ticker:draw()
  clock:draw()
  flux.update(0.0167)
end
