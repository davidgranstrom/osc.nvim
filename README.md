# osc.nvim

[Open Sound Control][osc] (OSC) library for Neovim.

[![asciicast](https://asciinema.org/a/387587.svg)](https://asciinema.org/a/387587)

`osc.nvim` can be used as an OSC 1.0 compliant client/server in order to let
`nvim` communicate with OSC enabled applications over UDP/TCP.

`osc.nvim` exposes the full API from the [losc][losc] OSC library, read the documentation for `losc` [here](https://davidgranstrom.github.io/losc/).

This plugin does *not* expose any mappings or commands and is `lua` only, see the examples below for usage.

## Project status

- [x] Send
- [x] Receive
- [x] UDP
- [ ] TCP

## Features

* Full OSC 1.0 compatability (see [losc] for more details).
* No binary dependencies (pure lua).
* TCP/UDP transport layers using `vim.loop`.
* Can be used as a dependency to enable OSC communication for any `nvim` plugin.

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

### Full example

```lua
--- Send an OSC message on every keystroke.
--
-- Save this file in a `lua` directory available in your `runtimepath`.
-- Example: `~/.config/nvim/lua/osc-keydown.lua`
-- 
-- Usage: `:lua require'osc-keydown'`
--        `:OSCEnable` to start sending OSC on every keystroke.
--        `:OSCDisable` to stop sending OSC.
local osc = require'osc'.new{
  transport = 'udp',
  sendAddr = '127.0.0.1',
  sendPort = 57120,
}

local M = {}

local on_keystroke = function(k)
  local message = osc.new_message{
    address = '/nvim/key',
    types = 'si',
    k, string.byte(k)
  }
  local ok, err = osc:send(message)
  if not ok then
    print(err)
  end
end

function M.enable()
  if not M.id then
    M.id = vim.register_keystroke_callback(on_keystroke)
  end
end

function M.disable()
  if M.id then
    vim.register_keystroke_callback(nil, M.id)
  end
  M.id = nil
end

-- Register commands
vim.cmd [[ com! OSCEnable :lua require'osc-keydown'.enable()   ]]
vim.cmd [[ com! OSCDisable :lua require'osc-keydown'.disable() ]]

return M
```

[osc]: http://opensoundcontrol.org/spec-1_0
[losc]: https://github.com/davidgranstrom/losc
