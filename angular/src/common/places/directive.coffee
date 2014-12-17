places = angular.module 'nucleus.common.places', []
places.factory 'placesResource', require './resource.coffee'

placesCtrl = ($scope, $location, $routeParams, placesResource, accessService) ->
  placesResource.query (places) ->
    $scope.places = places
    $scope.place = $scope.places[0]

    for place in $scope.places
      if place.id is $routeParams.placeId
        $scope.place = place

    accessService.getAccess $scope.place.id
    .then (access) ->
      $scope.access = access

  $scope.action =
    add: ->
      name = $scope.input.place
      $scope.input.place = ''

      if name
        placesResource.post
          name: name
        , (place) ->
          index = $scope.places.push
            name: name
            id: place.id

          $scope.action.switch $scope.places[index - 1]
    switch: (place) ->
      $location.path 'places/' + place.id
    delete: (place) ->
      if confirm 'Delete place ' + place.name + '?'
        placesResource.delete
          placeId: place.id
        , () ->
          $scope.places.splice $scope.places.indexOf(place), 1

          if $scope.places.length > 0
            $scope.action.switch $scope.places[0]
          else
            $location.path 'places'


places.directive 'places', () ->
  restrict: 'E'
  template: require './view.html'
  scope:
    place: '='
    access: '='
  controller: [
    '$scope'
    '$location'
    '$routeParams'
    'placesResource'
    'accessService'
    placesCtrl
  ]

module.exports = places