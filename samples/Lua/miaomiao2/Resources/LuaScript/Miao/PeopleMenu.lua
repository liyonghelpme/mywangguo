require "Miao.AllPeople"
require "Miao.FindPeople"
require "menu.EquipMenu"
require "menu.TrainMenu"
PeopleMenu = class()
function PeopleMenu:ctor(p)
    self.parent = p
    self.bg = CCNode:create()
    local temp = {
        "强度",
        "装备",
        "进行修习",
        "人才启用",
    }

    local initX = 0
    local initY = 0
    local offY = -45
    local allbut = {}
    for i=1, #temp, 1 do
        local but = ui.newButton({image="yearboard.jpg", conSize={100, 40}, text=temp[i], callback=self.onBut, delegate=self, param=i, size=20, color={10, 10, 10}})
        setPos(but.bg, {initX, initY+(i-1)*offY})
        but:setAnchor(0.5, 0.5)
        self.bg:addChild(but.bg)
        table.insert(allbut, but)
    end

    --[[
    if #Logic.waitPeople == 0 then
        setColor(allbut[4].sp, {0, 0, 0})
        allbut[4]:setCallback(nil)
    end
    --]]
end
function PeopleMenu:onBut(p)
    if p == 1 then
        local ap = AllPeople.new(global.director.curScene)
        self.parent.scene.menu.menu = ap
        global.director:popView()
        global.director:pushView(ap, 1, 0)
    elseif p == 2 then
        local em = EquipMenu.new()
        self.parent.scene.menu.menu = em
        global.director:popView()
        global.director:pushView(em, 1, 0)
    elseif p == 3 then
        local em = TrainMenu.new()
        self.parent.scene.menu.menu = em
        global.director:popView()
        global.director:pushView(em, 1, 0)
    elseif p==4 then
        local fp = FindPeople.new(self.parent.scene)
        global.director:popView()
        global.director:pushView(fp, 1, 0)
    end
end
