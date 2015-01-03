# Common
common = [
 require('../common/places/directive.coffee').name
]

# Experiments module
styleguide = angular.module 'nucleus.styleguide', common

# Styles
require './style.scss'

module.exports = styleguide