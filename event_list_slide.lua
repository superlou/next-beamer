require 'text_util'
local class = require '30log'
local json = require 'json'
local Slide = require 'slide'

local white_block = resource.load_image('white.png')

local EventListSlide = Slide:extend("EventListSlide")
local EventListItem = require 'event_list_item'

function EventListSlide:init(x, y, width, height, data_filename)
  self.super:init()
  self.x, self.y = x, y
  self.items_start = 150
  self.width, self.height = width, height
  self.items = {}
  self.pages = {}
  self:reset()

  util.file_watch(data_filename, function(content)
    local event_list = json.decode(content)
    self.font = resource.load_font(event_list.font)
    self.title = event_list.title
    self.events = event_list.events
    self.duration = event_list.duration

    self.items = {}
    self.pages = {}

    for i, event in ipairs(self.events) do
      self.items[i] = EventListItem(WIDTH, 90,
                                    event.name, event.start, event.location,
                                    self.font)
    end

    self.pages = self:group_items()
    self:reset()
  end)
end

function EventListSlide:group_items()
  local pages = {}

  local current_end = self.items_start
  local current_page = {}

  for i, item in ipairs(self.items) do
    if (current_end + item:get_height() < self.height) then
      table.insert(current_page, item)
      current_end = current_end + item:get_height()
    else
      table.insert(pages, current_page)

      current_page = {}
      table.insert(current_page, item)
      current_end = self.items_start + item:get_height()
    end
  end

  table.insert(pages, current_page)
  return pages
end

function EventListSlide:draw()
  self.super:tick()
  write_centered(self.title, 50, self.width / 2, 50, 1, 1, 1, 1)

  local page_num = math.floor(self.super.active_time / self.duration) + 1

  local y = self.items_start
  for i, item in ipairs(self.pages[page_num]) do
    item:draw(50, y, 1)
    y = y + item:get_height()
  end
end

function EventListSlide:reset()
  self.super:reset()
  self.x = -self.width
end

function EventListSlide:is_done()
  return (self.super.active_time > self.duration * #self.pages)
end

return EventListSlide
