
# test/tcpmole.coffee - Tests for the tcpmole function
do ->

  _ = require 'underscore'
  a = require 'async'
  net = require 'net'
  { nextTick } = process

  require './helper'

  MSG_HELLO = 'hello, please send me things!'
  MSG_REPLY = 'the quick brown fox jumps over the lazy dog.'
  OPTS =
    src:
      port: 111222
    dest:
      port: 222111

  describe 'tcpmole module', ->
    before -> @mole = source 'tcpmole'
    after -> delete @mole

    it 'should exports a function', ->
      @mole.should.be.a 'function'

    describe 'exported function', ->
      itShouldValidate = (description, opts, regex) ->
        it "should throws if #{description}", ->
          (=> @mole opts).should.throws regex

      itShouldValidate 'options not given', undefined, /options/i
      itShouldValidate 'options not an object', 'string', /options/i
      itShouldValidate 'src key not given in options', { }, /src/i
      itShouldValidate 'src key given not an object',  src: 'string', /src/i
      itShouldValidate 'dest key not given in options', src: { }, /dest/i
      itShouldValidate 'dest key given not an object', src: { }, /dest/i

    describe 'server creation', ->
      before ->
        @create = =>
          @tunnel = @mole OPTS

      after (done) ->
        delete @create

        unless @tunnel
          done()
        else
          @tunnel.close done
          delete @tunnel

      it 'should returns a net.Server instance', ->
        @create().should.be.instanceof net.Server

    describe 'with test server', ->
      before (done) ->
        @server = net.createServer (client) =>
          @server.client = client

          client.once 'data', (chunk) =>
            @server.emit 'message', chunk
            @server.lastMessage = chunk

            client.end MSG_REPLY if chunk.toString() is MSG_HELLO

          client.once 'end', () =>
            @server.emit 'client end'

        @server.listen OPTS.dest.port, done
        @tunnel = @mole OPTS

        _.bindAll @server
        _.bindAll @tunnel

      after (done) ->
        a.series [@server.close, @tunnel.close], done

      connect = (action) -> (done) ->
        @server.once 'connection', () =>
          action @server, client, (e) =>
            @server.client.destroy()
            client.destroy()
            done e

        client = net.connect OPTS.src.port


      it 'should connects to the server when a client connects to the mole',
        connect (server, client, done) ->
          server.connections.should.eq 1
          done()

      it 'should forwards message to the server when a client sends a message',
        connect (server, client, done) ->
          server.once 'message', (msg) ->
            msg.toString().should.eql MSG_HELLO
            done()

          client.write MSG_HELLO

      it 'should relays server messages to client when the server send replies',
        connect (server, client, done) ->
          client.once 'data', (chunk) ->
            chunk.toString().should.eql MSG_REPLY
            done()

          client.write MSG_HELLO

      it 'should ends server connection when client connection ends', ->
        connect (server, client, done) ->
          server.once 'client end', done
          client.end()

      it 'should ends client connection when server connection ends', ->
        connect (server, client, done) ->
          client.once 'end', done
          server.client.end()

