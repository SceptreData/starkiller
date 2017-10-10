-- Starkiller
-- enemy.lua
-- the file where we build new enemies to fight.
-- Contains all logic related to dudes trying to kill the player.

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
local HIT_DELAY = 0.1

local BLUE = {0, 0, 255}

local animations_not_loaded = true
local anim = {}


function Enemy:initialize(id, x ,y)
  local id = id or 'xeno'
  if animations_not_loaded then
    anim.idle    = Atlas.anim[id].idle:clone()
    anim.idleImpact = Atlas.anim[id].idleImpact:clone()

    anim.running = Atlas.anim[id].running:clone()
    anim.runningImpact = Atlas.anim[id].runningImpact:clone()

    anim.seek = Atlas.anim[id].running:clone()
    anim.fire = Atlas.anim[id].idle:clone()

    animations_not_loaded = false
  end

  Entity.initialize(self, x, y, ENEMY_SIZE, ENEMY_SIZE)
  self.isEnemy = true

  self.img  = Atlas.img[id]
  self.flip = false
  self.behaviors = {'seek'}

  self.state = 'idle'
  self:setAnim('idle')
  self.stunLock = false

  self.canAttack = false

  self.health = 3
  self.attackTimer    = 0
  self.attackCooldown = 2

  self.moveTimer = 0
  self.moveCooldown = 1

  self.hitAnim = false
  self.hitTimer = 0

  self.max_speed = MAX_SPEED
  self.vel = Vec2()
  self.ori = Vec2()
end


function Enemy:setState(state, animation)
  assert(type(state) == 'string')
  if state ~= self.state then
    self.state = state
    if not self.hitAnim then
      self:setAnim(animation or self.state)
    end
  end
end


function Enemy:isDead()
  return self.health < 1
end


function Enemy:setAnim(a)
  self.anim = anim[a]:clone()
  if self.flip == true then self.anim:flipH() end 
end


local collisionFilter = function(enemy, other)
  if other.parent == enemy then return nil
  else
    return 'slide'
  end
end


function Enemy:update(dt)
  if self.hitTimer > 0 then
    self.hitTimer = self.hitTimer - dt
    if self.hitTimer <= 0 then
      self.stunLock = false
      self.vel = Vec2(0,0)
      self.hitAnim = false
      self:setAnim(self.state)
    end
  end

  if self.moveTimer > 0 then
    self.moveTimer = self.moveTimer - dt
  end

  if self:isDead() then
    Game.kills = Game.kills + 1
    self:remove()
    return true
  end
  
  if not self.stunLock then
    if self.state == 'idle' and self:canAcquire(Game.player) then
      if not self.hitAnim then
        self.target = Game.player
        self:setState('seek')
        --self.moveTimer = self.moveCooldown
      end
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
  end

  if self.ori.x > 0 then
    if not self.flip then
      self.anim:flipH()
      self.flip = true
    end
  else
    if self.flip == true then
      self.anim:flipH()
      self.flip = false
    end
  end

  self.anim:update(dt)
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


function Enemy:takeDamage(dmg)
  if self.state == 'idle' or 'fire' then
    self:setAnim('idleImpact')
    self.hitAnim = true
    self.hitTimer = HIT_DELAY
  elseif self.state == 'running' or 'seek' then
    self:setAnim('runningImpact')
    self.hitAnim = true
    self.hitTimer = HIT_DELAY
  end

  self.health = self.health - dmg
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
  self.ori = dir:normalize()
  local dist = dir:len()

  if dist < ATTACK_RANGE then --and self:canMove() then
    self:setState('fire')
    self.moveTimer = self.moveCooldown
  else
    local dest = target.pos - (dir:normalize() * ATTACK_RANGE)
    self:seek(dest)
  end
end

function Enemy:arrive(target)
end

function Enemy:canMove()
  return self.moveTimer <= 0 and not self.hitAnim
end

function Enemy.getSize(id)
  -- return Atlas.aliens[id].size
  return 32
end


return Enemy
