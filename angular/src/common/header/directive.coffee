header = angular.module 'nucleus.common.header', []

header.directive 'uiHeader', () ->
  restrict: 'E'
  template: require './view.html'
  scope:
    loading: '='

module.exports = header