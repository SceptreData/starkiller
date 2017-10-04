local Block = require 'block'
local BSP   = require 'bsp'
local Enemy = require 'enemy'
local Hero = require 'hero'
local TileMap = require 'tilemap'
local util = require 'util'

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
  self.tilemap:draw(x, y, w, h)
  local visibleEnts, num = Game.world:queryRect(x, y, w, h)

  for i = 1, num do
    visibleEnts[i]:draw()
  end
end

function Map:setup()
  self:buildBoundaries(self.w, self.h, CELL_SIZE)
  self:generateBspMap(4)
  --self.tilemap:printMap()
end


function Map:generateBspMap(num_splits, w_ratio, h_ratio)
  local w, h = math.floor(self.w / CELL_SIZE), math.floor(self.h / CELL_SIZE)
  self.tilemap = TileMap.new(1, w, h)

  BSP.setRatio(w_ratio or 0.45, h_ratio or 0.45)
  local btree = BSP.new(num_splits, 1, 1, w, h)
  local rooms = BSP.getRooms(btree)

  for i, room in ipairs(rooms) do
    self.tilemap:fillRect(2, room.x, room.y, room.w, room.h)
  end
end


function Map:buildBoundaries(w, h, size)
  Block:new(COLOR_RED, 0, 0, w, size)
  Block:new(COLOR_RED, 0, size, size, h - size * 2)
  Block:new(COLOR_RED, w - size, size, size, h - size * 2)
  Block:new(COLOR_RED, 0, h- size, w, size)
end

function Map:spawnRandomEnemy(num)
  local num = num or 1
  for i=1, num do
    local x = util.rand(CELL_SIZE, self.w - CELL_SIZE)
    local y = util.rand(CELL_SIZE, self.h - CELL_SIZE)
    Enemy:new(x, y)
  end
end

return Map
