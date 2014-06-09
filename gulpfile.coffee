###*
@author Isaac Johnston <isaac.johnston@joukou.com>
@copright (c) 2014 Joukou Ltd. All rights reserved.

This Source Code Form is subject to the terms of the Mozilla Public License,
v. 2.0. If a copy of the MPL was not distributed with this file, You can obtain
one at http://mozilla.org/MPL/2.0/.
###

gulp        = require( 'gulp' )
plugins     = require( 'gulp-load-plugins' )( lazy: false )

gulp.task( 'sloc', ->
  gulp.src( 'src/**/*.coffee' )
    .pipe( plugins.sloc() )
)

gulp.task( 'coffeelint', ->
  gulp.src( 'src/**/*.coffee' )
    .pipe( plugins.coffeelint( optFile: 'coffeelint.json' ) )
    .pipe( plugins.coffeelint.reporter() )
    .pipe( plugins.coffeelint.reporter( 'fail' ) )
)

gulp.task( 'clean', ->
  gulp.src( 'lib', read: false )
    .pipe( plugins.clean( force: true ) )
    .on( 'error', plugins.util.log )
)

gulp.task( 'coffee', [ 'clean' ], ->
  gulp.src( 'src/**/*.coffee' )
    .pipe( plugins.coffee( bare: true ) )
    .pipe( gulp.dest( 'lib' ) )
    .on( 'error', plugins.util.log )
)

gulp.task( 'build', [ 'sloc', 'coffeelint', 'coffee' ] ) 

gulp.task( 'test', [ 'build' ], ( done ) ->
  gulp.src( 'lib/**/*.js' )
    .pipe( plugins.istanbul() )
    .on( 'finish', ->
      gulp.src( 'test/**/*.coffee', read: false )
        .pipe( plugins.mocha(
          ui: 'bdd'
          reporter: 'spec'
          compilers: 'coffee:coffee-script/register'
        ) )
        .pipe( plugins.istanbul.writeReports( 'coverage' ) )
        .on( 'end', done )
    )
  return
)

gulp.task( 'coveralls', [ 'test' ], ->
  gulp.src( 'coverage/lcov.info' )
    .pipe( plugins.coveralls() )
)

gulp.task( 'ci', [ 'coveralls' ] )

gulp.task( 'default', [ 'build' ] )