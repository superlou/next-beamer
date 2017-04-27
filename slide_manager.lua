local json = require 'json'
local class = require '30log'
require 'upcoming_slide'
require 'text_slide'

SlideManager = class("SlideManager")

function SlideManager:init(width, height, slides_filename, font)
  self.font = font
  self.width, self.height = width, height
  self.active_slide_index = nil
  self.slides = {}

  util.file_watch(slides_filename, function(content)
    local data = json.decode(content)
    self:build_slides(data.slides)
  end)
end

function SlideManager:build_slides(slides_data)
  self.slides = {}
  self.active_slide_index = nil
  -- self.active_slide_time = 0

  for i, slide_data in ipairs(slides_data) do
    local slide

    if slide_data.type == "upcoming_slide" then
      slide = UpcomingSlide(self.width, self.height, slide_data.data, slide_data.font)
    elseif slide_data.type == "text_slide" then
      slide = TextSlide(self.width, self.height, slide_data.data, slide_data.font)
    end

    if slide then
      table.insert(self.slides, slide)
      self.active_slide_index = 1
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
