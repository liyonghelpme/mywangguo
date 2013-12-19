require "menu.FindPeople2"
PeopleMenu2 = class()
function PeopleMenu2:ctor()
    local vs = getVS()
    self.bg = CCNode:create()
    local sz = {width=199, height=291}
    self.temp = setPos(addNode(self.bg), {213, fixY(vs.height, 187+sz.height)})
    local temp = {
        "强度",
        "装备",
        "进行修习",
        "人才启用",
    }

    local sp = setSize(setPos(addSprite(self.temp, "mainBoard.png"), {99, fixY(sz.height, 145)}), {199, 291})

    local initX = 99
    local initY = fixY(sz.height, 42)
    local offY = -70
    local allbut = {}
    self.data = {}
    for i=1, #temp, 1 do
        local but = ui.newButton({image="mainBa.png", callback=self.onBut, delegate=self, param=i})
        setPos(addChild(self.temp, but.bg), {99, fixY(sz.height, 42)+offY*(i-1)})
        local w = setPos(setAnchor(addChild(but.bg, ui.newTTFLabel({text=temp[i], size=24, color={255, 255, 255}})), {0, 0.5}), {13-181/2, fixY(60, 29)-60/2})

        if i == 4 then
            setColor(w, {255, 255, 255, 255*0.8})
        end
        table.insert(self.data, {but, w})
    end

    self:setSelect(1)
end
function PeopleMenu2:setSelect(s)
    if self.curSel ~= nil then
        setTexture(self.data[self.curSel][1].sp, "mainBa.png")
    end
    self.curSel = s
    setTexture(self.data[self.curSel][1].sp, "mainBb.png")
end
function PeopleMenu2:clearMenu()
    if self.subMenu then
        removeSelf(self.subMenu.bg)
        self.subMenu = nil
    end
end
function PeopleMenu2:onBut(p)
    if self.curSel ~= p then
        self:clearMenu()
        self:setSelect(p)

        if p == 1 then
        elseif p == 2 then
        elseif p == 4 then
            global.director:popView()
            global.director:pushView(FindPeople2.new(), 1)
        end
    end
end

