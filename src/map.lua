-- Starkiller
-- map.lua
-- This is where we generate and manage the levels the player is playing on.
local Block = require 'block'
local BSP   = require 'bsp'
local Enemy = require 'enemy'
local Hero = require 'hero'
local LevelGen = require 'levelgen'
local TileMap = require 'tilemap'
local util = require 'util'

local rand = util.roundedRandom

local Map = Class('Map')

local CELL_SIZE = 32
local COLOR_RED = {255, 0, 0}

local cur_level = nil

function Map:initialize(camera, w, h)
  self.w, self.h = w, h
  self.camera = camera
end

function Map:setup()
  cur_level = LevelGen.bspLevel(1, self.w, self.h, 3, 0.5, 0.3)
  --cur_level = LevelGen.debugSquare(self.w, self.h)
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
  cur_level.tilemap:draw(x, y, w, h)
  local visibleEnts, num = Game.world:queryRect(x, y, w, h)

  for i = 1, num do
    visibleEnts[i]:draw()
  end
end


function Map:spawnRandomEnemy(num)
  local num = num or 1
  local level = cur_level

  for i=1, num do
    local room = level.rooms[rand(1, #level.rooms)]
    local x = rand(room.x + 1, room.x + room.w - 1)
    local y = rand(room.y + 1, room.y + room.h - 2)

    Enemy:new('xeno', x * CELL_SIZE, y * CELL_SIZE)
  end
end

return Map
