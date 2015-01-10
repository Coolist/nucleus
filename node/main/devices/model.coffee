# Load Node modules
Q = require 'q'
redis = require 'redis'

# Load custom modules
db = require '../mongodb/connect.coffee'
db.places = db.db.collection 'places'
db.spaces = db.db.collection 'spaces'
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
        space: object.space
        service: object.service
        type: object.type
        properties: object.properties
        states: object.states
        activated: object.activated
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
        space: item.space
        type: item.type
        service: item.service
        properties: item.properties
        states: item.states
        activated: item.activated

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

  update = () ->
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

  if params.update.space?
    db.spaces.findOne
      _id: params.update.space
      place: params.placeId
    .then (object) ->
      if object
        update()
      else
        throw new Error errors.build 'A space with that ID was not found (or you do not have access to it).', 404
  else
    update()

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
        if serviceObject.service is 'nucleus-center'
          for key, value of params.body
            if checkProperty object.properties, key
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

# Check if property exists
checkProperty = (properties, name, writeable = true) ->
  if writeable?
    w = 2
  else
    w = 1

  for key, value of properties
    if name is key and value is w
      return true

  return false