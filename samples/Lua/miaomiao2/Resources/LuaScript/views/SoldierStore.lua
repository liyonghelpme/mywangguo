require "views.SoldierGoods"
SoldierStore = class()
function SoldierStore:ctor(s)
    self.scene = s
    self:initView()
end
function SoldierStore:onClose()
    global.director:popView()
end

--复用商店上半部分
function SoldierStore:initView()
    self.bg = CCLayer:create()
    local temp
    local but0
    local sz = {800, 480}

    temp = setPos(setAnchor(addSprite(self.bg, "back.png"), {0, 0}), {0, 0})
    temp = setPos(setAnchor(addSprite(self.bg, "diaBack.png"), {0, 1}), {38, fixY2(10)})
    temp = setSize(setPos(setAnchor(addSprite(self.bg, "moneyBack.png"), {0, 1}), {274, fixY2(27)}), {450, 33})
    but0 = ui.newButton({image="closeBut.png", delegate=self, callback=self.onClose})
    setPos(but0.bg, {752, fixY2(47)})
    self.bg:addChild(but0.bg)
    

    temp = setPos(setAnchor(addSprite(self.bg, "rightBack.png"), {0, 1}), {252, fixY(sz[2], 77)})
    temp = setPos(setAnchor(addSprite(self.bg, "leftBack.png"), {0, 1}), {32, fixY(sz[2], 77)})
    self.leftBack = temp
    --temp = setPos(setAnchor(addSprite(self.bg, "infoBack.png"), {0, 0}), {31, 246})
    temp = setSize(setPos(setAnchor(addSprite(self.bg, "gold.png"), {0, 1}), {439, fixY(sz[2], 28)}), {30, 30})
    temp = setSize(setPos(setAnchor(addSprite(self.bg, "crystal.png"), {0, 1}), {586, fixY(sz[2], 30)}), {30, 30})
    temp = setSize(setPos(setAnchor(addSprite(self.bg, "silver.png"), {0, 1}), {280, fixY(sz[2], 27)}), {30, 30})

    
    self.silverText = ui.newBMFontLabel({text="1", font="bound.fnt", size=23})
    setPos(setAnchor(self.silverText, {0, 0.5}), {318, fixY(sz[2], 43)})
    self.bg:addChild(self.silverText)
    
    self.goldText = ui.newBMFontLabel({text="1", font="bound.fnt", size=23})
    setPos(setAnchor(self.goldText, {0, 0.5}), {474, fixY(sz[2], 43)})
    self.bg:addChild(self.goldText)

    self.crystalText = ui.newBMFontLabel({text="1", font="bound.fnt", size=23})
    setPos(setAnchor(self.crystalText, {0, 0.5}), {621, fixY(sz[2], 43)})
    self.bg:addChild(self.crystalText)
    

    temp = setPos(setAnchor(addSprite(self.bg, "titCamp.png"), {0.5, 1}), {71, fixY(sz[2], 10)})
    temp = setPos(addSprite(self.bg, "conTitSol.png"), {514, fixY(sz[2], 112)})

    self.goods = SoldierGoods.new(self)
    self.bg:addChild(self.goods.bg)

    --士兵商店第一个士兵
    --selTab curNum idCanBuy
    self:setSoldier({nil, 1, 1})
    --购买等级是否达标
    self:updateText()
    --[[solId, sp], [solId, sp]]
    self.leftPanel = {}
    self:initLeftPanel()

    self.passTime = 0
    registerUpdate(self)
    registerEnterOrExit(self)
end

function SoldierStore:enterScene()
    Event:registerEvent(EVENT_TYPE.UPDATE_RESOURCE, self)
    Event:registerEvent(EVENT_TYPE.HARVEST_SOLDIER, self)
    self:updateText()
end
function SoldierStore:exitScene()
    Event:unregisterEvent(EVENT_TYPE.UPDATE_RESOURCE, self)
    Event:unregisterEvent(EVENT_TYPE.HARVEST_SOLDIER, self)
end
function SoldierStore:receiveMsg(name, msg)
    if name == EVENT_TYPE.UPDATE_RESOURCE then
        self:updateText()
    elseif name == EVENT_TYPE.HARVEST_SOLDIER then
        self:updateLeftPanel()
    end
end
function SoldierStore:updateText()
    local ures = global.user.resource
    local oldSilver = tonumber(self.silverText:getString())
    local oldGold = tonumber(self.goldText:getString())
    local oldCrystal = tonumber(self.crystalText:getString())
    print("oldValue", oldSilver, oldGold, oldCrystal)
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

function SoldierStore:setSoldier(idCan)
    self.curSelSol = idCan
end
function SoldierStore:sureToCall()
    local solId = self.goods.goodNum[self.curSelSol[2]]
    local cost = getCost(GOODS_KIND.SOLDIER, solId)
    local buyable = global.user:checkCost(cost)
    if buyable.ok == 0 then
        buyable.ok = nil
        for k, v in pairs(buyable) do
            addBanner(getStr("resLack", {"[NAME]", getStr(k, nil), "[NUM]", str(v)}) )
        end
        return
    end

    if #self.scene.objectList >= 3 then
        addBanner(getStr("campQueueEx", {"[NUM]", str(3)}))
        return 
    end
    
    local curSolNum = global.user:getSolNum()
    local campNum = global.user:getCampProductNum()
    curSolNum = curSolNum+campNum
    local peopleNum = global.user:getPeopleNum()
    if curSolNum > peopleNum then
        addBanner(getStr("buildHouse", {"[NUM1]", str(curSolNum), "[NUM2]", str(peopleNum)}))
        return 
    end


    local objectList = self.scene.objectList
    global.user:doCost(cost)
    local objectTime
    --首次招募士兵 开始当前时间
    if #objectList == 0 then
        objectTime = client2Server(Timer.now)
    else
        objectTime = client2Server(self.scene.funcBuild.objectTime)
    end
    print("objectTime", #objectList, self.scene.funcBuild.objectTime, Timer.now)
    table.insert(objectList, solId)
    local privateData = {objectId=0, objectTime=objectTime}
    self.scene.funcBuild:initWorking(privateData)
    global.user:updateBuilding(self.scene)

    sendReq("campAddSol", dict({{"uid", global.user.uid}, {"bid", self.scene.bid}, {"solId", solId}, {'cost', cost}, {'objectTime', objectTime}}))
    self:updateLeftPanel()
end

function SoldierStore:initLeftPanel()
    local initX = 96
    local initY = 64
    local offY = 130
    local sz = self.leftBack:getContentSize()
    local n = 0
    for k, v in ipairs(self.scene.objectList) do
        local sp = setPos(addSprite(self.leftBack, "solBlock.png"), {initX, fixY(sz.height, initY+offY*n)})
        local solId = v

        local pic = setPos(addSprite(sp, "soldier"..solId..".png"), {90, 51})
        --不停抖动的小兵
        local x = math.random(10)
        local y = math.random(5)
        pic:runAction(repeatForever(spawn({sequence({moveby(0.2, x, y), moveby(0.2, -x, -y)}), sequence({rotateby(0.2, 10), rotateby(0.2, -10)})})))

        local temp = setPos(ui.newBMFontLabel({text="--:--:--", size = 20, color={208, 70, 72}}), {90, fixY(102, 87)})
        sp:addChild(temp)

        table.insert(self.leftPanel, {solId, sp, temp})
        n = n+1
    end
end

function SoldierStore:updateLeftPanel()
    local initX = 96
    local initY = 64
    local offY = 130
    local sz = self.leftBack:getContentSize()
    local n = #self.leftPanel
    local sn = #self.scene.objectList
    print("leftPanel", n, sn)
    if #self.leftPanel < #self.scene.objectList then
        local sp = setPos(addSprite(self.leftBack, "solBlock.png"), {initX, fixY(sz.height, initY+offY*n)})
        local solId = self.scene.objectList[#self.scene.objectList]


        local pic = setPos(addSprite(sp, "soldier"..solId..".png"), {90, 51})
        --不停抖动的小兵
        local x = math.random(10)
        local y = math.random(5)
        pic:runAction(repeatForever(spawn({sequence({moveby(0.2, x, y), moveby(0.2, -x, -y)}), sequence({rotateby(0.2, 10), rotateby(0.2, -10)})})))

        local temp = setPos(ui.newBMFontLabel({text="--:--:--", size = 20, color={208, 70, 72}}), {90, fixY(102, 87)})
        sp:addChild(temp)

        table.insert(self.leftPanel, {solId, sp, temp})
        sp:setScale(0.1)
        sp:runAction(spawn({fadein(0.3), scaleto(0.3, 1, 1)}))

    elseif #self.leftPanel > #self.scene.objectList then
        local p = table.remove(self.leftPanel, 1)
        local function removeP()
            removeSelf(p[2])
        end
        p[2]:runAction(sequence({spawn({fadeout(0.3), scaleto(0.3, 0.1, 0.1)}), callfunc(nil, removeP)}))
        for k, v in ipairs(self.leftPanel) do
            v[2]:runAction(moveby(0.3, 0, offY))
        end
    end
end
function SoldierStore:update(diff)
    self.passTime = self.passTime + diff
    if self.passTime > 1 then
        self.passTime = 0
        if #self.leftPanel > 0 then
            local leftTime = self.scene.funcBuild:getRealLeftTime()
            local p = self.leftPanel[1][3]
            p:setColor(toCol({52, 101, 36}))
            p:setString(getWorkTime(leftTime[1]))
        end
    end
end
