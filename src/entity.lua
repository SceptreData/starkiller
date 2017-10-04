-- Starkiller
-- entity.lua
-- Base Class for all Entities
--   In this project all entities are axis aligned bounding boxes
--   AKA Rectangles.
local Entity = Class('Entity')

local function noCollisions(ent, other) return nil end

function Entity:initialize(x, y, w, h, not_solid)
  self.pos = Vec2(x, y)
  self.w, self.h = w, h

  if not_solid then
    self.collision_filter = noCollisions
  end
  
  -- Add Entity to the physical world
  Game.world:add(self, x, y, w, h)
  self.created_at = love.timer.getTime()
end

function Entity:getCentre()
  return Vec2(self.pos.x + self.w / 2,
              self.pos.y + self.h / 2
             )
end

function Entity:remove()
  if self.onRemove then self:onRemove() end
  return Game.world:remove(self)
end

return Entity
