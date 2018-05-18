local json = require 'json'
local class = require '30log'
local EventListSlide = require 'event_list_slide'
local TextSlide = require 'text_slide'
local ImageSlide = require 'image_slide'

SlideManager = class("SlideManager")

function SlideManager:init(x, y, width, height, slides_filename)
  self.x, self.y = x, y
  self.width, self.height = width, height
  self.active_slide_index = nil
  self.slides = {}

  util.file_watch(slides_filename, function(content)
    local data = json.decode(content)
    self:build_slides(data.slides)
  end)
end

function is_enabled(setting)
  local name = sys.get_env("NAME")

  if setting == true then
    return true
  elseif setting == nil then
    return true
  elseif name and type(setting) == "string" then
    return setting == name
  elseif name and type(setting) == "table" then
    for _, value in pairs(setting) do
      if value == name then
        return true
      end
    end
  end

  return false
end

function SlideManager:build_slides(slides_data)
  self.slides = {}
  self.active_slide_index = nil

  for i, slide_data in ipairs(slides_data) do
    local slide

    if is_enabled(slide_data.enable) then
      if slide_data.type == "event_list_slide" then
        slide = EventListSlide(self.x, self.y, self.width, self.height, slide_data.data)
      elseif slide_data.type == "text_slide" then
        slide = TextSlide(self.x, self.y, self.width, self.height, slide_data.data)
      elseif slide_data.type == "image_slide" then
        slide = ImageSlide(self.x, self.y, self.width, self.height, slide_data.data)
      end

      if slide then
        table.insert(self.slides, slide)
        self.active_slide_index = 1
      end
    end
  end
end

function SlideManager:draw()
  local active_slide = self.slides[self.active_slide_index]

  if active_slide:is_done() then
    active_slide:reset()
    self.active_slide_index = self.active_slide_index + 1

    if self.active_slide_index > #self.slides then
      self.active_slide_index = 1
    end

    active_slide = self.slides[self.active_slide_index]
  end

  active_slide:draw()
end
