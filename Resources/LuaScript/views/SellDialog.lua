SellDialog = class()
--可以上下拖动的新手对话框 
--在手机上面测试哪些图片没有
function SellDialog:ctor(w, cb)
    self.callback = cb
    self.bg = CCNode:create()
    local vs = getVS()
    local temp = setPos(addSprite(self.bg, "parchment.png"), {vs.width/2, vs.height/2})
    self.pic = temp
    print("temp pos")

    local sz = self.pic:getContentSize()
    setPos(addSprite(self.pic, "girl.png"), {11, fixY(sz.height, 51)})

    local but = ui.newButton({image="roleNameBut0.png", callback=self.onOk, delegate=self, conSize={100, 40}, text=getStr("ok"), size=30})
    setPos(but.bg, {sz.width/2-70, fixY(sz.height, 259)})
    self.pic:addChild(but.bg)
    but:setAnchor(0.5, 0.5)

    local but = ui.newButton({image="roleNameBut0.png", callback=self.onCancel, delegate=self, conSize={100, 40}, text=getStr("cancel"), size=30})
    setPos(but.bg, {sz.width/2+70, fixY(sz.height, 259)})
    self.pic:addChild(but.bg)
    but:setAnchor(0.5, 0.5)
    
    self.content = ui.newTTFLabel({text=w, font="", size=20, color={48, 52, 109}, dimensions={278, 0}})
    setAnchor(setPos(self.content, {122, fixY(sz.height, 142)}), {0, 0.5})
    self.pic:addChild(self.content)
end
--每次点击一下 进入下一个步骤
function SellDialog:onOk()
    global.director:popView()
    self.callback()
end
function SellDialog:onCancel()
    global.director:popView()
end


