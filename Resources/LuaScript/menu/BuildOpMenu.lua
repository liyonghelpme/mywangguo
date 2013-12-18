BuildOpMenu = class()
function BuildOpMenu:ctor()
    local vs = getVS()
    self.bg = CCNode:create()
    local sz = {width=1024, height=768}
    self.temp = setPos(addNode(self.bg), {0, 0})
    local but = ui.newButton({image="buta.png", text="详情", font="f2", size=23})
    setPos(addChild(self.temp, but.bg), {435, fixY(sz.height, 704)})
    local but = ui.newButton({image="buta.png", text="卖出", font="f2", size=23})
    setPos(addChild(self.temp, but.bg), {545, fixY(sz.height, 704)})
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="服装店", size=30, color={241, 13, 1179}, font="f2"})), {0.00, 0.50}), {446, fixY(sz.height, 625)})
end
