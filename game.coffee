util = require('util')
Ship = require('./ship.coffee')
_ = require('lodash')


getNanoSec = ->
  time = process.hrtime()
  time[0] * 1e9 + time[1]

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

  initiateShip: ->
    ship = new Ship()
    console.log("created ship %j", ship)
    @ships[ship.id] = ship
    ship.id

  updateShipStatus: (shipId, newData) ->
    ship = @ships[shipId]
    return unless ship
    ship.updateStatus(newData)

  removeShip: (id)->
    delete @ships[id]

  removeBullet: (id)->
    delete @bullets[id]

  runFrame: (cb)->
    if Object.keys(@ships).length
      currTime = getNanoSec()
      diff = (currTime - @lastUpdate) / 1000000000
      _.each(@ships,(ship, shipId)->
        ship.runFrame(diff)
      )
      _.each(@bullets, (bullet, bulletId)->
        bullet.runFrame(diff)
        @removeBullet(bulletId) if bullet.needToDelete()
      )

    setTimeout((->cb()), 0)


module.exports = Game
