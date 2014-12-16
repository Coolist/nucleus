accessService = ($q, accessResource, $localStorage) ->
  methods =
    roleValue: (role) ->
      switch role
        when 'owner'
          return 3
        when 'editor'
          return 2
        when 'viewer'
          return 1

    getAccess: (place) ->
      deferred = $q.defer()

      accessResource.query
        placeId: place
      , (users) ->
        for user in users
          if user.id = $localStorage.userSettings.id
            deferred.resolve methods.roleValue user.role

      return deferred.promise

module.exports = [
  '$q'
  'accessResource'
  '$localStorage'
  accessService
]