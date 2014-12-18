spacesNewCtrl = ($scope, $routeParams, $location, spacesResource) ->

  $scope.step = 1

  $scope.action =
    doStep: (step) ->
      switch step
        when 1
          if $scope.step = 1
            @.add()

          $scope.step = 2
        when 2
          $scope.step = 3
    add: ->
      name = $scope.input.name
      $scope.loading = true

      if name
        spacesResource.post
          placeId: $routeParams.placeId
        ,
          name: name
        , (space) ->
          ###
          $scope.spaces.push
            name: name
            id: space.id###
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
  

module.exports = [
  '$scope'
  '$routeParams'
  '$location'
  'spacesResource'
  spacesNewCtrl
]