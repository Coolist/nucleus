api = require '../common/api'

spacesResource = ($resource) ->
  $resource api.config.endpoint + '/places/:placeId/spaces/:spaceId',
    placeId: '@placeId'
    spaceId: '@spaceId'
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
  spacesResource
]