local Vec2 = require 'vec2'

local Tree = {}
Tree.__index = Tree


local function concat(...)
  local t = {}
  for i = 1, select('#', ...) do
    local cur = select(i, ...)
    if cur ~= nil then
      if type(cur) == 'table' then
        for _, v in ipairs(cur) do
          t[#t + 1] = v
        end
      else
        t[#t  + 1] = cur
      end
    end
  end
  return t
end



local function newNode(obj)
  local n = setmetatable({}, Tree)
  n.data = obj
  n.children = {}
  return n
end


function Tree:getLeaves()
  if self.children[1] == nil and self.children[2] == nil then
    --if type(self.data) ~= 'table' then self.data = {self.data} end
    return self.data
  else
    local left = self.children[1] and self.children[1]:getLeaves() or nil
    local right = self.children[2] and self.children[2]:getLeaves() or nil
    return concat(self.data, left, right)
  end
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


-- foo = 'Joe'
-- bar = 'Sam'
-- jam = 'Rita'
-- zip = 'jamal'
--
-- local tree = newNode(foo)
--
-- tree.children[1] = newNode(bar)
-- tree.children[2] = newNode(jam)
-- tree.children[1].children[1] = newNode(zip)
--
-- local read = tree:getLeaves()
-- for i, v in ipairs(read) do print(i, v) end
--
return setmetatable(Tree, { __call = function(_, ...) return newNode(...) end})
