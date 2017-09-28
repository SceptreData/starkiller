local util = require 'util'
local Vec2 = require 'vec2'

local Tree = {}
Tree.__index = Tree

local concat = util.concat


local function newNode(obj)
  local n = setmetatable({}, Tree)
  n.data = obj
  n.children = {}
  return n
end


function Tree:getLeaves()
  if self == nil then return nil end
  local left  = self.children[1] and self.children[1]:getLeaves() or nil
  local right = self.children[2] and self.children[2]:getLeaves() or nil

  return concat({self}, left, right)
end


function Tree:getValues()
  local vals = {}
  local leaves = self:getLeaves()
  for _, v in ipairs(leaves) do
    vals[#vals + 1] = v.data
  end
  return vals
end


function Tree:getLevel(lvl, q)
  if q == nil then
    q = {}
  end

  if lvl == 1 then
    q[#q + 1] = self
  else
    local left, right = self.children[1], self.children[2]
    if left ~= nil then
      left:getLevel(lvl - 1, q)
    end
    if right ~= nil then
      right:getLevel(lvl - 1, q)
    end
  end
  return q
end

function Tree:each(func, ...)
  if self == nil then return nil end
  func(self.data, ...)
  local left, right = self.children[1], self.children[2]
  if left then left:each(func, ...) end
  if right then right:each(func, ...) end
end


return setmetatable(Tree, {__call = function(_, ...) return newNode(...) end})
