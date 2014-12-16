placesCtrl = ($scope, $routeParams, $location, placesResource) ->
  
  placesResource.query (places) ->
    if places[0]?
      $location.path 'places/' + places[0].id
    else
      placesResource.post
        name: 'Example Place'
      , (project) ->
        $location.path 'places/' + project.id

module.exports = [
  '$scope'
  '$routeParams'
  '$location'
  'placesResource'
  placesCtrl
]