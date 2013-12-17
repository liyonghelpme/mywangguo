require "menu.PeopleMenu2"
PressMenu2 = class()
--适配在最后调整每个UI即可
function PressMenu2:ctor()
    local vs = getVS()
    self.bg = CCNode:create()
    local sz = {width=398, height=532}
    self.sz = sz

    self.temp = setPos(addNode(self.bg), {14, fixY(vs.height, 109+sz.height)})
    
    local temp = {
        "建筑",
        "村民",
        "研究",
        "商人",
        "兵力",
        "情报",
        "系统",
    }

    local sp = setSize(setPos(addSprite(self.temp, "mainBoard.png"), {99, fixY(sz.height, 266)}), {199, 532})
    --local sp = setSize(setPos(addSprite(self.temp, "mainB.png"), {99, fixY(sz.height, 120)}), {181, 60})
    --local sp = setSize(setPos(addSprite(self.temp, "mainA.png"), {99, fixY(sz.height, 50)}), {181, 60})
    
    local initX = 99
    local initY = fixY(sz.height, 50)
    local offY = -70
    local dTime= 0
    self.data = {}
    for i=1, #temp, 1 do
        local but = ui.newButton({image="mainA.png",  callback=self.onBut, delegate=self, param=i})
        local sp = setSize(setPos(addSprite(but.bg, string.format("icon%d.png", i-1)), {31-181/2, fixY(60, 33)-60/2}), {45, 42})
        local w = setPos(setAnchor(addChild(but.bg, ui.newTTFLabel({text=temp[i], size=24, color={255, 255, 255}})), {0, 0.5}), {95-181/2, fixY(60, 29)-60/2})

        setPos(but.bg, {initX, initY+(i-1)*offY})
        but:setAnchor(0.5, 0.5)
        self.temp:addChild(but.bg)
        but.bg:setVisible(false)
        local function app()
            but.bg:setVisible(true)
        end
        but.sp:runAction(sequence({delaytime(dTime), callfunc(nil, app), fadein(0.2)}))
        dTime = dTime+0.1
        table.insert(self.data, but)
    end
    self:setSelect(1)
end
function PressMenu2:setSelect(s)
    if self.curSel ~= nil then
        setTexture(self.data[self.curSel].sp, "mainA.png")
    end
    self.curSel = s
    setTexture(self.data[self.curSel].sp, "mainB.png")
end
function PressMenu2:clearMenu()
    if self.subMenu then
        removeSelf(self.subMenu.bg)
        self.subMenu = nil
    end
end
function PressMenu2:onBut(p)
    if self.curSel ~= p then
        self:clearMenu()
        self:setSelect(p)

        if p == 1 then
        elseif p == 2 then
            local m = PeopleMenu2.new(self)
            self.temp:addChild(m.bg)
            self.subMenu = m
            --local sp = setSize(setPos(addSprite(self.temp, "主菜单底板 .png"), {298, fixY(sz.height, 223)}), {199, 291})
            --setPos(m.bg, {298-199/2, fixY(self.sz.height, 223+291/2)})
        end
    end
end
