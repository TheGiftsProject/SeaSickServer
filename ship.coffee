_ = require('lodash')

lastShipId = 1
class Ship
  constructor: (options = {})->
    defaultOptions =
      direction: Math.random()*Math.PI*2
      health: 100
      position: [Math.random(), Math.random()]
      velocity: [0.08, 0.09]
      score: 0

    options = _.merge(defaultOptions, options)

    @id = lastShipId++
    @health = options.health
    @position = options.position
    @velocity = options.velocity
    @score = options.score
    @direction = options.direction

  serialize: ->
    id: @id
    score: @score
    health: @health
    position: @position
    velocity: @velocity
    direction: @direction

  updateStatus: (data)->
    @position = data.position
    @velocity = data.velocity
    @direction = data.direction

  runFrame: (timeDiff)->
    console.log("ship ", @position)
    @position = [@velocity[0]*timeDiff, @velocity[1]*timeDiff]
    @position[0] = Math.abs(@position[0] % 1) if @position[0]>1 || @position[0] < 0
    @position[1] = Math.abs(@position[1] % 1) if @position[1]>1 || @position[1] < 0


    @velocity = [@velocity[0]*0.9999, @velocity[1]*0.9999]
    @velocity[0] = 1 if @velocity[0] > 1
    @velocity[1] = 1 if @velocity[1] > 1
    @velocity[0] = 0 if @velocity[0] < 1
    @velocity[1] = 0 if @velocity[1] < 1


module.exports = Ship
