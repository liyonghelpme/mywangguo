require "views.Hint"
require "views.Goods"
require "views.Choice"
Store = class()
function Store:ctor(s)
    self.scene = s
    self.allGoods = StoreGoods
    local sz = {800, 480}
    self.pics = {
     --"goodTreasure.png", "goodBuild.png", "goodDecor.png",  "goodWeapon.png", "goodMagic.png",
     "goodBuild.png",
     "goodGold.png",
    }
    self.titles = {
    --"buyTreasure.png", "buyBuild.png", "buyDecor.png", "buyWeapon.png", "buyMagic.png",
    "buyBuild.png",
    "buyGold.png",
    }
    self.bg = CCNode:create()
    setDesignXY(self.bg)
    setMidPos(self.bg)

    local ds = global.director.designSize
    setPos(setAnchor(addSprite(self.bg, "back.png"), {0, 0}), {0, 0})
    setPos(setAnchor(addSprite(self.bg, "diaBack.png"), {0.5, 1}), {ds[1]/2, ds[2]-10})

    setPos(setAnchor(addSprite(self.bg, "rightBack.png"), {0, 0}), {254, fixY(global.director.designSize[2], 79, 387)})
    setPos(setAnchor(addSprite(self.bg, "storeLeft.png"), {0, 0}), {34, fixY(global.director.designSize[2], 79, 387)})

    local choose = setPos(setAnchor(CCSprite:create("instructArrow.png"), {0, 0}), {22, fixY(global.director.designSize[2], 211, 117)})
    self.bg:addChild(choose, 1)

    setPos(setAnchor(addSprite(self.bg, "moneyBack.png"), {0, 0}), {274, fixY(global.director.designSize[2], 28, 33)})
    setSize(setPos(setAnchor(addSprite(self.bg, "crystal.png"), {0, 0}), {586, fixY(global.director.designSize[2], 30, 29)}), {31, 29})
    setSize(setPos(setAnchor(addSprite(self.bg, "gold.png"), {0, 0}), {439, fixY(global.director.designSize[2], 30, 29)}), {31, 29})
    setSize(setPos(setAnchor(addSprite(self.bg, "silver.png"), {0, 0}), {280, fixY(global.director.designSize[2], 30, 29)}), {31, 29})

    self.silverText = ui.newBMFontLabel({text="1", font="bound.fnt", size=23})
    setPos(setAnchor(self.silverText, {0, 0.5}), {318, fixY(sz[2], 43)})
    self.bg:addChild(self.silverText)
    
    self.goldText = ui.newBMFontLabel({text="1", font="bound.fnt", size=23})
    setPos(setAnchor(self.goldText, {0, 0.5}), {474, fixY(sz[2], 43)})
    self.bg:addChild(self.goldText)

    self.crystalText = ui.newBMFontLabel({text="1", font="bound.fnt", size=23})
    setPos(setAnchor(self.crystalText, {0, 0.5}), {621, fixY(sz[2], 43)})
    self.bg:addChild(self.crystalText)


    setPos(setAnchor(addSprite(self.bg, "storeTit.png"), {0, 0}), {76, fixY(global.director.designSize[2], 7, 63)})

    self.goods = Goods.new(self)
    self.bg:addChild(self.goods.bg)

    self.tabs = Choice.new(self)
    self.bg:addChild(self.tabs.bg)

    setPos(setAnchor(addSprite(self.bg, "leftBoard.png"), {0, 0}), {29, fixY(global.director.designSize[2], 74, 396)})
    local but0 = ui.newButton({image="closeBut.png", delegate=self, callback=self.closeDialog}):setAnchor(0.5, 0.5)
    setPos(but0.bg, {772, fixY(global.director.designSize[2], 27, nil, 0.5)})
    self.bg:addChild(but0.bg)

    self:initData()
    self.curSel = -1
    self:changeTab(0)
    registerEnterOrExit(self)

    --self.bg:addChild(Hint.new().bg)
end
function Store:receiveMsg(name, msg)
    print("receiveMsg", name)
    if name == EVENT_TYPE.UPDATE_RESOURCE then
        self:updateText()
    elseif name == EVENT_TYPE.TAP_FARM then
        self.goods:showHint(0)
    end
end
function Store:updateText()
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

function Store:enterScene()
    Event:registerEvent(EVENT_TYPE.UPDATE_RESOURCE, self)
    Event:registerEvent(EVENT_TYPE.TAP_FARM, self)
    self:updateText()
end
function Store:exitScene()
    Event:unregisterEvent(EVENT_TYPE.TAP_FARM, self)
    Event:unregisterEvent(EVENT_TYPE.UPDATE_RESOURCE, self)
    --MyPlugins:getInstance():sendCmd("showAds", "");
end

function Store:closeDialog()
    global.director:popView()
end
function Store:initData()
end
function Store:changeTab(i)
    self.tabs:changeTab(i);
end
function Store:setTab(i)
    if i >= 0 and i < #self.allGoods then
        if self.curSel ~= i then
            self.curSel = i
            self.goods:setTab(i)
        end
    end
end
function Store:buy(gi)
    print("Store buy", gi[1], gi[2])
    local item = self.allGoods[gi[1]+1][gi[2]+1]
    local kind = item[1]
    local id = item[2]
    local cost
    local buyable
    local ret
    if kind == GOODS_KIND.GOLD then
        if id == 0 then
            MyPlugins:getInstance():sendCmd("showOffers", "")
        elseif id == 1 then
            MyPlugins:getInstance():sendCmd("freeCrystal", "")
            local reward = {}
            local dir = math.random(2)
            if dir == 1 then
                reward.crystal = 100
                addBanner(getStr("getRew", {"[NUM]", 100, "[KIND]", getStr("crystal")}))
            else
                reward.silver = 100
                addBanner(getStr("getRew", {"[NUM]", 100, "[KIND]", getStr("silver")}))
            end
            sendReq("killMonster", dict({{"uid", global.user.uid}, {"gain", reward}}))
            global.user:doAdd(reward)
        end
        return
    end

    local data = getData(kind, id)

    local ret = checkBuildNum(id)
    print("checkBuildNum", simple.encode(ret))
    if ret[1] == false then
        if ret[2] == 0 then
            addBanner(getStr("buildTooCon", {"[LEV]", str(getNextBuildNum(id)+1), "[NAME]", data.name}))
        else
            addBanner(getStr("buildMax", nil))
        end
        return
    end

    if kind == GOODS_KIND.BUILD then
        global.director:popView()
        self.scene:beginBuild(id)
    end
end
