
/**
@author Isaac Johnston <isaac.johnston@joukou.com>
@copright (c) 2014 Joukou Ltd. All rights reserved.

This Source Code Form is subject to the terms of the Mozilla Public License,
v. 2.0. If a copy of the MPL was not distributed with this file, You can obtain
one at http://mozilla.org/MPL/2.0/.
 */
var Q, spawn, _;

_ = require('lodash');

Q = require('q');

spawn = require('child_process').spawn;

module.exports = function(_arg) {
  var cmd;
  cmd = _arg.cmd;
  return {
    bucketType: {
      list: function() {
        var child, deferred, stderr, stdout;
        deferred = Q.defer();
        child = spawn(cmd, ['bucket-type', 'list']);
        stdout = '';
        stderr = '';
        child.stdout.on('data', function(chunk) {
          return stdout += chunk;
        });
        child.stderr.on('data', function(chunk) {
          return stderr += chunk;
        });
        child.on('close', function(code) {
          var bucketTypes, matches;
          if (code !== 0) {
            deferred.reject(new Error(stderr));
            return;
          }
          matches = stdout.match(/^[\w_]+ \((active|not active)\)$/gm);
          bucketTypes = _.map(matches, function(match) {
            var name, status, _ref;
            _ref = match.match(/^([\w_]+) \((active|not active)\)$/m), match = _ref[0], name = _ref[1], status = _ref[2];
            return {
              name: name,
              active: status === 'active'
            };
          });
          return deferred.resolve(bucketTypes);
        });
        return deferred.promise;
      },
      create: function(name, options) {
        var child, deferred, stderr, stdout;
        deferred = Q.defer();
        child = spawn(cmd, ['bucket-type', 'create', name, "'" + (JSON.stringify(options)) + "'"]);
        stdout = '';
        stderr = '';
        child.stdout.on('data', function(chunk) {
          return stdout += chunk;
        });
        child.stderr.on('data', function(chunk) {
          return stderr += chunk;
        });
        child.on('close', function(code) {
          if (code !== 0) {
            deferred.reject(new Error(stderr));
            return;
          }
          return deferred.resolve();
        });
        return deferred.promise;
      }
    }
  };
};
