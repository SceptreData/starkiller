-- Starkiller
-- bsp.lua
-- Binary Space Partition Level Generator
-- Splits a space into a tree, allowing us to create a series
-- of rooms.

local Tree = require 'tree'
local Vec2 = require 'vec2'
local util = require 'util'

local rand, floor = util.rand, math.floor

local function randomInt(min, max)
  return floor(rand() * (max - min + 1) + min)
end


local BSP = {}
BSP.__index = BSP

local DISCARD_BY_RATIO = true
local W_RATIO = 0.45
local H_RATIO = 0.45


local function newBox(x, y, w, h)
  return setmetatable({
    x = x,
    y = y,
    w = w,
    h = h,
    centre = Vec2(x + (w/2), y + (h/2))
  }, BSP)
end


function BSP.setRatio(w, h)
  W_RATIO = w or 0.45
  H_RATIO = h or 0.45
end


-- Recursive function for splitting our BSPBoxes, discarding invalid rooms
local function randomSplit(box)
  local left, right

  if randomInt(0, 1) == 0 then
    -- Vertical split
    left  = newBox(box.x, box.y, randomInt(1, box.w), box.h)
    right = newBox(box.x + left.w, box.y, box.w - left.w, box.h)

    -- If box doesn't fit ratio criteria, discard and get a new one.
    if DISCARD_BY_RATIO then
      local l_ratio  = left.w / left.h
      local r_ratio = right.w / right.h
      if l_ratio < W_RATIO or r_ratio < W_RATIO then
        return randomSplit(box)
      end
    end
  else
    -- Horizontal Split
    left  = newBox(box.x, box.y, box.w, randomInt(1, box.h))
    right = newBox(box.x, box.y + left.h, box.w, box.h - left.h)

    if DISCARD_BY_RATIO then
      local l_ratio  = left.h / left.w
      local r_ratio = right.h / right.w
      if l_ratio < H_RATIO or r_ratio < H_RATIO then
        return randomSplit(box)
      end
    end
  end

  return left, right
end

-- Build a tree of BSPes!
function BSP:split(iter, child)
  local root = Tree(self)
  if not child then root.levels = iter + 1 end
  if iter ~= 0 then
    -- Randomly Split our root, add it to tree
    local left, right = randomSplit(self)
    root.children[1] = left:split(iter - 1, true)
    root.children[2] = right:split(iter - 1, true)
  end
  return root
end


function BSP.buildRooms(tree, lvl)
  local lvl = lvl or tree.levels
  local ends = tree:getLevel(lvl)
  for _, v in ipairs(ends) do v.data:newRoom() end
end


function BSP.getRooms(tree)
  local ends = tree:getLevel(tree.levels)
  local rooms = {}
  for i=1, #ends do
    table.insert(rooms, ends[i].data.room)
  end
  return rooms
end


function BSP:newRoom()
  local room = {}
  room.x = self.x + randomInt(0, floor(self.w/3))
  room.y = self.y + randomInt(0, floor(self.h/3))
  room.w = self.w - (room.x - self.x)
  room.h = self.h - (room.y - self.y)

  room.w = room.w - randomInt(0, room.w/3)
  room.h = room.h - randomInt(0, room.h/3)

  self.room = room
end


function drawPath(start, dest, width)
  local old_w = love.graphics.getLineWidth()
  love.graphics.setLineWidth(width or 64)

  love.graphics.setColor(0, 255, 0)
  love.graphics.line(start.centre.x, (start.centre.y),
                     dest.centre.x, dest.centre.y
                    )
  love.graphics.setLineWidth(old_w)
end


-- Build a bresenham line path between BSP segments
function BSP.bresenPath(x0, y0, x1, y1, w)
  local width = w or 1

  local dx, dy = math.abs(x1 - x0), -math.abs(y1 - y0)
  local sx = x0 < x1 and width or -width 
  local sy = y0 < y1 and width or -width
  local err = dx + dy
  local e2

  while x0 ~= x1 and y0 ~= y1 do
    setTile(x0,y0)
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




local function drawBox(box)
  util.hollowRect({0, 0, 255}, box.x, box.y, box.w, box.h)
  if box.room then
    local r = box.room
    util.drawRect({0, 100, 0}, r.x, r.y, r.w, r.h)
  end
end


function BSP.drawTree(t)
  local box = t.data
  drawBox(box)

  local left, right = t.children[1], t.children[2]
  if left then
    BSP.drawTree(left)
  end
  if right then
    BSP.drawTree(right)
  end
end

function BSP.drawPaths(t)
  local left, right = t.children[1], t.children[2]
  if left and right then
    drawPath(left.data, right.data)
    BSP.drawPaths(left)
    BSP.drawPaths(right)
  end
end


BSP.new = function(num_splits, x, y, w, h)
  local box = newBox(x, y, w, h)
  local bsp = box:split(num_splits)
  BSP.buildRooms(bsp)
  return bsp
end

return BSP
