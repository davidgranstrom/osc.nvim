local losc = require'osc.lib.losc'
local udp = require'osc.udp-transport'
local tcp = require'osc.tcp-transport'

local osc = {
  __index = function (self, key)
    if not self.losc then
      error('[osc.nvim] Must call .new first.')
    end
    return self.losc[key]
  end
}

--- Create a new instance.
-- @tparam[options] table options Options.
-- @usage
-- local osc = require'osc'.new{
--   transport = 'udp',
--   sendAddr = '127.0.0.1',
--   sendPort = 57120,
--   recvAddr = '127.0.0.1',
--   recvPort  = 9000,
-- }
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

return osc
