-- Starkiller
-- tilemap.lua
-- This is where we handle everything related to the games tiles.
local util = require 'util'

local floor = math.floor

local TileMap = {}
TileMap.__index = TileMap

local LEVELS = {
  'ship'
}

local TileData = nil

function TileMap.new(lvl, w, h, size)
  if not TileData then TileData = Atlas.tile end

  local map = setmetatable({}, TileMap)
  map.size = size or 32
  map.w, map.h = w, h
  map.level = LEVELS[lvl]
  assert(map.level ~= nil)

  for row=1, h do
    for col = 1, w do
      map[row * w + col] = 1
    end
  end
  return map
end


function TileMap:get(x, y)
  return self[y * self.w + x]
end


function TileMap:set(val, x, y)
  self[y * self.w + x] = val
end


function TileMap:fillRect(val, x, y, w, h)
  for j = y, y+h do
    for i = x, x+w do
      if i <= self.w and j <= self.h then
        self:set(val, i, j)
      end
    end
  end
end


function TileMap:getTile(idx)
  return TileData[self.level][idx]
end


function TileMap:drawTile(x, y)
  local tval = self:get(x + 1, y + 1) or 1
  local tile = self:getTile(tval)
  util.resetColor()
  love.graphics.draw(tile.img, tile.sprite[1], x * self.size, y * self.size)
end


function TileMap:draw(x, y, w, h)
  local size = self.size
  local mx, my = floor(x / size), floor(y / size)
  local mw, mh = floor(w / size), util.round(h / size)

  for j=my, my + mh do
    for i=mx, mx + mw do
      self:drawTile(i, j)
    end
  end
end


function TileMap:printMap()
  for j = 1, self.h do
    for i = 1, self.w do
      io.write(string.format('%d ', self:get(i, j)))
    end
    print()
  end
end
    

return TileMap
