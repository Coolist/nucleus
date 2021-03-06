spacesCtrl = ($scope, $routeParams, $location, spacesResource, devicesResource, realtimeFactory) ->

  # Authenticate realtime
  realtimeFactory.checkAuth $routeParams.placeId

  # Temp loading var
  $scope.loading = 0

  # Realtime device state update
  $scope.$on 'socket:device:state', (ev, data) ->
    for i, device of $scope.devices
      if device.id? and device.id is data.id
        for state, value of data.states
          device.states[state] = value if device.states[state]?

  $scope.loading++
  spacesResource.query
    placeId: $routeParams.placeId
  , (spaces) ->

    if spaces.length is 0
      $location.path 'places/' + $routeParams.placeId + '/spaces/new'
    else
      if $routeParams.space?
        for space in spaces
          if $routeParams.space is space.id
            $scope.space = space

    $scope.spaces = spaces
    $scope.loading--

  $scope.loading++
  devicesResource.query
    placeId: $routeParams.placeId
  , (devices) ->

    $scope.devices = devices
    $scope.loading--

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

          $scope.action.goto.space space
      else
        $scope.loading = false

    setState: (device, name, value) ->
      update = {}
      update[name] = value

      devicesResource.updateState
        placeId: $routeParams.placeId
        deviceId: device.id
      , update

    delete: (space) ->
      if confirm 'Delete space ' + space.name + '?'
        $scope.spaces.splice $scope.spaces.indexOf(space), 1
        $scope.loading = true

        spacesResource.delete
          placeId: $routeParams.placeId
          spaceId: space.id
        , (success) ->
          $scope.loading = false

    goto:
      space: (space) ->
        $location.path 'places/' + $routeParams.placeId
        .search
          space: if space? then space.id else undefined
      addDevice: (space) ->
        $location.path 'places/' + $routeParams.placeId + '/spaces/' + space.id + '/devices/add'
        .search
          space: undefined
  

module.exports = [
  '$scope'
  '$routeParams'
  '$location'
  'spacesResource'
  'devicesResource'
  'realtimeFactory'
  spacesCtrl
]