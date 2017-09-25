--local Entity = require 'entity'
local Tree = require 'tree'
local Vec2 = require 'vec2'
local util = require 'util'

local rand, floor = math.random, math.floor

local function random(min, max)
  return floor(rand() * (max - min + 1) + min)
end

local BSP_Box = {}
BSP_Box.__index = BSP_Box


local function newBox(x, y, w, h)
  return setmetatable({
    x = x,
    y = y,
    w = w,
    h = h,
    centre = Vec2(x + (w/2), y + (h/2))
  }, BSP_Box)
end

local function randomSplit(box)
  local left, right
  if random(0, 1) == 0 then
    -- Vertical
    left  = newBox(box.x, box.y, random(1, box.w), box.h)
    right = newBox(box.x + left.w, box.y, box.w - left.w, box.h)
  else
    left  = newBox(box.x, box.y, box.w, random(1, box.h))
    right = newBox(box.x, box.y + left.h, box.w, box.h - left.h)
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


-- Build a tree of BSP_Boxes!
function BSP_Box:split(iter)
  local root = Tree(self)
  if iter ~= 0 then
    -- Randomly Split our root.
    local left, right = randomSplit(self)
    root.children[1] = left:split(iter - 1)
    root.children[2] = right:split(iter - 1)
  end
  return root
end

function BSP_Box:draw()
  util.hollowRect({0, 0, 255}, self.x, self.y, self.w, self.h)
end

local MAP_SIZE = 50
local SQUARE = 1024 / MAP_SIZE
local N_ITER = 4



BSP_Box.new = newBox

return BSP_Box
