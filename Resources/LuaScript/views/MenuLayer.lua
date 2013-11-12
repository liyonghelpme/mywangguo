require "views.ChatDialog"
require "views.Message"

MenuLayer = class()
function MenuLayer:ctor(sc)
    self.scene = sc
    self.menus = {nil, nil}
    self.showChildMenu = false
    self.MainMenuFunc = {
    [0]={"map", "sell", "plan", "rank"},
    [1]={"attack", "store", "friend", "mail"},
    }
    self:initView()
    registerEnterOrExit(self)
end
function MenuLayer:initDataOver()
    self:updateText()
    self:updateExp(0)
    self.name:setString(global.user:getValue("name"))
    MsgModel.initMsg()
end
function MenuLayer:enterScene()
    Event:registerEvent(EVENT_TYPE.UPDATE_RESOURCE, self)
    Event:registerEvent(EVENT_TYPE.LEVEL_UP, self)
    Event:registerEvent(EVENT_TYPE.UPDATE_EXP, self)
    Event:registerEvent(EVENT_TYPE.CHANGE_NAME, self)
    Event:registerEvent(EVENT_TYPE.TAP_MENU, self)
    Event:registerEvent(EVENT_TYPE.CLOSE_STORE, self)
    Event:registerEvent(EVENT_TYPE.UPDATE_MSG, self)
    Event:registerEvent(EVENT_TYPE.INIT_MSG, self)
    self:updateText()
    self:updateExp(0)
    ChatModel.startReceive()
end
function MenuLayer:exitScene()
    Event:unregisterEvent(EVENT_TYPE.INIT_MSG, self)
    Event:unregisterEvent(EVENT_TYPE.UPDATE_MSG, self)
    Event:unregisterEvent(EVENT_TYPE.CLOSE_STORE, self)
    Event:unregisterEvent(EVENT_TYPE.TAP_MENU, self)
    Event:unregisterEvent(EVENT_TYPE.CHANGE_NAME, self)
    Event:unregisterEvent(EVENT_TYPE.UPDATE_RESOURCE, self)
    Event:unregisterEvent(EVENT_TYPE.LEVEL_UP, self)
    Event:unregisterEvent(EVENT_TYPE.UPDATE_EXP, self)
end
function MenuLayer:receiveMsg(name, msg)
    if name == EVENT_TYPE.UPDATE_RESOURCE then
        self:updateText() 
    elseif name == EVENT_TYPE.UPDATE_EXP then
        self:updateExp(1)
    elseif name == EVENT_TYPE.LEVEL_UP then
        self:updateExp(1)
    elseif name == EVENT_TYPE.CHANGE_NAME then
        self.name:setString(global.user:getValue("name"))
    elseif name == EVENT_TYPE.TAP_MENU or name == EVENT_TYPE.CLOSE_STORE then
        local hint = Hint.new()
        self.menuButton.bg:addChild(hint.bg)
        setPos(hint.bg, {50, 50})
        NewLogic.setHint(hint)
    elseif name == EVENT_TYPE.UPDATE_MSG then
        local oldN = tonumber(self.finNum:getString())
        local newN = #ChatModel.chatMessage
        numAct(self.finNum, oldN, newN)
        self.finNum:runAction(repeatN(sequence({scaleto(0.5, 1.2, 1.2), scaleto(0.5, 1, 1)}), 4))
        local l = #ChatModel.chatMessage
        if l > 0 then
            local v = ChatModel.chatMessage[l]
            local name = v[2]
            local text = v[3] 
            self.wordLabel:setString(name..': '..text)
            self.wordLabel:runAction(sequence({fadeout(0.3), fadein(0.3)}))
        end
    elseif name == EVENT_TYPE.INIT_MSG then
        numAct(self.msgNum, 0, #MsgModel.msg.res)
    end
end
function MenuLayer:onMsg()
    global.director:pushView(Message.new(), 1, 0)
end
function MenuLayer:initView()
    self.bg = CCLayer:create()

    local temp = setSize(setPos(addSprite(self.bg, "name.png"), {33, fixY(nil, 36)}), {30, 30})
    local name = ui.newTTFLabel({text=global.user:getValue("name"), size=25, color={202, 70, 70}})
    setAnchor(setPos(name, {55, fixY(nil, 36)}), {0, 0.5})
    self.bg:addChild(name)
    self.name = name

    --scaleX
    self.banner = setSca(setPos(setAnchor(addSprite(self.bg, "menu_back.png"), {0, 0}), {0, 0}), global.director.disSize[1]/global.director.designSize[1])

    local temp = setPos(setAnchor(addSprite(self.banner, "menuFeather.png"), {0, 0}), {107, fixY(global.director.disSize[2], designToRealY(367), 59)})
    


    self.taskButton = ui.newButton({image="task.png", delegate=self, callback=self.onTask}) 
    setPos(self.taskButton.bg, {12, fixY(nil, designToRealY(395), 82)})
    self.banner:addChild(self.taskButton.bg)
    
    self.taskFin = setPos(setAnchor(addSprite(self.banner, "taskFin0.png"), {0, 0}), {83, fixY(nil, designToRealY(402), 27)})
    self.finNum = ui.newBMFontLabel({text=0, size=20, font="bound.fnt"})
    setPos(self.finNum, {100, fixY(nil, designToRealY(416), 0, 0.5)})
    self.banner:addChild(self.finNum)

    self.wordLabel = ui.newTTFLabel({text="", size=25, color={20, 12, 28}})
    self.banner:addChild(self.wordLabel)
    setAnchor(setPos(self.wordLabel, {20, 100}), {0, 0})
    
    self.expfiller = setAnchor(addSprite(self.banner, "exp_filler.png"), {0, 0})
    setPos(self.expfiller, {133, fixY(nil, designToRealY(419), getHeight(self.expfiller))})

    self.expBack = setPos(setAnchor(addSprite(self.banner, "level0.png"), {0, 0}), {120, fixY(nil, designToRealY(406), 36)})
    
    local expSize = self.expBack:getContentSize()
    self.levelLabel = setPos(setAnchor(addNode(self.expBack), {0.5, 0.5}), {expSize.width/2, expSize.height/2})
    
    self.collectionButton = ui.newButton({image="mainRank.png", delegate=self, callback=self.onRank})
    setPos(self.collectionButton.bg, {229, fixY(nil, designToRealY(445), 34)})
    self.banner:addChild(self.collectionButton.bg)

    self.chargeButton = ui.newButton({image="recharge.png", delegate=self, callback=self.openCharge})
    setAnchor(setPos(self.chargeButton.bg, {439, fixY(nil, designToRealY(444), 35)}), {0, 0})
    self.banner:addChild(self.chargeButton.bg)

    self.menuButton = ui.newButton({image="menu_button.png", delegate=self, callback=self.onClicked, param=0})
    setPos(setAnchor(self.menuButton.bg, {0, 0}), {685, fixY(nil, designToRealY(380), 106)})
    self.banner:addChild(self.menuButton.bg)

    self.crystalIcon = setPos(setSize(addSprite(self.banner, "crystal.png"), {30, 30}), {110, fixY(nil, designToRealY(461), nil, 0.5)})
    self:initText() 

    self.expBanner = setVisible(setPos(setAnchor(CCSprite:create("expBanner.png"), {0, 0}), {123, fixY(nil, designToRealY(432), 50)}), false)
    self.banner:addChild(self.expBanner)

    self.expWord = ui.newBMFontLabel({text=getStr("expToLev", nil), font="bound.fnt", size=17})
    --self.expWord = ShadowWords.new(, "", 17, nil, {255, 255, 255})
    setPos(setAnchor(self.expWord, {0.5, 0.5}), {75, 23})
    self.expBanner:addChild(self.expWord)


    local message = ui.newButton({image="message.png", callback=self.onMsg, delegate=self})
    message:setAnchor(0.5, 0.5)
    setPos(message.bg, {665, 73})
    self.banner:addChild(message.bg)
    local temp = setPos(addSprite(message.bg, "mnum.png"), {29, 13})
    local msgNum = ui.newBMFontLabel({text="0", font="bound.fnt", size=12})
    setPos(msgNum, {16, 16})
    temp:addChild(msgNum)
    self.msgNum = msgNum
end

local EXP_LEN = 108-22
local BASE_LEN = 22
function MenuLayer:updateExp(add)
    local level = global.user:getValue("level")
    local exp = global.user:getValue("exp")
    local needExp = getLevelUpNeedExp(level)
    local nowSize = exp*EXP_LEN/needExp+BASE_LEN
    if add > 0 then
        self.expfiller:stopAllActions()
        self.expfiller:runAction(sizeto(0.5, nowSize, 12, self.expfiller))
    else
        setSize(self.expfiller, {nowSize, 12})
    end

    --[[
    local leftExp = needExp-exp
    if add > 0 then
        self.expWord:setString(getStr("expToLev", {"[EXP]", str(leftExp), "[LEV]", str(level+2)}))
        self.expBanner:stopAllActions()
        self.expWord:stopAllActions()
        self.expBanner:setVisible(true)
        self.expBanner:runAction(sequence({fadein(0.2), delaytime(2), fadeout(1)}))
        self.expWord:runAction(sequence({fadein(0.2), delaytime(2), fadeout(1)}))
    end
    --]]

    local temp = altasWord("white", ""..(level+1))
    setPos(setAnchor(temp, {0.5, 0.5}), getPos(self.levelLabel))
    removeSelf(self.levelLabel)
    self.expBack:addChild(temp)
    self.levelLabel = temp

    local lSize = self.levelLabel:getContentSize()
    local bSize = self.expBack:getContentSize()
    
    local sca = getNodeSca(self.levelLabel, {math.min(lSize.width, bSize.width), math.min(lSize.height, 21)})
    self.levelLabel:setScale(sca)
end
function MenuLayer:initText()
    local temp = ui.newBMFontLabel({text="1", font="bound.fnt", size=23})
    self.banner:addChild(temp)
    self.silverText = setColor(setPos(setAnchor(temp, {0, 0.5}), {333, fixY(nil, designToRealY(461), nil, 0.5)}), {255, 255, 255})
    local temp = ui.newBMFontLabel({text="1", font="bound.fnt", size=23})
    self.banner:addChild(temp)
    self.goldText = setColor(setPos(setAnchor(temp, {0, 0.5}), {588, fixY(nil, designToRealY(461), nil, 0.5)}), {255, 255, 255})
    local temp = ui.newBMFontLabel({text="1", font="bound.fnt", size=23})
    self.banner:addChild(temp)
    self.crystalText = setColor(setPos(setAnchor(temp, {0.5, 0.5}), {169, fixY(nil, designToRealY(461), nil, 0.5)}), {255, 255, 255})
end
function MenuLayer:updateText()
    local ures = global.user.resource
    local oldSilver = tonumber(self.silverText:getString())
    local oldGold = tonumber(self.goldText:getString())
    local oldCrystal = tonumber(self.crystalText:getString())
    if oldSilver ~= ures.silver then
        self.silverText:stopAllActions()
        numAct(self.silverText, oldSilver, ures.silver)
    end
    if oldGold ~= ures.gold then
        self.goldText:stopAllActions()
        numAct(self.goldText, oldGold, ures.gold)
    end
    if oldCrystal ~= ures.crystal then
        self.crystalText:stopAllActions()
        numAct(self.crystalText, oldCrystal, ures.crystal)
    end

end

function MenuLayer:onTask()
    global.director:pushView(ChatDialog.new(s), 1, 0)
end

function MenuLayer:onRank()
end

function MenuLayer:openCharge()
end

function MenuLayer:onClicked()
    if not self.showChildMenu then
        self:drawAllMenu()
        NewLogic.triggerEvent(2)
        NewLogic.triggerEvent(NEW_STEP.GO_BATTLE)
    else
        self:cancelAllMenu()
    end
end

function MenuLayer:updateRightMenu()
end
function MenuLayer:drawFunc(index, funcs)
    self:updateRightMenu()
    --先移除旧的菜单再显示新的菜单
    --因为菜单可能正在移除过程中
    if self.menus[index] ~= nil then
        self.menus[index].bg:removeFromParentAndCleanup(true)
    end
    self.menus[index] = ChildMenuLayer.new(index, funcs, self.scene, self.MainMenuFunc[1-index], self)
    self.bg:addChild(self.menus[index].bg, -1)
end
--action 正在进行时 需要等待action结束么?
function MenuLayer:drawAllMenu()
    self.showChildMenu= true
    self:drawFunc(0, self.MainMenuFunc[0])
    self:drawFunc(1, self.MainMenuFunc[1])
end
function MenuLayer:cancelFunc(index)
    self.menus[index]:removeSelf()
end

function MenuLayer:cancelAllMenu()
    if self.showChildMenu then
        self.showChildMenu = false
        self:cancelFunc(0)
        self:cancelFunc(1)
    end
end
--关闭并且隐藏菜单 visible false 
--左右子菜单 隐藏下方banner
function MenuLayer:hideMenu(t)
    self:cancelAllMenu()
    self.banner:stopAllActions()
    self.banner:runAction(expout(moveby(0.3, 0, -100))) 
    --runAction(self.bg, sequence(fadeout(), callfunc(self:beg)))
end

function MenuLayer:showMenu()
    self.banner:stopAllActions()
    self.banner:runAction(expin(moveby(0.3, 0, 100)))
end



