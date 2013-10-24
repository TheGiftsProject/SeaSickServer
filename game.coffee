util = require('util')
Ship = require('./ship.coffee')
Helper = require('./helpers');
_ = require('lodash')

removeBullet = (bullets, bulletId)->
  delete bullets[bulletId]

class Game
  constructor: (@options = {})->
    defaultOptions =
      boardWidth: 1
      boardHeight: 1

    @lastUpdate = Helper.getNanoSec()

    @options = _.merge(defaultOptions, @options)

    util.log("creating game board size: [#{@options.boardHeight}, #{@options.boardWidth}]")

    @ships = {}
    @bullets = {}

  currentStatus: ->
      ships: _.map(@ships, (ship)-> ship.serialize())
      bullets: _.map(@bullets, (bullet) -> bullet.serialize())

  initiateShip: ->
    ship = new Ship()
    @ships[ship.id] = ship
    ship.id

  shipFired: (shipId)->
    bullet = @ships[shipId].fire()
    @bullets[bullet.id] = bullet

  updateShipAcceleration: (shipId, data) ->
    @ships[shipId].accelerating = data.accelerating

  updateShipDirection: (shipId, data) ->
    @ships[shipId].direction = data.direction

  removeShip: (id)->
    delete @ships[id]

  deletedMarkedBullets: ->
    _.each(@bullets, (bullet, bulletId)=>
      removeBullet(@bullets, bulletId) if bullet.isMarkedForDeletion()
    )

  runFrame: (cb)->
    if Object.keys(@ships).length
      currTime = Helper.getNanoSec()
      diff = (currTime - @lastUpdate) / 1000000000
      _.each(@ships,(ship, shipId)->
        ship.runFrame(diff)
      )
      _.each(@bullets, (bullet, bulletId)->
        bullet.runFrame(diff)
      )

      @detectCollisions()
      @detectShipCollisions()
      @deletedMarkedBullets()

      @lastUpdate = Helper.getNanoSec()

    setTimeout((->cb(diff)), 0)

  detectCollisions: ()->
    _.each(@bullets, (bullet) =>
      _.each(@ships, (ship) =>
        if (ship.isAlive() && bullet.shipId != ship.id && !bullet.isMarkedForDeletion())
          collisionHappened = Helper.squareDistanceBetweenVectors(bullet.position, ship.position) <= ship.size*ship.size
          if collisionHappened
            bullet.markForDeletion()
            ship.wasHit(bullet.velocity)
            if (!ship.isAlive())
              @ships[bullet.shipId].killedOtherShip()
      )
    )

  detectShipCollisions: ()->
    ships = _.values(@ships)
    #for (i = 0; i < ships.length; ++i)
      #for (j = 0; j < i; ++j)
    for i in [0...ships.length]
      for j in [0...i]
        ship1 = ships[i]
        ship2 = ships[j]
        if (ship1.id != ship2.id)
          collisionHappened = Helper.squareDistanceBetweenVectors(ship1.position, ship2.position) <= (ship1.size+ship2.size)*(ship1.size+ship2.size)
          if (collisionHappened)
            ship1.collidedWith(ship2)
            ship2.collidedWith(ship1)
    null


module.exports = Game
