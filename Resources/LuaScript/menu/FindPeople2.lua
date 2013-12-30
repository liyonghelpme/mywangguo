FindPeople2 = class()
function FindPeople2:adjustPos()
    local vs = getVS()
    local ds = global.director.designSize
    local sca = math.min(vs.width/ds[1], vs.height/ds[2])
    local pos = getPos(self.temp)
    local cx, cy = ds[1]/2-pos[1], ds[2]/2-pos[2]
    local nx, ny = vs.width/2-cx*sca, vs.height/2-cy*sca

    setScale(self.temp, sca)
    setPos(self.temp, {nx, ny})

    --调整切割屏幕高度

    local cx, cy = ds[1]/2, ds[2]/2
    local nx, ny = vs.width/2-cx*sca, vs.height/2-cy*sca
    setScale(self.butNode, sca)
    setPos(self.butNode, {nx, ny})
    print("butNode", nx, ny, sca)
end
function FindPeople2:ctor()
    local vs = getVS()
    self.bg = CCNode:create()
    setPos(self.bg, {0, 0})
    local sz = {width=715, height=601}
    local ds = global.director.designSize
    self.temp = setPos(addNode(self.bg), {173, fixY(ds[2], 66+sz.height)})
    self.num = 3

    local sp = setAnchor(setSize(setPos(addSprite(self.temp, "dialogA.png"), {338, fixY(sz.height, 316)}), {677, 569}), {0.50, 0.50})
    local sp = setAnchor(setSize(setPos(addSprite(self.temp, "dialogB.png"), {340, fixY(sz.height, 355)}), {603, 354}), {0.50, 0.50})
    --local but = ui.newButton({image="newClose.png"})
    --setPos(addChild(self.temp, but.bg), {677, fixY(sz.height, 40)})
    local but = ui.newButton({image="butc.png", text="进行启用", font="f1", size=34, callback=self.onPeople, delegate=self, conSize={152, 38}})
    setPos(addChild(self.temp, but.bg), {339, fixY(sz.height, 560)})
    local pdata = Logic.people[self.num]
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text=pdata.name, size=30, color={32, 7, 220}, font="f1"})), {0.00, 0.50}), {138, fixY(sz.height, 150)})
    self.name = w
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="Lv1", size=40, color=hexToDec('f8b551'), font="f2"})), {0.00, 0.50}), {511, fixY(sz.height, 147)})
    local total = #Logic.allPeople-2
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="人才启用1/"..total, size=34, color={102, 4, 554}, font="f1"})), {0.50, 0.50}), {339, fixY(sz.height, 86)})
    self.curPeople = w

    

    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="体力", size=28, color={255, 255, 255}, font="f2"})), {0.50, 0.50}), {308, fixY(sz.height, 258)})
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="腕力", size=28, color={255, 255, 255}, font="f2"})), {0.50, 0.50}), {308, fixY(sz.height, 309)})
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="射击", size=28, color={255, 255, 255}, font="f2"})), {0.50, 0.50}), {308, fixY(sz.height, 360)})
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="劳动", size=28, color={255, 255, 255}, font="f2"})), {0.50, 0.50}), {308, fixY(sz.height, 411)})

    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="启用费用", size=28, color={255, 255, 255}, font="f2"})), {0.00, 0.50}), {199, fixY(sz.height, 459)})
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text=pdata.health, size=25, color=hexToDec('f8b551'), font="f2"})), {1.00, 0.50}), {590, fixY(sz.height, 258)})
    self.health = w
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="9999银币", size=25, color=hexToDec('f8b551'), font="f2"})), {1.00, 0.50}), {508, fixY(sz.height, 461)})
    self.costWord = w
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text=pdata.brawn, size=25, color=hexToDec('f8b551'), font="f2"})), {1.00, 0.50}), {590, fixY(sz.height, 309)})
    self.brawn = w
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text=pdata.shoot, size=25, color=hexToDec('f8b551'), font="f2"})), {1.00, 0.50}), {590, fixY(sz.height, 360)})
    self.shoot = w
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text=pdata.labor, size=25, color=hexToDec('f8b551'), font="f2"})), {1.00, 0.50}), {590, fixY(sz.height, 411)})
    self.labor = w
    local sp = setAnchor(setSize(setPos(addSprite(self.temp, "peopBoard.png"), {171, fixY(sz.height, 336)}), {184, 183}), {0.50, 0.50})

    local sf = CCSpriteFrameCache:sharedSpriteFrameCache()
    sf:addSpriteFramesWithFile(string.format("cat_%d_walk.plist", (self.num)))
    local sp = setAnchor(setSize(setPos(addSprite(self.temp, "role.png"), {167, fixY(sz.height, 332)}), {162, 161}), {0.50, 0.50})
    self.head = sp
    self.head:setDisplayFrame(sf:spriteFrameByName(string.format("cat_%d_rb_0.png", self.num)))
    adjustBox(self.head, {150, 150}) 

    --local sp = setAnchor(setSize(setPos(addSprite(self.temp, "prob.png"), {434, fixY(sz.height, 262)}), {191, 29}), {0.50, 0.50})
    --local sp = setAnchor(setSize(setPos(addSprite(self.temp, "proa.png"), {434, fixY(sz.height, 262)}), {183, 20}), {0.50, 0.50})
    local banner = setAnchor(setSize(setPos(addSprite(self.temp, "prob.png"), {434, fixY(sz.height, 262)}), {191, 29}), {0.50, 0.50})
    local pro = setAnchor(setSize(setPos(addSprite(banner, "proa.png"), {4, 4.5}), {183, 20}), {0.0, 0})
    self.healthBar = pro

    local banner = setAnchor(setSize(setPos(addSprite(self.temp, "prob.png"), {434, fixY(sz.height, 307)}), {191, 29}), {0.50, 0.50})
    local pro = setAnchor(setSize(setPos(addSprite(banner, "proa.png"), {4, 4.5}), {183, 20}), {0.0, 0})
    self.brawnBar = pro

    local banner = setAnchor(setSize(setPos(addSprite(self.temp, "prob.png"), {434, fixY(sz.height, 357)}), {191, 29}), {0.50, 0.50})
    local pro = setAnchor(setSize(setPos(addSprite(banner, "proa.png"), {4, 4.5}), {183, 20}), {0.0, 0})
    self.shootBar = pro

    local banner = setAnchor(setSize(setPos(addSprite(self.temp, "prob.png"), {434, fixY(sz.height, 405)}), {191, 29}), {0.50, 0.50})
    local pro = setAnchor(setSize(setPos(addSprite(banner, "proa.png"), {4, 4.5}), {183, 20}), {0.0, 0})
    self.laborBar = pro


    self.butNode = addNode(self.bg)
    local but = ui.newButton({image="newRightArrow.png", text="", font="f1", size=18, callback=self.onRight, delegate=self})
    but:setContentSize(90, 106)
    setPos(addChild(self.butNode, but.bg), {922, 384})
    self.rightBut = but

    local but = ui.newButton({image="newLeftArrow.png", text="", font="f1", size=18, callback=self.onLeft, delegate=self})
    but:setContentSize(90, 106)
    setPos(addChild(self.butNode, but.bg), {102, 384})
    self.leftBut = but

    self:adjustPos()
    self:setPeople()
end

function FindPeople2:onLeft()
    if self.num > 3 then
        self.num = self.num-1
    else
        self.num = #Logic.allPeople
    end
    self:setPeople()
end
function FindPeople2:onRight()
    print("self.onRight", self.num, #Logic.allPeople)
    if self.num < #Logic.allPeople then
        self.num = self.num+1
    else
        self.num = 3
    end
    self:setPeople()
end
function FindPeople2:setPeople()
    --[[
    local sf = CCSpriteFrameCache:sharedSpriteFrameCache()
    self.head:setDisplayFrame(sf:spriteFrameByName(string.format("cat_%d_rb_0.png", self.num)))
    adjustBox(self.head, {150, 150}) 
    --]]

    local sf = CCSpriteFrameCache:sharedSpriteFrameCache()
    sf:addSpriteFramesWithFile(string.format("cat_%d_walk.plist", (self.num)))
    self.head:setDisplayFrame(sf:spriteFrameByName(string.format("cat_%d_rb_0.png", self.num)))
    adjustBox(self.head, {150, 150}) 

    local pdata = Logic.people[self.num]
    self.name:setString(pdata.name)
    self.health:setString(pdata.health)
    self.brawn:setString(pdata.brawn)
    self.shoot:setString(pdata.shoot)
    self.labor:setString(pdata.labor)
    local total = #Logic.allPeople-2
    self.curPeople:setString("人才启用"..(self.num-2)..'/'..total)

    newProNum(self.healthBar, pdata.health, 300)
    newProNum(self.brawnBar, pdata.brawn, 300)
    newProNum(self.shootBar, pdata.shoot, 300)
    newProNum(self.laborBar, pdata.labor, 300)

    if pdata.silver > 0 then
        self.costWord:setString(pdata.silver.."银币")
    else
        self.costWord:setString(pdata.gold.."金币")
    end
end

function FindPeople2:onPeople()
    local pdata = Logic.people[self.num]
    local cost = {silver=pdata.silver, gold=pdata.gold}
    if not checkCost(cost) then
        addBanner("钱不够!")
    else
        doCost(cost)
        global.director:popView()
        global.director.curScene.page:addPeople(self.num)
    end
end
