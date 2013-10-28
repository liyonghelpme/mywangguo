--新手逻辑控制
NEW_STEP = {
    STORE=3,
    HARVEST=4,
    TRAIN_SOL=5,
    TRAIN_OVER=6,
    GO_BATTLE=7,
    BATTLE_NOW=8,
    FINISH_NEW=9,
}
NewLogic = {}
NewLogic.step = 0
NewLogic.hint = nil
function NewLogic.nextStep()
    --if NewLogic.step == 0 then
    --    setBool("firstGame", true)
    --end
    NewLogic.step = NewLogic.step+1
    print("NewLogic step", NewLogic.step)
    if NewLogic.step == 1 then
        Event:sendMsg(EVENT_TYPE.TAP_MENU)
        global.director:pushView(NewDialog.new(getStr("step1")), 1, 0)
    elseif NewLogic.step == 2 then
    elseif NewLogic.step == 3 then
    end

end
function NewLogic.triggerEvent(e)
    print("triggerEvent", e, NewLogic.step)
    if e == 2  and NewLogic.step == 2 then
        global.director:pushView(NewDialog.new(getStr("step2")), 1, 0)
        Event:sendMsg(EVENT_TYPE.TAP_STORE)
    elseif e == NEW_STEP.STORE and NewLogic.step == 3 then
        Event:sendMsg(EVENT_TYPE.TAP_FARM)
    elseif e == NEW_STEP.HARVEST and NewLogic.step == 3 then
        Event:sendMsg(EVENT_TYPE.MATURE_FARM)
        global.director:pushView(NewDialog.new(getStr("step3")), 1, 0)
    elseif e == NEW_STEP.TRAIN_SOL and NewLogic.step == 4 then
        Event:sendMsg(EVENT_TYPE.CALL_SOL)
        global.director:pushView(NewDialog.new(getStr("step4")), 1, 0)
    elseif e == NEW_STEP.TRAIN_OVER and NewLogic.step == 5 then
        Event:sendMsg(EVENT_TYPE.CLOSE_STORE)
        global.director:pushView(NewDialog.new(getStr("step5")), 1, 0)
    elseif e == NEW_STEP.GO_BATTLE and NewLogic.step ==  6 then
        Event:sendMsg(EVENT_TYPE.BATTLE)
    elseif e == NEW_STEP.BATTLE_NOW and NewLogic.step == 6 then
        global.director:pushView(NewDialog.new(getStr("step6")), 1, 0)
    elseif e == NEW_STEP.FINISH_NEW and NewLogic.step == 7 then
        setBool("firstGame", true)
        NewLogic.setHint(nil)
    end
end

function NewLogic.setHint(h)
    if NewLogic.hint ~= nil then
        if NewLogic.hint.bg ~= nil then
            removeSelf(NewLogic.hint.bg)
        end
        NewLogic.hint = nil
    end
    NewLogic.hint = h
end
