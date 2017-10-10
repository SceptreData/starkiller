-- Starkiller
-- projectile.lua
-- Base projectile class, handles collisions and distributes death!
local util = require 'util'
local Entity = require 'entity'

local rand = math.random
local floor = math.floor

local Projectile = Class('Projectile', Entity)

local BULLET_SIZE = 26
local BULLET_SPEED = 600
local b_quad = nil
local impact_anim = nil

local function adjustForAccuracy(target, acc)
  return Vec2(
    floor(rand(target.x * acc, target.x * (1 + (1 - acc)))),
    floor(rand(target.y * acc, target.y * (1 + (1 - acc))))
  )
end

function Projectile:initialize(parent, origin, target, accuracy)
  local pos_mod = BULLET_SIZE * 0.5
    Entity.initialize(self, origin.x - pos_mod, origin.y - pos_mod, BULLET_SIZE, BULLET_SIZE)
  self.parent = parent

  self.img  = Atlas.img.bullet
  if not bullet_quad then
    b_quad = love.graphics.newQuad(128, 0, 32, 32, self.img:getDimensions())
    self.impact_img = Atlas:getImg('bulletE')
    impact_anim = Atlas:getAnim('bullet', 'impact')
  end

  local accuracy = accuracy or 1
  local target = adjustForAccuracy(target, accuracy)

  self.oriVec = (target - origin):normalize()

  self.vel = (target - origin):normalize() * BULLET_SPEED
  self.ori = origin:angleTo(target)

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

  if not self.isAnim and self.isDead then
    self:remove()
    return
  end

  if self.isAnim then
    if self.impact_anim.position == 3 then
      self.isAnim = false
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
    if col.other ~= self.parent then
      if col.other.isEnemy then
        col.other:takeDamage(1)
      elseif col.other.isWall then
        self.impact_anim = impact_anim:clone()
        self.impact_anim:gotoFrame(1)
        self.isAnim = true
        self.oriVec = self.oriVec * Vec2(math.abs(col.normal.x), math.abs(col.normal.y))
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

  love.graphics.setColor(255, 255, 255, 255)
  local centre = self:getCentre()
  if not self.isAnim  and not self.isDead then
    love.graphics.draw(self.img, b_quad, centre.x, centre.y, self.ori, 1, 1, 16, 16)
  else
    if self.isAnim then
      local r = math.atan2(self.oriVec.y, self.oriVec.x)
      self.impact_anim:draw(self.impact_img, centre.x, centre.y, r, 1, 1, 16, 16)
    end
  end
end

return Projectile
