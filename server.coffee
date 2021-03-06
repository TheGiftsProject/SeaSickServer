util = require('util')
Game = require('./game')
http = require('http')
Helper = require('./helpers')
express = require('express')
app = express()
WebSocketServer = require('ws').Server
port = process.env.PORT || 8088
gameInstance = new Game()


app.use(express.static(__dirname + '/'));

app.get("/scores", (req, res) ->
  res.json(gameInstance.getScore())
)

server = http.createServer(app);
server.listen(port);


wss = new WebSocketServer({server: server})

console.log("Started server on port: #{port}")


wss.broadcast = (data) ->
  return unless wss.clients.length
  #console.log(JSON.stringify(data))
  wss.clients.forEach (client)->
    data.params.playerShipId = client.shipId
    serializedData = JSON.stringify(data)
    client.send(serializedData)



wss.on('connection', (ws) ->
  shipId = gameInstance.initiateShip()
  util.log("Client Connected. ShipId: #{shipId}")
  ws.shipId = shipId
  ws.send(JSON.stringify({ action: "currentTime", params: Helper.getNanoSec() }))
  ws.on('close', =>
      gameInstance.removeShip(shipId)
  )
  ws.on('message', (data)=>
      gotData(shipId, data)
  )
)
#for i in [1..5]
gameInstance.initiateShip()


gotData= (shipId, data)->
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
