SellMenu2 = class()
function SellMenu2:ctor(b)
    self.build = b

    local vs = getVS()
    self.bg = CCNode:create()
    local sz = {width=1024, height=768}
    self.temp = setPos(addNode(self.bg), {0, 0})

    local sp = setAnchor(setSize(setPos(addSprite(self.temp, "smallDialog.png"), {533, fixY(sz.height, 386)}), {708, 396}), {0.50, 0.50})
    local w = colorWords({text=string.format("<ffffff你确定卖出><63a3f9%s>?", self.build.data.name), size=24, font="f1"})
    setPos(setAnchor(addChild(self.temp, w), {0.50, 0.50}), {531, fixY(sz.height, 363)})

    local but = ui.newButton({image="butc.png", text="确定", font="f1", size=25, delegate=self, callback=self.onSell})
    but:setContentSize(73, 38)
    setPos(addChild(self.temp, but.bg), {532, fixY(sz.height, 533)})
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="确定卖出？", size=34, color={102, 4, 554}, font="f1"})), {0.00, 0.50}), {450, fixY(sz.height, 247)})
end
function SellMenu2:onSell()
    global.director:popView()
    self.build:removeSelf()
end
