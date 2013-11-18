require "Miao.AllPeople"
require "Miao.FindPeople"
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
    for i=1, #temp, 1 do
        local but = ui.newButton({image="yearboard.jpg", conSize={100, 40}, text=temp[i], callback=self.onBut, delegate=self, param=i, size=20, color={10, 10, 10}})
        setPos(but.bg, {initX, initY+(i-1)*offY})
        but:setAnchor(0.5, 0.5)
        self.bg:addChild(but.bg)
    end
end
function PeopleMenu:onBut(p)
    if p == 1 then
        local ap = AllPeople.new(global.director.curScene)
        self.parent.scene.menu.menu = ap
        global.director:popView()
        global.director:pushView(ap, 1, 0)
    elseif p==4 then
        local fp = FindPeople.new(self.parent.scene)
        global.director:popView()
        global.director:pushView(fp, 1, 0)
    end
end
