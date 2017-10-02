local Animations = {
  pistol = {
    flash = {
      img = 'bullet_a',
      frames = {'1-5', 1},
      dur = 0.05
    }
  },

  tom = {
    idle = {
      img = 'tom',
      frames = {'1-3', 1},
      dur = 0.1
    },
    
    running = {
      img = 'tom',
      frames = {'2-3', 2, '1-3', 3},
      dur = 0.1,
    }
  },

  xeno = {
    idle = {
      img = 'xeno',
      frames = {'1-4', 1},
      dur = 0.08
    },

    running = {
      img = 'xeno',
      frames = {5, 1, '1-5', 2},
      dur = 0.08
    }
  }
}
return Animations
