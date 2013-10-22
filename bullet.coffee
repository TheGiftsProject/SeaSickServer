_ = require('lodash')

class Bullet
  constructor: ->
    defaultOptions =
      position: [Math.random(), Math.random()]
      velocity: [0.08, 0.09]
      frames: 0

    options = _.merge(defaultOptions, options)

    @position = options.position
    @velocity = options.velocity
    @frames = options.frames

  needToDelete: ->
    @frames >= 1000
  runFrame: (timeDiff)->
    @position = [@velocity[0] * timeDiff, @velocity[1] * timeDiff]
    @position[0] -= 1 if @position[0] > 1
    @position[1] -= 1 if @position[1] > 1
    @velocity = [@velocity[0] * 0.9999, @velocity[1] * 0.9999]
    @velocity[0] -= 1 if @velocity[0] > 1
    @velocity[1] -= 1 if @velocity[1] > 1
