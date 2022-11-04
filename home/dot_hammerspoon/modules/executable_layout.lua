layout = hs.hotkey.modal.new()
function layout:entered() end

layout:bind('', 'ESCAPE', 'LAYOUT OFF', function() local win = hs.window.focusedWindow() layout:exit() end)
layout:bind('', 'RETURN', 'LAYOUT OFF', function() local win = hs.window.focusedWindow() layout:exit() end)
layout:bind('', 'l', function() local win = hs.window.focusedWindow() win:right() end)
layout:bind('', 'h', function() local win = hs.window.focusedWindow() win:left() end)
layout:bind('', 'k', function() local win = hs.window.focusedWindow() win:up() end)
layout:bind('', 'j', function() local win = hs.window.focusedWindow() win:down() end)

layout:bind('', 'c', function() local win = hs.window.focusedWindow() hs.window.fullscreenCenter(win) end)
layout:bind('', 'f', function() local win = hs.window.focusedWindow() win:maximize() end)
layout:bind('', 'w', function() local win = hs.window.focusedWindow() win:codes() end)

layout:bind('alt', 'h', function() local win = hs.window.focusedWindow() win:upLeft() end)
layout:bind('alt', 'j', function() local win = hs.window.focusedWindow() win:downLeft() end)
layout:bind('alt', 'k', function() local win = hs.window.focusedWindow() win:downRight() end)
layout:bind('alt', 'l', function() local win = hs.window.focusedWindow() win:upRight() end)
layout:bind('alt', 'c', function() local win = hs.window.focusedWindow() hs.window.fullscreenWidth(win) end)
