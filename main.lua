-- Starkiller
-- The space combat adventure sim
-- David Bergeron 2017
love.filesystem.setRequirePath('?.lua;src/?.lua;')

-- 3rd party libraries
Camera   = require 'lib/camera'
Behavior = require 'lib/behavior'
Event    = require 'lib/signal'
lume     = require 'lib/lume'
Object = require 'classic'
timer    = require 'lib/timer'
tiny     = require 'lib.tiny'

-- Starkiller modules
Vec2  = require 'vec2'

local fs = love.filesystem
local lg = love.graphics

local ASSET_PATH = 'assets/'
local assets = {}

tx = 300
ty = 500
offset = 12
ship_angle = 0
gun_angle = 0
gun_abs = ship_angle + gun_angle


function love.load()
  love.window.setTitle('Starkiller')
  fs.setIdentity('Starkiller')
  
  local icon_img = lg.newImage('img/icon.png')
  love.window.setIcon(icon_img:getData())

  lg.setDefaultFilter('nearest', 'nearest')
  lg.setBackgroundColor(0, 0, 0)
  lg.clear()

  turret = lg.newImage('img/t3.png')
  base = newSprite(turret, 1, 1, 66, 66,  1)
  gun = newSprite(turret, 2, 1, 66, 66,  1)
  canvas = love.graphics.newCanvas(1280,720, 'hdr', 32)
end

function love.update(dt)
  gun_abs = ship_angle + gun_angle
end


--[[ lg.arc(mode, x, y, radius, angle1, angle2)
     Think of Radius as your distance to target
     Angle1/2 dont face north to start, they face east.
]]--

function love.draw()
  -- lg.setColor(255, 255, 255)
  lg.setCanvas(canvas)
  lg.setColor(255,255,255,255)
  lg.clear(168, 177, 219)
  lg.setBlendMode('alpha', 'premultiplied')
  lg.draw(turret, base, tx, ty, math.rad(ship_angle), 2, 2, 32, 32)
  lg.draw(turret, gun, tx, ty, math.rad(gun_abs), 2, 2, 32, 32 + 12)

  lg.draw(turret, base, tx, ty - 200, math.rad(ship_angle), 2, 2, 32, 32)
  lg.draw(turret, gun, tx, ty - 200, math.rad(gun_angle) + math.rad(ship_angle), 2, 2, 32, 32 + 12)

  lg.setColor(255,255,0, 15)
  lg.arc('fill', tx, ty , 200, math.rad(gun_abs - 15 - 90), math.rad(gun_abs + 15 - 90))
  lg.setColor(255,255,255,255)
  lg.setCanvas()
  lg.draw(canvas, 0, 0, 0, 1, 1)
  lg.setBlendMode('alpha')
  lg.print('FPS: '..tostring(love.timer.getFPS()), 10, 10)
end

function love.keypressed(key)
  if key == 'escape' then
    love.event.quit()
  end

  if key == 'right' then
    gun_angle = gun_angle + 15
  end
  if key == 'up' then
    ship_angle = ship_angle + 15
  end
end

function newSprite(img, x, y, fw, fh, border)
  local border = border or 0
  local spr_w, spr_h = fw - (border  * 2), fh - (border * 2)
  return lg.newQuad(
                   (x-1) * fw + border, 
                   (y-1) * fh + border, 
                    spr_w, spr_h,
                    img:getWidth(), img:getHeight())
end

function isInsideCone(target, origin, facing, cone_radius, fov)
  local dir = (target - origin)
  if dir > cone_radius then
    return false
  end
  local facing = radToVector(facing):normalize()
  local angle = math.acos(facing:dot(dir:normalize()))

  return (angle <= fov/2) and (angle >= -fov/2)
end


function radToVector(r)
  return Vec2(math.cos(r), math.sin(r))
end

-- Load image assets
    -- local asset_files = fs.getDirectoryItems(ASSET_PATH)
    -- for _, filename in ipairs(asset_files) do
    --   assets[filename] = lg.newImage(ASSET_PATH .. filename)
    -- end

