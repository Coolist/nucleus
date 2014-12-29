module.exports = (http) ->

  # Load Modules
  io = require('socket.io') http

  authentication = require './realtime/authentication.coffee'
  devices = require './realtime/devices.coffee'

  # Init Users
  users = []

  io.on 'connection', (socket) ->

    users[socket.id] =
      authenticated: false
      socket: socket

    socket.on 'auth:getAccess', (data) ->
      authentication.getAccess data, users[socket.id]

    socket.on 'auth:getRequest', (data) ->
      authentication.getRequest data, users[socket.id], (token) ->
        devices.getService users[socket.id], () ->
          devices.update users[socket.id].devices, users[socket.id]

    socket.on 'center:device:updateState', (data) ->
      if users[socket.id].devices?
        for device in users[socket.id].devices
          if device.id is data.id
            device.states[data.type] = data.value
            devices.update [ device ], users[socket.id]

    socket.on 'center:devices', (data) ->
      if not users[socket.id].devices?
        users[socket.id].devices = data
        devices.update data, users[socket.id]
      else if JSON.stringify(users[socket.id].devices) isnt JSON.stringify(data)
        devices.update data, users[socket.id]

    ###
    socket.emit 'device:setState',
      id: 'Lightswitch-1_0-221425K1300369'
      type: 'power'
      value: true
    ###

    socket.on 'disconnect', () ->
      delete users[socket.id]

  console.log 'Socket IO server init...'