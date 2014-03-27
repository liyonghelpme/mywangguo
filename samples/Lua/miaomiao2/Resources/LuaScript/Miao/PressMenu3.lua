require "menu.PeopleMenu3"
require "menu.NewBuildMenu3"
require "menu.StoreMenu3"
require "menu.ResearchMenu3"
require "menu.IncSoldierMenu"
require "menu.UseGoldMenu"
PressMenu3 = class()
function PressMenu3:ctor()
    local vs = getVS()
    self.bg = CCNode:create()
    local sz = {width=1024, height=768}
    self.temp = setPos(addNode(self.bg), {0, fixY(sz.height, 0+sz.height)+0})
    local sp = setAnchor(setSize(setPos(addSprite(self.temp, "mainBoard.png"), {896, fixY(sz.height, 376)}), {212, 551}), {0.50, 0.50})
    local temp = {
        "建筑",
        "村民",
        "研究",
        "商人",
        "兵力",
        "排行榜",
        "系统",
    }

    local initX = 896
    local initY = fixY(sz.height, 154)
    local offY = -74
    local dTime= 0
    
    self.data = {}
    for i=1, #temp, 1 do
        local but = ui.newButton({image="mainA.png", text="", font="f1", size=18, color={255, 255, 255}, touchColor=hexToDec('ce4e00'), delegate=self, callback=self.onBut, touchBegan=self.onTab, param=i, shadowColor={0, 0, 0}, color={255, 255, 255}})
        but:setContentSize(190, 77)
        setPos(addChild(self.temp, but.bg), {initX, initY+(i-1)*offY})

        local w = setPos(setAnchor(addChild(but.bg, ui.newTTFLabel({text=temp[i], size=24, color={255, 255, 255}, font="f2", shadowColor={0, 0, 0}})), {0.50, 0.50}), {129-190/2, fixY(77, 30)-77/2})
        but.text = w
        local sp = setAnchor(setSize(setPos(addSprite(but.bg, "icon"..(i-1)..".png"), {35-190/2, fixY(77, 32)-77/2}), {45, 47}), {0.50, 0.50})

        --调整info的位置
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
                local info = ui.newButton({image="info.png", text=edata.name..diff..'%', conSize={181, 60}, size=24, color={0, 0, 0}, font='f1'})
                setPos(info.bg, {-190, 0})
                but.bg:addChild(info.bg)
            end
        end
        table.insert(self.data, but)
    end

    rightTopUI(self.bg)
end

function PressMenu3:setSelect(s)
    if self.curSel ~= nil then
        setTexture(self.data[self.curSel].sp, "mainA.png")
    end
    self.curSel = s
    setTexture(self.data[self.curSel].sp, "mainB.png")
end
function PressMenu3:clearMenu()
    if self.subMenu then
        removeSelf(self.subMenu.bg)
        self.subMenu = nil
    end
end
function PressMenu3:onTab(p)
    self.first = false
    if self.curSel ~= p then
        self.first = true
        self:clearMenu()
        self:setSelect(p)
    end
end
function PressMenu3:onBut(p)
    if p == 1  then
        global.director:popView()
        local m = NewBuildMenu3.new()
        global.director:pushView(m, 1 )
    elseif p == 2 and  self.first then
        local m = PeopleMenu3.new(self)
        self.bg:addChild(m.bg)
        self.subMenu = m
    elseif p == 3 then
        if Logic.inResearch == nil then
            global.director:popView()
            global.director:pushView(ResearchMenu3.new(), 1 )
        end
    elseif p == 4 then
        global.director:popView()
        global.director:pushView(StoreMenu3.new(), 1)
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
