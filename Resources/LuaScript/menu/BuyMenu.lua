BuyMenu = class()
--装备和用户信息
function BuyMenu:ctor(p, e)
    self.people = p
    self.equip = e

    local vs = getVS()
    self.bg = CCNode:create()
    local sz = {width=1024, height=768}
    self.temp = setPos(addNode(self.bg), {36.5, fixY(vs.height, 0+sz.height)+4.5})
    local sp = setAnchor(setSize(setPos(addSprite(self.temp, "sdialoga.png"), {485, fixY(sz.height, 379)}), {619, 381}), {0.50, 0.50})
    local but = ui.newButton({image="butb.png", text="取消", font="f1", size=25, delegate=self, callback=self.onCancel})
    but:setContentSize(117, 43)
    setPos(addChild(self.temp, but.bg), {574, fixY(sz.height, 528)})
    local but = ui.newButton({image="butd.png", text="确定", font="f1", size=25, delegate=self, callback=self.onOK})
    but:setContentSize(117, 43)
    setPos(addChild(self.temp, but.bg), {411, fixY(sz.height, 528)})
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="信息", size=34, color={102, 66, 42}, font="f1"})), {0.50, 0.50}), {475, fixY(sz.height, 245)})
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="并进行装备", size=28, color={255, 255, 255}, font="f1"})), {0.50, 0.50}), {478, fixY(sz.height, 410)})
    local w = setPos(setAnchor(addChild(self.temp, colorWords({text=string.format("将<2070dc%s>购入", self.equip.name), size=28, color={255, 255, 255}, font="f1"})), {0.50, 0.50}), {483, fixY(sz.height, 366)})
end
function BuyMenu:onOK()
    global.director:popView()
    if not checkCost(self.equip.silver) then
        addBanner("银币不足")
    else
        doCost(self.equip.silver)
        self.people:setEquip(self.equip.id)
        addBanner(self.people.name.."装备"..self.equip.name..'成功')
    end
end
function BuyMenu:onCancel()
    global.director:popView()
end
