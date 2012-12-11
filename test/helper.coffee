
# test/helper.coffee - Test initializer / helpers
module.exports = do ->

  _ = require 'underscore'
  chai = require 'chai'
  sinon = require 'sinon'
  { Stream } = require 'stream'

  SRC_FOLDER = unless process.env.COVER
    "../src/"
  else
    "../lib-cov/"


  chai.use require 'sinon-chai'
  chai.should() # infect Object.prototype

  return _.extend global or exports or this,
    source: (path) -> require "#{SRC_FOLDER}#{path}"
    log: console.log
    expect: chai.expect
    stub: sinon.stub
    spy: sinon.spy

    TestStream: class TestStream extends Stream
      constructor: ->
        @readable = true
        @writable = true

      write: (data) ->
        @emit 'data', data

      end: ->
        @emit 'end'

