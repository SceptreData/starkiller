-- Starkiller
-- The space combat adventure sim
-- David Bergeron 2017
love.filesystem.setRequirePath('?.lua;src/?.lua;')

-- 3rd party libraries
Anim8    = require 'lib.anim8'
Class    = require 'lib.middleclass'
Behavior = require 'lib.behavior'
Bump     = require 'lib.bump'
--Gamera   = require 'lib.gamera'
--Event  = require 'lib.signal'
Timer    = require 'lib.timer'

-- Global Starkiller modules
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

assets = {}

local SCREEN_W = 1024
local SCREEN_H = 768

local CELL_SIZE = 32

-- Globals (GASP)
Game = {}

local blocks = {}
local player, foe
local camera, map

local game_w, game_h = 1000, 1000

--BSP STUFF
local MAP_SIZE = 50
local SQUARE = 1024 / MAP_SIZE
local N_ITER = 4


DEBUG_MODE = true
SOUND_ENABLED = false

local bsp, bspTree

function love.load()
  lg.setDefaultFilter('nearest', 'nearest')

  loadMedia()
  initWindow()

  --math.randomseed(os.time())

  -- Init Camera
  camera = CloverCam(0, 0, game_w, game_h, 5)
  Game.camera = camera
  --camera:setScale(1.5)

  -- Init Game World
  Game.world = Bump.newWorld(CELL_SIZE)
  map = Map:new(camera, game_w, game_h)
  map:setup()
  
  player = Hero:new(SCREEN_W/2, SCREEN_H/2)
  Game.player = player
  foe = Enemy:new(player.pos.x, player.pos.y - 300)

  bsp = BSP.new(N_ITER, 0, 0, 1024, 768)
  BSP.buildRooms(bsp)
end


function love.update(dt)
  -- Update all objects on our map
  map:update(dt)

  -- Centre camera on player, update camera
  local pos = player:getCentre()
  camera:set(pos.x, pos.y)
  camera:update(dt)
end


function love.draw()
  lg.setColor(255, 255, 255, 255)
  lg.clear(113, 102, 117) -- RUM GREY

  -- Draw our whole map
  camera:draw(function(x, y, w, h)
    map:draw(x, y, w, h)
  end)

  BSP.drawPaths(bsp)
  --BSP.cheatPath(bsp)
  BSP.drawTree(bsp)
  
  lg.setColor(255, 255, 255, 255)
  lg.print('FPS: '..tostring(love.timer.getFPS()), 10, 10)
end


function love.mousepressed(x, y, button)
  if button == 1 then
    local tx, ty = camera:toWorld(x, y)
    player:fireWeapon(tx, ty)
  end
end


function love.keypressed(key)
  if key == 'escape' then
    love.event.quit()
  end
end


function initWindow()
  -- Load window Defaults
  love.window.setTitle('Starkiller')
  fs.setIdentity('Starkiller')

  -- Set Icon
  love.window.setIcon(assets.icon:getData())
 
  -- Set Cursor
  local cursor     = love.mouse.newCursor(assets.cursor:getData(), 15, 15)
  love.mouse.setCursor(cursor)

  -- Screen defaults
  lg.setBackgroundColor(255, 255, 255)
  lg.clear()
end


function buildAnim(asset, row, col, dur)
  local w, h = asset:getDimensions()
  local g = Anim8.newGrid(32, 32, w, h)
  local animation = Anim8.newAnimation(g(row, col), dur)
  return animation
end


function loadMedia()
  assets.icon    = lg.newImage('img/icon.png')
  assets.cursor  = lg.newImage('img/cursor.png')
  assets.hero    = lg.newImage('img/tom.png')
  assets.xeno    = lg.newImage('img/xeno.png')

  Game.xenoIdle  = buildAnim(assets.xeno, '1-2', 1, 0.08)
  Game.heroIdle  = buildAnim(assets.hero, '1-3', 1, 0.1)
end
