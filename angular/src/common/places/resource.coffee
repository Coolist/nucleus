api = require '../api'

placesResource = ($resource) ->
  return $resource api.config.endpoint + '/places/:placeId',
    placeId: '@placeId',
    auth: true
  ,
    query:
      method: 'GET'
      isArray: true
    post:
      method: 'POST'
    get:
      method: 'GET'
    update:
      method: 'PUT'
    delete:
      method: 'DELETE'


module.exports = [
  '$resource',
  placesResource
]