require 'text_util'
local class = require '30log'
local json = require 'json'

local AllDayPanel = class('AllDayPanel')
local AllDayItem = require 'all_day_item'

function AllDayPanel:init(x, y, width, height, data_filename)
  self.x, self.y = x, y
  self.width, self.height = width, height
  self.items = {}

  util.file_watch(data_filename, function(content)
    local data = json.decode(content)
    self.font = resource.load_font(data.font)
    self.events = data.events

    for i, event in ipairs(self.events) do
      self.items[i] = AllDayItem(self.width, 30,
                                 event.name, event.location,
                                 event.time1, event.time2,
                                 event.running,
                                 self.font)
    end
  end)
end

function AllDayPanel:draw()
  for index, item in ipairs(self.items) do
    local i = index - 1

    item:draw(self.x, self.y + i * 57, 1)
  end
end

return AllDayPanel
