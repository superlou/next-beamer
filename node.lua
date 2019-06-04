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

local slide_manager = SlideManager(480, 0, WIDTH - 480, 800, 'data_slides.json')
local ticker = Ticker("data_ticker.json", 0, 800, WIDTH, 100)
local clock = Clock(1570, 12, 200, 100, 'right')
clock.text = "88:88 ZM"
local logo = resource.load_image("animenext_logo_transparent_800px_white2.png")
local all_day_panel = AllDayPanel(0, 116, 480, 700, 'data_all_day.json')

local background = create_color_resource_hex("#5c987b")
local background_image = resource.load_image('background-tint-lighter.png')
local left_background = create_color_resource_hex("#198b80")
local divider = create_color_resource_hex("#364a2b")

local left_decal = resource.load_image('decal.png')

util.data_mapper{
  ["clock/set"] = function(time)
    clock:update(time)
  end
}

local dt = 1 / 60

function node.render()
  gl.clear(0.0, 0.0, 0.0, 1)
  background_image:draw(0, 0, 1600, 900, 1.0)
  left_decal:draw(0, 0, 480, 800, 0.5)
  logo:draw(40, 35, 410, 85)
  slide_manager:draw()
  all_day_panel:draw(dt)
  divider:draw(480, 0, 482, 800, 1)
  ticker:draw()
  clock:draw()
  flux.update(dt)
end
