
# TCPMOLE

Creats quick-and-dirty ad-hoc local tcp connection tunnel / proxy to another port / machine.

```sh
$ npm install -g tcpmole
```

### How to

EXAMPLE: Create local tunnels to run your redis-based tests on production servers:

```sh
$ tcpmole 6379 your-amazon-host.amazon.com:6379
```

This will makes your local port 6379 actually connects to amazon! :)

### Also good for monitoring stuff

Wanna see all the live traffic going through the tunnel? Just add `--monitor`!

```sh
$ tcpmole --monitor 6379 your-amazon-host.amazon.com:6379
```

### Also works for websites as well.

Much easier than writing obscure package capture language for sure!

```sh
$ tcpmole --monitor 80 3000
```

Now sends something to port 80 and you should see the HTTP packets being sent.

### Uses as a module

Right now the mole exports a simple function that creates proxying server when invoked:

```js
var mole = require('tcpmole')
  , opts =
    { src: { port: 80 }
    , dest: { host: '0.0.0.0', port: 8080 }
    }
  , tunnel = mole(opts);

tunnel.on('connection', function() {
  // a connection has been made to the mole
});
```

# LICENSE

BSD

# SUPPORT / CONTRIBUTE

Just opens [a new GitHub issue](https://github.com/chakrit/tcpmole/issues/new),
pings me on Twitter [@chakrit](https://twitter.com/chakrit),
or if you see me on the node.js irc channel (by the name chakrit), just ask me there :)

