-- Starkiller
-- brain.lua
-- collection of AI behaviors for our enemies.
local Brain = Class('Brain')


local function newSteering()
  local s = {}
  s.linear  = Vec2()
  s.angular = 0
  return s
end


local Steering = {}
function Steering.update(ent, dt)
  assert(ent.steering)
  ent.pos = ent.pos + (ent.vel * dt)
  ent.vel = ent.vel + (ent.steering.linear * dt)
  ent.vel:limit(ent.max_speed)
end,

function Steering.seek(ent)
  local s = newSteering()

  s.linear = ent.target - ent.pos
  s.linear:setMag(ent.max_speed)

  s.angular = 0

  return s
end


function Steering.flee(ent)
  local s = newSteering()

  s.linear = ent.pos - ent.target
  s.linear:setMag(ent.max_speed)

  s.angular = 0

  return s
end

function Steering.arrive(ent)
  local s = newSteering()

  local dir = ent.target - ent.pos
  local dist = dir:len()

  if dist < ent.arrive_radius then
    return nil
  end

  local target_speed = 0
  if dist > ent.slow_radius then
    target_speed = ent.max_speed
  else
    target_speed = ent.max_speed * dist / ent.slow_radius
  end

  local target_v = dir
  target_v:setMag(target_speed)

  s.linear = target_v - ent.vel
  s.linear = s.linear / ent.time_to_target
  s.linear:limit(ent.max_force)

  s.angular = 0
  return s
end




return Brain
