util = require('util')
Game = require('./game')
WebSocketServer = require('ws').Server
wss = new WebSocketServer({port: 8088})

gameInstance = new Game()

wss.broadcast = (data) ->
  return unless wss.clients.length
#  util.log("broadcasting to #{wss.clients.length} clients #{serializedData}")
  wss.clients.forEach (client)->
    data.params.playerShipId = client.shipId
    serializedData = JSON.stringify(data)
#    console.log serializedData
    client.send(serializedData)



wss.on('connection', (ws) ->
  util.log('client connected')
  shipId = gameInstance.initiateShip()
  ws.shipId = shipId
  ws.on('close', =>
      gameInstance.removeShip(shipId)
  )
  ws.on('message', (data)=>
      gotData(shipId, data)
  )

)
for i in [1..5]
  gameInstance.initiateShip()


gotData= (shipId, data)->
#  console.log("got data for ship id: %d and data: #{data}", shipId)
  data = JSON.parse(data)
  switch data.action
    when 'shipDirection'
      gameInstance.updateShipDirection(shipId, data.params)
    when 'shipAccelerator'
      gameInstance.updateShipAcceleration(shipId, data.params)
    when 'shipFired'
      gameInstance.shipFired(shipId)

#calculateLoop = null;
runLoop = ->
  gameInstance.runFrame((executionTime)->
    wss.broadcast({
      action: 'gameState'
      params: gameInstance.currentStatus()
    })
    setTimeout((=>runLoop()), 16 - executionTime)
  )

runLoop()
