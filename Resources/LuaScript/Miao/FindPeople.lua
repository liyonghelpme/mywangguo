FindPeople = class()
function FindPeople:ctor(s)
    self.scene = s
    self.bg = CCNode:create()
    local vs = getVS()
    local temp = setContentSize(display.newScale9Sprite("tabback.jpg"), {500, 325})
    setPos(temp, {vs.width/2, vs.height/2})
    self.bg:addChild(temp)
    local tit = setPos(addSprite(temp, "title.png"), {250, fixY(325, 23)})
    local tw = ui.newTTFLabel({text="村民甲", size=18, color={0, 0, 0}})
    setPos(tw, {250, fixY(325, 23)})
    temp:addChild(tw)

    local sf = CCSpriteFrameCache:sharedSpriteFrameCache()
    sf:addSpriteFramesWithFile("cat_walk.plist")
    
    local head = CCSprite:createWithSpriteFrame(sf:spriteFrameByName("cat_rb_0.png"))
    self.head = head
    local sca = getSca(head, {130, 130})
    setScale(setPos(head, {92, fixY(325, 155)}), sca)
    temp:addChild(self.head)
    
    local health = ui.newTTFLabel({text='体力', size=14, color={8, 20, 176}})
    setPos(health, {267, fixY(325, 88)})
    temp:addChild(health)

    local banner = setSize(setPos(addSprite(temp, "probg.png"), {364, fixY(325, 93)}), {150, 29})
    local pro = display.newScale9Sprite("pro.png")
    banner:addChild(pro)
    setAnchor(setPos(pro, {27, fixY(76, 40)}), {0, 0.5})

    local w = ui.newBMFontLabel({text="31", size=14,  font="fonts.fnt", color={10, 10, 10}})
    setAnchor(setPos(w, {477, fixY(325, 93)}), {1, 0.5})
    temp:addChild(w)

    local health = ui.newTTFLabel({text='腕力', size=14, color={8, 20, 176}})
    setPos(health, {267, fixY(325, 128)})
    temp:addChild(health)

    local banner = setSize(setPos(addSprite(temp, "probg.png"), {364, fixY(325, 128)}), {150, 29})
    local pro = display.newScale9Sprite("pro.png")
    banner:addChild(pro)
    setAnchor(setPos(pro, {27, fixY(76, 40)}), {0, 0.5})

    local w = ui.newBMFontLabel({text="22", size=14,  font="fonts.fnt", color={10, 10, 10}})
    setAnchor(setPos(w, {477, fixY(325, 128)}), {1, 0.5})
    temp:addChild(w)

    local health = ui.newTTFLabel({text='射击', size=14, color={8, 20, 176}})
    setPos(health, {267, fixY(325, 168)})
    temp:addChild(health)


    local banner = setSize(setPos(addSprite(temp, "probg.png"), {364, fixY(325, 168)}), {150, 29})
    local pro = display.newScale9Sprite("pro.png")
    banner:addChild(pro)
    setAnchor(setPos(pro, {27, fixY(76, 40)}), {0, 0.5})

    local w = ui.newBMFontLabel({text="160", size=14,  font="fonts.fnt", color={10, 10, 10}})
    setAnchor(setPos(w, {477, fixY(325, 168)}), {1, 0.5})
    temp:addChild(w)

    local health = ui.newTTFLabel({text='劳动', size=14, color={8, 20, 176}})
    setPos(health, {267, fixY(325, 203)})
    temp:addChild(health)

    local banner = setSize(setPos(addSprite(temp, "probg.png"), {364, fixY(325, 203)}), {150, 29})
    local pro = display.newScale9Sprite("pro.png")
    banner:addChild(pro)
    setAnchor(setPos(pro, {27, fixY(76, 40)}), {0, 0.5})

    local w = ui.newBMFontLabel({text="29", size=14,  font="fonts.fnt", color={10, 10, 10}})
    setAnchor(setPos(w, {477, fixY(325, 203)}), {1, 0.5})
    temp:addChild(w)

    local fe = ui.newTTFLabel({text="交涉费用", size=14, color={8, 20, 176}})
    temp:addChild(fe)
    setPos(fe, {209, fixY(325, 236)})

    local num = ui.newTTFLabel({text="270贯", size=14, color={0, 0, 0}})
    temp:addChild(num)
    setPos(num, {283, fixY(325, 236)})
    
    local but = ui.newButton({image="tabbut.png", callback=self.onBut, delegate=self, text="进行启用", size=18, color={10, 10, 10}})
    temp:addChild(but.bg)
    setPos(but.bg, {250, fixY(325, 297)})

    self.num = 3
    local leftBut = ui.newButton({image="arrow_left.png", callback=self.onLeft, delegate=self})
    temp:addChild(leftBut.bg)
    setPos(leftBut.bg, {33, fixY(325, 30)})
    
    local rightBut = ui.newButton({image="arrow_right.png", callback=self.onRight, delegate=self})
    temp:addChild(rightBut.bg)
    setPos(rightBut.bg, {470, fixY(325, 30)})
end
function FindPeople:onLeft()
    if self.num > 3 then
        self.num = self.num-1
        local sf = CCSpriteFrameCache:sharedSpriteFrameCache()
        if self.num == 3 then
            self.head:setDisplayFrame(sf:spriteFrameByName("cat_rb_0.png"))
        else
            self.head:setDisplayFrame(sf:spriteFrameByName(string.format("cat_%d_rb_0.png", self.num)))
        end
    end
end
function FindPeople:onRight()
    local allP = Logic.allPeople
    if self.num < #allP then
        self.num = self.num+1
        local sf = CCSpriteFrameCache:sharedSpriteFrameCache()
        sf:addSpriteFramesWithFile(string.format("cat_%d_walk.plist", (self.num)))
        self.head:setDisplayFrame(sf:spriteFrameByName(string.format("cat_%d_rb_0.png", self.num)))
    end
end
function FindPeople:onBut()
    global.director:popView()
    self.scene.menu:clearMenu()
    self.scene.page:addPeople(self.num)
end
