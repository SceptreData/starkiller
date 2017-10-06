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

local function adjustForAccuracy(target, acc)
  return Vec2(
    floor(rand(target.x * acc, target.x * (1 + (1 - acc)))),
    floor(rand(target.y * acc, target.y * (1 + (1 - acc))))
  )
end

function Projectile:initialize(parent, origin, target, accuracy)
    Entity.initialize(self, origin.x, origin.y, BULLET_SIZE, BULLET_SIZE)
  self.parent = parent

  self.img  = Atlas.img.bullet_a
  if not bullet_quad then
    b_quad = love.graphics.newQuad(128, 0, 32, 32, self.img:getDimensions())
  end

  local accuracy = accuracy or 1
  local target = adjustForAccuracy(target, accuracy)

  self.vel = (target - origin):normalize() * BULLET_SPEED
  self.ori = origin:angleTo(target)

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
  self.lifetime = self.lifetime + dt
  local dest = self.pos + self.vel * dt
  local x, y, cols, n_cols = Game.world:move(self, dest.x, dest.y, bulletFilter)

  for i=1, n_cols do
    local col = cols[i]
    if col.other ~= self.parent then
      if col.other.isEnemy then
        col.other:takeDamage(1)
      end
      self:remove()
      return true
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
  love.graphics.draw(self.img, b_quad, centre.x, centre.y, self.ori, 1, 1, 16, 16)
end

return Projectile
