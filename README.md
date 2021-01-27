# osc.nvim

[OSC][osc] (Open Sound Control) library for Neovim.

This plugin can be used as a OSC client/server and/or as a drop-in library to
enable OSC communcation for any `nvim` plugin.

It is built on the [losc][losc] OSC library for lua.

## Project status

- [x] Send
- [x] Receive
- [x] UDP
- [ ] TCP

## Features

* No external binary dependencies
* Full OSC 1.0 compatability (see [losc] for more details)
* TCP/UDP transport layers
* Standalone
* Can be used as drop-in library for third-party plugins

## Examples

### Simple server

```lua
local osc = require'osc'.new{
  transport = 'udp',
  recvAddr = '127.0.0.1',
  recvPort  = 9000,
}

-- register a "catch all" handler
osc:add_handler('*', function(data)
  print(vim.inspect(data))
end)

-- open the OSC server
osc:open()
```

### Simple client

```lua
local osc = require'osc'.new{
  transport = 'udp',
  sendAddr = '127.0.0.1',
  sendPort = 57120,
}

local message = osc.new_message{
  address = '/test',
  types = 'ifs',
  1, 2, 'hello from nvim!'
}

local ok, err = osc:send(message)
if not ok then
  print(err)
end
```

[osc]: http://opensoundcontrol.org/spec-1_0
[losc]: https://github.com/davidgranstrom/losc
