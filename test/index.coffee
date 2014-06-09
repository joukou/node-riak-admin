###*
@author Isaac Johnston <isaac.johnston@joukou.com>
@copright (c) 2014 Joukou Ltd. All rights reserved.

This Source Code Form is subject to the terms of the Mozilla Public License,
v. 2.0. If a copy of the MPL was not distributed with this file, You can obtain
one at http://mozilla.org/MPL/2.0/.
###

assert            = require( 'assert' )
chai              = require( 'chai' )
chai.use( require( 'sinon-chai' ) )
chai.use( require( 'chai-as-promised' ) )
should            = chai.should()
sinon             = require( 'sinon' )
rewire            = require( 'rewire' )

{ EventEmitter }  = require( 'events' )

main              = rewire( '../' )
riak_admin        = main( cmd: 'sudo /usr/sbin/riak-admin' )

stubSpawn = ( stdout, stderr, code ) ->
  child = new class extends EventEmitter
    stdout: new class extends EventEmitter
    stderr: new class extends EventEmitter

  interval = setInterval( ->
    if stdout.length
      child.stdout.emit( 'data', stdout.shift() )
    if stderr.length
      child.stderr.emit( 'data', stderr.shift() )
    if not (stdout.length or stderr.length)
      clearInterval( interval )
      child.emit( 'close', code )
  , 5 )

  sinon.stub().returns( child )


describe 'riak-admin', ->

  describe 'bucketType', ->

    specify 'is defined', ->
      should.exist( riak_admin.bucketType )

    describe 'list', ->

      specify 'is defined', ->
        should.exist( riak_admin.bucketType.list )
        riak_admin.bucketType.list.should.be.a( 'function' )

      specify 'is an array of a single bucket type given the default state', ->
        main.__set__( 'spawn', stubSpawn( [ 'default (active)' ], [], 0 ) )
        riak_admin.bucketType.list().should.eventually.deep.equal(
          [
            {
              name: 'default'
              active: true
            }
          ]
        )

      specify 'is an array of several bucket types given a non-default state', ->
        main.__set__( 'spawn', stubSpawn(
          [ 'default (active)\n', 'n_val_of_2 (not active)\n', 'user_account_bucket (active)' ],
          [],
          0
        ) )
        riak_admin.bucketType.list().should.eventually.deep.equal(
          [
            {
              name: 'default'
              active: true
            }
            {
              name: 'n_val_of_2'
              active: false
            }
            {
              name: 'user_account_bucket'
              active: true
            }
          ]
        )

      specify 'is an Error given a failure exit code', ->
        main.__set__( 'spawn', stubSpawn( [ 'default (active)' ], [ 'There was an error' ], 1 ) )
        riak_admin.bucketType.list().should.eventually.be.rejectedWith( Error, 'There was an error' )

    describe 'create', ->

      specify 'is defined', ->
        should.exist( riak_admin.bucketType.create )
        riak_admin.bucketType.create.should.be.a( 'function' )

      specify 'creates a new bucket type', ->
        spawn = stubSpawn( [ 'n_val_of_2 created' ], [], 0 )
        main.__set__( 'spawn', spawn )
        result = riak_admin.bucketType.create( 'n_val_of_2', props: { n_val: 2 } )
        result.should.eventually.be.fulfilled
        spawn.should.have.been.calledWithMatch( 'sudo /usr/sbin/riak-admin', [ 'bucket-type', 'create', 'n_val_of_2', '\'{"props":{"n_val":2}}\'' ] )
        result
