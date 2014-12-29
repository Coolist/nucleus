# Load Node modules
Q = require 'q'

# Load custom modules
db = require '../mongodb/connect.coffee'
db.services = db.db.collection 'services'
db.devices = db.db.collection 'devices'
Nest = require '../bindings/nest.coffee'

# Helpers
errors = require '../helpers/errors.coffee'

# Services
services =
  nest:
    'auth_url': 'https://home.nest.com/login/oauth2?client_id=578b4e73-2ca9-4a7f-a336-b444ecd93d25&state=STATE'
    'query_token': 'code'

# Find a service auth redirect URL
exports.getRedirect = (service) ->

  if services[service]?
    return services[service].auth_url

# Find an "activate service" URL
exports.getActivate = (req) ->
  service = req.params.service

  if services[service]?
    return "http://nucleushome.com/device-auth?service=#{service}&token=#{req.query[services[service].query_token]}"
    
# Activate service
exports.activateService = (params) ->
  switch params.service
    when 'nest'
      service = new Nest.class params.authToken

  db.services.findOne
    place: params.place
    service: params.service
  .then (object) ->
    if object
      if new Date() > new Date object.expires_in
        throw new Error errors.build 'Service has expired.  Reauthentication required.', 404
      else
        service.setAccess object.access_token
        return object
    else
      service.getAccess()
      .then (res) ->
        db.services.insert
          _id: db.id()
          service: params.service
          place: params.place
          auth_token: params.authToken
          access_token: res.access_token
          expires: new Date Date.now() + res.expires_in * 1000
        .then (object) ->
          return object
      .fail () ->
        throw new Error errors.build 'Invalid service authentication token.', 400
  .then (object) ->
    service.getDevices()
    .then (devices) ->

      for device in devices
        device._id = db.id()
        device.place = params.place
        device.activated = false
        device.service = object._id

        db.devices.findOne
          service_id: device.service_id
        .then (object) ->
          if not object
            db.devices.insert device

    .fail () ->
      throw new Error errors.build 'Failed to retrieve device list.', 400


