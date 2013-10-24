_ = require('lodash')
helper = require('./helpers');


_calculateInitialVelocity= (direction, initialSpeed, initialVelocity)->
  x = Math.cos(direction)
  y = Math.sin(direction)
  helper.addVectors(helper.multVector([x, y], initialSpeed), initialVelocity)


lastBulletId = 1

class Bullet
  constructor: (options = {})->
    defaultOptions =
      position: [Math.random(), Math.random()]
      velocity: [0.08, 0.09]
      maxTravelDistance: 1
      initialSpeed: 0.01
      direction: null
      shipId: 0
      active: true

    options = _.merge(defaultOptions, options)

    @maxTravelDistance = options.maxTravelDistance
    @initialPosition = options.position;
    @position = options.position
    @shipId = options.shipId
    @velocity = _calculateInitialVelocity(options.direction,
                                          options.initialSpeed,
                                          options.velocity)
    @active = options.active

    @id= lastBulletId++

    console.log("created bullet with velocity: #{@velocity} position: #{@position} initialPosition: #{@initialPosition}")

  serialize: ->
    id: @id
    position: @position
    velocity: @velocity

  markForDeletion: ->
    @active = false

  isMarkedForDeletion: ->
    !@active

  runFrame: (timeDiff)->
    velocityWithTime = helper.multVector(@velocity, timeDiff)
    @position = helper.addVectors(@position, velocityWithTime)

    @position[0] = @position[0] % 1
    @position[0] = 1 - @position[0] if @position[0] < 0
    @position[1] = @position[1] % 1
    @position[1] = 1 - @position[1] if @position[1] < 0

    @velocity[0] = Math.max(-1, Math.min(@velocity[0], 1));
    @velocity[1] = Math.max(-1, Math.min(@velocity[1], 1));
    needToRemove = helper.squareDistanceBetweenVectors(@position,@initialPosition) >= @maxTravelDistance * @maxTravelDistance
    console.log("Need to remove bullet") if needToRemove
    @markForDeletion() if needToRemove
    console.log("bullet moved to #{@position} with velocity #{@velocity}")



module.exports = Bullet
