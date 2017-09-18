local Entity  = require 'entity'
local util    = require 'util'

local getColor = util.getColor

local Hero = Class('Hero', Entity)

local HERO_SIZE         = 32
local HERO_MAX_SPEED    = 500
local HERO_ACCEL_SPEED  = 100
local HERO_BRAKE_SPEED  = 500
local HERO_COLOR        = {0, 255, 0} -- GREEN


function Hero:initialize(x, y)
  Entity.initialize(self, x, y, HERO_SIZE, HERO_SIZE)
  self.health = 10
  self.isDead = false
  self.vel    = Vec2(0,0)
  self.ori    = 0
end


function Hero:update(dt)
  self:getVelocityInput(dt)
  self.vel:setMag(HERO_MAX_SPEED * dt)

  local cols, n_cols
  if not self.vel:isZero() then
    dest = self.pos + self.vel
    self.pos.x, self.pos.y, cols, n_cols = Game.world:move(self, dest.x, dest.y)
  end
end


function Hero:getVelocityInput(dt)
  if self.isDead then return end

  local vx, vy = self.vel.x, self.vel.y

  if love.keyboard.isDown('left', 'a') then
    vx = vx - dt * (vx > 0 and HERO_BRAKE_SPEED or HERO_ACCEL_SPEED)
  elseif love.keyboard.isDown('right', 'd') then
    vx = vx + dt * (vx < 0 and HERO_BRAKE_SPEED or HERO_ACCEL_SPEED)
  else
    local h_brake = dt * (vx < 0 and HERO_BRAKE_SPEED or -HERO_BRAKE_SPEED)
    if math.abs(h_brake) > math.abs(vx) then
      vx = 0
    else
      vx = vx + h_brake
    end
  end

  if love.keyboard.isDown('up', 'w') then
    vy = vy - dt * (vy > 0 and HERO_BRAKE_SPEED or HERO_ACCEL_SPEED)
  elseif love.keyboard.isDown('down', 's') then
    vy = vy + dt * (vy < 0 and HERO_BRAKE_SPEED or HERO_ACCEL_SPEED)
  else
    local v_brake = dt * (vy < 0 and HERO_BRAKE_SPEED or -HERO_BRAKE_SPEED)
    if math.abs(v_brake) > math.abs(vy) then
      vy = 0
    else
      vy = vy + v_brake
    end
  end

  self.vel.x, self.vel.y = vx, vy
end

function Hero:draw()
  local r, g, b = getColor(HERO_COLOR)
  love.graphics.setColor(r, g, b, 100)
  love.graphics.rectangle('fill', self.pos.x, self.pos.y, self.w, self.h)
  love.graphics.setColor(r, g, b)
  love.graphics.rectangle('line', self.pos.x, self.pos.y, self.w, self.h)
end

return Hero
