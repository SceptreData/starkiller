local Entity = require 'entity'
local subclass = require 'class'

Actor = subclass(Entity)
Actor.__index = Actor

function Actor.new(info)
  return setmetatable(info, Actor)
end

--setmetatable(Actor, {__call = function(_, ...) return Entity(...) end }
function Actor:speak(str) print(str) end

--setmetatable(Actor, {__call = function(_, ...) return Actor.new(...) end })
Entity.new = new
hero = Actor.new({
  id = 'Fred',
  onInit = function() print('init') end,
  onRemove = function() print('remove') end
})



hero:init()
print(hero.id)
hero:remove()
hero:speak('titties')

