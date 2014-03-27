SellMenu2 = class()
function SellMenu2:adjustPos()
    local vs = getVS()
    local ds = global.director.designSize
    local sca = math.min(vs.width/ds[1], vs.height/ds[2])
    local pos = getPos(self.temp)
    local cx, cy = ds[1]/2-pos[1], ds[2]/2-pos[2]
    local nx, ny = vs.width/2-cx*sca, vs.height/2-cy*sca

    setScale(self.temp, sca)
    setPos(self.temp, {nx, ny})
end
function SellMenu2:ctor(b)
    self.build = b

    local vs = getVS()
    self.bg = CCNode:create()
    local sz = {width=1024, height=768}
    self.temp = setPos(addNode(self.bg), {0, fixY(sz.height, 0+sz.height)+0})
    local sp = setOpacity(setAnchor(setSize(setPos(addSprite(self.temp, "sdialoga.png"), {512, fixY(sz.height, 396)}), {633, 427}), {0.50, 0.50}), 255)
    local sp = setOpacity(setAnchor(setSize(setPos(addSprite(self.temp, "smallDialogb.png"), {512, fixY(sz.height, 403)}), {588, 246}), {0.50, 0.50}), 255)
    local but = ui.newButton({image="newClose.png", text="", font="f1", size=18, delegate=self, callback=closeDialog, shadowColor={0, 0, 0}, color={255, 255, 255}})
    but:setContentSize(80, 82)
    setPos(addChild(self.temp, but.bg), {813, fixY(sz.height, 196)})
    local but = ui.newButton({image="butc.png", text="确定", font="f1", size=27, delegate=self, callback=self.onSell, shadowColor={0, 0, 0}, color={255, 255, 255}})
    but:setContentSize(158, 50)
    setPos(addChild(self.temp, but.bg), {513, fixY(sz.height, 553)})
    local sp = setOpacity(setAnchor(setSize(setPos(addSprite(self.temp, "sellTitle.png"), {533, fixY(sz.height, 234)}), {219, 39}), {0.50, 0.50}), 255)
    local sp = setOpacity(setAnchor(setSize(setPos(addSprite(self.temp, "dialogCat.png"), {749, fixY(sz.height, 500)}), {101, 157}), {0.50, 0.50}), 255)

    local w = colorWords({text=string.format("<ffffff你确定卖出><63a3f9%s>?", self.build.data.name), font='f2', size=24})
    setPos(setAnchor(addChild(self.temp, w), {0.00, 1.00}), {261, fixY(sz.height, 323)})
    centerUI(self)
end
function SellMenu2:onSell()
    global.director:popView()
    self.build:removeSelf()
end
