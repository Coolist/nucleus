# Load Node modules
Q = require 'q'
redis = require 'redis'

# Load custom modules
db = require '../main/mongodb/connect.coffee'
db.services = db.db.collection 'services'
db.devices = db.db.collection 'devices'
check = require '../main/authentication/check'

# Helpers
errors = require '../main/helpers/errors.coffee'

# Notification queue
notificationMQ = redis.createClient()

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

      do (device, update) ->
        db.devices.findOne
          service_id: device.id
        .then (object) ->
          if object
            db.devices.update
              service_id: device.id
            ,
              $set: update

            exports.updateNotify
              _id: object._id
              place: object.place
              states: update.states
          else
            update._id = db.id()
            update.activated = false
            update.name = device.local_name

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
              when 'hue:light:1'
                update.type = 'light'
                update.properties =
                  power: 2
                  color: 2
                  brightness: 2

            db.devices.insert update
            .then (object) ->
              exports.updateNotify object

exports.updateNotify = (object) ->
  do (object) ->
  notificationMQ.publish 'notification-mq', JSON.stringify
    type: 'state'
    place: object.place
    id: object._id
    states: object.states
