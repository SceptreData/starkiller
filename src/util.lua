local util = {}


function util.getColor(rgb_t)
  return unpack(rgb_t)
end


function util.drawRect(color, x, y, w, h)
  local r, g, b = util.getColor(color)
  love.graphics.setColor(r, g, b, 100)
  love.graphics.rectangle('fill', x, y, w, h)
  love.graphics.setColor(r, g, b)
  love.graphics.rectangle('line', x, y, w, h)
end

function util.hollowRect(color, x, y, w, h)
  local r, g, b = util.getColor(color)
  love.graphics.setColor(r, g, b)
  love.graphics.rectangle('line', x, y, w, h)
end

  


return util
