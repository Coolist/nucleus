# Load Node modules
Q = require 'q'
restler = require 'restler'

# Helpers
errors = require '../helpers/errors.coffee'

class Nest
  constructor: (@token) ->
  setAccess: (@access) ->
  getAccess: () ->
    deferred = Q.defer()

    restler.post "https://api.home.nest.com/oauth2/access_token?client_id=578b4e73-2ca9-4a7f-a336-b444ecd93d25&code=#{@token}&client_secret=T3PyxigkHBMsn2tP94S77JW4A&grant_type=authorization_code"
    .on 'complete', (data, res) ->
      if res.statusCode is 200
        @access = data.access_token
        deferred.resolve data
      else
        deferred.reject false

    return deferred.promise
  getDevices: () ->
    deferred = Q.defer()
    devices = []

    restler.get "https://developer-api.nest.com/devices.json?auth=#{@access}"
    .on 'complete', (data, res) ->
      if res.statusCode is 200
        if data.thermostats?
          for k,v of data.thermostats
            devices.push
              service_id: k
              type: 'thermostat'
              name: v.name_long
              temperature_scale: v.temperature_scale
              properties:
                'temperature': 'read/write'
                'humidity': 'read'
        deferred.resolve devices
      else
        deferred.reject false

    return deferred.promise

exports.class = Nest