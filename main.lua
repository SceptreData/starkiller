-- Starkiller
-- The space combat action game
-- David Bergeron 2017
love.filesystem.setRequirePath('?.lua;src/?.lua;')

-- 3rd party libraries
Anim8    = require 'lib.anim8'
Class    = require 'lib.middleclass'
Behavior = require 'lib.behavior'
Bump     = require 'lib.bump'
Timer    = require 'lib.timer'

-- Global Starkiller modules
Atlas = require 'atlas'
BSP = require 'bsp'
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

local SCREEN_W = 1024
local SCREEN_H = 768

local CELL_SIZE = 32


-- Globals (GASP)
Game   = {}

local player, foe
local map

local game_w = 1000
local game_h = 1000

--BSP STUFF
local MAP_SIZE = 50
local SQUARE = 1024 / MAP_SIZE
local N_ITER = 4


DEBUG_MODE     = false
SOUND_ENABLED  = false
DRAW_BSP       = false

local bsp, bspTree

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
  map = Map:new(camera, game_w, game_h)
  map:setup()
  
  player = Hero:new(SCREEN_W/2, SCREEN_H/2)
  Game.player = player
  foe = Enemy:new(player.pos.x, player.pos.y - 300)

  map:spawnRandomEnemy(5)

  bsp = BSP.new(N_ITER, 0, 0, 1024, 768)
  BSP.buildRooms(bsp)
end


function love.update(dt)
  -- Update all objects on our map
  map:update(dt)

  -- Centre camera on player, update camera
  local mouse_pos = Vec2(love.mouse.getPosition())
  local cam_pos = mouse_pos:midpoint(player:getCentre())
  Game.camera:set(cam_pos.x, cam_pos.y)
  Game.camera:update(dt)
end


function love.draw()
  lg.setColor(255, 255, 255, 255)
  lg.clear(113, 102, 117) -- RUM GREY

  if DRAW_BSP then
    BSP.drawPaths(bsp)
    BSP.drawTree(bsp)
  end

  -- Draw our whole map
  Game.camera:draw(function(x, y, w, h)
    map:draw(x, y, w, h)
  end)

  printFPS()
end


function love.mousepressed(x, y, button)
  if button == 1 then
    local tx, ty = Game.camera:toWorld(x, y)
    player:fireWeapon(tx, ty)
  end
end


function love.keypressed(key)
  if key == 'escape' then
    love.event.quit()
  end
  
  if key == 'f5' then
    SOUND_ENABLED = not SOUND_ENABLED
  elseif key == 'f6' then
    DRAW_BSP = not DRAW_BSP
  elseif key == 'f7' then
    DEBUG_MODE = not DEBUG_MODE
  elseif key == 'f2' then
    map:spawnRandomEnemy()
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

  -- Screen defaults
  lg.setBackgroundColor(255, 255, 255)
  lg.clear()
end


function printFPS()
  lg.setColor(255, 255, 255, 255)
  lg.print('FPS: '..tostring(love.timer.getFPS()), 10, 10)
end
