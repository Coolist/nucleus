spacesNewCtrl = ($scope, $routeParams, $location, spacesResource) ->

  $scope.step = 1
  $scope.space = {}
  $scope.loading = false

  $scope.action =
    add: ->
      name = $scope.input.name
      $scope.input.name = ''

      if name and $scope.loading is false
        $scope.loading = true

        spacesResource.post
          placeId: $routeParams.placeId
        ,
          name: name
        , (space) ->
          $scope.space =
            id: space.id

          $scope.loading = false
          $location.path 'places/' + $routeParams.placeId

module.exports = [
  '$scope'
  '$routeParams'
  '$location'
  'spacesResource'
  spacesNewCtrl
]