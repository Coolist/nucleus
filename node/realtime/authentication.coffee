# Load related models
controller = require '../main/authentication/controller.coffee'

exports.getAccess = (data, socket) ->
  controller.getAccess
    query: data
  ,
    send: (mes, code) ->
      socket.emit 'auth:getAccess', [ mes, code ]

exports.getRequest = (data, socket) ->
  controller.getRequest
    query: data
  ,
    send: (mes, code) ->
      socket.emit 'auth:getRequest', [ mes, code ]