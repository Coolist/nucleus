projectsCtrl = ($scope, $routeParams, $location, projectsResource) ->
  
  projectsResource.query (projects) ->
    if projects[0]?
      $location.path 'places/' + projects[0].id
    else
      projectsResource.post
        name: 'Example Place'
      , (project) ->
        $location.path 'places/' + project.id

module.exports = [
  '$scope'
  '$routeParams'
  '$location'
  'projectsResource'
  projectsCtrl
]