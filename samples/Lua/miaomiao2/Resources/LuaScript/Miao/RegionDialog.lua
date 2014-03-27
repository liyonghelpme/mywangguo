RegionDialog = class()
function RegionDialog:ctor()
    self.bg = CCNode:create()
    local vs = getVS()
    local temp = setPos(setContentSize(addChild(self.bg, display.newScale9Sprite("tabback.jpg")), {318, 243}), {vs.width/2, vs.height/2})
    local head = setPos(addSprite(temp, "business_trader_12.png"), {47, fixY(243, 87)})
    local w = setPos(setAnchor(addChild(temp, ui.newTTFLabel({text="地名", size=15, color={8, 20, 176}})), {1, 0.5}), {127, fixY(243, 51)})
    local w = setPos(setAnchor(addChild(temp, ui.newTTFLabel({text="面积", size=15, color={8, 20, 176}})), {1, 0.5}), {127, fixY(243, 81)})
    local w = setPos(setAnchor(addChild(temp, ui.newTTFLabel({text="领主", size=15, color={8, 20, 176}})), {1, 0.5}), {127, fixY(243, 112)})
    local w = setPos(setAnchor(addChild(temp, ui.newTTFLabel({text="攻略费用", size=15, color={8, 20, 176}})), {1, 0.5}), {127, fixY(243, 160)})

    local w = setPos(setAnchor(addChild(temp, ui.newTTFLabel({text="一滤波地区", size=15, color={10, 10, 10}})), {0.5, 0.5}), {192, fixY(243, 51)})
    local w = setPos(setAnchor(addChild(temp, ui.newTTFLabel({text="20格", size=15, color={10, 10, 10}})), {0.5, 0.5}), {192, fixY(243, 81)})
    local w = setPos(setAnchor(addChild(temp, ui.newTTFLabel({text="西所持家", size=15, color={10, 10, 10}})), {0.5, 0.5}), {192, fixY(243, 112)})
    local w = setPos(setAnchor(addChild(temp, ui.newTTFLabel({text="20贯", size=15, color={10, 10, 10}})), {0.5, 0.5}), {192, fixY(243, 160)})

    local but = ui.newButton({image="tabbut.png", text="攻略", color={10, 10, 10}, size=15, callback=self.onAttack, delegate=self})
    temp:addChild(but.bg)
    setPos(but.bg, {158, fixY(243, 211)})
end
--Logic里面放一些 全局的Fight信息
function RegionDialog:onAttack()
    global.director:popView()
    local fi = FightInfo.new({callback=self.fightNow, delegate=self})
    global.director:pushView(fi, 1, 0)
end
function RegionDialog:fightNow()
    Logic.getNewRegion = true
    global.director:pushScene(FightScene.new()) 
end
