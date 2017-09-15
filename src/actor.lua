local Entity = require 'entity'

local Actor = Entity:extend()

function Actor:new(id)
end

--setmetatable(Actor, {__call = function(_, ...) return Entity(...) end }
function Actor:speak(str) print(str) end

return Actor
