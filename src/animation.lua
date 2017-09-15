local Animation = {}
Animation.__index = Animation

function Animation.new(states, loop)
  local anim  = setmetatable({}, Animation)
  anim.loop   = true or loop
  anim.paused = false
  anim.flipH  = false
  anim.flipV  = false
  anim.state = Behavior(states)
end

function Animation:update(dt)
  if not self.paused then
    self.states:update(dt)
  end
end

function Animation:draw(x, y, angle, sx, sy, ox, oy)
  local img, sprite = lookupSprite(self:get('sprite'))
end

function Animation:get(key)
  return self.state.frame[key]
end

function Animation:pause()
  self.paused = true
end

function Animation:resume()
  self.paused = false
end

function Animation:set(state, idx)
  self.state:set(state, idx or nil)
end

return Animation
