local Block = require 'block'
local BSP   = require 'bsp'
local Level = require 'level'
local TileMap = require 'tilemap'
local Wall = require 'wall'
local util = require 'util'

local floor = math.floor

local LevelGen = {}

local COLOR_RED = {255, 0, 0}

local DEFAULT_SPLITS = 3


function getRectCentre(r)
  return Vec2(r.x + r.w / 2, r.y + r.h / 2)
end

local function cheatRooms(level)
  local x0,y0,x1, y1
  local rooms = level.rooms
  for i = 1, #rooms - 1 do
    local start, dest = getRectCentre(rooms[i]):floor(), getRectCentre(rooms[i + 1]):floor()

    --table.insert(level.paths, level:pathRect(floor(start.x), floor(start.y), floor(dest.x), floor(dest.y), 1))
    level:pathRect(start.x, start.y, dest.x, dest.y, 2)
  end
end

local function connectRooms(tree, level)
  local left, right = tree.children[1], tree.children[2]
  if left and right then
    x0, y0 = floor(left.data.centre.x), floor(left.data.centre.y)
    x1, y1 = floor(right.data.centre.x), floor(right.data.centre.y)

    --level:buildPath(x0, y0, x1, y1)
    table.insert(level.paths, level:pathRect(x0, y0, x1, y1, 3))

    connectRooms(left,  level)
    connectRooms(right, level)
  end
end

function LevelGen.bspLevel(id, w, h, num_splits, w_ratio, h_ratio)
  local level = Level.new(id, w, h)

  local num_splits = num_splits or DEFAULT_SPLITS
  BSP.setRatio(w_ratio or 0.45, h_ratio or 0.45)

  local btree = BSP.new(num_splits, 1, 1, level.tilemap.w, level.tilemap.h)
  level.rooms = BSP.getRooms(btree)
  print(#level.rooms)

  for _, room in ipairs(level.rooms) do
    level:hollowOut(room)
  end
  
  level:wallOff()
 --cheatRooms(level) 
  
 connectRooms(btree, level)

  for _, room in ipairs(level.rooms) do
     --level:buildWalls(room)
     local walls = level:buildWalls2(room)
     for _, wall in ipairs(walls) do
       print(wall.id, wall.x, wall.y, wall.w, wall.h)
       Wall:new(wall.x, wall.y, wall.w, wall.h, true)
     end
  end


  -- for _, path in ipairs(level.paths) do
  --   level:buildWalls(path)
  -- end


  return level
end

function LevelGen.debugSquare(w, h)
  local level = Level.new(1, w, h)
  buildBoundaries(w, h, 32)
  w = w/32
  h = h/32
  local x = (w / 2) - (w/4)
  local y = (h/2) - (h/4)

  local room = {x=x, y=y, w=w/2, h=h/2}
  level:hollowOut(room)
  local wall_t = level:buildWalls2(room)
  print(#wall_t)
  for _, wall in ipairs(wall_t) do
    Wall:new(wall.x, wall.y, wall.w, wall.h, true)
  end

  return level
end
  

return LevelGen
