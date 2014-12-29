# Load related models
controller = require '../main/authentication/controller.coffee'

exports.getAccess = (data, user) ->
  controller.getAccess
    query: data
  ,
    send: (mes, code) ->
      user.socket.emit 'auth:getAccess', [ mes, code ]

exports.getRequest = (data, user, success) ->
  controller.getRequest
    query: data
  ,
    send: (mes, code) ->
      user.socket.emit 'auth:getRequest', [ mes, code ]

      if mes.success
        user.authenticated = true
        user.id = mes.account
        user.place = data.place
        user.type = data.type
        user.token = mes.token

        success()