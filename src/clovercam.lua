-- Starkiller
-- clovercam.lua
-- Camera library
-- My wrapper built over kikito's Gamera in order to add camera shake.
local Gamera = require 'lib.gamera'

local CloverCam = {}

function newCloverCam(x, y, w, h, maxShake, fade)
  local clover = setmetatable({}, {__index = CloverCam})
  clover.cam = Gamera.new(x, y, w, h)
  clover.shakeWeight = 0
  clover.maxShake = maxShake or 5
  clover.fade = fade or 4
  return clover
end


function CloverCam:draw(func)
  self.cam:draw(func)
end
  

function CloverCam:set(x, y)
  self.cam:setPosition(x, y)
end


function CloverCam:setScale(s)
  self.cam:setScale(s)
end


function CloverCam:getVisible()
  return self.cam:getVisible()
end


function CloverCam:toWorld(x, y)
  return self.cam:toWorld(x, y)
end

function CloverCam:toScreen(x, y)
  return self.cam:toScreen(x, y)
end

function CloverCam:shake(power)
  local power = power or 3
  self.shakeWeight = math.min(self.maxShake, self.shakeWeight + power)
end

function CloverCam:update(dt)
  self.shakeWeight = math.max(0, self.shakeWeight - self.fade * dt)
  if self.shakeWeight > 0 then
    local x, y = self.cam:getPosition()
    x = x + (100 - 200 * math.random(self.shakeWeight)) * dt
    y = y + (100 - 200 * math.random(self.shakeWeight)) * dt
    self:set(x, y)
  end
end

return setmetatable(CloverCam, {__call = function(_, ...) return newCloverCam(...)end })
