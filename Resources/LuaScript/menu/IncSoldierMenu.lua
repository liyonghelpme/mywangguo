IncSoldierMenu  = class()
function IncSoldierMenu:ctor()
    local vs = getVS()
    self.bg = CCNode:create()
    local sz = {width=1024, height=768}
    self.temp = setPos(addNode(self.bg), {0, fixY(sz.height, 0+sz.height)+12})
    local sp = setOpacity(setAnchor(setSize(setPos(addSprite(self.temp, "sdialoga.png"), {512, fixY(sz.height, 396)}), {633, 427}), {0.50, 0.50}), 255)
    local sp = setOpacity(setAnchor(setSize(setPos(addSprite(self.temp, "smallDialogb.png"), {512, fixY(sz.height, 407)}), {588, 255}), {0.50, 0.50}), 255)
    local but = ui.newButton({image="newClose.png", text="", font="f1", size=18, delegate=self, callback=closeDialog, shadowColor={0, 0, 0}, color={255, 255, 255}})
    but:setContentSize(80, 82)
    setPos(addChild(self.temp, but.bg), {813, fixY(sz.height, 196)})
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="不能再增加了", size=26, color={32, 112, 220}, font="f2", shadowColor={255, 255, 255}})), {0.50, 0.50}), {513, fixY(sz.height, 554)})
    self.desWord = w
    local sp = setOpacity(setAnchor(setSize(setPos(addSprite(self.temp, "incTitle.png"), {525, fixY(sz.height, 234)}), {195, 39}), {0.50, 0.50}), 255)

    local sp = setOpacity(setAnchor(setSize(setPos(addSprite(self.temp, "peopBoard.png"), {332, fixY(sz.height, 408)}), {184, 183}), {0.50, 0.50}), 255)
    local sp = setOpacity(setAnchor(setSize(setPos(addSprite(self.temp, "role.png"), {329, fixY(sz.height, 404)}), {162, 161}), {0.50, 0.50}), 255)

    local but = ui.newButton({image="selSoldier.png", text="", font="f1", size=18, delegate=self, callback=self.onBut, param=1,  shadowColor={0, 0, 0}, color={255, 255, 255}})
    but:setContentSize(341, 42)
    setPos(addChild(self.temp, but.bg), {611, fixY(sz.height, 342)})
    local but1 = but

    local but = ui.newButton({image="selSoldier.png", text="", font="f1", size=18, delegate=self, callback=self.onBut, param=2, shadowColor={0, 0, 0}, color={255, 255, 255}})
    but:setContentSize(341, 42)
    setPos(addChild(self.temp, but.bg), {611, fixY(sz.height, 389)})
    local but2 = but

    local but = ui.newButton({image="selSoldier.png", text="", font="f1", size=18, delegate=self, callback=self.onBut, param=3, shadowColor={0, 0, 0}, color={255, 255, 255}})
    but:setContentSize(341, 42)
    setPos(addChild(self.temp, but.bg), {611, fixY(sz.height, 436)})
    local but3 = but

    local but = ui.newButton({image="selSoldier.png", text="", font="f1", size=18, delegate=self, callback=self.onBut, param=4, shadowColor={0, 0, 0}, color={255, 255, 255}})
    but:setContentSize(341, 42)
    setPos(addChild(self.temp, but.bg), {611, fixY(sz.height, 483)})
    local but4 = but
    self.buts = {but1, but2, but3, but4}
    self.words = {}

    local w1 = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="步卒", size=25, color={255, 255, 255}, font="f2", shadowColor={0, 0, 0}})), {0.00, 0.50}), {446, fixY(sz.height, 342)})
    local w2 = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="999", size=25, color={248, 181, 81}, font="f2", shadowColor={0, 0, 0}})), {0.00, 0.50}), {515, fixY(sz.height, 342)})
    local w3 = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="12345银币", size=25, color={248, 181, 81}, font="f1", shadowColor={0, 0, 0}})), {1.00, 0.50}), {778, fixY(sz.height, 342)})
    table.insert(self.words, {w1, w2, w3})
    
    local w1 = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="弓队", size=25, color={255, 255, 255}, font="f2", shadowColor={0, 0, 0}})), {0.00, 0.50}), {448, fixY(sz.height, 389)})
    local w2 = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="658", size=25, color={248, 181, 81}, font="f2", shadowColor={0, 0, 0}})), {0.00, 0.50}), {515, fixY(sz.height, 389)})
    local w3 = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="12345银币", size=25, color={248, 181, 81}, font="f1", shadowColor={0, 0, 0}})), {1.00, 0.50}), {778, fixY(sz.height, 389)})
    table.insert(self.words, {w1, w2, w3})

    local w1 = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="魔法", size=25, color={255, 255, 255}, font="f2", shadowColor={0, 0, 0}})), {0.00, 0.50}), {446, fixY(sz.height, 436)})
    local w2 = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="123", size=25, color={248, 181, 81}, font="f2", shadowColor={0, 0, 0}})), {0.00, 0.50}), {517, fixY(sz.height, 436)})
    local w3 = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="12345银币", size=25, color={248, 181, 81}, font="f1", shadowColor={0, 0, 0}})), {1.00, 0.50}), {779, fixY(sz.height, 436)})
    table.insert(self.words, {w1, w2, w3})

    local w1 = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="铁骑", size=25, color={255, 255, 255}, font="f2", shadowColor={0, 0, 0}})), {0.00, 0.50}), {445, fixY(sz.height, 483)})
    local w2 = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="123", size=25, color={248, 181, 81}, font="f2", shadowColor={0, 0, 0}})), {0.00, 0.50}), {517, fixY(sz.height, 483)})
    local w3 = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="无法运用", size=25, color={248, 181, 81}, font="f1", shadowColor={0, 0, 0}})), {1.00, 0.50}), {774, fixY(sz.height, 483)})
    table.insert(self.words, {w1, w2, w3})

    self:initButton()
    self:selTab(1)

    centerUI(self)
end
function IncSoldierMenu:initButton()
    for i=1, 4, 1 do
        self.buts[i].sp:setVisible(false)
        self:updateBut(i)
    end
end
function IncSoldierMenu:updateBut(n)
    local s = Logic.soldiers[n]
    local nword = self.words[n]
    if s[1] == 0 then
        setColor(nword[1], {149, 149, 149})
        nword[2]:setString('')
        setColor(nword[3], {149, 149, 149})
        nword[3]:setString("无法运用")
    elseif s[2] >= 999 then
        setColor(nword[1], {255, 255, 255})
        nword[2]:setString(s[2])
        nword[3]:setString('')
    else
        setColor(nword[1], {255, 255, 255})
        nword[2]:setString(s[2])
        local cost = math.floor(math.pow(1.5, s[1]-1)*Logic.IncCost[n][3])
        nword[3]:setString(cost..'银币')
        if not checkCost(cost) then
            setColor(nword[3], {254, 7, 1})
        else
            setColor(nword[3], {248, 181, 81})
        end
    end
end
function IncSoldierMenu:selTab(s)
    if self.curTab ~= nil then
        self.curTab.sp:setVisible(false)
    end
    self.curTab = self.buts[s]
    self.curTab.sp:setVisible(true)

    local solData = Logic.soldiers[s]
    if solData[1] == 0 then
        self.desWord:setString("该部队还无法运用")
    elseif solData[2] >= 999 then
        self.desWord:setString("不能再增加了")
    else
        self.desWord:setString("点击增强兵力")
    end
    self.selNum = s
end

function IncSoldierMenu:onBut(param)
    if self.selNum ~= param then
        self.selNum = param
    else
        local solData = Logic.soldiers[self.selNum]
        if solData[1] == 0 then
        elseif solData[2] >= 999 then
        else
            local cost = math.floor(math.pow(1.5, solData[1]-1)*Logic.IncCost[self.selNum][3])
            if not checkCost(cost) then
                addBanner("银币不足")
            else
                doCost(cost)
                local cnName = {'步卒', '弓队', '魔法', '铁骑'}
                addBanner("增加"..cnName[self.selNum].."成功")
                solData[1] = solData[1]+1
                solData[2] = solData[2]+Logic.IncCost[self.selNum][2]

                self:updateBut(self.selNum)
                self:selTab(self.selNum)
            end
        end
    end
end

