local Entity = {}
Entity.__index = Entity

function Entity.new(t)
  return setmetatable(t, Entity)
end

function Entity:init(...)
  if self.onInit then self:onInit(...) end
  world:addEntity()
end


function Entity:remove()
  if self.onRemove then self:onRemove() end
  return world:remove(self)
end

return Entity
