util = require('util')
Ship = require('./ship.coffee')
Helper = require('./helpers');
_ = require('lodash')


getNanoSec = ->
  time = process.hrtime()
  time[0] * 1e9 + time[1]

removeBullet = (bullets, bulletId)->
  console.log("deleting bullets")
  delete bullets[bulletId]

class Game
  constructor: (@options = {})->
    defaultOptions =
      boardWidth: 1
      boardHeight: 1

    @lastUpdate = getNanoSec()

    @options = _.merge(defaultOptions, @options)

    util.log("creating game board size: [#{@options.boardHeight}, #{@options.boardWidth}]")

    @ships = {}
    @bullets = {}

  currentStatus: ->
      ships: _.map(@ships, (ship)-> ship.serialize())
      bullets: _.map(@bullets, (bullet) -> bullet.serialize())

  initiateShip: ->
    ship = new Ship()
    console.log("created ship %j", ship)
    @ships[ship.id] = ship
    ship.id

  shipFired: (shipId)->
    console.log("ship fired")
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
      currTime = getNanoSec()
      diff = (currTime - @lastUpdate) / 1000000000
      _.each(@ships,(ship, shipId)->
        ship.runFrame(diff)
      )
      _.each(@bullets, (bullet, bulletId)->
        bullet.runFrame(diff)
      )

      @detectCollisions()
      @deletedMarkedBullets()

      @lastUpdate = getNanoSec()

    setTimeout((->cb(diff)), 0)

  detectCollisions: ()->
    _.each(@bullets, (bullet)=>
      _.each(@ships, (ship)->
        if (ship.isAlive() && bullet.shipId != ship.id && !bullet.isMarkedForDeletion())
          collisionHappened = Helper.squareDistanceBetweenVectors(bullet.position, ship.position) <= ship.size*ship.size
          if collisionHappened
            console.log("KABOOM! shipId = " + ship.id + ", bullet ship id = " + bullet.shipId)
            bullet.markForDeletion()
            ship.wasHit()
            if (!ship.isAlive()) {
              @ships[bullet.shipId].killedOtherShip()
            }
      )
    )


module.exports = Game
