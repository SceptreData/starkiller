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

-- System Information
local OPERATING_SYSTEM = nil

-- Program State Globals
DEBUG_MODE     = false
SOUND_ENABLED  = false

-- Options for gif recording
local AUTO_BUILD_GIF = true
local RECORD_FPS = 30


-- Game Defaults
local game_w = 1024
local game_h = 1024

local CELL_SIZE = 32
local MAX_CAM_SHAKE = 5
local SHAKE_FADE = 6

-- Global Game Table
Game   = {
  kills = 0,
  level = 1
}

local map
local font

function love.load()
  lg.setDefaultFilter('nearest', 'nearest')
  love.math.setRandomSeed(1234567)--os.time())
--  love.math.setRandomSeed(os.time()) 
  Atlas:loadAssets()
  initWindow()

  -- Init Camera
  Game.camera = CloverCam(0, 0, game_w, game_h, MAX_CAM_SHAKE, SHAKE_FADE)
  --Game.camera:setScale(2)

  -- Init Game World
  Game.world = Bump.newWorld(CELL_SIZE)
  map = Map:new(Game.camera, game_w, game_h)
  map:setup()
  
  
  Game.player = Hero:new(game_w/2, game_h/2)
  --Enemy:new('xeno', Game.player.pos.x, Game.player.pos.y - 300)

  Game.camera:set(Game.player.pos.x, Game.player.pos.y)
  map:spawnRandomEnemy(10)
end


function love.update(dt)
  -- Centre camera on player, update camera
  local mx, my = Game.camera:toWorld(love.mouse.getPosition())
  local cam_pos = Vec2(mx, my):midpoint(Game.player:getCentre())
  Game.camera:set(cam_pos.x, cam_pos.y)
  Game.camera:update(dt)

  -- Update all objects on our map
  map:update(dt)
 end


function love.draw()
  lg.setColor(255, 255, 255, 255)

  -- Draw everything inside our map.
  Game.camera:draw(function(x, y, w, h)
    map:draw(x, y, w, h)
  end)

  if DEBUG_MODE then
    printDebug()
  end

  printFPS()
  printConsole()
end


function love.mousepressed(x, y, button)
  if button == 1 then
    Game.player:fireWeapon(Game.camera:toWorld(x, y))
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
  elseif key == 'f11' then
    RECORDING = not RECORDING
    Game.camera:toggleRecord(RECORD_FPS)
  elseif key == 'f12' then
    lg.newScreenshot():encode('png', 'screenshots/' .. os.time() .. '.png')
    end
end

function love.quit()
  -- Process all of our recorded screenshot frames.
  if Game.camera.frames_recorded > 0 then
    Game.camera:processFrames()

    if OPERATING_SYSTEM == 'Windows' and AUTO_BUILD_GIF == true then
      os.execute(fs.getSaveDirectory() .. '/makeGif.bat')
    end
  end
end

function initWindow()
  -- Load window Defaults
  love.window.setTitle('Starkiller')
  fs.setIdentity('Starkiller')

  OPERATING_SYSTEM = love.system.getOS()
  fs.createDirectory('screenshots')
  fs.createDirectory('frames')

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
  font = lg.newFont(18)
  lg.setFont(font)
end

CONSOLE_BUFFER = ''
function printConsole()
  lg.setColor(0, 255, 0, 255)
  love.graphics.print(CONSOLE_BUFFER, 10, 50)
end


function setConsole(str)
  CONSOLE_BUFFER = str
end

function printFPS()
  lg.setColor(0, 255, 0, 255)
  lg.print('FPS: '..tostring(love.timer.getFPS()), 10, 10)
end

function printDebug()
  lg.setColor(0, 255, 0, 255)
  local tx, ty = Game.camera:toWorld(love.mouse.getPosition())
  lg.print(string.format('Tile: %d, %d', tx / 32 + 1, ty / 32 + 1), 10, 30)
end
