require "menu.SureGold"

FindPeople3 = class()
function FindPeople3:ctor()
    self.num = 1
    local pid = Logic.ownPeople[self.num]
    local pdata = Logic.people[pid]

    local vs = getVS()
    self.bg = CCNode:create()
    local sz = {width=1024, height=768}
    self.temp = setPos(addNode(self.bg), {-13.5, fixY(sz.height, 0+sz.height)+4})
    local sp = setOpacity(setAnchor(setSize(setPos(addSprite(self.temp, "dialogA.png"), {525, fixY(sz.height, 388)}), {693, 588}), {0.50, 0.50}), 255)
    local sp = setOpacity(setAnchor(setSize(setPos(addSprite(self.temp, "dialogB.png"), {523, fixY(sz.height, 418)}), {626, 358}), {0.50, 0.50}), 255)
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="Lv.1", size=26, color={32, 112, 220}, font="f2", shadowColor={255, 255, 255}})), {0.00, 0.50}), {682, fixY(sz.height, 216)})
    self.level = w
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text=pdata.name, size=26, color={32, 112, 220}, font="f2", shadowColor={255, 255, 255}})), {0.00, 0.50}), {259, fixY(sz.height, 215)})
    self.name = w
    local but = ui.newButton({image="newClose.png", text="", font="f1", size=18, delegate=self, callback=closeDialog, shadowColor={0, 0, 0}, color={255, 255, 255}})
    but:setContentSize(80, 82)
    setPos(addChild(self.temp, but.bg), {848, fixY(sz.height, 112)})
    local but = ui.newButton({image="newLeftArrow.png", text="", font="f1", size=18, delegate=self, callback=self.onLeft, shadowColor={0, 0, 0}, color={255, 255, 255}})
    but:setContentSize(90, 106)
    setPos(addChild(self.temp, but.bg), {131, fixY(sz.height, 388)})
    local but = ui.newButton({image="newRightArrow.png", text="", font="f1", size=18, delegate=self, callback=self.onRight, shadowColor={0, 0, 0}, color={255, 255, 255}})
    but:setContentSize(90, 106)
    setPos(addChild(self.temp, but.bg), {923, fixY(sz.height, 390)})
    local but = ui.newButton({image="butc.png", text="进行启用", font="f1", size=27, delegate=self, callback=self.onPeople, shadowColor={0, 0, 0}, color={255, 255, 255}})
    but:setContentSize(158, 50)
    setPos(addChild(self.temp, but.bg), {533, fixY(sz.height, 625)})
    local sp = setOpacity(setAnchor(setSize(setPos(addSprite(self.temp, "infoTitle.png"), {531, fixY(sz.height, 148)}), {212, 42}), {0.50, 0.50}), 255)


    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="体力", size=28, color={255, 255, 255}, font="f2", shadowColor={0, 0, 0}})), {0.00, 0.50}), {465, fixY(sz.height, 328)})
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="9999", size=25, color={248, 181, 81}, font="f2", shadowColor={0, 0, 0}})), {1.00, 0.50}), {785, fixY(sz.height, 328)})
    self.health = w
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="腕力", size=28, color={255, 255, 255}, font="f2", shadowColor={0, 0, 0}})), {0.00, 0.50}), {465, fixY(sz.height, 380)})
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="9999副本", size=25, color={248, 181, 81}, font="f2", shadowColor={0, 0, 0}})), {1.00, 0.50}), {785, fixY(sz.height, 380)})
    self.brawn = w
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="射击", size=28, color={255, 255, 255}, font="f2", shadowColor={0, 0, 0}})), {0.00, 0.50}), {465, fixY(sz.height, 425)})
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="222", size=25, color={248, 181, 81}, font="f2", shadowColor={0, 0, 0}})), {1.00, 0.50}), {782, fixY(sz.height, 425)})
    self.shoot = w
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="劳动", size=28, color={255, 255, 255}, font="f2", shadowColor={0, 0, 0}})), {0.00, 0.50}), {465, fixY(sz.height, 475)})
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="555", size=25, color={248, 181, 81}, font="f2", shadowColor={0, 0, 0}})), {1.00, 0.50}), {782, fixY(sz.height, 475)})
    self.labor = w

    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="启用费用", size=28, color={255, 255, 255}, font="f2", shadowColor={0, 0, 0}})), {0.00, 0.50}), {463, fixY(sz.height, 525)})
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="9999银币", size=25, color={248, 181, 81}, font="f2", shadowColor={0, 0, 0}})), {1.00, 0.50}), {780, fixY(sz.height, 527)})
    self.costWord = w

    local headBoard = setOpacity(setAnchor(setSize(setPos(addSprite(self.temp, "peopBoard.png"), {349, fixY(sz.height, 402)}), {184, 183}), {0.50, 0.50}), 255)

    local sf = CCSpriteFrameCache:sharedSpriteFrameCache()
    sf:addSpriteFramesWithFile(string.format("cat_%d_walk.plist", (pid)))
    local sp = setAnchor(setPos(addSprite(headBoard, string.format("cat_%d_rb_0.png", pid)), {92, 92}), {0.50, 0.50})
    local sca = getSca(sp, {162, 162})
    setScale(sp, sca)
    self.head = sp

    local banner = setAnchor(setSize(setPos(addSprite(self.temp, "prob.png"), {626, fixY(sz.height, 328)}), {191, 29}), {0.50, 0.50})
    local pro = setAnchor(setSize(setPos(addSprite(banner, "proa.png"), {4, 4.5}), {183, 20}), {0.0, 0})
    self.healthBar = pro

    local banner = setAnchor(setSize(setPos(addSprite(self.temp, "prob.png"), {626, fixY(sz.height, 380)}), {191, 29}), {0.50, 0.50})
    local pro = setAnchor(setSize(setPos(addSprite(banner, "proa.png"), {4, 4.5}), {183, 20}), {0.0, 0})
    self.brawnBar = pro

    local banner = setAnchor(setSize(setPos(addSprite(self.temp, "prob.png"), {626, fixY(sz.height, 425)}), {191, 29}), {0.50, 0.50})
    local pro = setAnchor(setSize(setPos(addSprite(banner, "proa.png"), {4, 4.5}), {183, 20}), {0.0, 0})
    self.shootBar = pro

    local banner = setAnchor(setSize(setPos(addSprite(self.temp, "prob.png"), {626, fixY(sz.height, 475)}), {191, 29}), {0.50, 0.50})
    local pro = setAnchor(setSize(setPos(addSprite(banner, "proa.png"), {4, 4.5}), {183, 20}), {0.0, 0})
    self.laborBar = pro

    centerUI(self)
    self:setPeople()
end

function FindPeople3:onLeft()
    if self.num > 1 then
        self.num = self.num-1
    else
        self.num = #Logic.ownPeople
    end
    self:setPeople()
end
function FindPeople3:onRight()
    --print("self.onRight", self.num, #Logic.allPeople)
    if self.num < #Logic.ownPeople then
        self.num = self.num+1
    else
        self.num = 1
    end
    self:setPeople()
end

function FindPeople3:setPeople()
    local pid = Logic.ownPeople[self.num]
    local sf = CCSpriteFrameCache:sharedSpriteFrameCache()
    sf:addSpriteFramesWithFile(string.format("cat_%d_walk.plist", (pid)))
    self.head:setDisplayFrame(sf:spriteFrameByName(string.format("cat_%d_rb_0.png", pid)))
    adjustBox(self.head, {150, 150}) 

    local pdata = Logic.people[pid]
    self.name:setString(pdata.name)
    self.health:setString(pdata.health)
    self.brawn:setString(pdata.brawn)
    self.shoot:setString(pdata.shoot)
    self.labor:setString(pdata.labor)
    local total = #Logic.ownPeople
    --self.curPeople:setString("人才启用"..(self.num)..'/'..total)

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

function FindPeople3:onPeople()
    local pid = Logic.ownPeople[self.num]
    local pdata = Logic.people[pid]
    local cost = {silver=pdata.silver, gold=pdata.gold}
    if not checkCost(cost) then
        addBanner("钱不够!")
    else
        local function callPeople()
            doCost(cost)
            global.director:popView()
            global.director.curScene.page:addPeople(pid)
            --移除掉这个村民
            table.remove(Logic.ownPeople, self.num)
        end
        if pdata.gold > 0 then
            global.director:pushView(SureGold.new(callPeople, self), nil)
        else
            callPeople()
        end
    end
end

