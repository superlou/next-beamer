require 'text_util'
local class = require '30log'
local json = require 'json'

local AllDayPanel = class('AllDayPanel')
local AllDayItem = require 'all_day_item'

function AllDayPanel:init(x, y, width, height, data_filename)
  self.x, self.y = x, y
  self.width, self.height = width, height
  self.pages = {}
  self.item_height = 55
  self.item_pad = 8
  self.item_total_height = self.item_height + self.item_pad

  self.t = 0
  self.active_page = 1

  util.file_watch(data_filename, function(content)
    local data = json.decode(content)
    self.font = resource.load_font(data.font)
    self.events = data.events

    self.pages = {}
    local page_num = 1
    local page_items = {}

    for i, event in ipairs(self.events) do
      item = AllDayItem(self.width, self.item_height,
                                 event.name, event.location,
                                 event.time1, event.time2,
                                 event.running,
                                 self.font)

      if (#page_items + 1) * self.item_total_height < self.height then
        table.insert(page_items, item)
      else
        table.insert(self.pages, page_items)
        page_items = {}
      end
    end

    if #page_items > 0 then
      table.insert(self.pages, page_items)
    end
  end)
end

function AllDayPanel:draw(dt)
  self.t = self.t + dt

  if self.t > 8 then
    self.t = 0
    self.active_page = self.active_page + 1

    if self.active_page > #self.pages then
      self.active_page = 1
    end
  end

  for index, item in ipairs(self.pages[self.active_page]) do
    local i = index - 1

    item:draw(self.x, self.y + i * self.item_total_height, 1)
  end
end

return AllDayPanel
