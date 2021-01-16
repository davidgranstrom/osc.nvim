local losc = require'osc.lib.losc'
local udp = require'osc.udp-transport'
local tcp = require'osc.tcp-transport'

local osc = {}
osc.__index = osc

--- Create a new instance.
-- @tparam[options] table options Options.
-- @usage local osc = osc.new()
-- @usage local osc = osc.new {plugin = plugin.new()}
function osc.new(options)
  local self = setmetatable({}, osc)
  self.losc = losc.new()
  if options then
    local plugin
    if options.transport == 'udp' then
      plugin = udp.new(options)
    elseif options.transport == 'tcp' then
      plugin = tcp.new(options)
    else
      error('Unrecognized plugin')
    end
    self.losc:use(plugin)
  end
  return self
end

--- Create a new Message.
-- @tparam[opt] string|table args OSC address or table constructor.
-- @return message object
-- @see osc.message
-- @usage local message = osc.new_message()
-- @usage local message = osc.new_message('/address')
-- @usage local message = osc.new_message({ address = '/foo', types = 'iif', 1, 2, 3})
function osc.new_message(...)
  local args = {...}
  local ok, message = pcall(losc.new_message, args)
  if not ok then
    error(message)
  end
  return message
end

--- Create a new OSC bundle.
-- @param[opt] ... arguments.
-- @return bundle object
-- @see osc.bundle
-- @usage local bundle = osc.new_bundle()
-- @usage
-- local tt = Timetag.new_raw()
-- local bundle = osc.new_bundle(tt)
-- @usage
-- local tt = Timetag.new(os.time(), 0)
-- local bundle = osc.new_bundle(tt, osc_msg, osc_msg2)
-- @usage
-- local tt = Timetag.new(os.time(), 0)
-- local bundle = osc.new_bundle(tt, osc_msg, other_bundle)
function osc.new_bundle(...)
  local ok, bundle = pcall(losc.new_bundle, ...)
  if not ok then
    error(bundle)
  end
  return bundle
end

--- Get an OSC timetag with the current timestamp.
-- Will fall back to `os.time()` if `now()` is not implemented by the plugin
-- in use.
function osc:now()
  return self.losc.plugin:now()
end

--- Opens an OSC server.
-- @param[opt] ... Plugin specific arguments.
-- @return status, plugin handle or error
function osc:open(...)
  if not self.losc.plugin then
    error('"open" must be implemented using a plugin.')
  end
  print(vim.inspect(self.losc.plugin))
  return pcall(self.losc.plugin.open, self.losc.plugin, ...)
end

--- Closes an OSC server.
-- @param[opt] ... Plugin specific arguments.
-- @return status, nil or error
function osc:close(...)
  if not self.losc.plugin then
    error('"close" must be implemented using a plugin.')
  end
  return pcall(self.losc.plugin.close, self.losc.plugin, ...)
end

--- Send an OSC packet.
-- @param[opt] ... Plugin specific arguments.
-- @return status, nil or error
function osc:send(...)
  if not self.losc.plugin then
    error('"send" must be implemented using a plugin.')
  end
  return pcall(self.losc.plugin.send, self.losc.plugin, ...)
end

--- Add an OSC handler.
-- @param pattern The pattern to match on.
-- @param func The callback to run if a message is received.
-- The callback will get a single argument `data` from where the messsage can be retrived.
function osc:add_handler(pattern, func)
  self.losc:add_handler(pattern, func)
end

--- Remove an OSC handler.
-- @param pattern The pattern for the handler to remove.
function osc:remove_handler(pattern)
  self.losc:remove_handler(pattern, func)
end

--- Remove all registered OSC handlers.
function osc:remove_all()
  self.losc:remove_all(pattern, func)
end

return osc
