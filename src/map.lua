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

local Map = Class('Map')

local CELL_SIZE = 32
local COLOR_RED = {255, 0, 0}

local cur_level = nil

function Map:initialize(camera, w, h)
  self.w, self.h = w, h
  self.camera = camera
end

function Map:setup()
  cur_level = LevelGen.bspLevel(1, self.w, self.h)
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


-- Build a new map for the player to TRY

function Map:spawnRandomEnemy(num)
  local num = num or 1
  for i=1, num do
    local x = util.rand(CELL_SIZE, self.w - CELL_SIZE)
    local y = util.rand(CELL_SIZE, self.h - CELL_SIZE)
    Enemy:new(x, y)
  end
end

return Map
