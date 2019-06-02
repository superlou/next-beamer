require 'slide_manager'
require 'color_util'
AllDayPanel = require 'all_day'
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

local video = util.videoplayer("GreenHoneycombPixelsVidevo.mov", {["loop"] = true;})
local slide_manager = SlideManager(480, 0, WIDTH - 480, 800, 'data_slides.json')
local ticker = Ticker("data_ticker.json", 0, 800, WIDTH, 100)
local clock = Clock(55, 0, 200, 100)
clock.text = "88:88 ZM"
local logo = resource.load_image("logo.png")
local all_day_panel = AllDayPanel(0, 100, 480, 700, 'data_all_day.json')

local background = create_color_resource_hex("#5c987b")
local left_background = create_color_resource_hex("#198b80")
local divider = create_color_resource_hex("#364a2b")

util.data_mapper{
  ["clock/set"] = function(time)
    clock:update(time)
  end
}

local dt = 1 / 60

function node.render()
  gl.clear(0.0, 0.0, 0.0, 1)
  -- video:draw(0, 0, WIDTH, HEIGHT, 0.2)
  background:draw(0, 0, 1600, 800, 1.0)
  left_background:draw(0, 0, 480, 800, 1.0)
  -- logo:draw(0, 0, 460, 366)
  slide_manager:draw()
  all_day_panel:draw(dt)
  divider:draw(480, 0, 482, 800)
  ticker:draw()
  clock:draw()
  flux.update(dt)
end
