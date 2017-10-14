-- Starkiller
-- clovercam.lua
-- Camera library
-- My wrapper built over kikito's Gamera in order to add camera shake.
local Gamera = require 'lib.gamera'
local util = require 'util'

local rand = util.rand
local lg = love.graphics

local CloverCam = {}

local DEFAULT_RECORD_FPS = 60

function newCloverCam(x, y, w, h, maxShake, fade)
  local clover = setmetatable({}, {__index = CloverCam})
  clover.cam = Gamera.new(x, y, w, h)
  clover.shakeWeight = 0
  clover.maxShake = maxShake or 5
  clover.fade = fade or 4

  clover.isRecording = false
  clover.frames_recorded = 0
  clover.frame_buf = {}
  clover.time = 0

  return clover
end


function CloverCam:update(dt)
  self.shakeWeight = math.max(0, self.shakeWeight - self.fade * dt)
  if self.shakeWeight > 0 then
    local x, y = self.cam:getPosition()
    x = x + (100 - 200 * rand(self.shakeWeight)) * dt
    y = y + (100 - 200 * rand(self.shakeWeight)) * dt
    self:set(x, y)
  end

  if self.isRecording then
    self:record(dt)
  end
end


function CloverCam:draw(func)
  self.cam:draw(func)
end
  

function CloverCam:set(x, y)
  self.cam:setPosition(x, y)
end

function CloverCam:offset(x, y)
  local camx, camy = self.cam:getPosition()
  self:set(camx - x, camy - y)
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

function CloverCam:toggleRecord(fps)
  self.recordFPS = fps or DEFAULT_RECORD_FPS
  self.isRecording = not self.isRecording
end

function CloverCam:record(dt)
  self.time = self.time + dt
  if self.time < 1/self.recordFPS then
    return
  end
  self.frames_recorded = self.frames_recorded + 1
  self.frame_buf[self.frames_recorded] = lg.newScreenshot()
  self.time = 0
end

function CloverCam:processFrames()
  for i=1, self.frames_recorded do
    self.frame_buf[i]:encode('png', string.format('frames/%d.png', i))
  end
end

return setmetatable(CloverCam, {__call = function(_, ...) return newCloverCam(...)end })
