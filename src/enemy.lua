local Entity      = require 'entity'
--local Brain       = require 'brain'
local Projectile  = require 'projectile'
local util        = require 'util'

local Enemy = Class('Enemy', Entity)

local ENEMY_SIZE = 32
local MAX_SPEED = 4
local ACQUIRE_DIST = 300
local ATTACK_RANGE = 200
local ARRIVE_RADIUS = 50
local ENEMY_ACC = 0.95

local BLUE = {0, 0, 255}

local animations_not_loaded = true
local anim = {}

function Enemy:initialize(x, y, id)
  local id = id or 'xeno'
  if animations_not_loaded then
    anim.idle    = Atlas.anim[id].idle:clone()
    anim.running = Atlas.anim[id].running:clone()

    anim.seek = Atlas.anim[id].running:clone()
    anim.fire = Atlas.anim[id].idle:clone()

    animations_not_loaded = false
  end

  Entity.initialize(self, x, y, ENEMY_SIZE, ENEMY_SIZE)
  self.isEnemy = true

  self.img  = Atlas.img[id]
  self.behaviors = {'seek'}

  self.state = 'idle'
  self:setAnim('idle')

  self.canAttack = false

  self.health = 2
  self.isDead = false
  self.attackTimer    = 0
  self.attackCooldown = 2

  self.moveTimer = 0
  self.moveCooldown = 1

  self.max_speed = MAX_SPEED
  self.vel = Vec2()
  self.ori = Vec2()
end


function Enemy:setState(state, animation)
  assert(type(state) == 'string')
  if state ~= self.state then
    self.state = state
    self:setAnim(animation or self.state)
  end
end


function Enemy:setAnim(a)
  self.anim = anim[a]:clone()
end


function Enemy:takeDamage(dmg)
  self.health = self.health - dmg
  if self.health < 1 then 
    self.isDead = true
  end
end


function Enemy:fireAt(target, dt)
  if self.attackTimer == 0 then
    local origin = self:getCentre()
    local b = Projectile:new(self, origin, target:getCentre(), ENEMY_ACC)
    self.attackTimer = self.attackTimer + dt
  else
    if self.attackTimer >= self.attackCooldown then
      self.attackTimer = 0
    else
      self.attackTimer = self.attackTimer + dt
    end
  end
end


function Enemy:canAcquire(target)
  return self.pos:dist2(target.pos) < ACQUIRE_DIST * ACQUIRE_DIST
end

-- Will implement seek for now, ARRIVE is probably what we want
-- TODO: Arrive desired distance from player
function Enemy:seek(pos)
  self.vel = pos - self.pos
  self.vel:setMag(MAX_SPEED)
end


function Enemy:moveToAttackRange(target)
  local dir = target.pos - self.pos
  local dist = dir:len()

  if dist < ATTACK_RANGE then
    self.canAttack = true
    self:setState('fire', 'idle')
  end

  local dest = target.pos - (dir:normalize() * ATTACK_RANGE)
  self:seek(dest)
end

function Enemy:arrive(target)
end

function Enemy:canMove()
  return self.moveTimer <= 0
end

local collisionFilter = function(enemy, other)
  if other.parent == enemy then return nil
  else
    return 'slide'
  end
end


function Enemy:update(dt)
  self.anim:update(dt)

  if self.moveTimer > 0 then
    self.moveTimer = self.moveTimer - dt
  end

  if self.health < 1 or self.isDead then
    self:remove()
    return true
  end

  if self.state == 'idle' and self:canAcquire(Game.player) then
    self.target = Game.player
    self:setState('seek')
    self.moveTimer = self.moveCooldown
  end

  if self.state == 'seek' then
    --self:seek(Game.player)
    self:moveToAttackRange(Game.player)
  end

  if self.state == 'fire' then
    -- Stop moving and shoot
    self.vel = Vec2(0,0)
    self:fireAt(Game.player, dt)

    -- If we the player moves away, chase him!
    if self.pos:dist2(Game.player.pos) > ATTACK_RANGE * ATTACK_RANGE then
      if self:canMove() then
        self:setState('seek')
        self.moveTimer = self.moveCooldown
      end
    end
  end

  local cols, n_cols
  if not self.vel:isZero() then
    local dest = self.pos + self.vel
    self.pos.x, self.pos.y, cols, n_cols = Game.world:move(self, dest.x, dest.y, collisionFilter)
  end
end


function Enemy:draw()
  local x, y = self.pos.x, self.pos.y

  if DEBUG_MODE then
    util.drawRect(BLUE, x, y, self.w, self.h)
  end
  
  love.graphics.setColor(255,255,255,255)
  self.anim:draw(self.img, self.pos.x, self.pos.y)
end

return Enemy
