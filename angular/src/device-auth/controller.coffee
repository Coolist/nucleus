deviceAuthCtrl = ($scope, $routeParams, $location, deviceAuthResource) ->
  
  deviceAuthResource.query (deviceAuth) ->
    if deviceAuth[0]?
      $location.path 'deviceAuth/' + deviceAuth[0].id
    else
      deviceAuthResource.post
        name: 'Example Place'
      , (project) ->
        $location.path 'deviceAuth/' + project.id

module.exports = [
  '$scope'
  '$routeParams'
  '$location'
  'deviceAuthResource'
  deviceAuthCtrl
]