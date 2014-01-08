FightMenu = class()
function FightMenu:ctor()
    local vs = getVS()
    self.bg = CCNode:create()
    local sz = {width=1024, height=768}
    self.temp = setPos(addNode(self.bg), {0, fixY(sz.height, 0+sz.height)+0})
    self.rightBottom = addNode(self.temp)
    local but = ui.newButton({image="buta.png", text="返回", font="f2", size=30, delegate=self, callback=self.onBut, shadowColor={255, 255, 255}, color={206, 78, 0}})
    but:setContentSize(107, 113)
    setPos(addChild(self.rightBottom, but.bg), {945, fixY(sz.height, 706)})
    rightBottomUI(self.rightBottom)
end
function FightMenu:onBut()
    global.director:popScene()
end

