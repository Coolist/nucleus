//Define modules/config
var express = require('express'),
    app = express(),
    http = require('http').Server(app),
    config = require('./node/config.json');

// Run Coffeescript
require('coffee-script/register');

//Load routes
require('./node/routes')(app, express.Router());

//Load Socket.io service
require('./node/socketio')(http);

//Start server
http.listen(3000);

console.log('Node ' + config.server + ' server running on port 3000');