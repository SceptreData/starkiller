local Entity = require 'entity'

local Projectile = Class('Projectile', Entity)

local BULLET_SIZE = 32
local BULLET_SPEED = 500

local bullet_img = love.graphics.newImage('img/bullet.png')

function Projectile:initialize(parent, origin, target)
  Entity.initialize(self, origin.x, origin.y, BULLET_SIZE, BULLET_SIZE)
  self.parent = parent
  self.vel = (target - origin):normalize() * BULLET_SPEED
  self.lifetime = 0
  self.isBullet = true
  table.insert(Game.bullets, self)
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
      self:remove()
      return true
    end
  end

  self.pos = Vec2(x, y)
end


function Projectile:draw()
  love.graphics.setColor(255, 255, 255, 255)
  local x, y = self.pos.x, self.pos.y
  local centre = self:getCentre()
  --love.graphics.draw(bullet_img, centre.x, centre.y, 0, 1, 1, 16, 16)
  love.graphics.draw(bullet_img, x, y, 0, 1, 1, 16, 16)
end

return Projectile
