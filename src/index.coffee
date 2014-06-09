###*
@author Isaac Johnston <isaac.johnston@joukou.com>
@copright (c) 2014 Joukou Ltd. All rights reserved.

This Source Code Form is subject to the terms of the Mozilla Public License,
v. 2.0. If a copy of the MPL was not distributed with this file, You can obtain
one at http://mozilla.org/MPL/2.0/.
###


_ = require( 'lodash' )
Q = require( 'q' )
{ spawn } = require( 'child_process' )

module.exports = ( { cmd } ) ->

  bucketType:

    list: ->
      deferred = Q.defer()

      child = spawn( cmd, [ 'bucket-type', 'list' ] )

      stdout = ''
      stderr = ''

      child.stdout.on( 'data', ( chunk ) ->
        stdout += chunk
      )

      child.stderr.on( 'data', ( chunk ) ->
        stderr += chunk
      )

      child.on( 'close', ( code ) ->
        unless code is 0
          deferred.reject( new Error( stderr ) )
          return

        matches = stdout.match( /^[\w_]+ \((active|not active)\)$/gm )
        bucketTypes = _.map( matches, ( match ) ->
          [ match, name, status ] =
            match.match( /^([\w_]+) \((active|not active)\)$/m )
          name: name
          active: status is 'active'
        )

        deferred.resolve( bucketTypes )
      )

      deferred.promise

    create: ( name, options ) ->
      deferred = Q.defer()

      child = spawn( cmd, [
        'bucket-type', 'create', name, "'#{JSON.stringify( options )}'"
      ] )
      
      stdout = ''
      stderr = ''

      child.stdout.on( 'data', ( chunk ) ->
        stdout += chunk
      )

      child.stderr.on( 'data', ( chunk ) ->
        stderr += chunk
      )

      child.on( 'close', ( code ) ->
        unless code is 0
          deferred.reject( new Error( stderr ) )
          return

        deferred.resolve()
      )

      deferred.promise
