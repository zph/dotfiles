focus = hs.hotkey.modal.new()

function focus:entered() end
local window = require "hs.window"

focus:bind('', 'ESCAPE', 'FOCUS OFF', function() focus:exit() end)
focus:bind('', 'RETURN', 'FOCUS OFF', function() focus:exit() end)

focus:bind('', 'h', '', function() window.focusedWindow():focusWindowWest() end)
focus:bind('', 'l', function() window.focusedWindow():focusWindowEast() end)
focus:bind('', 'k', function() window.focusedWindow():focusWindowNorth() end)
focus:bind('', 'j', function() window.focusedWindow():focusWindowSouth() end)
