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
    require "MyDia.MainDialog"
    require "MyDia.AllHeroes"
    require "MyDia.AllLevel"
    require "MyDia.AllUser"
    require "MyDia.AllFriend"
    require 'MyDia.Formation'
    require "Battle.BattleGround"
    
    local ground = BattleGround.new()
    ground:initTest()
    ground:prepareBattle()
    local scene = {bg=CCScene:create()}
    scene.bg:addChild(ground:initView())
    
    CCDirector:sharedDirector():getScheduler():setTimeScale(2)
    global.director:runWithScene(scene)
end

xpcall(main, __G__TRACKBACK__)
