require "menu.TrainNow"
TrainMenu = class(MenuBase)
function TrainMenu:ctor()
    self:setTitle("村民一览")
end
function TrainMenu:setItemList()
    local vs = self.temp:getContentSize()

    local teq = ui.newTTFLabel({text="Lv", size=18, color={10, 10, 10}})
    setAnchor(setPos(teq, {131, fixY(370, 64)}), {0, 0.5})
    self.temp:addChild(teq)

    local teq = ui.newTTFLabel({text="费用", size=18, color={10, 20, 176}})
    setAnchor(setPos(teq, {481, fixY(370, 64)}), {0, 0.5})
    self.temp:addChild(teq)

    local teq = ui.newTTFLabel({text="点击查看详情", size=18, color={10, 20, 176}})
    setAnchor(setPos(teq, {vs.width/2, fixY(370, 350)}), {0.5, 0.5})
    self.temp:addChild(teq)
end
function TrainMenu:updateTab()
    self.flowHeight = 0
    local offY = 43
    local n = 1
    local tempData = {1, 1, 1, 1, 1}
    for k, v in ipairs(tempData) do
        local panel = CCNode:create()
        self.flowNode:addChild(panel)
        setPos(panel, {0, -offY*n})
        setContentSize(panel, {500, 43})

        local temp = CCSprite:create("psel.png")
        panel:addChild(temp)
        setPos(setSize(temp, {420, 27}), {479/2, 21})
        
        local head = setSize(setPos(addSprite(panel, "business_trader_1.png"), {30, 21}), {30, 30})

        local name = ui.newTTFLabel({text="1", size=18, font="msyhbd.ttf", color={0,0,0}})
        setAnchor(setPos(name, {95, 21}), {1, 0.5})
        panel:addChild(name)

        local physic = ui.newBMFontLabel({text="万米授田", size=18, font="bound.fnt", color={0,0,0}})
        setAnchor(setPos(physic, {137, 21}), {0, 0.5})
        panel:addChild(physic)

        local name = ui.newTTFLabel({text="200贯", size=18, font="msyhbd.ttf", color={0,0,0}})
        setPos(name, {455, 21})
        panel:addChild(name)

        self.flowHeight = self.flowHeight+offY
        n = n + 1
    end 
end
function TrainMenu:onChild(c)
    local tn = TrainNow.new()
    global.director.curScene.menu.menu = tn
    global.director:popView()
    global.director:pushView(tn)
end
