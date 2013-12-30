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
    self.temp = setPos(addNode(self.bg), {0, 0})
    self:adjustPos()

    local sp = setAnchor(setSize(setPos(addSprite(self.temp, "smallDialog.png"), {533, fixY(sz.height, 386)}), {708, 396}), {0.50, 0.50})
    local w = colorWords({text=string.format("<ffffff你确定卖出><63a3f9%s>?", self.build.data.name), font='f2', size=24})
    setPos(setAnchor(addChild(self.temp, w), {0.50, 0.50}), {531, fixY(sz.height, 363)})

    local but = ui.newButton({image="butc.png", text="确定", font="f1", size=25, delegate=self, callback=self.onSell, conSize={117, 43} })
    --but:setContentSize(73, 38)
    setPos(addChild(self.temp, but.bg), {532, fixY(sz.height, 533)})
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="确定卖出？", size=34, color={102, 4, 554}, font="f1"})), {0.00, 0.50}), {450, fixY(sz.height, 247)})
end
function SellMenu2:onSell()
    global.director:popView()
    self.build:removeSelf()
end
