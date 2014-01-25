require "menu.ChooseMenu"
require "menu.ArmyMenu"
ConfigMenu = class()
function ConfigMenu:ctor(ct)
    self.city = ct

    local vs = getVS()
    self.bg = CCNode:create()
    local sz = {width=1024, height=768}
    self.temp = setPos(addNode(self.bg), {0, fixY(sz.height, 0+sz.height)+0})
    local sp = setOpacity(setAnchor(setSize(setPos(addSprite(self.temp, "dialogA.png"), {525, fixY(sz.height, 388)}), {693, 588}), {0.50, 0.50}), 255)
    local sp = setOpacity(setAnchor(setSize(setPos(addSprite(self.temp, "dialogB.png"), {524, fixY(sz.height, 409)}), {626, 340}), {0.50, 0.50}), 255)
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="参战费用", size=26, color={32, 112, 220}, font="f2", shadowColor={255, 255, 255}})), {0.00, 0.50}), {258, fixY(sz.height, 215)})
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="(野外村落仅限英雄出战)", size=26, color={247, 5, 39}, font="f2", shadowColor={255, 255, 255}})), {0.00, 0.50}), {514, fixY(sz.height, 215)})
    local but = ui.newButton({image="newClose.png", text="", font="f1", size=18, delegate=self, callback=closeDialog, shadowColor={0, 0, 0}, color={255, 255, 255}})
    but:setContentSize(80, 82)
    setPos(addChild(self.temp, but.bg), {848, fixY(sz.height, 112)})
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="+34", size=18, color={248, 181, 81}, font="f1", shadowColor={0, 0, 0}})), {0.00, 0.50}), {341, fixY(sz.height, 531)})
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="+35", size=18, color={248, 181, 81}, font="f1", shadowColor={0, 0, 0}})), {0.00, 0.50}), {446, fixY(sz.height, 531)})
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="+36", size=18, color={248, 181, 81}, font="f1", shadowColor={0, 0, 0}})), {0.00, 0.50}), {550, fixY(sz.height, 531)})
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="+37", size=18, color={248, 181, 81}, font="f1", shadowColor={0, 0, 0}})), {0.00, 0.50}), {654, fixY(sz.height, 531)})
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="步兵", size=18, color={255, 255, 255}, font="f1", shadowColor={0, 0, 0}})), {0.50, 0.50}), {364, fixY(sz.height, 493)})
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="弓箭", size=18, color={255, 255, 255}, font="f1", shadowColor={0, 0, 0}})), {0.50, 0.50}), {469, fixY(sz.height, 494)})
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="魔法", size=18, color={255, 255, 255}, font="f1", shadowColor={0, 0, 0}})), {0.50, 0.50}), {574, fixY(sz.height, 493)})
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="骑兵", size=18, color={255, 255, 255}, font="f1", shadowColor={0, 0, 0}})), {0.50, 0.50}), {677, fixY(sz.height, 493)})
    local but = ui.newButton({image="butc.png", text="配置调整", font="f1", size=27, delegate=self, callback=self.onBut, param=1, shadowColor={0, 0, 0}, color={206, 78, 0}})
    but:setContentSize(158, 50)
    setPos(addChild(self.temp, but.bg), {528, fixY(sz.height, 615)})
    local but = ui.newButton({image="butd.png", text="出战!", font="f1", size=27, delegate=self, callback=self.onBut, param=3, shadowColor={0, 0, 0}, color={255, 255, 255}})
    but:setContentSize(158, 50)
    setPos(addChild(self.temp, but.bg), {712, fixY(sz.height, 615)})
    local but = ui.newButton({image="butc.png", text="参加者", font="f1", size=27, delegate=self, callback=self.onBut, param=2, param=2, shadowColor={0, 0, 0}, color={206, 78, 0}})
    but:setContentSize(159, 50)
    setPos(addChild(self.temp, but.bg), {342, fixY(sz.height, 614)})
    local sp = setOpacity(setAnchor(setSize(setPos(addSprite(self.temp, "picBefore.png"), {523, fixY(sz.height, 365)}), {519, 176}), {0.50, 0.50}), 255)
    local sp = setOpacity(setAnchor(setSize(setPos(addSprite(self.temp, "configTitle.png"), {533, fixY(sz.height, 147)}), {212, 41}), {0.50, 0.50}), 255)

    centerUI(self)
end

function ConfigMenu:onBut(p)
    if p == 1 then
        global.director:pushView(ArmyMenu.new(), 1)
    elseif p == 2 then
        global.director:pushView(ChooseMenu.new(), 1, 0)
    elseif p == 3 then
        print("fight menu city")
        global.director.curScene.page:sendCat(self.city)
        global.director:popView()
        global.director:pushView(SessionMenu.new("那么现在开始向\n战场出发!!"), 1, 0)
    end
end

function ConfigMenu:refreshData()
end

