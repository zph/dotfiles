require('modules/main')
require('modules/toggle')
require('modules/focus')
require('modules/moovr')
require('modules/sizer')
require('modules/layout')

local app = hs.application

-- Auto reload config file on save.
function reloadConfig(files)
    doReload = false
    for _,file in pairs(files) do
        if file:sub(-4) == ".lua" then
            doReload = true
        end
    end
    if doReload then
        hs.reload()
        hs.alert.show("Config reloaded")
    end
end

hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", reloadConfig):start()

local debug = function(msg, value)
  print(string.format("%s: %s", msg, inspect(value)))
end

local mash = {"cmd", "shift", "ctrl"}

hs.window.animationDuration = 0
-- Credit: https://github.com/cmsj/hammerspoon-config/blob/master/init.lua
-- Defines for window grid
local hyper = {"cmd", "shift", "ctrl", "alt"}
hs.grid.GRIDWIDTH = 6
hs.grid.GRIDHEIGHT = 5
hs.grid.MARGINX = 0
hs.grid.MARGINY = 0
hs.grid.ui.showExtraKeys = false
hs.grid.ui.textSize = 35

local frameCache = {}
function toggleWindowMaximized()
  local win = hs.window.focusedWindow()
  if frameCache[win:id()] then
    win:setFrame(frameCache[win:id()])
    frameCache[win:id()] = nil
  else
    frameCache[win:id()] = win:frame()
    win:maximize()
  end
end
-- Toggle an application between being the frontmost app, and being hidden
function toggleApplication(_app)
  local app = hs.appfinder.appFromName(_app)
  if not app then
    hs.application.launchOrFocus(_app)
    return
  end
  if hs.application.isFrontmost(app) then
    hs.application.hide(app)
  else
    app.launchOrFocus(_app)
  end
end
-- Hotkeys to move windows between screens, retaining their position/size relative to the screen
-- hs.urlevent.bind('hyperfnleft', function() hs.window.focusedWindow():moveOneScreenWest() end)
-- hs.urlevent.bind('hyperfnright', function() hs.window.focusedWindow():moveOneScreenEast() end)

-- Hotkeys to resize windows absolutely
hs.hotkey.bind(hyper, 'H', function() hs.window.focusedWindow():moveToUnit(hs.layout.left30) end)
hs.hotkey.bind(hyper, 'L', function() hs.window.focusedWindow():moveToUnit(hs.layout.right70) end)
hs.hotkey.bind(hyper, '[', function() hs.window.focusedWindow():moveToUnit(hs.layout.left50) end)
hs.hotkey.bind(hyper, ']', function() hs.window.focusedWindow():moveToUnit(hs.layout.right50) end)
hs.hotkey.bind(hyper, 'F', toggleWindowMaximized)
hs.hotkey.bind(hyper, 'R', function() hs.window.focusedWindow():toggleFullScreen() end)

-- Hotkeys to interact with the window grid
hs.hotkey.bind(hyper, 'G', hs.grid.show)
hs.hotkey.bind(hyper, 'Left', hs.grid.pushWindowLeft)
hs.hotkey.bind(hyper, 'Right', hs.grid.pushWindowRight)
hs.hotkey.bind(hyper, 'Up', hs.grid.pushWindowUp)
hs.hotkey.bind(hyper, 'Down', hs.grid.pushWindowDown)

-- -- Callback function for USB device events
-- Could use this for ergodox + karabiner config flip
-- function usbDeviceCallback(data)
--     print("usbDeviceCallback: "..hs.inspect(data))
--     if (data["productName"] == "ScanSnap S1300i") then
--         event = data["eventType"]
--         if (event == "added") then
--             hs.application.launchOrFocus("ScanSnap Manager")
--         elseif (event == "removed") then
--             app = hs.appfinder.appFromName("ScanSnap Manager")
--             app:kill()
--         end
--     end
-- end
-- END CREDIT

local bindWindowKey = function(name, key)
  return hs.hotkey.bind(mash, key, function() toggleApplication(name) end)
end

local apps = {
  {key = "S", app = "Slack"},
  {key = "T", app = "iTerm"},
  {key = "E", app = "Emacs"},
  {key = "G", app = "DataGrip"},
  {key = "P", app = "1Password 6"},
  {key = "C", app = "Google Chrome"},
  {key = "X", app = "TaskPaper"},
  {key = "V", app = "MacVim"},
}

for i,k in ipairs(apps) do
  bindWindowKey(k.app, k.key)
end

-- App switching
hs.hotkey.bind({"shift", "ctrl"}, "tab", hs.window.switcher.nextWindow, nil,hs.window.switcher.nextWindow)
hs.hotkey.bind({"shift", "ctrl", "alt"}, "tab", hs.window.switcher.previousWindow,nil,hs.window.switcher.previousWindow)

hs.tabs.enableForApp("MacVim")
-- -- Force paste one char at a time
-- hs.hotkey.bind(mash, "V", function() hs.eventtap.keyStrokes(hs.pasteboard.getContents()) end)

-- Modal window layouts
hs.hints.showTitleThresh = 0
hs.hints.style = "vimperator"
hs.hotkey.bind(mash, "H", hs.hints.windowHints)
hs.hotkey.bind(mash, "M", toggleWindowMaximized)
hs.hotkey.bind(mash, "R", hs.reload)
