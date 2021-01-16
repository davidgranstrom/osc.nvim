--------------------------------
-- UDP client/server for Neovim.
--
-- @module osc.udp-transport
-- @author David Granström
-- @license MIT
-- @copyright David Granström 2021

local losc = require'osc.lib.losc'
local Timetag = require'osc.lib.losc.timetag'
local Pattern = require'osc.lib.losc.pattern'
local Packet = require'osc.lib.losc.packet'
local uv = vim.loop

local M = {}
M.__index = M
--- Fractional precision for bundle scheduling.
-- 1000 is milliseconds. 1000000 is microseconds etc. Any precision is valid
-- that makes sense for the plugin's scheduling function.
M.precision = 1000

--- Create a new instance.
-- @tparam[options] table options Options.
-- @usage local udp = plugin.new()
-- @usage
-- local udp = plugin.new {
--   sendAddr = '127.0.0.1',
--   sendPort = 9000,
--   recvAddr = '127.0.0.1',
--   recvPort = 8000,
-- }
function M.new(options)
  local self = setmetatable({}, M)
  self.options = options or {}
  self.handle = uv.new_udp('inet')
  print(vim.inspect(handle))
  assert(self.handle, 'Could not create UDP handle.')
  return self
end

--- Create a Timetag with the current time.
-- Precision is in milliseconds.
-- @return Timetag object with current time.
function M:now() -- luacheck: ignore
  local s, m = uv.gettimeofday()
  return Timetag.new(s, m / M.precision)
end

--- Schedule a OSC method for dispatch.
--
-- @tparam number timestamp When to schedule the bundle.
-- @tparam function handler The OSC handler to call.
function M:schedule(timestamp, handler) -- luacheck: ignore
  local timer = uv.new_timer()
  timestamp = math.max(0, timestamp)
  timer:start(timestamp, 0, function()
    handler()
  end)
end

--- Start UDP server.
-- This function is blocking.
-- @tparam string host IP address (e.g. 'localhost').
-- @tparam number port The port to listen on.
function M:open(host, port)
  host = host or self.options.recvAddr
  port = port or self.options.recvPort
  print(host, port)
  self.handle:bind(host, port, {reuseaddr=true})
  self.handle:recv_start(function(err, data, addr)
    assert(not err, err)
    if data then
      self.remote_info = addr
      Pattern.dispatch(data, self)
    end
  end)
  -- updated if port 0 is passed in as default (chooses a random port)
  self.options.recvPort = self.handle:getsockname().port
end

--- Close UDP server.
function M:close()
  self.handle:recv_stop()
  if not self.handle:is_closing() then
    self.handle:close()
  end
end

--- Send a OSC packet.
-- @tparam table packet The packet to send.
-- @tparam string address The IP address to send to.
-- @tparam number port The port to send to.
function M:send(packet, address, port)
  address = address or self.options.sendAddr
  port = port or self.options.sendPort
  packet = assert(Packet.pack(packet))
  self.handle:udp_try_send(packet, address, port)
end

return M
