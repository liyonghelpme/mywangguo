MiaoMenu = class()
function MiaoMenu:ctor(s)
    self.scene = s
    self.bg = CCNode:create()
    local but = ui.newButton({image="roleNameBut0.png", conSize={100, 50}, callback=self.onBuild, delegate=self, text="New", size=20})
    setPos(but.bg, {50, 50})
    but:setAnchor(0.5, 0.5)
    self.bg:addChild(but.bg)

    local but = ui.newButton({image="roleNameBut0.png", conSize={100, 50}, callback=self.onOk, delegate=self, text="确定", size=20})
    setPos(but.bg, {150, 50})
    but:setAnchor(0.5, 0.5)
    self.bg:addChild(but.bg)
end
function MiaoMenu:onBuild()
    self.scene:beginBuild()
end
function MiaoMenu:onOk()
    self.scene:finishBuild()
end
