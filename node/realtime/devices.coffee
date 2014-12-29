# Load Node modules
Q = require 'q'

# Load custom modules
db = require '../main/mongodb/connect.coffee'
db.services = db.db.collection 'services'
db.devices = db.db.collection 'devices'
check = require '../main/authentication/check'

# Helpers
errors = require '../main/helpers/errors.coffee'

exports.getService = (user, success) ->

  check.permissions
    query:
      token: user.token
    params:
      id: user.place
  , 3
  .then () ->
    db.services.findOne
      place: user.place
      service: 'nucleus-center'
    .then (object) ->
      if object
        user.service = object._id
        success()
      else
        db.services.insert
          _id: db.id()
          service: 'nucleus-center'
          place: user.place
        .then (object) ->
          user.service = object._id
          success()
  .fail (error) ->
    e = errors.parse error.message

  .done()

exports.update = (data, user) ->
  if user.service? and data?
    for device in data
      update =
        service_id: device.id
        place: user.place
        service: user.service
        states: device.states

      switch device.name
        when 'wemo:wallSwitch:1'
          update.type = 'switch'
          update.properties =
            power: 2
        when 'wemo:lightSwitch:1'
          update.type = 'switch'
          update.properties =
            power: 2
        when 'wemo:motion:1'
          update.type = 'sensor'
          update.properties =
            motion: 1

      do (device, update) ->
        db.devices.findOne
          service_id: device.id
        .then (object) ->
          if object
            db.devices.update
              service_id: device.id
            ,
              $set: update
          else
            update._id = db.id()
            update.activated = false

            db.devices.insert update

