local Animations = require 'animations'
local util = require 'util'

local fs = love.filesystem
local lg = love.graphics
local ls = love.sound

local Atlas = {}
Atlas.__index = Atlas

local IMG_PATH = 'img/'
local SND_PATH = 'snd/'

Atlas.img = {}
Atlas.snd = {}
Atlas.anim = {}
Atlas.quads = {}


local function isImage(ftype) return ftype == 'png' end
local function isSound(ftype) return ftype == 'wav' or ftype == 'mp3' end


function Atlas:loadAssets()
  Atlas:loadImageFiles()
  Atlas:loadSoundFiles()
  Atlas:loadAnimations()
end


local function loadImage(file)
  return lg.newImage(IMG_PATH .. file)
end

local function loadSound(file)
  return ls.newSoundData(SND_PATH .. file)
end


function Atlas:loadImageFiles()
  local img_files = fs.getDirectoryItems(IMG_PATH)

  for _, file in ipairs(img_files) do
    local name, ftype = util.splitFilename(file)
    if isImage(ftype) then
      Atlas.img[name] = loadImage(file)
    end
  end
end


function Atlas:loadSoundFiles()
  local snd_files = fs.getDirectoryItems(SND_PATH)

  for _, file in ipairs(snd_files) do
    local name, ftype = util.splitFilename(file)
    if isSound(ftype) then
      Atlas.snd[name] = loadSound(file)
    end
  end
end


local function buildAnim(img, frames, dur, sw, sh)
  local w, h = img:getDimensions()
  local sw, sh = spr_w or 32, spr_h or 32
  local g = Anim8.newGrid(sw, sh, w, h)

  return Anim8.newAnimation(g(unpack(frames)), dur)
end

function Atlas:loadAnimations()
  for ent_id, ent_anims in pairs(Animations) do
    anim_t = {}
    for anim_id, data in pairs(ent_anims) do
      anim_t[anim_id] = Atlas:newAnimation(ent_id, anim_id, data)
    end
    Atlas.anim[ent_id] = anim_t
  end
end
  
function Atlas:newAnimation(ent_id, anim_id, info)
  local img = Atlas:get('img', info.img)
  return buildAnim(img, info.frames, info.dur, info.sw, info.sh)
end

function Atlas:getAnim(ent_id, anim)
  assert(Atlas.anim[ent_id], ent_id .. " does not exist")
  return Atlas.anim[ent_id][anim]
end

function Atlas:newQuad(name, x, y, w, h, sw, sh)
  self.quads[name] = lg.newQuad(x, y, w, h, sw, sh)
  return self.quads[name]
end

function Atlas:get(group, id)
  assert(type(group) == 'string' and type(id) == 'string')
  return Atlas[group][id]
end

return Atlas
