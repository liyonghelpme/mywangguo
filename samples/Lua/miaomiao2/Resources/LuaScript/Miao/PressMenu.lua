require "Miao.Setting"
require "Miao.NewBuildMenu"
require "Miao.PeopleMenu"
require "Miao.Welcome2"
require "menu.ResearchMenu"
require "menu.StoreMenu"
require "menu.IncreasePower"
PressMenu = class()
function PressMenu:ctor(s)
    self.scene = s
    self.bg = CCNode:create()
    local temp = {
        "建筑",
        "村民",
        "研究",
        "商人",
        "兵力",
        "情报",
        "系统",
    }
    local vs = getVS()
    local initX = 10+50
    local initY = vs.height-10-20-40
    local offY = -45
    local dTime= 0
    for i=1, #temp, 1 do
        local but = ui.newButton({image="yearboard.jpg", conSize={100, 40}, text=temp[i], callback=self.onBut, delegate=self, param=i, size=20, color={10, 10, 10}})
        setPos(but.bg, {initX, initY+(i-1)*offY})
        but:setAnchor(0.5, 0.5)
        self.bg:addChild(but.bg)
        but.bg:setVisible(false)
        local function app()
            but.bg:setVisible(true)
        end
        but.sp:runAction(sequence({delaytime(dTime), callfunc(nil, app), fadein(0.2)}))
        dTime = dTime+0.1
    end
end
function PressMenu:onHouse()
    --调整touch 优先级需要在touch处理结束之后 进行 touch中调整没有效果
    self.scene.menu.menu = NewBuildMenu.new(self.scene) 
    global.director:pushView(self.scene.menu.menu, 1, 0)
end
function PressMenu:onBut(p)
    local vs = getVS()
    local initX = 10+50
    local initY = vs.height-10-20
    local offY = -45
    --建筑
    if p == 1 then
        self.scene.menu.menu = nil
        global.director:popView()
        if Logic.inNew and not Logic.buyHouseYet then
            Logic.buyHouseYet = true
            local w = Welcome2.new(self.onHouse, self)
            w:updateWord("首先从'环境'中选择<0000ff农家>吧")
            global.director:pushView(w, 1, 0)
            return
        end

        --调整touch 优先级需要在touch处理结束之后 进行 touch中调整没有效果
        self.scene.menu.menu = NewBuildMenu.new(self.scene) 
        global.director:pushView(self.scene.menu.menu, 1, 0)
    --保存游戏 UserDefault 里面
    --读取游戏
    elseif p == 2 then
        local pm = PeopleMenu.new(self)
        self.bg:addChild(pm.bg)
        setPos(pm.bg, {10+100+50, vs.height-10-45-20})
    elseif p == 3 then
        global.director:popView()
        local rm = ResearchMenu.new()
        global.director:pushView(rm, 1, 0)
    elseif p == 4 then
        global.director:popView()
        global.director:pushView(StoreMenu.new(), 1, 0)
    elseif p == 5 then
        global.director:popView()
        global.director:pushView(IncreasePower.new(), 1, 0)
    elseif p == 7 then
        local set = Setting.new(self)
        self.bg:addChild(set.bg)
        setPos(set.bg, {10+100+50, vs.height-10-45-20})
    end
end
