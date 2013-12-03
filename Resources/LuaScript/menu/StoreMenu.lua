StoreMenu = class(MenuBase)
function StoreMenu:ctor()
    self:setTitle("南瓜家")
end
function StoreMenu:setItemList()
    local sp = CCSprite:create("business_trader_3.png")
    setSize(setPos(sp, {52, fixY(370, 66)}), {45, 45})
    self.temp:addChild(sp)
    
    local teq = ui.newTTFLabel({text="全部", size=18, color={8, 20, 176}})
    setAnchor(setPos(teq, {134, fixY(370, 66)}), {0.5, 0.5})
    self.temp:addChild(teq)

    local teq = ui.newTTFLabel({text="所持", size=18, color={8, 20, 176}})
    setAnchor(setPos(teq, {363, fixY(370, 66)}), {0.5, 0.5})
    self.temp:addChild(teq)

    local teq = ui.newTTFLabel({text="价格", size=18, color={8, 20, 176}})
    setAnchor(setPos(teq, {484, fixY(370, 66)}), {1, 0.5})
    self.temp:addChild(teq)

    local teq = ui.newTTFLabel({text="好东西", size=18, color={8, 20, 176}})
    setAnchor(setPos(teq, {263, fixY(370, 350)}), {1, 0.5})
    self.temp:addChild(teq)
end
function StoreMenu:updateTab()
    self.flowHeight = 0
    local offY = 43
    local n = 1
    local tempData = {1, 1, 1, 1, 1}
    for k, v in ipairs(tempData) do
        local panel = CCNode:create()
        self.flowNode:addChild(panel)
        setContentSize(setPos(panel, {0, -offY*n}), {500, 43})
        panel:setTag(k)
        

        local temp = CCSprite:create("psel.png")
        panel:addChild(temp)
        setPos(setSize(temp, {420, 27}), {479/2, 21})
        
        local head = setSize(setPos(addSprite(panel, "equip70.png"), {30, 21}), {30, 30})

        local name = ui.newTTFLabel({text="割草镰刀", size=18, font="msyhbd.ttf", color={0,0,0}})
        setAnchor(setPos(name, {73, 21}), {0, 0.5})
        panel:addChild(name)

        local physic = ui.newBMFontLabel({text="1", size=18, font="bound.fnt", color={0,0,0}})
        setAnchor(setPos(physic, {331, 21}), {0.5, 0.5})
        panel:addChild(physic)

        local name = ui.newTTFLabel({text="800贯", size=18, font="msyhbd.ttf", color={0,0,0}})
        setAnchor(setPos(name, {452, 21}), {1, 0.5})
        panel:addChild(name)

        self.flowHeight = self.flowHeight+offY
        n = n + 1
    end 
end
function StoreMenu:onChild(c)
    addBanner("购买成功! "..c)
end


