sizer = hs.hotkey.modal.new()
local grid = require "hs.grid"

function sizer:entered() end

sizer:bind('', 'ESCAPE', 'SIZER OFF', function() sizer:exit() end)
sizer:bind('', 'RETURN', 'SIZER OFF', function() sizer:exit() end)

sizer:bind('', 'k', grid.resizeWindowShorter)
sizer:bind('', 'j', grid.resizeWindowTaller)
sizer:bind('', 'l', grid.resizeWindowWider)
sizer:bind('', 'h', grid.resizeWindowThinner)
