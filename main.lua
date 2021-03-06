-- Starkiller
-- The space combat action game
-- David Bergeron 2017
love.filesystem.setRequirePath('?.lua;src/?.lua;')

-- 3rd party libraries
Anim8    = require 'lib.anim8'
Class    = require 'lib.middleclass'
Bump     = require 'lib.bump'

-- Global Starkiller modules
-- The Atlas is where I store all my assets and data.
Atlas = require 'atlas'
CloverCam = require 'clovercam'
Vec2  = require 'vec2'

-- Non-Global Modules
local Enemy  = require 'enemy'
local Hero   = require 'hero'
local Map    = require 'map'
local util   = require 'util'

local fs = love.filesystem
local lg = love.graphics

local IMG_PATH = 'img/'
local SND_PATH = 'snd/'

local CELL_SIZE = 32


-- Globals (GASP)
Game   = {}


local game_w = 1024
local game_h = 1024

DEBUG_MODE     = false
SOUND_ENABLED  = false

local map

function love.load()
  lg.setDefaultFilter('nearest', 'nearest')
  --love.math.setRandomSeed(os.time())
  
  Atlas:loadAssets()
  initWindow()

  -- Init Camera
  Game.camera = CloverCam(0, 0, game_w, game_h, 5)
  Game.camera:setScale(2)

  -- Init Game World
  Game.world = Bump.newWorld(CELL_SIZE)
  map = Map:new(Game.camera, game_w, game_h)
  map:setup()
  
  
  Game.player = Hero:new(game_w/2, game_h/2)
  Enemy:new(Game.player.pos.x, Game.player.pos.y - 300)

  Game.camera:set(Game.player.pos.x, Game.player.pos.y)
  map:spawnRandomEnemy(5)
end


function love.update(dt)
  -- Update all objects on our map
  map:update(dt)

  -- Centre camera on player, update camera
  local mx, my = Game.camera:toWorld(love.mouse.getPosition())
  local cam_pos = Vec2(mx, my):midpoint(Game.player:getCentre())
  Game.camera:set(cam_pos.x, cam_pos.y)
  Game.camera:update(dt)
end


function love.draw()
  lg.setColor(255, 255, 255, 255)

  -- Draw everything inside our map.
  Game.camera:draw(function(x, y, w, h)
    map:draw(x, y, w, h)
  end)

  printFPS()
end


function love.mousepressed(x, y, button)
  if button == 1 then
    local tx, ty = Game.camera:toWorld(x, y)
    Game.player:fireWeapon(tx, ty)
  end
end


function love.keypressed(key)
  if key == 'escape' then
    love.event.quit()
  end
  
  if key == 'f2' then
    map:spawnRandomEnemy()
  elseif key == 'f3' then
    Game.camera:setScale(2)
  elseif key == 'f4' then
    Game.camera:setScale(1)
  elseif key == 'f5' then
    SOUND_ENABLED = not SOUND_ENABLED
  elseif key == 'f7' then
    DEBUG_MODE = not DEBUG_MODE
    end
end


function initWindow()
  -- Load window Defaults
  love.window.setTitle('Starkiller')
  fs.setIdentity('Starkiller')

  -- Set Icon
  local icon_img = Atlas.img.icon
  love.window.setIcon(icon_img:getData())
 
  -- Set Cursor
  local cursor_img = Atlas:get('img', 'cursor')
  local cursor     = love.mouse.newCursor(cursor_img:getData(), 15, 15)
  love.mouse.setCursor(cursor)

  love.mouse.setGrabbed(true)
  love.mouse.setPosition(love.graphics.getWidth() * 0.5, love.graphics.getHeight() * 0.5)

  -- Screen defaults
  lg.setBackgroundColor(255, 255, 255)
  lg.clear()
end


function printFPS()
  lg.setColor(255, 255, 255, 255)
  lg.print('FPS: '..tostring(love.timer.getFPS()), 10, 10)
end
