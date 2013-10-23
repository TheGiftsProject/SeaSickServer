var WebSocket = require('ws');
var ws = new WebSocket('ws://127.0.0.1:8088');

ws.on('open', function () {
  console.log('connected');
  var fire ={
    action: 'shipFired'
  };
  ws.send(JSON.stringify(fire));
});

ws.on('close', function () {
  console.log('disconnected');
});

//ws.on('message', function (data, flags) {
//  console.log('Roundtrip time: ' + (Date.now() - parseInt(data)) + 'ms', flags);
//  setTimeout(function () {
//    ws.send(Date.now().toString(), {mask: true});
//  }, 500);
//});
