local Entity = require 'entity'
local util   = require 'util'

local drawRect = util.drawRect

local Block = Class('Block', Entity)

function Block:initialize(color, x, y, w, h)
  Entity.initialize(self, x, y, w, h)
  self.color = color
end


function Block:update(dt)
end


function Block:draw()
  drawRect(self.color, self.pos.x, self.pos.y, self.w, self.h)
end

return Block
