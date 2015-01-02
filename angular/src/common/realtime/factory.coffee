io = require 'node/socket.io-client'
api = require '../api'

factory = (socketFactory, authInterceptor, $location, $localStorage) ->
  socket = socketFactory
    ioSocket: io.connect api.config.socketio
  socket.forward 'device:state'

  @socket = socket

  store =
    authenticated: false

  @checkAuth = (place) ->
    if not store.authenticated
      store.place = place

      if $localStorage.tokenAccess?
        socket.emit 'auth:getRequest',
          token: $localStorage.tokenAccess
          place: place
          type: 'user'
      else
        $location.path 'account/login'

  socket.on 'auth:getRequest', (data) =>
    if data[0].success
      store.authenticated = true
      store.token = data[0].token
    else
      store.authenticated = false
      @checkAuth store.place

  socket.on 'auth:reauthenticate', (data) ->
    store.authenticated = false
    @checkAuth store.place

  socket.on 'reconnect', () =>
    store.authenticated = false

    if $localStorage.tokenAccess?
      @checkAuth store.place

  @

module.exports = [
  'socketFactory'
  'authInterceptor'
  '$location'
  '$localStorage'
  factory
]