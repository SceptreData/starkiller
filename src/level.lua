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

function Level:hollowOut(room)
  self:fill(FLOOR_TILE, room.x, room.y, room.w, room.h)
end


function Level:buildWalls(room)
  local x, y, w, h = room.x, room.y, room.w, room.h

  local walls = {}

  local top = y - 1
  if top < 1 then top = 1 end

  local wx, wy = x - 1, top
  local ww, wh = 0, 1

  for i = x-1, x+w+1 do
    if self.tilemap:get(i, top) ~= FLOOR_TILE then
      self.tilemap:set(WALL_TILE, i, top)
      ww = ww + 1
    else
      if ww > 0 then
        Wall:new(wx, wy, ww, wh, true)
        wx = wx + ww
        ww = 0
      end
    end
  end

  local bot = y + h + 1
  wx, wy = x - 1, bot
  ww, wh = 0, 1
  for i=x-1, x+w+1 do
    if self.tilemap:get(i, y + (h + 1)) ~= FLOOR_TILE then
      self.tilemap:set(WALL_TILE, i, bot)
      ww = ww + 1
    else
      if ww > 0 then
        Wall:new(wx, wy, ww, wh, true)
        wx = wx + ww
        ww = 0
      end
    end
  end

  local left = x - 1
  if left < 1 then left = 1 end
  wx, wy = left, y - 1
  ww, wh = 1, 0
  for j=y-1, y+h+1 do
    if self.tilemap:get(left, j) ~= FLOOR_TILE then
      self.tilemap:set(WALL_TILE, left, j)
      wh = wh + 1
    else
      if wh > 0 then
        Wall:new(wx, wy, ww, wh, true)
        wy = wy + wh
        wh = 0
      end
    end
  end

  local right = x + w + 1
  wx, wy = right, y - 1
  ww, wh = 1, 0
  for j=y-1, y+h+1 do
    if self.tilemap:get(right, j) ~= FLOOR_TILE then
      self.tilemap:set(WALL_TILE, right, j)
      wh = wh + 1
    else
      if wh > 0 then
        Wall:new(wx, wy, ww, wh, true)
        wy = wy + wh
        wh = 0
      end
    end
  end
end


function Level:fill(val, x, y, w, h)
  self.tilemap:fillRect(val, x, y, w, h)
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
  self:buildWalls({x=x, y=y, w=w, h=h})
end


local function entIsBlocking(x, y, w, h)
  local ents, num = Game.world:queryRect(x, y, w, h, 
    function(e) 
      return not e.notSolid
    end
  )
  return num > 0
end


function Level:isBlocked(x, y, w, h)
  local w, h = w or 1, h or 1
  return self.tilemap:rectIsBlocked(x, y, w, h) and entIsBlocking(x, y, w, h)
end

return Level
