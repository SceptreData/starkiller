-- Starkiller
-- playerWeapon.lua
-- This is where we handle drawing and orienting the players different weapons.
local Entity      = require 'entity'
local Projectile  = require 'projectile'
local util        = require 'util'

local atan2 = math.atan2
local playSound = love.audio.newSource


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
    --flash_img = Game.flash
  }
}


function PlayerWeapon:initialize(gun_id, parent)
  local gun = weapon_list[gun_id]
  assert(gun)

  self.id = gun_id
  self.isWeapon = true
  self.parent = parent

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

  local sprites = Atlas:getSpriteGroup(gun_id)
  self.img = sprites.weapon.img
  self.gun_sprite = sprites.weapon.quad
  

  if gun.ejects_shells then
    self.shell_sprite = sprites.shell.quad
  elseif gun.drops_clip then
    self.clip_sprite = sprites.clip.quad
  end

  self.sound = Atlas:getSound(gun.snd)
  
  return self
end


function  PlayerWeapon:update()
  local default = self.parent:getCentre() + self.offset

  local ori = self.parent:getOrientation()
  self.flip = ori.x > 0 and 1 or -1
  self.rot = atan2(ori.y, ori.x)
  self.pos = default:rotateAround(self.parent:getAnchor() , self.rot)
end


function PlayerWeapon:draw()
  love.graphics.setColor(255, 255, 255, 255)
  love.graphics.draw(self.img, self.gun_sprite, self.pos.x, self.pos.y, self.rot, 1, self.flip, 4, 8)
  if DEBUG_MODE then
    util.drawRect({0,0, 255}, self.pos.x + 10 * math.cos(self.rot), self.pos.y + 10 * math.sin(self.rot),  16, 16)
  end
end


function PlayerWeapon:fireAt(target)

   gun_offset = Vec2(self.pos.x + 10 * math.cos(self.rot),
                     self.pos.y + 10 * math.sin(self.rot)
                    )
  -- local centre = self.parent:getCentre()
  -- gun_offset = Vec2(centre.x - 8 * math.cos(self.rot),
  --                   centre.y - 8 * math.sin(self.rot))
  --
  --local gun_offset = self.parent:getCentre()

  print(gun_offset)
  Projectile:new(self.parent, gun_offset, target, self.accuracy)
  if SOUND_ENABLED then
    playSound(self.sound)
  end
end


function PlayerWeapon:getCentre()
  return Vec2(self.pos.x + self.w * 0.5, self.pos.y + self.h * 0.5)
end


return PlayerWeapon
