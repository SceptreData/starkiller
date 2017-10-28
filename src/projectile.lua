-- Starkiller
-- projectile.lua
-- Base projectile class, handles collisions and distributes death!
local util = require 'util'
local Entity = require 'entity'

local rand, floor, atan2, abs = util.rand, math.floor, math.atan2, math.abs

local Projectile = Class('Projectile', Entity)

local BULLET_SIZE = 26
local BULLET_SPEED = 600
local BULLET_POWER = 3

local b_sprite= nil
local impact_anim = nil


local function adjustForAccuracy(ori, acc)
  local a = math.rad((100 - (100 * acc)))
  local r = math.atan2(ori.y, ori.x)
  r = rand(r - a, r + a)
  return Vec2(math.cos(r), math.sin(r))
end

function Projectile:initialize(parent, origin, target, accuracy)
  local pos_mod = BULLET_SIZE * 0.5
  Entity.initialize(self, origin.x - pos_mod, origin.y - pos_mod, BULLET_SIZE, BULLET_SIZE)
  self.parent = parent

  self.img  = Atlas:getImg('bullet')
  if not b_sprite then
    b_sprite = Atlas:getSprite('bullet', 'model')
    impact_anim = Atlas:getAnim('bullet', 'impact')
  end

  local accuracy = accuracy or 1

  local dir = (target - origin):normalize()
  self.ori = adjustForAccuracy(dir, accuracy)

  self.vel = self.ori * BULLET_SPEED
  self.rot = origin:angleTo(target)

  self.isDead = false
  self.lifetime = 0
  self.isBullet = true
end


function bulletFilter(bullet, other)
  if other == bullet.parent or other.isBullet then return nil
  else
    return 'slide'
  end
end

function Projectile:update(dt)

  if not self.isAnimating and self.isDead then
    self:remove()
    return
  end

  if self.isAnimating then
    if self.impact_anim.position == 5 then
      self.isAnimating = false
      self:remove()
      return
    end
    
    self.impact_anim:update(dt)
  end

  self.lifetime = self.lifetime + dt
  local dest = self.pos + self.vel * dt
  local x, y, cols, n_cols = Game.world:move(self, dest.x, dest.y, bulletFilter)

  for i=1, n_cols do
    local col = cols[i]
    local other = col.other
    if other ~= self.parent then
      if other.isEnemy then
        other:takeDamage(1)
        self:knockback(other)
        love.timer.sleep(0.02)
      elseif col.other.isWall then
        self.impact_anim = impact_anim:clone()
        self.isAnimating = true
        self.ori = self.ori * Vec2(abs(col.normal.x), abs(col.normal.y))
      end
      self.isDead = true
      self.vel = Vec2(0,0)
    end
  end

  self.pos = Vec2(x, y)
end


function Projectile:draw()
  if DEBUG_MODE then
    util.hollowRect({255, 0, 0}, self.pos.x, self.pos.y, self.w, self.h)
  end

  local centre = self:getCentre()
  local r = atan2(self.ori.y, self.ori.x)

  love.graphics.setColor(255, 255, 255, 255)
  if not self.isAnimating  and not self.isDead then
    love.graphics.draw(self.img, b_sprite.quad, centre.x, centre.y, r, 1, 1, 16, 16)
  else
    if self.isAnimating then
      self.impact_anim:draw(self.img, centre.x, centre.y, r, 1, 1, 16, 16)
    end
  end
end

function Projectile:knockback(other)
  other.stunLock = true
  other.vel = self.ori * BULLET_POWER
end

return Projectile
