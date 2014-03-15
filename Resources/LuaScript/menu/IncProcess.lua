IncProcess = class()
function IncProcess:ctor(kind)
    local vs = getVS()
    self.bg = CCNode:create()
    local sz = {width=1024, height=768}
    self.temp = setPos(addNode(self.bg), {0, fixY(sz.height, 0+sz.height)+0})
    local sp = setOpacity(setAnchor(setSize(setPos(addSprite(self.temp, "sdialoga.png"), {512, fixY(sz.height, 396)}), {633, 427}), {0.50, 0.50}), 255)
    local sp = setAnchor(setPos(addChild(self.temp, createSmallDialogb("smallDialogb.png")), {512, fixY(sz.height, 403)}), {0.50, 0.50})

    local sp = setOpacity(setAnchor(setSize(setPos(addSprite(self.temp, "dialogCat.png"), {749, fixY(sz.height, 500)}), {101, 157}), {0.50, 0.50}), 255)
    
    initSoldier() 
    local kn = {
        'foot',
        'arrow',
        'magic',
        'cavalry'
    }
    local num = {
        14,
        14,
        20, 
        16,
    }
    local ani = createAnimation("cat_"..kn[kind].."_attackA", "cat_"..kn[kind].."_attackA_%d.png", 0, num[kind], 2, 1, true)
    --[[
        self.soldier.attackA = createAnimation("cat_arrow_attackA", "cat_arrow_attackA_%d.png", 0, num[kind], 2, 1, true)
        self.soldier.attackA = createAnimation("cat_magic_attackA", "cat_magic_attackA_%d.png", 0, num[kind], 2, 1, true)
        self.soldier.attackA = createAnimation("cat_cavalry_attackA", "cat_cavalry_attackA_%d.png", 0, num[kind], 2, 1, true)
    --]]
    local sp = setOpacity(setAnchor(setPos(addSprite(self.temp, "cat_"..kn[kind]..'_attackA_'..num[kind]..'.png'), {310, fixY(sz.height, 401)}), {0.50, 0.50}), 255)
    sp:runAction(repeatForever(CCAnimate:create(ani)))

    local words = {
        "步兵增强中",
        "弓箭手增强中",
        "魔法兵增强中",
        "骑兵增强中",
    }
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text=words[kind], size=25, color={10, 76, 176}, font="f1", shadowColor={0, 0, 0}})), {0.00, 0.50}), {482, fixY(sz.height, 356)})
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="兵力增强", size=35, color={10, 10, 10}, font="f1", shadowColor={0, 0, 0}})), {0.50, 0.50}), {516, fixY(sz.height, 231)})

    self.banner, self.pro = createFacBanner()
    setAnchor(setPos(self.banner, {482, fixY(sz.height, 402)}), {0, 0.5})
    
    self.temp:addChild(self.banner) 
    setFacProNum(self.pro, 0, 10) 
    centerUI(self)
    self.needUpdate = true
    registerEnterOrExit(self)
    self.process = 0
end

function IncProcess:update(diff)
    self.process = self.process+diff
    setFacProNum(self.pro, self.process, 2)
    if self.process >= 2 then
        global.director:popView()
    end
end
