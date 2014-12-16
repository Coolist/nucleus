api = require '../api'

accessResource = ($resource) ->
  return $resource api.config.endpoint + '/places/:placeId/users/:userId',
    placeId: '@placeId',
    userId: '@userId'
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
  '$resource'
  accessResource
]