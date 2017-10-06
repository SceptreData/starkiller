-- Temporary list of all my animations. I eventually want to move this into
-- separate files for organization purposes.
return {
  DATA_ID = 'animations',

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

    idleImpact = {
      img = 'xeno',
      frames = {'1-2', 2},
      dur  = 0.025,
      onLoop = 'pauseAtEnd'
    },

    running = {
      img = 'xeno',
      frames = {'3-4', 2, '1-4', 3},
      dur = 0.07
    },
    runningImpact = {
      img = 'xeno',
      frames = {'1-2', 4},
      dur = 0.025,
      onLoop = 'pauseAtEnd'
    }
  }
}
