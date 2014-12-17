spacesCtrl = ($scope, $routeParams, $location, spacesResource) ->

  # Temp loading var
  $scope.loading = true

  spacesResource.query
    placeId: $routeParams.placeId
  , (spaces) ->
    $scope.spaces = spaces
    $scope.loading = false

  $scope.action =
    add: ->
      name = $scope.input.name
      $scope.input.name = ''
      $scope.loading = true

      if name
        spacesResource.post
          placeId: $routeParams.placeId
        ,
          name: name
        , (space) ->
          $scope.spaces.push
            name: name
            id: space.id
            active: false
            archived: false
          $scope.loading = false
      else
        $scope.loading = false
    

    delete: (space) ->
      if confirm 'Delete space ' + space.name + '?'
        $scope.spaces.splice $scope.spaces.indexOf(space), 1
        $scope.loading = true

        spacesResource.delete
          placeId: $routeParams.placeId
          spaceId: space.id
        , (success) ->
          $scope.loading = false

###goto:
  tests: (space) ->
    $location.path 'places/' + $routeParams.placeId + '/spaces/' + space.id
###
  

module.exports = [
  '$scope'
  '$routeParams'
  '$location'
  'spacesResource'
  spacesCtrl
]