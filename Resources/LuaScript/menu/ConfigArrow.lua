ConfigArrow = class()
function ConfigArrow:ctor()

local vs = getVS()
self.bg = CCNode:create()
local sz = {width=1024, height=768}
self.temp = setPos(addNode(self.bg), {0, fixY(sz.height, 0+sz.height)+0})
local sp = setOpacity(setAnchor(setSize(setPos(addSprite(self.temp, "sdialoga.png"), {512, fixY(sz.height, 396)}), {633, 427}), {0.50, 0.50}), 255)
local sp = setAnchor(setPos(addChild(self.temp, createSmallDialogb()), {512, fixY(sz.height, 403)}), {0.50, 0.50})
local but = ui.newButton({image="butc.png", text="确定", font="f1", size=27, delegate=self, callback=self.onBut, param=0, shadowColor={0, 0, 0}, color={255, 255, 255}})
but:setContentSize(158, 50)
setPos(addChild(self.temp, but.bg), {509, fixY(sz.height, 551)})
local sp = setOpacity(setAnchor(setSize(setPos(addSprite(self.temp, "dialogCat.png"), {749, fixY(sz.height, 500)}), {101, 157}), {0.50, 0.50}), 255)
local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="箭矢的攻击对象", size=25, color={10, 76, 176}, font="f1", shadowColor={0, 0, 0}})), {0.00, 0.50}), {269, fixY(sz.height, 383)})
local but = ui.newButton({image="butd.png", text="委任", font="f1", size=25, delegate=self, callback=self.onBut, shadowColor={0, 0, 0}, color={10, 10, 10}})
but:setContentSize(117, 43)
self.bword = but

setPos(addChild(self.temp, but.bg), {593, fixY(sz.height, 384)})
local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="战斗情报", size=35, color={10, 10, 10}, font="f1", shadowColor={0, 0, 0}})), {0.50, 0.50}), {516, fixY(sz.height, 231)})
local but = ui.newButton({image="lefta.png", text="", font="f1", size=18, delegate=self, callback=self.onBut, param=1,  shadowColor={0, 0, 0}, color={255, 255, 255}})
but:setContentSize(45, 51)
setPos(addChild(self.temp, but.bg), {508, fixY(sz.height, 385)})
local but = ui.newButton({image="righta.png", text="", font="f1", size=18, delegate=self, callback=self.onBut, param=2, shadowColor={0, 0, 0}, color={255, 255, 255}})
but:setContentSize(45, 51)
setPos(addChild(self.temp, but.bg), {678, fixY(sz.height, 385)})
self.selTarget = Logic.selTarget
self:setSel()

registerEnterOrExit(self)
end
function ConfigArrow:setSel()
    local t = {'委任', '步兵', '弓箭', '魔法', '骑兵'}
    self.selTarget = self.selTarget%5
    Logic.selTarget = self.selTarget
    self.bword.text:setString(t[self.selTarget+1])
end
function ConfigArrow:onBut(p)
    if p == 0 then
        global.director:popView()
    elseif p == 1 then
        self.selTarget = self.selTarget-1
        self:setSel()
    elseif p == 2 then
        self.selTarget = self.selTarget+1
        self:setSel()
    end
end

function ConfigArrow:exitScene()
    Logic.battlePause = false
end
