--local Entity = require 'entity'
local Tree = require 'tree'
local Vec2 = require 'vec2'
local util = require 'util'

local rand, floor = util.rand, math.floor

local function randomInt(min, max)
  return floor(rand() * (max - min + 1) + min)
end


local BSP_Box = {}
BSP_Box.__index = BSP_Box

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
  }, BSP_Box)
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


function BSP_Box.drawTree(t)
  t.data:draw()
  if t.children[1] ~= nil then
    BSP_Box.drawTree(t.children[1])
  end
  if t.children[2] ~= nil then
    BSP_Box.drawTree(t.children[2])
  end
end

function BSP_Box.buildRooms(t, lvl)
  local ends = t:getLevel(lvl)
  for _, v in ipairs(ends) do v.data:newRoom() end

  -- local left, right = t.children[1], t.children[2]
  -- if left ~= nil then
  --   BSP_Box.buildRooms(left)
  -- end
  -- if right ~= nil then
  --   BSP_Box.buildRooms(right)
  -- end
end


-- Build a tree of BSP_Boxes!
function BSP_Box:split(iter, child)
  local root = Tree(self)
  if iter ~= 0 then
    -- Randomly Split our root.
    local left, right = randomSplit(self)
    root.children[1] = left:split(iter - 1, true)
    root.children[2] = right:split(iter - 1, true)
  end
  return root
end


function BSP_Box:newRoom()
  local room = {}
  room.x = self.x + randomInt(0, floor(self.w/3))
  room.y = self.y + randomInt(0, floor(self.h/3))
  room.w = self.w - (room.x - self.x)
  room.h = self.h - (room.y - self.y)

  room.w = room.w - randomInt(0, room.w/3)
  room.h = room.h - randomInt(0, room.h/3)

  self.room = room
end

function BSP_Box:setRatio(w, h)
  W_RATIO = w or 0.45
  H_RATIO = h or 0.45
end


function BSP_Box:draw()
  util.hollowRect({0, 0, 255}, self.x, self.y, self.w, self.h)
  if self.room then
    local r = self.room
    util.drawRect({0, 100, 0}, r.x, r.y, r.w, r.h)
  end
end




BSP_Box.new = newBox

return BSP_Box
