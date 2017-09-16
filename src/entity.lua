local Entity = Class('Entity')

function Entity:initalize(x, y, w, h)
  self.pos = Vec2(x, y)
  self.w, self.h = w, h
  --if self.onInit then self:onInit(...) end
  world:add(self, x, y, w, h)
  self.created_at = love.timer.getTime()
end

function Entity:getCentre()
  return Vec2(self.pos.x + self.w / 2,
              self.pos.y + self.h / 2
             )
end

function Entity:remove()
  --if self.onRemove then self:onRemove() end
  return world:remove(self)
end

return Entity
