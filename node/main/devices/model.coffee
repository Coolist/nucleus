# Load Node modules
Q = require 'q'
redis = require 'redis'

# Load custom modules
db = require '../mongodb/connect.coffee'
db.places = db.db.collection 'places'
db.devices = db.db.collection 'devices'
db.services = db.db.collection 'services'

# Helpers
errors = require '../helpers/errors.coffee'

# Client for the device message queue
deviceMQ = redis.createClient()

# Find a device
exports.readOne = (params) ->
  db.devices.findOne
    _id: params.id
    place: params.placeId
  .then (object) ->
    if object
      ret =
        id: object._id
        name: object.name
        place: object.place
        service: object.service
        properties: object.properties
        states: object.states
    else
      throw new Error errors.build 'A device with that ID was not found.', 404
    return ret

# Find all devices
exports.read = (params) ->
  activated = true
  activated = false if params.activated? and params.activated is 'false'

  db.devices.find
    place: params.placeId
    activated: activated
  .toArray()
  .then (object) ->
    ret = []

    for item in object
      ret.push
        id: item._id
        name: item.name
        place: item.place
        service: item.service
        properties: item.properties
        states: item.states

    return ret

# Create new device
###
exports.create = (params) ->
  deviceId = db.id()

  db.places.findOne
    _id: params.placeId
  .then (object) ->
    if not object
      throw new Error errors.build 'A place with that ID was not found.', 404
  .then () ->
    db.devices.insert
      _id: deviceId
      place: params.placeId
      name: params.name
  .then (object) ->
    return object._id
###

# Update a device
exports.update = (params) ->
  db.devices.update
    _id: params.id
    place: params.placeId
  ,
    { $set: params.update }
  .then (res) ->
    if res.ok
      return true
    else
      throw new Error errors.build 'A device with that ID was not found.', 404

# Update a device's state
exports.updateState = (params) ->
  db.devices.findOne
    _id: params.id
    place: params.placeId
  .then (object) ->
    if object
      db.services.findOne
        _id: object.service
      .then (serviceObject) ->
        switch serviceObject.service
          when 'nucleus-center'
            for key, value of params.body
              exists = false

              # Check to see if the property exists and is writeable
              for keyP, valueP of object.properties
                if key is keyP and valueP is 2
                  exists = true

              if exists
                do (deviceMQ, object, key, value) ->
                  deviceMQ.publish 'device-mq', JSON.stringify
                    device: object._id
                    id: object.service_id
                    place: object.place
                    property: key
                    value: value
    else
      throw new Error errors.build 'A device with that ID was not found.', 404
    

# Delete a device
exports.delete = (params) ->
  db.devices.findOne
    _id: params.id
    place: params.placeId
  .then (object) ->
    if object
      db.devices.remove
        _id: params.id
      return true
    else
      throw new Error errors.build 'A device with that ID was not found.', 404
    return ret