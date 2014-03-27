SureGold = class()
function SureGold:ctor(cb, del)
    self.callback = cb
    self.delegate = del

    local vs = getVS()
    self.bg = CCNode:create()
    local sz = {width=1024, height=768}
    self.temp = setPos(addNode(self.bg), {0, fixY(sz.height, 0+sz.height)+0})
    local sp = setOpacity(setAnchor(setSize(setPos(addSprite(self.temp, "sdialoga.png"), {512, fixY(sz.height, 396)}), {633, 427}), {0.50, 0.50}), 255)
    local sp = setOpacity(setAnchor(setSize(setPos(addSprite(self.temp, "smallDialogb.png"), {512, fixY(sz.height, 403)}), {588, 246}), {0.50, 0.50}), 255)
    local but = ui.newButton({image="newClose.png", text="", font="f1", size=18, delegate=self, callback=closeDialog, shadowColor={0, 0, 0}, color={255, 255, 255}})
    but:setContentSize(80, 82)
    setPos(addChild(self.temp, but.bg), {813, fixY(sz.height, 196)})
    local but = ui.newButton({image="butc.png", text="确定", font="f1", size=27, delegate=self, callback=self.onBut, param=1, shadowColor={0, 0, 0}, color={255, 255, 255}})
    but:setContentSize(158, 50)
    setPos(addChild(self.temp, but.bg), {512-123, fixY(sz.height, 553)})

    local but = ui.newButton({image="butc.png", text="取消", font="f1", size=27, delegate=self, callback=self.onBut, param=2,  shadowColor={0, 0, 0}, color={255, 255, 255}})
    but:setContentSize(158, 50)
    setPos(addChild(self.temp, but.bg), {512+123, fixY(sz.height, 553)})

    --local sp = setOpacity(setAnchor(setSize(setPos(addSprite(self.temp, "sellTitle.png"), {533, fixY(sz.height, 234)}), {219, 39}), {0.50, 0.50}), 255)
    local sp = setOpacity(setAnchor(setSize(setPos(addSprite(self.temp, "dialogCat.png"), {749, fixY(sz.height, 500)}), {101, 157}), {0.50, 0.50}), 255)


    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text='要花费金币么？', dimensions=CCSizeMake(1024, 768), align=ui.TEXT_ALIGN_LEFT, valign=ui.TEXT_VALIGN_TOP, size=28, color={255, 255, 255}, font="f1", shadowColor={0, 0, 0}})), {0.00, 1.00}), {261, fixY(sz.height, 323)})

    centerUI(self)
end
function SureGold:onBut(p)
    global.director:popView()
    if p == 1 then
        self.callback(self.delegate)
    else
    end
end
