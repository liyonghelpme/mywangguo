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
    require "Miao.Logic"
    --require "Miao.MiaoScene"
    require "Miao.TMXScene"

    require "myMap.MapScene"


    global.director:runWithScene(TMXScene.new())
    
    --global.director:runWithScene(FightScene.new())
    --require "Menu.TestMenu"
    --global.director:runWithScene(TestMenu.new())
    --global.director:runWithScene(MapScene.new())

end

xpcall(main, __G__TRACKBACK__)
