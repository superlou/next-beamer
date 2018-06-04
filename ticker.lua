local class = require '30log'
local json = require 'json'

local Ticker = class("Ticker")
local TickerMsg = class("TickerMsg")

separator = resource.load_image("separator.png")

function Ticker:init(data_filename, x, y, width, height)
  self.x, self.y = x, y
  self.width, self.height = width, height
  self.active = false
  self.background = resource.create_colored_texture(0, 0, 0, 0.4)
  self.ticker_msgs = {}
  self.next_msg_id = 1

  self.viewing_area_end = self.x + self.width

  util.file_watch(data_filename, function(content)
    local data = json.decode(content)
    self.speed = data.speed
    self.font = resource.load_font(data.font)
    self.active = data.active
    self.messages = data.messages
  end)
end

function Ticker:draw()
  if not self.active then return end
  self.background:draw(self.x, self.y, self.x + self.width, self.y + self.height)
  self.background:draw(self.x, self.y, self.x + self.width, self.y + 2)

  -- Populate the first TickerMsg if there are none
  if #self.ticker_msgs == 0 then
    self.ticker_msgs[1] = TickerMsg(self.messages[self.next_msg_id],
                                    self.x, self.y + 20, self.font, 60)
    self.next_msg_id = self.next_msg_id + 1
  end

  -- Reset back to 1 if there is only 1 message
  if self.next_msg_id > #self.messages then
    self.next_msg_id = 1
  end

  -- Add additional TickerMsgs until they span across the viewing area
  while self:last_msg_end_x() < self.viewing_area_end do
    self.ticker_msgs[#self.ticker_msgs + 1] = TickerMsg(self.messages[self.next_msg_id],
                                    self:last_msg_end_x(), self.y + 20, self.font, 60)

    self.next_msg_id = self.next_msg_id + 1
    if self.next_msg_id > #self.messages then self.next_msg_id = 1 end
  end

  -- Draw the TickerMsgs
  for i, ticker_msg in ipairs(self.ticker_msgs) do
    ticker_msg:draw()
    ticker_msg:shift_left(self.speed)
  end

  -- Prune any TickerMsgs that are no longer visible
  while self:first_msg_end_x() < self.x do
    table.remove(self.ticker_msgs, 1)
  end
end

function Ticker:first_msg_end_x()
  return self.ticker_msgs[1]:end_x()
end

function Ticker:last_msg_end_x()
  return self.ticker_msgs[#self.ticker_msgs]:end_x()
end

function TickerMsg:init(text, x, y, font, size)
  self.text = text
  self.x, self.y = x, y
  self.font = font
  self.size = size
  self.width = self.font:width(self.text, self.size)
end

function TickerMsg:draw()
  local text_width = self.font:write(self.x, self.y, self.text, self.size, 1, 1, 1, 1)
  local width, height = 20, 20
  local x_offset = 20
  local y_offset = 18
  separator:draw(self.x + text_width + x_offset, self.y + y_offset,
                 self.x + text_width + width + x_offset, self.y + height + y_offset,
                 0.5)
end

function TickerMsg:shift_left(delta)
  self.x = self.x - delta
end

function TickerMsg:end_x()
  return self.x + self.width + 60
end

return Ticker
