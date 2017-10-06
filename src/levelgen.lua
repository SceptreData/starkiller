local Block = require 'block'
local BSP   = require 'bsp'
local Level = require 'level'
local TileMap = require 'tilemap'
local util = require 'util'

local floor = math.floor

local LevelGen = {}

local COLOR_RED = {255, 0, 0}

local DEFAULT_SPLITS = 3

local function buildBoundaries(w, h, size)
  Block:new(COLOR_RED, 0, 0, w, size)
  Block:new(COLOR_RED, 0, size, size, h - size * 2)
  Block:new(COLOR_RED, w - size, size, size, h - size * 2)
  Block:new(COLOR_RED, 0, h- size, w, size)
end


local function connectRooms(tree, level)
  local left, right = tree.children[1], tree.children[2]
  if left and right then
    x0, y0 = floor(left.data.centre.x), floor(left.data.centre.y)
    x1, y1 = floor(right.data.centre.x), floor(right.data.centre.y)

    --level:buildPath(x0, y0, x1, y1)
    level:pathRect(x0, y0, x1, y1, 1)

    connectRooms(left,  level)
    connectRooms(right, level)
  end
end

function LevelGen.bspLevel(id, w, h, num_splits, w_ratio, h_ratio)
  local level = Level.new(id, w, h)
  --buildBoundaries(w, h, 32)

  local num_splits = num_splits or DEFAULT_SPLITS
  BSP.setRatio(w_ratio or 0.45, h_ratio or 0.45)

  local btree = BSP.new(num_splits, 1, 1, level.tilemap.w, level.tilemap.h)
  level.rooms = BSP.getRooms(btree)

  for _, room in ipairs(level.rooms) do
    level:hollowOut(room)
  end

  for _, room in ipairs(level.rooms) do
    level:buildWalls(room)
  end

  connectRooms(btree, level)

  return level
end

return LevelGen
