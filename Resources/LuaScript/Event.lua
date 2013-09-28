EVENT_TYPE = {
    INITDATA=1, RECEIVE_MSG=2, BUY_HERO = 3, UPDATE_HERO=4, DO_MOVE=5, FINISH_MOVE=6, LEVEL_UP=7, UPDATE_EXP=8, CALL_SOL=9, UPDATE_RESOURCE=10, 
    PLAN_BUILDING=11,
    UPDATE_HERO = 12,
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
    if Event.callbacks[name] ~= nil then
        for k, v in pairs(Event.callbacks[name]) do
            k:receiveMsg(name, msg)
        end
    end
end
