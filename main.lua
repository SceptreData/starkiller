-- Starkiller
-- The space combat adventure sim
-- David Bergeron 2017
love.filesystem.setRequirePath('?.lua;src/?.lua;')

-- 3rd party libraries
Camera   = require 'lib.camera'
Class    = require 'lib.middleclass'
Behavior = require 'lib.behavior'
Bump     = require 'lib.bump'
--Event  = require 'lib.signal'
Timer    = require 'lib.timer'

-- Global Starkiller modules
Vec2  = require 'vec2'

-- Non-Global Modules
local Hero = require 'hero'
local util = require 'util'



local fs = love.filesystem
local lg = love.graphics

local IMG_PATH = 'img/'
local SND_PATH = 'snd/'

local assets = {}

local SCREEN_W = 1024
local SCREEN_H = 768

-- Globals (GASP)
Game = {}
local blocks = {}
local player

function love.load()
  -- Set up Window
  love.window.setTitle('Starkiller')
  fs.setIdentity('Starkiller')
  
  local icon_img = lg.newImage('img/icon.png')
  love.window.setIcon(icon_img:getData())

  lg.setDefaultFilter('nearest', 'nearest')
  lg.setBackgroundColor(0, 0, 0)
  lg.clear()

  -- Initialize Game World
  Game.world = Bump.newWorld(32)
  newBlock(0, 0,  1024,    32)
  newBlock(0, 32, 32,     768-32*2)
  newBlock(1024-32, 32, 32,     768-32*2)
  newBlock(0, 768-32, 1024, 32)
  player = Hero:new(SCREEN_W/2, SCREEN_H/2)
end


function love.update(dt)
  player:update(dt)
end


function love.draw()
  lg.clear(113, 102, 117) -- RUM GREY

  player:draw()
  drawBlocks()

  lg.setColor(255, 255, 255)
  lg.print('FPS: '..tostring(love.timer.getFPS()), 10, 10)
end


function love.keypressed(key)
  if key == 'escape' then
    love.event.quit()
  end
end

function newBlock(x,y,w,h)
    local b = {x=x, y=y, w=w, h=h}
    blocks[#blocks+1] = b
    Game.world:add(b, x, y, w, h)
end

function drawBlocks()
  for _, b in ipairs(blocks) do
    util.drawRect({255, 0, 0}, b.x, b.y, b.w, b.h)
  end
end
