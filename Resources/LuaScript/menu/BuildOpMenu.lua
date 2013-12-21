require "menu.SellMenu2"

BuildOpMenu = class()
function BuildOpMenu:adjustPos()
    local vs = getVS()
    local ds = global.director.designSize
    local offX = vs.width/2-ds[1]/2

    setPos(self.temp, {offX, 0})
end
function BuildOpMenu:ctor(b)
    self.build = b
    local vs = getVS()
    self.bg = CCNode:create()
    local sz = {width=1024, height=768}
    self.temp = setPos(addNode(self.bg), {0, 0})
    local but = ui.newButton({image="buta.png", text="详情", font="f2", size=23})
    but:setContentSize(87, 87)
    setPos(addChild(self.temp, but.bg), {457, fixY(sz.height, 704)})
    local but = ui.newButton({image="buta.png", text="卖出", font="f2", size=23, delegate=self, callback=self.onSell})
    but:setContentSize(87, 87)
    setPos(addChild(self.temp, but.bg), {567, fixY(sz.height, 704)})
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text=self.build.data.name, size=30, color=hexToDec('f1d49b'), font="f2"})), {0.50, 0.50}), {512, fixY(sz.height, 625)})
    registerEnterOrExit(self)
end
function BuildOpMenu:exitScene()
    self.build.funcBuild:clearMenu()
end
function BuildOpMenu:onSell()
    global.director:popView()
    --self.build:removeSelf()
    global.director:pushView(SellMenu2.new(self.build), 1)
end

