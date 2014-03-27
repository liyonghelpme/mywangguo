BuyMenu = class()
--装备和用户信息
function BuyMenu:ctor(p, e)
    self.people = p
    self.equip = e
    --[[
    local vs = getVS()
    self.bg = CCNode:create()
    local sz = {width=1024, height=768}
    self.temp = setPos(addNode(self.bg), {36.5, 4.5})
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
    --]]

    local vs = getVS()
    self.bg = CCNode:create()
    local sz = {width=1024, height=768}
    self.temp = setPos(addNode(self.bg), {0, fixY(sz.height, 0+sz.height)+0})
    local sp = setOpacity(setAnchor(setSize(setPos(addSprite(self.temp, "sdialoga.png"), {512, fixY(sz.height, 396)}), {633, 427}), {0.50, 0.50}), 255)
    local sp = setOpacity(setAnchor(setSize(setPos(addSprite(self.temp, "smallDialogb.png"), {512, fixY(sz.height, 403)}), {588, 246}), {0.50, 0.50}), 255)
    local but = ui.newButton({image="newClose.png", text="", font="f1", size=18, delegate=self, callback=self.onBut, shadowColor={0, 0, 0}, color={255, 255, 255}})
    but:setContentSize(80, 82)
    setPos(addChild(self.temp, but.bg), {813, fixY(sz.height, 196)})
    local but = ui.newButton({image="butc.png", text="取消", font="f1", size=27, delegate=self, callback=self.onCancel, shadowColor={0, 0, 0}, color={255, 255, 255}})
    but:setContentSize(158, 50)
    setPos(addChild(self.temp, but.bg), {612, fixY(sz.height, 551)})
    local but = ui.newButton({image="butd.png", text="确定", font="f1", size=27, delegate=self, callback=self.onOK, shadowColor={0, 0, 0}, color={206, 78, 0}})
    but:setContentSize(159, 50)
    setPos(addChild(self.temp, but.bg), {406, fixY(sz.height, 551)})
    local sp = setOpacity(setAnchor(setSize(setPos(addSprite(self.temp, "buyEquipTitle.png"), {522, fixY(sz.height, 234)}), {196, 39}), {0.50, 0.50}), 255)
    local sp = setOpacity(setAnchor(setSize(setPos(addSprite(self.temp, "dialogCat.png"), {749, fixY(sz.height, 500)}), {101, 157}), {0.50, 0.50}), 255)

    local w = setPos(setAnchor(addChild(self.temp, colorWords({text=string.format("将<2070dc%s>购入", self.equip.name), size=28, color={255, 255, 255}, font="f1"})), {0.00, 1.00}), {263, fixY(sz.height, 323)})

    centerUI(self)
end
function BuyMenu:onOK()
    if not checkCost(self.equip.silver) then
        addBanner("银币不足")
    else
        doCost(self.equip.silver)
        self.people:setEquip(self.equip.id)
        addBanner(self.people.data.name.."装备"..self.equip.name..'成功')
    end
    --先更新数据 再退出对话框 或者使用通知机制
    --先退出对话框 接着 接受更新通知
    global.director:popView()
end
function BuyMenu:onCancel()
    global.director:popView()
end
