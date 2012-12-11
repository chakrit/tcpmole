
# src/cli.coffee - CLI for tcpmole
module.exports = do ->

  assert = require 'assert'
  url = require 'url'
  colors = require 'colors' # infect String.prototype
  optimist = require 'optimist'
  { log } = console

  argv = optimist
    .boolean('monitor').default('monitor', false)
    .boolean('quiet').default('quiet', false)
    .argv

  mole = require './tcpmole'

  # validate args
  port = argv._[0]
  dest = argv._[1]

  try
    assert typeof port is 'number'
    assert typeof dest is 'number' or typeof dest is 'string'
  catch e
    return log(
      """
      USAGE: tcpmole [--monitor] [--quiet] local_port dest_port_or_uri

        local_port        - Port to bind locally.
        dest_port_or_uri  - Destination port to forward connections to.

        --monitor         - Prints all traffic going through the mole
        --quiet           - Disables all printing completely
      """
    )

  # starts a tunnel
  tunnel = mole
    src:
      port: port
    dest: if typeof dest is 'number'
      port: dest
    else
      dest = url.parse dest
      dest.host = dest.hostname
      dest

  tunnel.on 'connection', (client) ->
    remote = "#{client.remoteAddress}:#{client.remotePort}"

    unless argv.quiet
      log "#{remote} connects (#{tunnel.connections} alive)".grey
      client.once 'end', ->
        log "#{remote} disconnects (#{tunnel.connections} alive)".grey

      if argv.monitor
        client.on 'data', (chunk) ->
          log "#{remote} sends".green
          log chunk.toString()

        client.write = do (write_ = client.write) -> (chunk, args...) ->
          log "#{remote} receives".yellow
          log chunk.toString()

          write_.call client, chunk, args...

