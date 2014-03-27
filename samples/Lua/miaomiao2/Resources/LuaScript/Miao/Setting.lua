Setting = class()
function Setting:ctor(p)
    self.parent = p
    self.bg = CCNode:create()
    local temp = {
        "保存",
        "更改设定",
        "游戏方法",
        "最高得分",
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
function Setting:onBut(p)
    if p == 1 then
        global.director:popView()
        global.director.curScene.menu:clearMenu()
        global.director.curScene:saveGame()
    end
end
