spacesCtrl = ($scope, $routeParams, $location, spacesResource, devicesResource, realtimeFactory) ->

  # Temp loading var
  $scope.loading = 0

  $scope.loading++
  spacesResource.get
    placeId: $routeParams.placeId
    spaceId: $routeParams.spaceId
  , (space) ->

    $scope.space = space
    $scope.loading--
  , (error) ->
    alert 'That space not found, yo.'
    $location.path 'places/' + $routeParams.placeId

  $scope.loading++
  devicesResource.query
    placeId: $routeParams.placeId
    activated: false
  , (devices) ->

    $scope.devices = devices
    $scope.loading--

  $scope.selectedDevices = 0

  $scope.$watch 'devices', (devices) ->
    count = 0

    angular.forEach devices, (device) ->
      if device.selected
        count++

    $scope.selectedDevices = count
  , true

  $scope.action =
    add: () ->
      requests = 0
      $scope.loading++

      angular.forEach $scope.devices, (device) ->
        if device.selected
          requests++

          devicesResource.update
            placeId: $routeParams.placeId
            deviceId: device.id
          ,
            activated: true
            space: $routeParams.spaceId
          , (data) ->
            if data.success
              requests--

              if requests <= 0
                $scope.loading--
                $location.path 'places/' + $routeParams.placeId
                .search
                  space: $scope.space.id

    goto:
      space: (space) ->
        $location.path 'places/' + $routeParams.placeId
        .search
          space: if space? then space.id else undefined
  

module.exports = [
  '$scope'
  '$routeParams'
  '$location'
  'spacesResource'
  'devicesResource'
  'realtimeFactory'
  spacesCtrl
]