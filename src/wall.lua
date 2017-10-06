local Entity = require 'entity'
local util   = require 'util'

local Wall = Class('Wall', Entity)

local collidesWith = function(me, other)
end

local CELL_SIZE = 32

function Wall:initialize(x, y, w, h, adjust)
  print('newWall', x, y, w, h)
  if adjust then
    x, y, w, h = (x-1) * CELL_SIZE, (y-1) * CELL_SIZE, w * CELL_SIZE, h * CELL_SIZE
  end


  Entity.initialize(self, x, y, w, h)
  self.isWall = true
  self.id = 'wall'
  self.size = 32
end

function Wall:update(dt)
end

function Wall:draw()
  if DEBUG_MODE then
    util.drawRect({255,0,0}, self.pos.x, self.pos.y, self.w, self.h)
  end
end

function Wall:hsplit(sx, gap, adjust)
  if adjust then
    local sx, gap = sx * self.size, gap * self.size
  end

  local a, b
  if sx > self.x + self.size then
    a = Wall:new(self.x, self.y, sx - self.x, self.h)
  end

  if sx + (gap * self.size) < self.x + self.w - self.size then
    local b = Wall:new(sx + gap, self.y, self.w - (sx - self.x) - gap, self.h)
  end

  self:remove()
  return a, b
end


function Wall:vsplit(sy, gap, adjust)
  if adjust then
    local sy, gap = sy * self.size, gap * self.size
  end

  local a, b
  if sy > self.y + self.size then
    a = Wall:new(self.x, self.y, self.w, sy - self.y)
  end
  if sy + (gap * self.size) < self.y + self.h - self.size then
    local b = Wall:new(self.x, sy + gap, self.w, self.h - (sy - self.y) - gap)
  end

  self:remove()
  return a, b
end

return Wall
