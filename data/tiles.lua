-- Starkiller
-- List of tile types.
return {
  ship = {
    img = 'shipTiles',
    sw = 32,
    sh = 32,
    {
      id = 'floor',
      frames = {1, 1},
      walkable = true
    },{
      id = 'wall',
      frames = {2, 1},
      walkable = false
    },{
      id = 'hull',
      frames = {3, 1},
      walkable = false
    }
  }
}
