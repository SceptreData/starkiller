local Entity      = require 'entity'
local Projectile  = require 'projectile'
local util        = require 'util'

local PlayerWeapon = Class('PlayerWeapon', Entity)

local weapon_list = {
  pistol = {
    projectile = 'bullet',
    base_damage = 2,
    base_accuracy = 0.95,
    clip_size = 12,
    reload_time = 1.0,
    bullet_speed = 600,
    bullet_size = 26,

    img = 'blaster'
    snd = 'pistol_snd'
    flash_img = Game.flash

  }
}

function PlayerWeapon:initialize()
end
