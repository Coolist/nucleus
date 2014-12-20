# Load Node modules
Q = require 'q'

# Load custom modules
db = require '../mongodb/connect.coffee'
db.services = db.db.collection 'services'
# db.spaces = db.db.collection 'spaces'

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

# Activate a service (auth)
exports.getActivate = (req) ->
  service = req.params.service

  if services[service]?
    return "http://nucleushome.com/device-auth?service=#{service}&token=#{req.query[services[service].query_token]}"
    