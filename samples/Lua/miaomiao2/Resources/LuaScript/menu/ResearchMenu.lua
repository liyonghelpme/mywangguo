ResearchMenu = class(MenuBase)
function ResearchMenu:ctor()
    self:setTitle("研究")
end
function ResearchMenu:setItemList()
    local teq = ui.newTTFLabel({text="费用", size=18, color={8, 20, 176}})
    setAnchor(setPos(teq, {478, fixY(370, 64)}), {1, 0.5})
    self.temp:addChild(teq)
    local teq = ui.newTTFLabel({text="枪", size=18, color={8, 20, 176}})
    setAnchor(setPos(teq, {56, fixY(370, 346)}), {0.5, 0.5})
    self.temp:addChild(teq)

    local teq = ui.newTTFLabel({text="攻击", size=18, color={8, 20, 176}})
    setAnchor(setPos(teq, {143, fixY(370, 346)}), {0.5, 0.5})
    self.temp:addChild(teq)

    local teq = ui.newTTFLabel({text="+18", size=18, color={10, 10, 10}})
    setAnchor(setPos(teq, {251, fixY(370, 346)}), {1, 0.5})
    self.temp:addChild(teq)

    local teq = ui.newTTFLabel({text="防御", size=18, color={8, 20, 176}})
    setAnchor(setPos(teq, {321, fixY(370, 346)}), {0.5, 0.5})
    self.temp:addChild(teq)

    local teq = ui.newTTFLabel({text="+20", size=18, color={10, 10, 10}})
    setAnchor(setPos(teq, {466, fixY(370, 346)}), {1, 0.5})
    self.temp:addChild(teq)

end
function ResearchMenu:updateTab()
    self.flowHeight = 0
    local offY = 43
    local n = 1
    local tempData = {1, 1, 1, 1, 1, 1, 1, 1}
    for k, v in ipairs(tempData) do
        local panel = CCNode:create()
        self.flowNode:addChild(panel)
        setPos(panel, {0, -offY*n})

        local temp = CCSprite:create("psel.png")
        panel:addChild(temp)
        setPos(setSize(temp, {420, 27}), {479/2, 21})
        
        local head = setSize(setPos(addSprite(panel, "equip70.png"), {30, 21}), {30, 30})

        local name = ui.newTTFLabel({text="割草镰刀", size=18, font="msyhbd.ttf", color={0,0,0}})
        setAnchor(setPos(name, {84, 21}), {0, 0.5})
        panel:addChild(name)

        local physic = ui.newTTFLabel({text="800贯", size=18, font="msyhbd.fnt", color={0,0,0}})
        setAnchor(setPos(physic, {457, 21}), {1, 0.5})
        panel:addChild(physic)

        self.flowHeight = self.flowHeight+offY
        n = n + 1
    end 
end
function ResearchMenu:onChild()
end
