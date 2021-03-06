_ = require('lodash')
Bullet = require('./bullet')
Helper = require('./helpers')

randomizePosition = ->
  [Math.random(), Math.random()]

lastShipId = 1
class Ship
  constructor: (options = {})->
    defaultOptions =
      direction: Math.random()*Math.PI*2
      position: randomizePosition()
      velocity: [0, 0]
      score: 0
      size: 0.025
      accelerating: false
      acceleration: 3
      timeSinceDeath: 0
      initialHealth: 5
      respawnTime: 3
      immunityTime: 3
      timeSinceImmunity: 0

    options = _.merge(defaultOptions, options)

    @id = lastShipId++
    @direction = options.direction
    @position = options.position
    @velocity = options.velocity
    @score = options.score
    @size = options.size
    @accelerating = options.accelerating
    @acceleration = options.acceleration
    @timeSinceDeath = options.timeSinceDeath
    @health = options.initialHealth
    @initialHealth = options.initialHealth
    @respawnTime = options.respawnTime
    @immunityTime = options.immunityTime
    @timeSinceImmunity = options.timeSinceImmunity
    @isImmune = true

  serialize: ->
    id: @id
    score: @score
    health: @health
    position: @position
    velocity: @velocity
    direction: @direction
    isImmune: @isImmune

  fire:->
    new Bullet(
      position: [@position[0], @position[1]]
      velocity: [@velocity[0], @velocity[1]]
      direction: @direction
      shipId: @id
    )

  wasHit: (bulletVelocity) ->
    @health -= 1
    @velocity = Helper.addVectors(@velocity, Helper.multVector(bulletVelocity, 0.01))

  isAlive: ->
    @health > 0

  killedOtherShip: ->
    @score += 1

  collidedWith: (other) ->
    normal = Helper.subVectors(@position, other.position)
    if (Math.abs(@velocity[0]) > 0.000001 || Math.abs(@velocity[1]) > 0.000001)
      reflectVector = Helper.reflectVector(@velocity, normal)
      @velocity = Helper.multVector(reflectVector, Helper.vecLength(@velocity))

  setAccelerating: (accelerating) ->
    @accelerating = accelerating

  runFrame: (timeDiff)->
    if (@health == 0)
      @timeSinceDeath += timeDiff
      if (@timeSinceDeath > @respawnTime)
        @timeSinceDeath = 0
        @health = @initialHealth
        @position = randomizePosition()
        @velocity = [0, 0]
        @isImmune = true
    else
      if (@isImmune)
        @timeSinceImmunity += timeDiff
        if (@timeSinceImmunity > @immunityTime)
          @timeSinceImmunity = 0
          @isImmune = false

      if (@accelerating)
        accelVector = Helper.multVector([Math.cos(@direction), Math.sin(@direction)], @acceleration)
        @velocity = Helper.addVectors(@velocity, Helper.multVector(accelVector, timeDiff))

      @position = Helper.addVectors(@position, Helper.multVector(@velocity, timeDiff))
      @position[0] = @position[0] % 1
      @position[0] = 1 - @position[0] if @position[0] < 0
      @position[1] = @position[1] % 1
      @position[1] = 1 - @position[1] if @position[1] < 0

      @velocity = [@velocity[0]*0.99, @velocity[1]*0.99]
      @velocity[0] = Math.max(-1, Math.min(@velocity[0], 1));
      @velocity[1] = Math.max(-1, Math.min(@velocity[1], 1));

module.exports = Ship
