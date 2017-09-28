local Block = require 'block'
local BSP   = require 'bsp'
local Hero = require 'hero'
local Enemy = require 'enemy'

local Map = Class('Map')

local CELL_SIZE = 32

local COLOR_RED = {255, 0, 0}


-- TODO: Add sort options etc.

function Map:initialize(camera, w, h)
  self.w, self.h = w, h
  self.camera = camera
end


function Map:update(dt, x, y, w, h)
  x, y, w, h = x or 0, y or 0, w or self.w, h or self.w
  local visibleEnts, num = Game.world:queryRect(x, y, w, h)

  -- Sort intelligently here (SOME DAY!)

  for i=1, num do
    visibleEnts[i]:update(dt)
  end
end


function Map:draw(x, y, w, h)
  x, y, w, h = x or 0, y or 0, w or self.w, h or self.w
  local visibleEnts, num = Game.world:queryRect(x, y, w, h)

  for i = 1, num do
    visibleEnts[i]:draw()
  end
end

function Map:setup()
  self:buildBoundaries(self.w, self.h, CELL_SIZE)
end

function Map:buildBoundaries(w, h, size)
  Block:new(COLOR_RED, 0, 0, w, size)
  Block:new(COLOR_RED, 0, size, size, h - size * 2)
  Block:new(COLOR_RED, w - size, size, size, h - size * 2)
  Block:new(COLOR_RED, 0, h- size, w, size)
end

return Map
