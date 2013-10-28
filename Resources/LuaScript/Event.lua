EVENT_TYPE = {
    INITDATA=1, RECEIVE_MSG=2, BUY_HERO = 3, UPDATE_HERO=4, DO_MOVE=5, FINISH_MOVE=6, LEVEL_UP=7, UPDATE_EXP=8, UPDATE_RESOURCE=10, 
    PLAN_BUILDING=11, MOVE_TO_FARM=12,
    MOVE_TO_CAMP=13,
    ADD_SOLDIER=14,
    HARVEST_SOLDIER=15,
    KILL_SOLDIER=16, --从经营页面杀死某个士兵
    INIT_BATTLE=17, 
    FINISH_INIT_BUILD=18,
    CHANGE_NAME=19,


    TAP_MENU=20,
    TAP_STORE=21,
    TAP_FARM=22,
    MATURE_FARM=23,
    CALL_SOL=24,
    CLOSE_STORE=25,
    BATTLE=26,
}
Event = {}
Event.callbacks = {}
function Event:registerEvent(name, obj)
    if Event.callbacks[name] == nil then
        Event.callbacks[name] = {}
    end
    Event.callbacks[name][obj] = true
end
function Event:unregisterEvent(name, obj)
    if Event.callbacks[name] ~= nil then
        Event.callbacks[name][obj] = nil
    end
end

function Event:sendMsg(name, msg)
    print("sendMsg", name)
    if Event.callbacks[name] ~= nil then
        for k, v in pairs(Event.callbacks[name]) do
            k:receiveMsg(name, msg)
        end
    end
end
