local Entity = require 'entity'
local Projectile = require 'projectile'
local util = require 'util'

local Enemy = Class('Enemy', Entity)

local ENEMY_SIZE = 32
local BLUE = {0, 0, 255}

function Enemy:initialize(x, y)
  Entity.initialize(self, x, y, ENEMY_SIZE, ENEMY_SIZE)
  self.isEnemy = true
  self.health = 2
  self.isDead = false
  self.vel = Vec2()
  self.ori = Vec2()
  table.insert(Game.ents, self)
end


local collisionFilter = function(enemy, other)
  if other.parent == enemy then return nil
  else
    return 'slide'
  end
end


function Enemy:takeDamage(dmg)
  self.health = self.health - dmg
  if self.health < 1 then 
    self.isDead = true
  end
end


function Enemy:update(dt)
  if self.health < 1 or self.isDead then
    self:remove()
    return true
  end

  local cols, n_cols
  if not self.vel:isZero() then
    local dest = self.pos + self.vel
    self.pos.x, self.pos.y, cols, n_cols = Game.world:move(self, dest.x, dest.y, collisionFilter)
  end
end


function Enemy:draw()
  local r, g, b = util.getColor(BLUE)
  love.graphics.setColor(r, g, b, 100)
  love.graphics.rectangle('fill', self.pos.x, self.pos.y, self.w, self.h)
  love.graphics.setColor(r, g, b)
  love.graphics.rectangle('line', self.pos.x, self.pos.y, self.w, self.h)
end

return Enemy
