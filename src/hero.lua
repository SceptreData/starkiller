local Entity      = require 'entity'
local Projectile  = require 'projectile'
local util        = require 'util'

local getColor = util.getColor

local Hero = Class('Hero', Entity)

local HERO_SIZE         = 32
local HERO_MAX_SPEED    = 300
local HERO_ACCEL_SPEED  = 100
local HERO_BRAKE_SPEED  = 300
local HERO_COLOR        = {0, 255, 0} -- GREEN

local LINE_SIZE         = HERO_SIZE



function Hero:initialize(x, y)
  Entity.initialize(self, x, y, HERO_SIZE, HERO_SIZE)
  self.health = 10
  self.isDead = false
  self.vel    = Vec2(0,0)
  self.ori    = Vec2()
end


function Hero:update(dt)
  -- Point our gun towards the mouse
  local mouse_pos =  Vec2(love.mouse.getX(), love.mouse.getY())
  self.ori = (mouse_pos - self.pos):normalize()
  
  -- Get input to move our hero
  -- TODO: Rewrite all this crap so friction works properly.
  self:getVelocityInput(dt)
  self.vel:setMag(HERO_MAX_SPEED * dt)

  local cols, n_cols
  if not self.vel:isZero() then
    dest = self.pos + self.vel
    self.pos.x, self.pos.y, cols, n_cols = Game.world:move(self, dest.x, dest.y)
  end
end


function Hero:fireWeapon(x, y)
  local origin = self:getCentre()
  print(origin)
  local b = Projectile:new(self, self:getCentre(), Vec2(x, y))
  table.insert(Game.bullets, b)
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
  -- Draw filled rectangle
  local r, g, b = getColor(HERO_COLOR)
  love.graphics.setColor(r, g, b, 100)
  love.graphics.rectangle('fill', self.pos.x, self.pos.y, self.w, self.h)
  love.graphics.setColor(r, g, b)
  love.graphics.rectangle('line', self.pos.x, self.pos.y, self.w, self.h)

  -- Draw line towards mouse
  local centre = self:getCentre()
  local line_end = centre + self.ori * LINE_SIZE
  love.graphics.setLineWidth(2)
  love.graphics.line(centre.x, centre.y, line_end.x, line_end.y)
  love.graphics.setLineWidth(1)
end

return Hero
