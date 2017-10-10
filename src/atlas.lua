-- Starkiller
-- atlas.lua
-- Asset management singleton
-- Where we handle all the loading and parsing of assets and data.
local Animations = require 'data.animations'
local util = require 'util'

local fs = love.filesystem
local lg = love.graphics
local ls = love.sound

local t_insert = table.insert

local Atlas = {}
Atlas.__index = Atlas

local IMG_PATH   = 'img/'
local SND_PATH   = 'snd/'
local DATA_PATH  = 'data/'

Atlas.img = {}
Atlas.snd = {}
Atlas.anim = {}
Atlas.sprite = {}
Atlas.quads = {}

Atlas.tile = {}

Atlas.data = {}


local function isImage(ftype) return ftype == 'png' end
local function isSound(ftype) return ftype == 'wav' or ftype == 'mp3' end

-- Load all the things
function Atlas:loadAssets()
  Atlas:loadImageFiles()
  Atlas:loadSoundFiles()
  Atlas:loadAnimations()

  Atlas:loadSprites()
  Atlas:loadTiles()
end


local function loadImage(file)
  return lg.newImage(IMG_PATH .. file)
end

local function loadSound(file)
  return ls.newSoundData(SND_PATH .. file)
end

local function loadData(file)
  return fs.load(DATA_PATH .. file)()
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


function Atlas:loadData(file, id)
  local data, id = loadData(file)

  Atlas.data[id] = data
  return data
end

function Atlas:freeData(id)
  Atlas.data[id] = nil
end

local function getSpriteGrid(img, spr_w,  spr_h)
  local w, h = img:getDimensions()
  local sw, sh = spr_w or 32, spr_h or 32
  return Anim8.newGrid(sw, sh, w, h)
end

local function buildAnim(img, frames, dur, sw, sh, onLoop)
  local grid = getSpriteGrid(img, sw, sh)
  return Anim8.newAnimation(grid(unpack(frames)), dur, onLoop)
end


function Atlas:newAnimation(ent_id, anim_id, info)
  local img = Atlas:get('img', info.img)
  return buildAnim(img, info.frames, info.dur, info.sw, info.sh, info.onLoop)
end


function Atlas:loadAnimations()
  local animations = loadData('animations.lua')
  animations.DATA_ID = nil
  for ent_id, ent_anims in pairs(animations) do
    anim_t = {}
    for anim_id, data in pairs(ent_anims) do
      anim_t[anim_id] = Atlas:newAnimation(ent_id, anim_id, data)
    end
    Atlas.anim[ent_id] = anim_t
  end
end

local function getSpriteQuad(grid, frame)
  assert(#frame == 2)
  return grid(unpack(frame))[1]
end

function Atlas:addSpriteGroup(name, sprites)
  assert(type(name) == 'string')
  Atlas.sprite[name] = sprites
end

function Atlas:loadSprites()
  local sprite_data = loadData('sprites.lua')

  for group_name, sprite_sheet in pairs(sprite_data) do
    local img = Atlas:getImg(sprite_sheet.img)
    local sprite_w, sprite_h = sprite_sheet.sw, sprite_sheet.sh
    local grid = getSpriteGrid(img, sprite_w, sprite_h)

    local sprite_t ={}
    for sprite_id, frame in pairs(sprite_sheet.sprites) do
      sprite_t[sprite_id] = {
        img = img,
        sw = sprite_w,
        sh = sprite_h,
        quad = getSpriteQuad(grid, frame)
      }
    end

    Atlas:addSpriteGroup(group_name, sprite_t)
  end
end


function Atlas:addTileGroup(name, tiles)
  assert(type(name) == 'string')
  Atlas.tile[name] = tiles
end

 
function Atlas:loadTiles()
  local tile_data = loadData('tiles.lua')
  for group_id, tiles in pairs(tile_data) do
    tgroup = {}
    local img = Atlas.img[tiles.img]
    local grid = getSpriteGrid(img, tiles.sw, tiles.sh)

    for i=1, #tiles do
      local new_tile = {
        img = img,
        id = tiles[i].id,
        sprite = grid(unpack(tiles[i].frames)),
        isWalkable = tiles[i].walkable,
      }
      t_insert(tgroup, new_tile)
    end
    tgroup.kmap = util.mapKeys(tgroup, 'id')
    Atlas:addTileGroup(group_id, tgroup)
  end
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


function Atlas:getSound(id)
  local snd = Atlas.snd[id]
  assert(snd)
  return snd
end


function Atlas:getImg(id)
  return Atlas.img[id]
end


function Atlas:getSprite(group, id)
  return Atlas.sprite[group][id]
end


function Atlas:getSpriteGroup(name)
  return Atlas.sprite[name]
end

return Atlas
