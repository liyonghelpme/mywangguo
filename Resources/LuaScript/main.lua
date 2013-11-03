-- cclog
cclog = function(...)
    print(string.format(...))
end

-- for CCLuaEngine traceback
function __G__TRACKBACK__(msg)
    cclog("----------------------------------------")
    cclog("LUA ERROR: " .. tostring(msg) .. "\n")
    cclog(debug.traceback())
    cclog("----------------------------------------")
end

local function main()
    -- avoid memory leak
    collectgarbage("setpause", 100)
    collectgarbage("setstepmul", 5000)

    ---------------
    require "Global.INCLUDE"

    local director = CCDirector:sharedDirector()
    local runscene = director:getRunningScene()
    if runscene == nil then
        global.director:runWithScene(ca)
    else
        local ca = CastleScene.new()
        director:replaceScene(ca.bg)
        global.director:onlyRun(ca)
    end
    global.director:pushView(Loading.new(), 1, 0, 0)
    --等待加入场景之后 再初始化
    global.user:initData()
end

xpcall(main, __G__TRACKBACK__)
