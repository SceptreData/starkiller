--
-- Utility functions
-- Contains functions from rxi's lume library, licensed under MIT
--
local util = {}

local random, floor, ceil = love.math.random, math.floor, math.ceil

-- rxi
local getiter = function(x)
  if util.isarray(x) then
    return ipairs
  elseif type(x) == "table" then
    return pairs
  end
  error("expected table", 3)
end

local patternescape = function(str)
  return str:gsub("[%(%)%.%%%+%-%*%?%[%]%^%$]", "%%%1")
end

-- rxi
-- check if a value is an array
function util.isarray(x)
  return (type(x) == "table" and x[1] ~= nil) and true or false
end

function util.array(...)
  local t = {}
  for x in ... do t[#t + 1] = x end
  return t
end

-- lume function
function util.clamp(x, min, max)
  return x < min and min or (x > max and max or x)
end


-- lume function
function util.round(x, increment)
  if increment then return util.round(x / increment) * increment end
  return x >= 0 and floor(x + .5) or ceil(x - .5)
end


-- lume function
function util.sign(x)
  return x < 0 and -1 or 1
end


-- lume function
-- Concatenates tables into a single table.
function util.concat(...)
  local rtn = {}
  for i = 1, select("#", ...) do
    local t = select(i, ...)
    if t ~= nil then
      local iter = getiter(t)
      for _, v in iter(t) do
        rtn[#rtn + 1] = v
      end
    end
  end
  return rtn
end

-- rxi
-- splits a string at the specified delimiter, defaults to spaces.
function util.split(str, sep)
  if not sep then
    return util.array(str:gmatch("([%S]+)"))
  else
    assert(sep ~= "", "empty separator")
    local psep = patternescape(sep)
    return util.array((str..sep):gmatch("(.-)("..psep..")"))
  end
end

function util.splitFilename(file)
  local spl = util.split(file, '.')
  local front, back = spl[1], spl[2]
  return front, back
end

function util.getFilename(f)
  local name = util.splitFilename(f)
  return name
end

-- lume func
function util.rand(a, b)
  if not a then a, b = 0, 1 end
  if not b then b = 0 end
  return a + random() * (b - a)
end

function util.rectIntersects(a, b)
  return (a.x <= b.x + b.w and
          b.x <= a.x + a.w and
          a.y <= b.y + b.h and
          b.y <= a.y + a.h)
end

-- returns a table which references the index of table elements in an array.
-- looksup the value specified by 'field' to use as a key.
function util.mapKeys(arr, field)
  assert(util.isarray(arr))
  local kmap = {}
  for i=1, #arr do
    local key = arr[i][field]
    kmap[key] = i
  end
  return kmap
end

function util.printkv(t)
  assert(type(t) == 'table', 'Expected table, received '.. type(t))
  for k, v in pairs(t) do print(k, v) end
end


function util.printKeys(t)
  assert(type(t) == 'table', 'Expected table, received '.. type(t))
  for k, _ in pairs(t) do print(k) end
end


function util.printVals(t)
  assert(type(t) == 'table', 'Expected table, received '.. type(t))
  local iter = getiter(t)
  for _, v in iter(t) do print(v) end
end

-- Converts an RGB table to 3 return vals.
function util.getColor(rgb_t)
  return unpack(rgb_t)
end

function util.resetColor()
  love.graphics.setColor(255, 255, 255, 255)
end

-- Draw functions
-- Draw shaded rect with border
function util.drawRect(color, x, y, w, h)
  local r, g, b = util.getColor(color)
  love.graphics.setColor(r, g, b, 100)
  love.graphics.rectangle('fill', x, y, w, h)
  love.graphics.setColor(r, g, b)
  love.graphics.rectangle('line', x, y, w, h)
end

-- Draws a hollow rectangle
function util.hollowRect(color, x, y, w, h)
  local r, g, b = util.getColor(color)
  love.graphics.setColor(r, g, b)
  love.graphics.rectangle('line', x, y, w, h)
end


return util
