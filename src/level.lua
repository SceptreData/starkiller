local Block = require 'block'
local Enemy = require 'enemy'
local TileMap = require 'tilemap'
local Wall = require 'wall'
local util = require 'util'

local floor = math.floor

local Level = {}

local VOID_TILE   = 1
local FLOOR_TILE  = 2
local WALL_TILE   = 3

local CELL_SIZE = 32

function Level.new(id, w, h)
  local lvl = setmetatable({}, {__index = Level})
  lvl.id = id
  lvl.w, lvl.h = w, h

  lvl.tilemap = TileMap.new(id, floor(w / CELL_SIZE), floor(h / CELL_SIZE))
  lvl.rooms = {}
  lvl.paths = {}
  lvl.player_start = Vec2(0,0)
  lvl.enemies = {}
  lvl.dead = {}

  return lvl
end


function Level:setPlayerStart(x, y)
  self.player_start = Vec2(x, y)
end


function Level:addEnemy(id, x, y)
  local size = Enemy.getSize(id)
  if not self:isBlocked(x, y, size, size) then
    table.insert(self.enemies, Enemy(id, x, y))
  end
end


function Level:clearDead()
  local alive = {}
  for _, enemy in ipairs(self.enemies) do
    if not enemy:isDead() then
      table.insert(alive, enemy)
    else
      table.insert(self.dead, enemy)
    end
  end
  self.enemies = alive
end
    

function Level:getEnemies(id)
  local foes = {}
  for i=1, #self.enemies do
    if id then
      if self.enemies[i].id == id then
        foes[#foes + 1] = self.enemies[i]
      end
    else
      foes[#foes + 1] = self.enemies[i]
    end
  end
  return foes
end


function Level:fill(val, x, y, w, h)
  self.tilemap:fillRect(val, x, y, w, h)
end


function Level:hollowOut(room)
  if room.x == 1 then room.x = 2 end
  if room.x + room.w > self.tilemap.w then
    room.w = self.tilemap.w - room.x end
  if room.y == 1 then room.y = 2 end
  if room.y + room.h > self.tilemap.h then 
    room.h = self.tilemap.h - room.y
  end

  self:fill(FLOOR_TILE, room.x, room.y, room.w, room.h)
end


function Level:buildPath(x0, y0, x1, y1)
  self.tilemap:line(FLOOR_TILE, x0, y0, x1, y1)
end


function Level:pathRect(x0, y0, x1, y1, pathw)
  local pathw = pathw or 1
  local x, y, w, h

  -- Determine coordinates of top left corner
  if x0 < x1 then
    x, w = x0, x1 -x0
  else
    x, w = x1, x0 - x1
  end

  if y0 < y1 then
    y, h = y0, y1 - y0
  else
    y, h = y1, y0-y1
  end

  if w == 0 then
    w = w + pathw
  else
    h = h+pathw
  end
  self:fill(FLOOR_TILE, x, y, w, h)
  return {x=x,y=y,w=w,h=h}
  --self:buildWalls({x=x, y=y, w=w, h=h})
end


local function entIsBlocking(x, y, w, h)
  local ents, num = Game.world:queryRect(x, y, w, h, 
    function(e) 
      return not e.notSolid
    end)
  return num > 0
end


function Level:getTile(x, y)
  return self.tilemap:get(x,y)
end


function Level:isBlocked(x, y, w, h)
  local w, h = w or 1, h or 1
  return self.tilemap:rectIsBlocked(x, y, w, h) and entIsBlocking(x, y, w, h)
end


local function new_wall(id, x, y, w, h)
  return  { id=id, x=x, y=y, w=w, h=h}
end


function Level:buildWalls(room)
  local x, y, w, h = room.x - 1, room.y - 1, room.w + 2, room.h + 2

  local changedHeight = false
  if x + w > self.tilemap.w then w = self.tilemap.w - x 
  end
  if y + h > self.tilemap.h then
    y = y + 1
    h = self.tilemap.h - y
    changedHeight = true
  end

  local wall_t = {}
  --assert(y > 0 and x > 0 and x + w <= self.tilemap.w and y + h <= self.tilemap.h,
  --string.format('%d, %d, %d, %d', x, y, x + w, y + h))

  local top = new_wall('top', x, y, 0, 1)

  local i = x
  while i <= x + w do
    if self:getTile(i, y) ~= FLOOR_TILE then
      self.tilemap:set(WALL_TILE, i, y)
      top.w = top.w + 1
    else
      if top.w == 0 then
        top.x = i + 1
      elseif top.w > 0 then
        table.insert(wall_t, top)
        top = new_wall('top', i, y, 0, 1)
      end
    end
    i = i + 1
  end

  if top.w > 0 then
    table.insert(wall_t, top)
  end

  local bot= new_wall('bot_start', x, y + h, 0, 1)
  i = x
  while i <= x + w do
    if self:getTile(i, y + h) ~= FLOOR_TILE then
      self.tilemap:set(WALL_TILE, i, y + h)
      bot.w = bot.w + 1
    else
      if bot.w > 0 then
        table.insert(wall_t, bot)
        bot = new_wall('bot_in', i, y + h, 0, 1)
      else
        bot.x = i + 1
      end
    end
    i = i + 1
  end

  if bot.w > 0 then
    bot.id = 'bot_remain'
    --bot.x = bot.x + 1
    table.insert(wall_t, bot)
  end

  local left = new_wall('left', x, y, 1, 0)
  local j = y + 1
  while j <= y + h do
    if self:getTile(x, j) ~= FLOOR_TILE then
      self.tilemap:set(WALL_TILE, x, j)
      left.h = left.h + 1
    else
      if left.h > 0 then
        left.y = left.y + 1
        table.insert(wall_t, left)
        left = new_wall('left_early',x, j, 1, 0)
      else
        left.y = j + 1
      end
    end
    j = j + 1
  end

  if left.h > 0 then
    --left.y = left.y + 1
    left.id = 'left_late'
    table.insert(wall_t, left)
  end

  local right = new_wall('right', x + w, y, 1, 0)
  j = y + 1
  while j <= y + h  do
    if self:getTile(x + w, j) ~= FLOOR_TILE then
      self.tilemap:set(WALL_TILE, x+w, j)
      right.h = right.h + 1
    else
      if right.h > 0 then
        right.y = right.y + 1
        table.insert(wall_t, right)
        right = new_wall('right_early', x+w, j, 1, 0)
      else
        right.y = j + 1
      end
    end
    j = j + 1
  end

  if right.h > 0 then
    right.id = 'right_late'
    if changedHeight then right.y = right.y + 1 end
    --right.y = right.y + 1
    table.insert(wall_t, right)
  end

  return wall_t
end

local function buildBoundaries(w, h, size)
  Wall:new(0, 0, w, size)
  Wall:new(0, size, size, h - size * 2)
  Wall:new(w - size, size, size, h - size * 2)
  Wall:new(0, h- size, w, size)
end

function Level:wallOff()
  for i=1, self.tilemap.w do self.tilemap:set(WALL_TILE, i, 1) end
  for i=1, self.tilemap.w do self.tilemap:set(WALL_TILE, i, self.tilemap.h) end
  for j=2, self.tilemap.h - 1 do self.tilemap:set(WALL_TILE, 1, j) end
  for j=2, self.tilemap.h - 1 do self.tilemap:set(WALL_TILE, self.tilemap.w, j) end

  buildBoundaries(self.tilemap.w * 32, self.tilemap.h * 32, 32)
end

return Level
