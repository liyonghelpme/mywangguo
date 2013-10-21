
MenuLayer = class()
function MenuLayer:ctor(sc)
    self.scene = sc
    self.menus = {nil, nil}
    self.showChildMenu = false
    self.MainMenuFunc = {
    [0]={"map", "rank", "plan", "setting"},
    [1]={"attack", "store", "friend", "mail"},
    }
    self:initView()
    registerEnterOrExit(self)
end
function MenuLayer:initDataOver()
    self:updateText()
    self:updateExp(0)
    self.name:setString(global.user:getValue("name"))
end
function MenuLayer:enterScene()
    Event:registerEvent(EVENT_TYPE.UPDATE_RESOURCE, self)
    Event:registerEvent(EVENT_TYPE.LEVEL_UP, self)
    Event:registerEvent(EVENT_TYPE.UPDATE_EXP, self)
    Event:registerEvent(EVENT_TYPE.CHANGE_NAME, self)
    self:updateText()
    self:updateExp(0)
end
function MenuLayer:exitScene()
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
    end
end
function MenuLayer:initView()
    self.bg = CCLayer:create()

    local temp = setSize(setPos(addSprite(self.bg, "name.png"), {33, fixY(nil, 36)}), {30, 30})
    local name = ui.newTTFLabel({text=global.user:getValue("name"), size=25, color={202, 70, 70}})
    setAnchor(setPos(name, {55, fixY(nil, 36)}), {0, 0.5})
    self.bg:addChild(name)
    self.name = name

    self.banner = setSca(setPos(setAnchor(addSprite(self.bg, "menu_back.png"), {0, 0}), {0, 0}), global.director.disSize[1]/global.director.designSize[1])

    local temp = setPos(setAnchor(addSprite(self.banner, "menuFeather.png"), {0, 0}), {107, fixY(global.director.disSize[2], 367, 59)})
    
    self.taskButton = ui.newButton({image="task.png", delegate=self, callback=self.onTask}) 
    setPos(self.taskButton.bg, {12, fixY(nil, 395, 82)})
    self.banner:addChild(self.taskButton.bg)
    
    self.taskFin = setPos(setAnchor(addSprite(self.banner, "taskFin0.png"), {0, 0}), {83, fixY(nil, 402, 27)})
    self.finNum = setColor(setPos(setAnchor(addLabel(self.banner, getStr("99+", nil), "", 18), {0.5, 0.5}), {96, fixY(nil, 416, 0, 0.5)}), {255, 255, 255})
    
    self.expfiller = setAnchor(addSprite(self.banner, "exp_filler.png"), {0, 0})
    setPos(self.expfiller, {133, fixY(nil, 419, getHeight(self.expfiller))})

    self.expBack = setPos(setAnchor(addSprite(self.banner, "level0.png"), {0, 0}), {120, fixY(nil, 406, 36)})
    
    local expSize = self.expBack:getContentSize()
    self.levelLabel = setPos(setAnchor(addNode(self.expBack), {0.5, 0.5}), {expSize.width/2, expSize.height/2})
    
    self.collectionButton = ui.newButton({image="mainRank.png", delegate=self, callback=self.onRank})
    setPos(self.collectionButton.bg, {229, fixY(nil, 445, 34)})
    self.banner:addChild(self.collectionButton.bg)

    self.chargeButton = ui.newButton({image="recharge.png", delegate=self, callback=self.openCharge})
    setAnchor(setPos(self.chargeButton.bg, {439, fixY(nil, 444, 35)}), {0, 0})
    self.banner:addChild(self.chargeButton.bg)

    self.menuButton = ui.newButton({image="menu_button.png", delegate=self, callback=self.onClicked, param=0})
    setPos(setAnchor(self.menuButton.bg, {0, 0}), {685, fixY(nil, 380, 106)})
    self.banner:addChild(self.menuButton.bg)

    self.crystalIcon = setPos(setSize(addSprite(self.banner, "crystal.png"), {30, 30}), {110, fixY(nil, 461, nil, 0.5)})

    self:initText() 

    self.expBanner = setVisible(setPos(setAnchor(CCSprite:create("expBanner.png"), {0, 0}), {123, fixY(nil, 432, 50)}), false)
    self.banner:addChild(self.expBanner)

    self.expWord = ui.newBMFontLabel({text=getStr("expToLev", nil), font="bound.fnt", size=17})
    --self.expWord = ShadowWords.new(, "", 17, nil, {255, 255, 255})
    setPos(setAnchor(self.expWord, {0.5, 0.5}), {75, 23})
    self.expBanner:addChild(self.expWord)


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
    self.silverText = setColor(setPos(setAnchor(temp, {0, 0.5}), {333, fixY(nil, 461, nil, 0.5)}), {255, 255, 255})
    local temp = ui.newBMFontLabel({text="1", font="bound.fnt", size=23})
    self.banner:addChild(temp)
    self.goldText = setColor(setPos(setAnchor(temp, {0, 0.5}), {588, fixY(nil, 461, nil, 0.5)}), {255, 255, 255})
    --[[
    local w = ''..global.user.rankOrder
    if global.user.rankOrder > 999 then
        w = '999+'
    end
    --]]
    local temp = ui.newBMFontLabel({text="1", font="bound.fnt", size=23})
    self.banner:addChild(temp)
    --self.gloryLevText = setColor(setPos(setAnchor(temp, {0.5, 0.5}), {169, fixY(nil, 461, nil, 0.5)}), {255, 255, 255})
    self.crystalText = setColor(setPos(setAnchor(temp, {0.5, 0.5}), {169, fixY(nil, 461, nil, 0.5)}), {255, 255, 255})
    
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
end

function MenuLayer:onRank()
end

function MenuLayer:openCharge()
end

function MenuLayer:onClicked()
    if not self.showChildMenu then
        self:drawAllMenu()
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



