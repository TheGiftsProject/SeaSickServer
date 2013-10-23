_ = require('lodash')
Bullet = require('./bullet')
Helper = require('./helpers')

lastShipId = 1
class Ship
  constructor: (options = {})->
    defaultOptions =
      direction: Math.random()*Math.PI*2
      health: 100
      position: [Math.random(), Math.random()]
      velocity: [Math.random(), Math.random()]
      score: 0
      size: 0.025
      accelerating: false
      acceleration: 3

    options = _.merge(defaultOptions, options)

    @id = lastShipId++
    @health = options.health
    @position = options.position
    @velocity = options.velocity
    @score = options.score
    @direction = options.direction
    @size = options.size
    @accelerating = options.accelerating
    @acceleration = 3

  serialize: ->
    id: @id
    score: @score
    health: @health
    position: @position
    velocity: @velocity
    direction: @direction

  fire:->
    new Bullet(
      position: [@position[0], @position[1]]
      velocity: [@velocity[0], @velocity[1]]
      direction: @direction
      shipId: @id
    )

  wasHit: ->
    @health -= 1

  updateStatus: (data)->
    @position = data.position
    @velocity = data.velocity
    @direction = data.direction

  runFrame: (timeDiff)->
    if (@accelerating)
      accelVector = Helper.multVector([Math.cos(@direction), Math.sin(@direction)], @acceleration)
      @velocity = Helper.addVectors(@velocity, Helper.multVector(accelVector, timeDiff))
    @position = [@position[0] + @velocity[0]*timeDiff, @position[1] + @velocity[1]*timeDiff]
    @position[0] = @position[0] % 1
    @position[0] = 1 - @position[0] if @position[0] < 0
    @position[1] = @position[1] % 1
    @position[1] = 1 - @position[1] if @position[1] < 0

    @velocity = [@velocity[0]*0.9999, @velocity[1]*0.9999]
    @velocity[0] = Math.max(0, Math.min(@velocity[0], 1));
    @velocity[1] = Math.max(0, Math.min(@velocity[1], 1));

module.exports = Ship
