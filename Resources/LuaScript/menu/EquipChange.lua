require "menu.MenuBase"
EquipChange = class(MenuBase)
function EquipChange:ctor()
    self:setTitle("装备变更")
end
function EquipChange:setItemList()
    local sp = CCSprite:create("business_trader_1.png")
    setSize(setPos(sp, {48, fixY(370, 64)}), {45, 45})
    self.temp:addChild(sp)

    local teq = ui.newTTFLabel({text="武器", size=18, color={8, 20, 176}})
    setAnchor(setPos(teq, {105, fixY(370, 64)}), {0, 0.5})
    self.temp:addChild(teq)

    local teq = ui.newTTFLabel({text="攻击力", size=18, color={8, 20, 176}})
    setAnchor(setPos(teq, {351, fixY(370, 64)}), {1, 0.5})
    self.temp:addChild(teq)

    local teq = ui.newTTFLabel({text="剩余", size=18, color={8, 20, 176}})
    setAnchor(setPos(teq, {476, fixY(370, 64)}), {1, 0.5})
    self.temp:addChild(teq)

    local teq = ui.newTTFLabel({text="刀", size=18, color={8, 20, 176}})
    setAnchor(setPos(teq, {44, fixY(370, 350)}), {0.5, 0.5})
    self.temp:addChild(teq)

    local teq = ui.newTTFLabel({text="攻击", size=18, color={8, 20, 176}})
    setAnchor(setPos(teq, {117, fixY(370, 350)}), {0.5, 0.5})
    self.temp:addChild(teq)

    local teq = ui.newTTFLabel({text="+8", size=18, color={10, 10, 10}})
    setAnchor(setPos(teq, {233, fixY(370, 350)}), {1, 0.5})
    self.temp:addChild(teq)

    local teq = ui.newTTFLabel({text="防御", size=18, color={8, 20, 176}})
    setAnchor(setPos(teq, {330, fixY(370, 350)}), {0.5, 0.5})
    self.temp:addChild(teq)

    local teq = ui.newTTFLabel({text="+5", size=18, color={10, 10, 10}})
    setAnchor(setPos(teq, {483, fixY(370, 350)}), {1, 0.5})
    self.temp:addChild(teq)
end

function EquipChange:updateTab()
    self.flowHeight = 0
    local offY = 43
    local n = 1
    local tempData = {1, 1, 1, 1, 1}
    for k, v in ipairs(tempData) do
        local panel = CCNode:create()
        self.flowNode:addChild(panel)
        setPos(panel, {0, -offY*n})

        local temp = CCSprite:create("psel.png")
        panel:addChild(temp)
        setPos(setSize(temp, {420, 27}), {479/2, 21})
        
        local head = setSize(setPos(addSprite(panel, "equip70.png"), {30, 21}), {30, 30})

        local name = ui.newTTFLabel({text="割草镰刀", size=18, font="msyhbd.ttf", color={0,0,0}})
        setAnchor(setPos(name, {73, 21}), {0, 0.5})
        panel:addChild(name)

        local physic = ui.newBMFontLabel({text="3", size=18, font="bound.fnt", color={0,0,0}})
        setAnchor(setPos(physic, {316, 21}), {1, 0.5})
        panel:addChild(physic)

        local name = ui.newTTFLabel({text="2个", size=18, font="msyhbd.ttf", color={0,0,0}})
        setPos(name, {446, 21})
        panel:addChild(name)

        self.flowHeight = self.flowHeight+offY
        n = n + 1
    end 
end
function EquipChange:onChild()
end
