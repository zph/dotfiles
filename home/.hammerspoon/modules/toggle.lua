toggle = hs.hotkey.modal.new()
function toggle:entered() end

toggle:bind('', 'ESCAPE', 'TOGGLE OFF', function() toggle:exit() end)
toggle:bind('', 'RETURN', 'TOGGLE OFF', function() toggle:exit() end)

-- [[
-- toggle push window to edge and restore to screen

-- somewhere to store the original position of moved windows
local origWindowPos = {}

-- cleanup the original position when window restored or closed
local function cleanupWindowPos(_,_,_,id)
  origWindowPos[id] = nil
end

-- function to move a window to edge or back
local function movewin(direction)
  local win = hs.window.focusedWindow()
  local res = hs.screen.mainScreen():frame()
  local id = win:id()

  if not origWindowPos[id] then
    -- move the window to edge if no original position is stored in
    -- origWindowPos for this window id
    local f = win:frame()
    origWindowPos[id] = win:frame()

    -- add a watcher so we can clean the origWindowPos if window is closed
    local watcher = win:newWatcher(cleanupWindowPos, id)
    watcher:start({hs.uielement.watcher.elementDestroyed})

    if direction == "left" then f.x = (res.w - (res.w * 2)) + 10 end
    if direction == "right" then f.x = (res.w + res.w) - 10 end
    if direction == "down" then f.y = (res.h + res.h) - 10 end
    win:setFrame(f)
  else
    -- restore the window if there is a value for origWindowPos
    win:setFrame(origWindowPos[id])
    -- and clear the origWindowPos value
    cleanupWindowPos(_,_,_,id)
  end
end


toggle:bind('', 'a', function() movewin("left") end)
toggle:bind('', 'd', function() movewin("right") end)
toggle:bind('', 's', function() movewin("down") end)

-- /toggle push window to edge and restore to screen
-- ]]
