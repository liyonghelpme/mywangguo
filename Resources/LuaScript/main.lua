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

    require "myMap.MapScene"
    require 'Miao.FightScene'

    --global.director:runWithScene(TMXScene.new())

    local director = CCDirector:sharedDirector()
    --[[
    local sc = TMXScene.new()
    director:replaceScene(sc.bg)
    global.director:onlyRun(sc)
    --]]

    --require "Miao.TestScene"
    --global.director:runWithScene(TestScene.new())
    
    local sc = FightScene.new()
    director:replaceScene(sc.bg)
    global.director:onlyRun(sc)

    --require "Menu.TestMenu"
    --global.director:runWithScene(TestMenu.new())
    
    --global.director:runWithScene(MapScene.new())

end

xpcall(main, __G__TRACKBACK__)
