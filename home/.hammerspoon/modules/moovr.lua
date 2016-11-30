moovr = hs.hotkey.modal.new()
local grid = require "hs.grid"

function moovr:entered() end

moovr:bind('', 'ESCAPE', 'MOOVR OFF', function() moovr:exit() end)
moovr:bind('', 'RETURN', 'MOOVR OFF', function() moovr:exit() end)

moovr:bind('', 'j', grid.pushWindowDown)
moovr:bind('', 'k', grid.pushWindowUp)
moovr:bind('', 'h', grid.pushWindowLeft)
moovr:bind('', 'l', grid.pushWindowRight)
