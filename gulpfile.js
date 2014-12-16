var gulp = require('gulp'),
  concat = require('gulp-concat'),
  uglify = require('gulp-uglify'),
  watch = require('gulp-watch'),
  nodemon = require('gulp-nodemon'),
  coffee = require('gulp-coffee'),
  gutil = require('gulp-util'),
  coffeelint = require('gulp-coffeelint'),
  mocha = require('gulp-mocha');

require('coffee-script/register');

gulp.task('coffeelint', function() {
  gulp
    .src([
      './javascript/**/*.coffee',
      './test.coffee',
      './node/**/*.coffee',
      './node/main/**/*.coffee'])
    .pipe(coffeelint({
      'indentation': {
        'value': 2
      },
      'no_tabs': {
        'level': 'ignore'
      },
      'no_backticks': {
        'level': 'ignore'
      },
      'max_line_length': {
        'level': 'ignore'
      }
    }))
        .pipe(coffeelint.reporter())
});

gulp.task('test', function () {
  gulp.src('./test/**/*.coffee')
    .pipe(mocha({reporter: 'spec'}));
});

// Start Node server + watch files for changes
gulp.task('serve', ['coffeelint'], function () {

  nodemon({ script: 'node.js', ext: 'html js coffee', ignore: ['node_modules/*', 'angular/*'] })
    .on('change', ['coffeelint'])
    .on('restart', function (files) {
      
    });
});