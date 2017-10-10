-- Starkiller
-- hero.lua
-- This is where all of my logic related to moving, displaying and
-- pampering the player takes place.
local Entity      = require 'entity'
local PlayerWeapon = require 'playerWeapon'
local Projectile  = require 'projectile'
local util        = require 'util'

local getColor = util.getColor

local Hero = Class('Hero', Entity)


local HERO_SIZE         = 32
local HERO_MAX_SPEED    = 300
local HERO_ACCEL_SPEED  = 100
local HERO_BRAKE_SPEED  = 300
local HERO_COLOR        = {0, 255, 0} -- GREEN

local HERO_ACC          = 0.95

local LINE_SIZE         = HERO_SIZE


local animations_are_loaded = false

local anim = {
}

function Hero:initialize(x, y, char)
  local char = char or 'tom'
  if not animations_are_loaded then
    anim.idle = Atlas:getAnim(char, 'idle')
    anim.running = Atlas:getAnim(char, 'running')
    animations_are_loaded = true
  end

  Entity.initialize(self, x, y, HERO_SIZE, HERO_SIZE)
  self.isHero = true

  self.img  = Atlas.img[char]

  self.state  = 'idle'
  self.anim = anim.idle
  self.flip = false

  self.health = 10
  self.isDead = false

  self.vel    = Vec2(0,0)
  self.ori    = Vec2()
  self.anchor = Vec2(0, 4)

  self.weapon = PlayerWeapon:new('blaster', self)

  Game.player = self
end


function Hero:setState(state)
  if self.state ~= state then
    self.state = state
    self:setAnim(state)
  end
end

function Hero:setAnim(state)
  self.anim = anim[state]:clone()
  if self.flip then self.anim:flipH() end
end


function Hero:fireWeapon(tx, ty)
  self.weapon:fireAt(Vec2(tx, ty))

  Game.camera:shake(0.7)
  love.timer.sleep(0.015)
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


local heroFilter = function(hero, other)
  if other.parent == hero then return nil
  else
    return 'slide'
  end
end


function Hero:update(dt)
  -- Point our gun towards the mouse
  local tx, ty = Game.camera:toWorld(love.mouse.getX(), love.mouse.getY())
  self.target = Vec2(tx, ty)
  
  self.ori = (self.target - self.pos):normalize()
  if self.ori.x > 0 then
    if self.flip == false then
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
  
  -- Get input to move our hero
  -- TODO: Rewrite all this crap so friction works properly.
  self:getVelocityInput(dt)
  self.vel:setMag(HERO_MAX_SPEED * dt)

  local cols, n_cols
  if not self.vel:isZero() then
    self:setState('running')
    local dest = self.pos + self.vel
    self.pos.x, self.pos.y, cols, n_cols = Game.world:move(self, dest.x, dest.y, heroFilter)
  else
    self:setState('idle')
  end

  self.weapon:update()
end


local function drawTargetingLine(x, y, ori)
  love.graphics.setColor(255, 255, 255, 255)

  local dest = Vec2(x, y) + ori * LINE_SIZE
  love.graphics.setLineWidth(2)
  love.graphics.line(x, y, dest.x, dest.y)
  love.graphics.setLineWidth(1)

  love.graphics.line(x, y, dest.x, dest.y)
end


function Hero:getOrientation()
  return (self.target - self:getCentre()):normalize()
end


function Hero:getAnchor()
  return self:getCentre() + self.anchor
end


function Hero:draw()
  -- Draw filled rectangle
  local centre = self:getCentre()

  if DEBUG_MODE then
    local r, g, b = getColor(HERO_COLOR)
    love.graphics.setColor(r, g, b, 100)
    love.graphics.rectangle('fill', self.pos.x, self.pos.y, self.w, self.h)
    love.graphics.setColor(r, g, b)
    love.graphics.rectangle('line', self.pos.x, self.pos.y, self.w, self.h)
    drawTargetingLine(centre.x, centre.y, self.ori)
  end

  love.graphics.setColor(255, 255, 255, 255)
  self.anim:draw(self.img, self.pos.x, self.pos.y)
  
  -- Draw gun sprite
  self.weapon:draw()
end


return Hero
