module.exports = (http) ->

  # Load Modules
  io = require('socket.io') http
  redis = require 'redis'

  authentication = require './realtime/authentication.coffee'
  devices = require './realtime/devices.coffee'

  # Init Users
  users = []

  # Subscribe to device message queue Redis channel
  deviceMQ = redis.createClient()
  deviceMQ.subscribe 'device-mq'
  deviceMQ.subscribe 'notification-mq'

  deviceMQ.on 'message', (channel, mes) ->
    if channel is 'device-mq'
      m = JSON.parse mes
      
      for userId, user of users
        if user.place is m.place and user.type is 'center'
          
          user.socket.emit 'device:setState',
            id: m.id
            type: m.property
            value: m.value
    else if channel is 'notification-mq'
      m = JSON.parse mes

      switch m.type
        when 'state'
          for userId, user of users
            if user.place is m.place and user.type is 'user'
              user.socket.emit 'device:state',
                id: m.id
                states: m.states

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
            break

    socket.on 'center:devices', (data) ->
      if not users[socket.id].devices?
        users[socket.id].devices = data
        devices.update data, users[socket.id]
      else if JSON.stringify(users[socket.id].devices) isnt JSON.stringify(data)
        users[socket.id].devices = data
        devices.update data, users[socket.id]

    socket.on 'disconnect', () ->
      delete users[socket.id]

  console.log 'Socket IO server started.'