require "Miao.PeopleInfo"
require "Miao.ConfigInfo"
FightInfo = class()
function FightInfo:ctor(param)
    self.callback = param.callback
    self.delegate = param.delegate
    self.bg = CCNode:create()
    local vs = getVS()
    local temp = setPos(setContentSize(addChild(self.bg, display.newScale9Sprite("tabback.jpg")), {500, 325}), {vs.width/2, vs.height/2})
    local tit = setPos(addSprite(temp, "title.png"), {250, fixY(325, 26)})
    local tw = setPos(addChild(temp, ui.newTTFLabel({text="合战参加者", size=15, color={10, 10, 10}})), {250, fixY(325, 29)})
    
    local head = setPos(addSprite(temp, "business_trader_1.png"), {87, fixY(325, 128)})
    local head = setPos(addSprite(temp, "business_trader_2.png"), {197, fixY(325, 128)})
    local head = setPos(addSprite(temp, "business_trader_3.png"), {304, fixY(325, 128)})
    local head = setPos(addSprite(temp, "business_trader_4.png"), {410, fixY(325, 128)})

    local w1 = setPos(addChild(temp, ui.newTTFLabel({text="步卒", size=12, color={8, 20, 176}})), {82, fixY(325, 197)})
    local w1 = setPos(addChild(temp, ui.newTTFLabel({text="弓队", size=12, color={8, 20, 176}})), {199, fixY(325, 197)})
    local w1 = setPos(addChild(temp, ui.newTTFLabel({text="铁统", size=12, color={8, 20, 176}})), {306, fixY(325, 197)})
    local w1 = setPos(addChild(temp, ui.newTTFLabel({text="铁骑", size=12, color={8, 20, 176}})), {410, fixY(325, 197)})
    
    local w1 = setAnchor(setPos(addChild(temp, ui.newBMFontLabel({text="+4", size=15, color={210, 125, 44}})), {92, fixY(325, 215)}), {1, 0.5})

    local w1 = setPos(addChild(temp, ui.newTTFLabel({text="进攻费用", size=15, color={8, 20, 176}})), {164, fixY(325, 257)})
    local w1 = setPos(addChild(temp, ui.newTTFLabel({text="435贯", size=15, color={10, 10, 10}})), {322, fixY(325, 257)})

    local but = ui.newButton({image="tabbut.png", text="参加者", size=15, color={10, 10, 10}, callback=self.onPeople, delegate=self})
    setPos(addChild(temp, but.bg), {107, fixY(325, 297)})
    local but = ui.newButton({image="tabbut.png", text="配置改变", size=15, color={10, 10, 10}, callback=self.onConfig, delegate=self})
    setPos(addChild(temp, but.bg), {250, fixY(325, 297)})
    local but = ui.newButton({image="tabbut.png", text="出征", size=15, color={10, 10, 10}, callback=self.onAttack, delegate=self})
    setPos(addChild(temp, but.bg), {413, fixY(325, 297)})
end
--返回到上一级菜单中
function FightInfo:onPeople()
    global.director:popView()
    local p = PeopleInfo.new(self.scene)
    global.director.curScene.menu.menu = p
    global.director:pushView(p, 1, 0)
end
function FightInfo:onConfig()
    global.director:popView()
    local p = ConfigInfo.new()
    global.director.curScene.menu.menu = p
    global.director:pushView(p, 1, 0)
end
function FightInfo:onAttack()
    global.director:popView()
    if self.callback ~= nil then
        self.callback(self.delegate)
    else
        global.director.curScene.layer.buildLayer:addPeople()  
    end
end
