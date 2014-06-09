[![Stories in Ready](https://badge.waffle.io/joukou/node-riak-admin.png?label=ready&title=Ready)](https://waffle.io/joukou/node-riak-admin) [![Build Status](https://travis-ci.org/joukou/node-riak-admin.svg?branch=master)](https://travis-ci.org/joukou/node-riak-admin) [![Coverage Status](https://img.shields.io/coveralls/joukou/node-riak-admin.svg)](https://coveralls.io/r/joukou/node-riak-admin) [![NPM version](https://badge.fury.io/js/riak-admin.svg)](http://badge.fury.io/js/node-riak-admin) ![Dependencies](https://david-dm.org/joukou/node-riak-admin.png) [![MPL-2.0](http://img.shields.io/badge/license-MPL--2.0-brightgreen.svg)](#license)

node-riak-admin
===============

A Node.js module for programmatically using the riak-admin tool for Basho Riak
2.0.

## Usage

### Bucket Types

#### List

Equivalent of `riak-admin bucket-type list`

```javascript
var riak_admin = require( 'riak-admin' )( cmd: 'sudo /usr/sbin/riak-admin' );
riak_admin.bucketType.list().then( function( bucketTypes ) {
  # bucketTypes is e.g. [ { name: 'default', active: true } ]
});
```

#### Status

Equivalent of `riak-admin bucket-type status`

```javascript
var riak_admin = require( 'riak-admin' )( cmd: 'sudo /usr/sbin/riak-admin' );
riak_admin.bucketType.status( 'n_val_of_2' ).then( function( status ) {

});
```

### Activate

Equivalent of `riak-admin bucket-type activate`

```javascript
var riak_admin = require( 'riak-admin' )( cmd: 'sudo /usr/sbin/riak-admin' );
riak_admin.bucketType.activate( 'n_val_of_2' ).then( function( ) {

});
```

#### Create

Equivalent of `riak-admin bucket-type create`

```javascript
var riak_admin = require( 'riak-admin' )( cmd: 'sudo /usr/sbin/riak-admin' );
riak_admin.bucketType.create( 'n_val_of_2', props: { n_val: 2 } ).then( function() {
 # success
});
```

#### Update

Equivalent of `riak-admin bucket-type update`

```javascript
var riak_admin = require( 'riak-admin' )( cmd: 'sudo /usr/sbin/riak-admin' );
riak_admin.bucketType.update( 'n_val_of_2', props: { allow_mult: false } ).then( function() {
 # success
});
```

## License

This Source Code Form is subject to the terms of the Mozilla Public License,
v. 2.0. If a copy of the MPL was not distributed with this file, You can obtain
one at http://mozilla.org/MPL/2.0/.
