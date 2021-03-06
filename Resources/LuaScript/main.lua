-- cclog
cclog = function(...)
    print(string.format(...))
end

-- for CCLuaEngine traceback
function __G__TRACKBACK__(msg)
    cclog("----------------------------------------")
    local err = "LUA ERROR: " .. tostring(msg) .. "\n"
    err = err..debug.traceback()
    cclog(err)
    cclog("----------------------------------------")
    sendReq('synError', dict({{"error", err}})) 
end

OldPrint = print
function print(...)
    --if DEBUG then
        OldPrint(...)
    --end
end


local function main()
    -- avoid memory leak
    collectgarbage("setpause", 100)
    collectgarbage("setstepmul", 5000)

    ---------------
    require "Global.INCLUDE"
    require "Miao.Logic"
    --require "Miao.MiaoScene"
    require "Miao.TMXScene"

    --require "myMap.MapScene"
    require 'Miao.FightScene'
    require 'myMap.FightMap'
    require "Miao.LoadingScene"

    local director = CCDirector:sharedDirector()

    if not DEBUG_SOL then
        local sc = LoadingScene.new()
        director:replaceScene(sc.bg)
        global.director:onlyRun(sc)
    else
        local sc = FightScene.new()
        director:replaceScene(sc.bg)
        global.director:onlyRun(sc)
    end

    --[[
    local sc = FightMap.new()
    director:replaceScene(sc.bg)
    global.director:onlyRun(sc)
    --]]

    --require "Menu.TestMenu"
    --global.director:runWithScene(TestMenu.new())
    
    --global.director:runWithScene(MapScene.new())
    local allMsg = {"EVENT_COCOS_PAUSE", "EVENT_COCOS_RESUME"}
    for k, v in ipairs(allMsg) do
        CCNotificationCenter:sharedNotificationCenter():registerScriptObserver(CCNotificationCenter:sharedNotificationCenter(), Event.cppMsg, v)
    end
end

xpcall(main, __G__TRACKBACK__)
