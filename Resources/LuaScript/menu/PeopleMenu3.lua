require "menu.TrainMenu2"
require "menu.FindPeople2"
require "menu.EquipMenu2"
require "menu.AttributeMenu"
PeopleMenu3 = class()
function PeopleMenu3:ctor()
    local vs = getVS()
    self.bg = CCNode:create()
    local sz = {width=1024, height=768}
    self.temp = setPos(addNode(self.bg), {0, fixY(sz.height, 0+sz.height)+0})
    local sp = setAnchor(setSize(setPos(addSprite(self.temp, "mainBoarda.png"), {688, fixY(sz.height, 337)}), {212, 332}), {0.50, 0.50})

    local temp = {
        "强度",
        "装备",
        "进行修习",
        "人才启用",
    }

    local sp = setAnchor(setSize(setPos(addSprite(self.temp, "mainBa.png"), {688, fixY(sz.height, 445)}), {190, 68}), {0.50, 0.50})
    local sp = setAnchor(setSize(setPos(addSprite(self.temp, "mainBa.png"), {688, fixY(sz.height, 296)}), {190, 68}), {0.50, 0.50})
    local sp = setAnchor(setSize(setPos(addSprite(self.temp, "mainBb.png"), {688, fixY(sz.height, 364)}), {190, 81}), {0.50, 0.50})

    local initX = 688
    local initY = fixY(sz.height, 222)
    local offY = -74
    local allbut = {}
    self.data = {}
    for i=1, #temp, 1 do
        local but = ui.newButton({image="mainBa.png", text="", font="f1", size=18, color={255, 255, 255}, touchColor=hexToDec('ce4e00'), delegate=self, callback=self.onBut, shadowColor={0, 0, 0}, color={255, 255, 255}, param=i, touchBegan=self.onTab})
        but:setContentSize(190, 68)
        setPos(addChild(self.temp, but.bg), {688, initY+(i-1)*offY})

        local w = setPos(setAnchor(addChild(but.bg, ui.newTTFLabel({text=temp[i], size=24, color={255, 255, 255}, font="f2", shadowColor={0, 0, 0}})), {1.00, 0.50}), {171-190/2, fixY(68, 28)-68/2})
        but.text = w
        if i == 4 then
            setColor(w, {255, 255, 255, 255*0.8})
        end
        table.insert(self.data, {but, w})
    end
    self:setSelect(1)
end

function PeopleMenu3:onTab(p)
    self.first = false
    if self.curSel ~= p then
        self:clearMenu()
        self:setSelect(p)
        self.first = true
    end
end
function PeopleMenu3:setSelect(s)
    if self.curSel ~= nil then
        setTexture(self.data[self.curSel][1].sp, "mainBa.png")
    end
    self.curSel = s
    setTexture(self.data[self.curSel][1].sp, "mainBb.png")
end
function PeopleMenu3:clearMenu()
    if self.subMenu then
        removeSelf(self.subMenu.bg)
        self.subMenu = nil
    end
end
function PeopleMenu3:onBut(p)
    if p == 1 then
        global.director:popView()
        global.director:pushView(AttributeMenu.new(), 1)
    elseif p == 2 then
        global.director:popView()
        global.director:pushView(EquipMenu2.new(), 1)
    elseif p == 3 then
        global.director:popView()
        global.director:pushView(TrainMenu2.new(), 1)
    elseif p == 4 then
        global.director:popView()
        global.director:pushView(FindPeople2.new(), 1)
    end
end

