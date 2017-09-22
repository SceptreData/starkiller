-- Starkiller
-- The space combat adventure sim
-- David Bergeron 2017
love.filesystem.setRequirePath('?.lua;src/?.lua;')

-- 3rd party libraries
Class    = require 'lib.middleclass'
Behavior = require 'lib.behavior'
Bump     = require 'lib.bump'
Gamera   = require 'lib.gamera'
--Event  = require 'lib.signal'
Timer    = require 'lib.timer'

-- Global Starkiller modules
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

local assets = {}

local SCREEN_W = 1024
local SCREEN_H = 768

local CELL_SIZE = 32

-- Globals (GASP)
Game = {}
Game.bullets = {}
Game.ents = {}

local blocks = {}
local player, foe
local camera, map

local game_w, game_h = 1000, 1000

function love.load()
  initWindow()

  -- Init Camera
  camera = Gamera.new(0, 0, game_w, game_h)

  -- Init Game World
  Game.world = Bump.newWorld(CELL_SIZE)
  map = Map:new(camera, game_w, game_h)
  map:setup()
  
  player = Hero:new(SCREEN_W/2, SCREEN_H/2)
  Game.player = player
  foe = Enemy:new(player.pos.x, player.pos.y - 300)
end



function love.update(dt)
  -- Update all objects on our map
  map:update(dt)

  -- Centre camera on player, update camera
  local pos = player:getCentre()
  camera:setPosition(pos.x, pos.y)
end


function love.draw()
  lg.setColor(255, 255, 255, 255)
  lg.clear(113, 102, 117) -- RUM GREY

  -- Draw our whole map
  camera:draw(function(x, y, w, h)
    map:draw(x, y, w, h)
  end)
  
  lg.setColor(255, 255, 255, 255)
  lg.print('FPS: '..tostring(love.timer.getFPS()), 10, 10)
end


function love.mousepressed(x, y, button)
  if button == 1 then
    player:fireWeapon(x, y)
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

  -- Set Window icon 
  local icon_img = lg.newImage('img/icon.png')
  love.window.setIcon(icon_img:getData())
 
  -- Set Cursor
  local cursor_img = lg.newImage('img/cursor.png')
  local cursor     = love.mouse.newCursor(cursor_img:getData(), 15, 15)
  love.mouse.setCursor(cursor)

  -- Screen defaults
  lg.setDefaultFilter('nearest', 'nearest')
  lg.setBackgroundColor(255, 255, 255)
  lg.clear()
end
