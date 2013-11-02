UseGold = class()
function UseGold:ctor(cb, gold)
    self.callback = cb
    self.bg = CCNode:create()
    local vs = getVS()
    local temp = setPos(addSprite(self.bg, "parchment.png"), {vs.width/2, vs.height/2})
    self.pic = temp

    local sz = self.pic:getContentSize()
    setPos(addSprite(self.pic, "girl.png"), {11, fixY(sz.height, 51)})

    local but = ui.newButton({image="roleNameBut0.png", callback=self.onOk, delegate=self, conSize={100, 50}, text=getStr("ok"), size=30})
    setPos(but.bg, {sz.width/2-120, fixY(sz.height, 259)})
    self.pic:addChild(but.bg)
    but:setAnchor(0.5, 0.5)

    local but = ui.newButton({image="roleNameBut0.png", callback=self.onCancel, delegate=self, conSize={100, 50}, text=getStr("cancel"), size=30})
    setPos(but.bg, {sz.width/2+120, fixY(sz.height, 259)})
    self.pic:addChild(but.bg)
    but:setAnchor(0.5, 0.5)

    print("useGold", gold.gold)
    self.content = ui.newTTFLabel({text=getStr("useGold", {"[NUM]", str(gold.gold)}), font="", size=20, color={48, 52, 109}, dimensions={278, 0}})
    setAnchor(setPos(self.content, {122, fixY(sz.height, 142)}), {0, 0.5})
    self.pic:addChild(self.content)
end
--先关闭自身再回调
function UseGold:onOk()
    global.director:popView()
    self.callback(true)
end
function UseGold:onCancel()
    global.director:popView()
    self.callback(false)
end
