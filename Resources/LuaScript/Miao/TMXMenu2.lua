require "Miao.PressMenu2"
TMXMenu2 = class()
function TMXMenu2:ctor(s)
    self.scene = s
    local vs = getVS()
    self.bg = CCNode:create()
    self.temp = addNode(self.bg)
    local temp = self.temp
    local sz = vs


    local but = ui.newButton({image="buta.png", text="地图"})
    setPos(addChild(temp, but.bg), {62, fixY(768, 704)})
    local but = ui.newButton({image="buta.png", text="菜单", delegate=self, callback=self.onMenu})
    setPos(addChild(temp, but.bg), {vs.width-fixX(1024, 961), fixY(768, 704)})
    local sp = setSize(setPos(addSprite(self.temp, "numBack.png"), {110, fixY(sz.height, 72)}), {156, 30})
    local sp = setSize(setPos(addSprite(self.temp, "silverIcon.png"), {39, fixY(sz.height, 72)}), {50, 50})


    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="10000", size=18, color={255, 255, 255}})), {0, 0.5}), {79, fixY(sz.height, 70)})
    local sp = setSize(setPos(addSprite(self.temp, "numBack.png"), {288, fixY(sz.height, 72)}), {156, 30})
    local sp = setSize(setPos(addSprite(self.temp, "chargeIcon.png"), {349, fixY(sz.height, 73)}), {33, 37})
    local sp = setSize(setPos(addSprite(self.temp, "goldIcon.png"), {217, fixY(sz.height, 73)}), {50, 50})

    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="10000", size=18, color={255, 255, 255}})), {0, 0.5}), {257, fixY(sz.height, 70)})

    local w = colorWords({text="<57b7fd999><ffffff年><57b7fd12><ffffff月><57b7fd7><ffffff周>"})
    setPos(setAnchor(addChild(self.temp, w), {0, 0.5}), {210, fixY(sz.height, 24)})


    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="最长的村落名字", size=24, color={255, 255, 255}})), {0, 0.5}), {16, fixY(sz.height, 25)})
end

function TMXMenu2:onMenu()
    global.director:pushView(PressMenu2.new(), 1, 0)
end
