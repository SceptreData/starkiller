-- Starkiller
-- playerWeapon.lua
-- This is where we handle drawing and orienting the players different weapons.
local Entity      = require 'entity'
local Projectile  = require 'projectile'
local util        = require 'util'

local atan2, cos, sin = math.atan2, math.cos, math.sin
local playSound = love.audio.newSource
local lg = love.graphics


local PlayerWeapon = Class('PlayerWeapon')


local weapon_list = {
  blaster = {
    projectile = 'bullet',
    damage = 2,
    accuracy = 0.95,
    clip_size = 12,
    max_ammo = 255,
    reload_time = 1.0,
    bullet_speed = 600,
    bullet_size = 26,
    
    width = 16,
    height = 16,

    ejects_shells = true,
    drops_clip = true,

    snd = 'pistol_snd',
    flash_anim = 'flash'
  }
}


function PlayerWeapon:initialize(gun_id, parent)
  local gun = weapon_list[gun_id]
  assert(gun)

  self.id = gun_id
  self.isWeapon = true
  self.parent = parent

  self.kick = Vec2(0,0)
  self.offset = Vec2(4, 6)
  self.pos = parent:getCentre() + self.offset
  self.vel = Vec2(0,0)
  self.rot = 0
  self.flip = 1

  self.w, self.h = gun.width, gun.height

  self.projectile = gun.projectile
  self.dmg = gun.dmg
  self.acc = gun.accuracy
  self.clip_size = gun.clip_size
  self.reload_time = gun.reload_time
  self.accuracy = gun.accuracy

  local sprites = Atlas:getSpriteGroup(gun_id)
  self.img = sprites.weapon.img
  self.gun_sprite = sprites.weapon.quad

  self.flash_img = Atlas:getImg('bullet')
  self.flash_anim = Atlas:getAnim('blaster', 'flash')
  

  if gun.ejects_shells then
    self.shell_sprite = sprites.shell.quad
  elseif gun.drops_clip then
    self.clip_sprite = sprites.clip.quad
  end

  self.sound = Atlas:getSound(gun.snd)
  
  return self
end


function  PlayerWeapon:update(dt)
  local default = self.parent:getCentre() + self.offset

  local ori = self.parent:getOrientation()
  self.flip = ori.x > 0 and 1 or -1
  self.rot = atan2(ori.y, ori.x)
  self.pos = default:rotateAround(self.parent:getAnchor() , self.rot)

  if not self.kick:isZero() then
    self:updateKick(dt)
  end

  if self.isFlashing then
    self.flash_anim:update(dt)
    self.flashOff = self.flashOff + self.parent.vel
    if self.flash_anim.position == 6 then
      self.isFlashing = false
    end
  end
end


function PlayerWeapon:draw()
  lg.setColor(255, 255, 255, 255)
  lg.draw(self.img, self.gun_sprite, self.pos.x - self.kick.x, self.pos.y - self.kick.y, self.rot, 1, self.flip, 4, 8)
  if self.isFlashing then
    self.flash_anim:draw(self.flash_img, self.flashOff.x - self.kick.x, self.flashOff.y - self.kick.y, self.rot, 1, 1, 16, 16)
  end
end


function PlayerWeapon:fireAt(target)
  local c, s = cos(self.rot), sin(self.rot)
  Game.camera:offset(7 * c, 7 * s)
  Game.camera:shake(1)
  love.timer.sleep(0.025)

  self:setKick(c, s, 4)

  local flashAdjust = 25
  self.flashOff = Vec2(self.pos.x + flashAdjust * c, self.pos.y + flashAdjust * s)
  self.flash_anim:gotoFrame(1)
  self.isFlashing = true
 
  if SOUND_ENABLED then
    playSound(self.sound):play()
  end

  bullet_offset = Vec2(self.pos.x + 10 * c, self.pos.y + 10 * s)
  Projectile:new(self.parent, bullet_offset, target, self.accuracy)
  end


function PlayerWeapon:getCentre()
  return Vec2(self.pos.x + self.w * 0.5, self.pos.y + self.h * 0.5)
end

function PlayerWeapon:ejectShell()
  
end

function PlayerWeapon:setKick(c, s, val)
  --self.kick = Vec2(util.round(val * c), util.round(val * s))
  self.kick = Vec2(val * c, val * s)
end

function PlayerWeapon:updateKick(dt)
  local xFlip = util.sign(self.kick.x)
  local yFlip = util.sign(self.kick.y)

  if self.kick.x ~= 0 then
    self.kick.x = self.kick.x - xFlip
  end
  if self.kick.y ~= 0 then
    self.kick.y = self.kick.y - yFlip
  end

  if xFlip < 0 then
    if self.kick.x >= 0 then self.kick.x = 0 end
  else
    if self.kick.x <= 0 then self.kick.x = 0 end
  end

  if yFlip < 0 then
    if self.kick.y >= 0 then self.kick.y = 0 end
  else
    if self.kick.y <= 0 then self.kick.y = 0 end
  end
end

return PlayerWeapon
