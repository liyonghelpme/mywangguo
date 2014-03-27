require "menu.PeopleMenu2"
require "menu.NewBuildMenu2"
require "menu.StoreMenu2"
require "menu.ResearchMenu3"
require "menu.IncSoldierMenu"
require "menu.UseGoldMenu"
PressMenu2 = class()

function PressMenu2:adjustHeight()
    local vs = getVS()
    local ds = global.director.designSize
    local scy = vs.height/global.director.designSize[2] 
    setScale(self.bg, scy)
    
    --bg 整体向上平移位置 保证比例不变
    local pos = getPos(self.temp)
    local ay = (pos[2]+self.sz.height)/ds[2]
    local cheight = scy*(pos[2]+self.sz.height)/vs.height
    local ny = (ay-cheight)*vs.height
    setPos(self.bg, {0, ny})

    --local height = self.sz.height
    --setPos(self.temp, {pos[1], pos[2]+(1-scy)*height})
end
--菜单太高需要调整 菜单超出屏幕范围才需要调整 高度 但是位置呢？
--适配在最后调整每个UI即可
function PressMenu2:ctor()
    local vs = getVS()
    self.bg = CCNode:create()
    local sz = {width=398, height=532}
    self.sz = sz
    local ds = global.director.designSize
    self.temp = setPos(addNode(self.bg), {14, fixY(ds[2], 109+sz.height)})
    self:adjustHeight() 
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
        local but = ui.newButton({image="mainA.png",  callback=self.onBut, touchBegan=self.onTab, delegate=self, param=i})
        local sp = setSize(setPos(addSprite(but.bg, string.format("icon%d.png", i-1)), {31-181/2, fixY(60, 33)-60/2}), {45, 42})
        local w = setPos(setAnchor(addChild(but.bg, ui.newTTFLabel({text=temp[i], font='f2', size=24, color={255, 255, 255}})), {0, 0.5}), {95-181/2, fixY(60, 29)-60/2})
        if temp[i] == "研究" then
            if Logic.inResearch ~= nil then
                local sd = Logic.inResearch
                local diff = math.floor(math.max(math.min((sd[2])/10, 1), 0)*100)
                local rd = Logic.researchGoods[sd[1]]
                local edata
                if rd[1] == 0 then
                    edata = Logic.equip[rd[2]]
                elseif rd[1] == 1 then
                    edata = GoodsName[rd[2]]
                end
                local info = ui.newButton({image="info.png", text=edata.name..diff..'%', conSize={181, 60}, size=24, color={0, 0, 0}, font='f2'})
                setPos(info.bg, {182, 0})
                but.bg:addChild(info.bg)
            end
        end

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
function PressMenu2:onTab(p)
    self.first = false
    if self.curSel ~= p then
        self.first = true
        self:clearMenu()
        self:setSelect(p)
    end
end
function PressMenu2:onBut(p)
    --[[
    local first = false
    if self.curSel ~= p then
        first = true
        self:clearMenu()
        self:setSelect(p)
    end
    --]]

    if p == 1  then
        global.director:popView()
        local m = NewBuildMenu2.new()
        global.director:pushView(m, 1 )
    elseif p == 2 and  self.first then
        local m = PeopleMenu2.new(self)
        self.bg:addChild(m.bg)
        self.subMenu = m
    elseif p == 3 then
        if Logic.inResearch == nil then
            global.director:popView()
            global.director:pushView(ResearchMenu3.new(), 1 )
        end
    elseif p == 4 then
        global.director:popView()
        global.director:pushView(StoreMenu2.new(), 1)
    elseif p == 5 then
        global.director:popView()
        global.director:pushView(IncSoldierMenu.new(), 1)
    elseif p == 6 then
        global.director:popView()
        global.director:pushView(UseGoldMenu.new(), 1)
    elseif p == 7 then
        global.director:popView()
        global.director.curScene:saveGame()
    end
end
