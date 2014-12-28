module.exports = (http) ->

  # Load Modules
  io = require('socket.io') http

  authentication = require './realtime/authentication.coffee'

  # Init Users
  users = []

  io.on 'connection', (socket) ->
    console.log 'New user'

    users[socket.id] =
      authenticated: false

    socket.on 'auth:getAccess', (data) ->
      authentication.getAccess data, socket

    socket.on 'auth:getRequest', (data) ->
      authentication.getRequest data, socket


    socket.on 'disconnect', () ->
      delete users[socket.id]

  console.log 'Socket IO server init...'