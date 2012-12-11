
# src/tcpmole.coffee - Main tcpmole tunnel function
module.exports = do ->

  net = require 'net'
  assert = require 'assert'

  return (opts) ->
    assert typeof opts is 'object', 'options argument missing not an object'
    assert typeof opts.src is 'object', 'options.src missing or not an object'
    assert typeof opts.dest is 'object', 'options.dest missing or not an object'

    handleClient = (client) ->
      forward = net.connect opts.dest
      client.pipe forward
      forward.pipe client

    tunnel = net.createServer handleClient
    tunnel.listen opts.src.port

    return tunnel

