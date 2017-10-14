--    Sceptre's sexy luajit Vec2 lib

local sqrt, cos, sin, atan2, floor = math.sqrt, math.cos, math.sin, math.atan2, math.floor

local Vec2_mt = {}

local function new(x, y)
  return setmetatable({
    x = x or 0,
    y = y or 0
  }, Vec2_mt)
end

if jit then
  ffi = require('ffi')
  ffi.cdef[[
    typedef struct { double x, y; } vec2_t;
  ]]
  new = ffi.typeof('vec2_t')
end


local Vec2 = {}

function Vec2.isVector(v)
    if type(v) == 'cdata' then
      return ffi.istype('vec2_t', v)
    end
    return type(v) == 'table' and
           type(v.x) == 'number' and
           type(v.y) == 'number'
end

function Vec2.isZero(v)
  return v.x == 0 and v.y == 0
end

function Vec2.new(x, y)
    if x and y then
        return new(x, y)
    else
        return new()
    end
end

function Vec2.clone(v)
    return new(v.x, v.y)
end


function Vec2.add(a, b)
    if type(b) == 'number' then
      return new(a.x + b, a.y + b)
    end
    return new(a.x + b.x, a.y + b.y)
end

function Vec2.sub(a, b)
    return new(a.x - b.x, a.y - b.y)
end

function Vec2.mul(a,b)
    return new(a.x * b.x, a.y * b.y) 
end

function Vec2.div(a, b)
    return new(a.x / b.x, a.y / b.y)
end

function Vec2.dot(a, b)
    return a.x * b.x + a.y * b.y
end

function Vec2.cross(a, b)
    return a.x * b.y - a.y * b.x
end

function Vec2.len(v)
    return sqrt(v.x * v.x + v.y * v.y)
end

function Vec2.len2(v)
    return v.x * v.x + v.y * v.y
end

function Vec2.dist(a, b)
    local dx = a.x - b.x
    local dy = a.y - b.y
    return sqrt(dx * dx + dy * dy)
end


function Vec2.dist2(a, b)
    local dx = a.x - b.x
    local dy = a.y - b.y
    return dx * dx + dy * dy
end


function Vec2.area(a)
    return a.x * a.x + a.y * a.y
end


function Vec2.scale(v, s)
    return new(v.x * s, v.y * s)
end


function Vec2.midpoint(a, b)
  return (a + b) * 0.5
end


function Vec2.scaleMe(v, s)
  v.x = v.x * s
  v.y = v.y * s
  return v
end


function Vec2.normalize(v)
    if v.x == 0 and v.y == 0 then
        return new()
    end
    return v:scale(1 / v:len())
end


function Vec2:normalizeMe()
  local mag = self:len()
  if mag > 0 then
    self:scaleMe(1 / mag)
  end
  return self
end


function Vec2.setMag(v, mag)
  v:normalizeMe()
  v:scaleMe(mag)
  return v
end


function Vec2.limit(v, max)
  if v:len2() > max * max then
    v:setMag(max)
  end
  return v
end


function Vec2.limited(v, max)
  return v:clone():limit(max)
end


function Vec2.rotate(v, rad)
    local c, s = cos(rad), sin(rad)
    return new(c * v.x - s * v.y,
               s * v.x + c * v.y
    )
end


function Vec2:rotateMe(rad)
    local c, s = cos(rad), sin(rad)
    self.x = c * self.x - s * self.y
    self.y = s * self.x + c * self.y
    return self
end


function Vec2.rotateAround(v, pivot, rad)
  return (v - pivot):rotate(rad) + pivot
end

function Vec2.rot2(p, o, r)
  local dir = p - o
  dir = dir:rotate(r)
  return dir + o
end

function Vec2.perpendicular(v)
    return new(-v.y, v.x)
end


function Vec2.angleTo(a, b)
    if b then
      return atan2(a.y - b.y, a.x - b.x)
    end
    return atan2(a.y, a.x)
end


function Vec2.project(a, b)
  local den = b:dot(b)
  return b * (a:dot(b)/den)
end


function Vec2.floor(v)
  return new(floor(v.x), floor(v.y))
end


function Vec2.toString(v)
    return '(' .. v.x ..', ' .. v.y .. ')'
end


Vec2_mt.__index = Vec2
Vec2_mt.__tostring = Vec2.toString

Vec2_mt.__call = function(_, x, y)
    return Vec2.new(x, y)
end

Vec2_mt.__add = function(a, b)
  assert(Vec2.isVector(a))
  assert(Vec2.isVector(b))
  return a:add(b)
end

Vec2_mt.__sub = function(a, b)
  assert(Vec2.isVector(a))
  assert(Vec2.isVector(b))
  return a:sub(b)
end

Vec2_mt.__mul = function(a, b)
    if Vec2.isVector(b) then
        return a:mul(b)
    end
    return a:scale(b)
end

Vec2_mt.__div = function(a, b)
    if Vec2.isVector(b) then
        return a:div(b)
    end
    return a:scale(1/b)
end

Vec2_mt.__eq = function(a,b)
  if not Vec2.isVector(a) or not Vec2.isVector(b) then
    return false
  end
  return a.x == b.x and a.y == b.y
end


if ffi then
  ffi.metatype(new, Vec2_mt)
end

return setmetatable({}, Vec2_mt)
