-- Starkiller
-- The space combat adventure sim
-- David Bergeron 2017
love.filesystem.setRequirePath('?.lua;src/?.lua;')

-- 3rd party libraries
Camera   = require 'lib.camera'
Class    = require 'lib.middleclass'
Behavior = require 'lib.behavior'
--Event    = require 'lib.signal'
Timer    = require 'lib.timer'

-- Starkiller modules
Vec2  = require 'vec2'

local fs = love.filesystem
local lg = love.graphics

local IMG_PATH = 'img/'
local SND_PATH = 'snd/'

local assets = {}

function love.load()
  love.window.setTitle('Starkiller')
  fs.setIdentity('Starkiller')
  
  local icon_img = lg.newImage('img/icon.png')
  love.window.setIcon(icon_img:getData())

  lg.setDefaultFilter('nearest', 'nearest')
  lg.setBackgroundColor(0, 0, 0)
  lg.clear()
end

function love.update(dt)
end


function love.draw()
  -- lg.setColor(255, 255, 255)
  lg.clear(168, 177, 219)
  lg.print('FPS: '..tostring(love.timer.getFPS()), 10, 10)
end

function love.keypressed(key)
  if key == 'escape' then
    love.event.quit()
  end
end

