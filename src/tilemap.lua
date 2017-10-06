-- Starkiller
-- tilemap.lua
-- This is where we handle everything related to the games tiles.
local util = require 'util'

local floor, math_abs = math.floor, math.abs

local TileMap = {}
TileMap.__index = TileMap

local CELL_SIZE = 32

local LEVELS = {
  'ship'
}

local LEVEL_LOOKUP = {
  ship = 1
}

local TileData = nil

local function relate(val)
  return floor(val / CELL_SIZE)
end

local function relateCoords(x, y, w, h)
  local x, y, w, h = x or 0, y or 0, w or 0, h or 0
  return relate(x), relate(y), relate(w), relate(h)
end

function TileMap.new(lvl, w, h, size)
  if not TileData then TileData = Atlas.tile end

  local map = setmetatable({}, TileMap)
  map.size = size or 32
  map.w, map.h = w, h
  
  if type(lvl) == 'string' then
    map.level = lvl
  else
    map.level = LEVELS[lvl]
  end

  assert(map.level ~= nil)

  for row=1, h do
    for col = 1, w do
      map[row * w + col] = 1
    end
  end
  return map
end


function TileMap:lookup(idx)
  return TileData[self.level][idx]
end


function TileMap:get(x, y)
  return self[y * self.w + x]
end


function TileMap:set(val, x, y)
  self[y * self.w + x] = val
end

function TileMap:getTileWidth(val, x, y)
  local tile = self:get(x, y)

  local len = 0
  while tile == val do
    len = len + 1
    tile = self:get(x + len, y)
  end
  return len
end


function TileMap:getTileHeight(val, x, y)
  local tile = self:get(x, y)

  local len = 0
  while tile == val do
    len = len + 1
    tile = self:get(x, y + len)
  end
  return len
end


function TileMap:line(val, x0, y0, x1, y1, ignore)
  assert(util.inRect(x0, y0, 1, 1, self.w, self.h))
  assert(util.inRect(x1, y1, 1, 1, self.w, self.h))
  local width = 1
  
  local dx, dy = math_abs(x1 - x0), -math_abs(y1 - y0)
  local sx = x0 < x1 and width or -width 
  local sy = y0 < y1 and width or -width
  local err = dx + dy
  local e2

  while true do
    self:set(val, x0, y0)
    if x0 == x1 and y0 == y1 then
      break
    end

    e2 = 2 * err

    if e2 >= dy then
      err = err + dy
      x0 = x0 + sx
    end

    if e2 <= dx then
      err = err + dx
      y0 = y0 + sy
    end
  end
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


function TileMap:drawTile(x, y)
  local tval = self:get(x + 1, y + 1) or 1
  local tile = self:lookup(tval)
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

function TileMap:blockedAt(x, y)
  local x, y = relateCoords(x, y)
  local tile = self:lookup(self:get(x, y))
  return not tile.isWalkable
end

function TileMap:rectIsBlocked(x, y, w, h)
  local x, y, w, h = relateCoords(x, y, w, h)
  local blocked = false
  for j=y, y+h do
    for i=x, x+w do
      blocked = self:blockedAt(i, j)
      if blocked then return true end
    end
  end
  return false
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
