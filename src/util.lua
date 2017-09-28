--
-- Utility functions
-- Several of these are lifted from lume, a lib by rxi under MIT.
-- I have indicated this where possible.
--
local util = {}

local random = math.random

-- lume
local getiter = function(x)
  if util.isarray(x) then
    return ipairs
  elseif type(x) == "table" then
    return pairs
  end
  error("expected table", 3)
end

-- lume
-- check if a value is an array
function util.isarray(x)
  return (type(x) == "table" and x[1] ~= nil) and true or false
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


-- lume function
function util.clamp(x, min, max)
  return x < min and min or (x > max and max or x)
end


-- lume function
function util.round(x, increment)
  if increment then return util.round(x / increment) * increment end
  return x >= 0 and math_floor(x + .5) or math_ceil(x - .5)
end


-- lume function
function util.sign(x)
  return x < 0 and -1 or 1
end


function util.rand(a, b)
  if not a then a, b = 0, 1 end
  if not b then b = 0 end
  return a + random() * (b - a)
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
