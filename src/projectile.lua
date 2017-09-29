local util = require 'util'
local Entity = require 'entity'

local rand = math.random
local floor = math.floor

local Projectile = Class('Projectile', Entity)

local BULLET_SIZE = 26
local BULLET_SPEED = 600


local function adjustForAccuracy(target, acc)
  return Vec2(
    floor(rand(target.x * acc, target.x * (1 + (1 - acc)))),
    floor(rand(target.y * acc, target.y * (1 + (1 - acc))))
  )
end

function Projectile:initialize(parent, origin, target, accuracy)
  Entity.initialize(self, origin.x, origin.y, BULLET_SIZE, BULLET_SIZE)
  self.parent = parent

  self.img  = assets.bullet_a
  self.quad = Game.bullet

  local accuracy = accuracy or 1
  local target = adjustForAccuracy(target, accuracy)
  self.vel = (target - origin):normalize() * BULLET_SPEED

  self.ori = target:angleTo(origin)

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
  local x, y = self.pos.x, self.pos.y
  if DEBUG_MODE then
    util.hollowRect({255, 0, 0}, x, y, self.w, self.h)
  end
  love.graphics.setColor(255, 255, 255, 255)
  local centre = self:getCentre()
  --love.graphics.draw(bullet_img, centre.x, centre.y, 0, 1, 1, 16, 16)
  love.graphics.draw(self.img, self.quad, centre.x, centre.y, self.ori, 1, 1, 16, 16)
end

return Projectile
