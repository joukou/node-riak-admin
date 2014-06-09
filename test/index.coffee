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

    describe 'status', ->

      specify 'is defined', ->
        should.exist( riak_admin.bucketType.status )
        riak_admin.bucketType.status.should.be.a( 'function' )

      specify 'is an object of properties for the requested bucket type', ->
        spawn = stubSpawn(
          [
            'n_val_of_3 has been created and may be activated\n'
            '\n'
            'young_vclock: 20\n'
            'w: quorum\n'
            'small_vclock: 50\n'
            'rw: quorum\n'
            'r: quorum\n'
            'pw: 0\n'
            'precommit: []\n'
            'pr: 0\n'
            'postcommit: []\n'
            'old_vclock: 86400\n'
            'notfound_ok: true\n'
            'n_val: 3\n'
            'linkfun: {modfun,riak_kv_wm_link_walker,mapreduce_linkfun}\n'
            'last_write_wins: false\n'
            'dw: quorum\n'
            'dvv_enabled: true\n'
            'chash_keyfun: {riak_core_util,chash_std_keyfun}\n'
            'big_vclock: 50\n'
            'basic_quorum: false\n'
            'allow_mult: true\n'
            'active: false\n'
            'claimant: \'riak@127.0.0.1\'\n'
          ],
          [],
          1 # riak-admin bucket-type status incorrectly returns non-zero exit code
        )
        main.__set__( 'spawn', spawn )
        result = riak_admin.bucketType.status( 'n_val_of_2' )
        result.should.eventually.deep.equal(
          young_vclock: 20,
          w: 'quorum',
          small_vclock: 50,
          rw: 'quorum',
          r: 'quorum',
          pw: 0,
          precommit: '[]',
          pr: 0,
          postcommit: '[]',
          old_vclock: 86400,
          notfound_ok: true,
          n_val: 3,
          linkfun: '{modfun,riak_kv_wm_link_walker,mapreduce_linkfun}',
          last_write_wins: false,
          dw: 'quorum',
          dvv_enabled: true,
          chash_keyfun: '{riak_core_util,chash_std_keyfun}',
          big_vclock: 50,
          basic_quorum: false,
          allow_mult: true,
          active: false,
          claimant: '\'riak@127.0.0.1\''
        )
        spawn.should.have.been.calledWithMatch( 'sudo /usr/sbin/riak-admin', [ 'bucket-type', 'status', 'n_val_of_2' ] )
        result

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
