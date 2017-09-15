local Entity = Object:extend()

function Entity:init(...)
  if self.onInit then self:onInit(...) end
  world:addEntity()
end


function Entity:remove()
  if self.onRemove then self:onRemove() end
  return world:remove(self)
end

return Entity
