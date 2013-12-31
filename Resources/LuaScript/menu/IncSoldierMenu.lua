IncSoldierMenu  = class()
function IncSoldierMenu:ctor()
    local vs = getVS()
    self.bg = CCNode:create()
    local sz = {width=1024, height=768}
    self.temp = setPos(addNode(self.bg), {-20.0, -4.5})
    local sp = setAnchor(setSize(setPos(addSprite(self.temp, "sdialoga.png"), {513, fixY(sz.height, 379)}), {619, 381}), {0.50, 0.50})
    
    local but = ui.newButton({image="selSoldier.png", text="", font="f1", size=18, delegate=self, callback=self.onBut, param=1, touchBegan=self.selTab})
    but:setContentSize(341, 42)
    setPos(addChild(self.temp, but.bg), {612, fixY(sz.height, 328)})
    local but1 = but

    local but = ui.newButton({image="selSoldier.png", text="", font="f1", size=18, delegate=self, callback=self.onBut, param=2, touchBegan=self.selTab})
    but:setContentSize(341, 42)
    setPos(addChild(self.temp, but.bg), {612, fixY(sz.height, 372)})
    local but2 = but

    local but = ui.newButton({image="selSoldier.png", text="", font="f1", size=18, delegate=self, callback=self.onBut, param=3, touchBegan=self.selTab})
    but:setContentSize(341, 42)
    setPos(addChild(self.temp, but.bg), {612, fixY(sz.height, 416)})
    local but3 = but

    local but = ui.newButton({image="selSoldier.png", text="", font="f1", size=18, delegate=self, callback=self.onBut, param=4, touchBegan=self.selTab})
    but:setContentSize(341, 42)
    setPos(addChild(self.temp, but.bg), {612, fixY(sz.height, 459)})
    local but4 = but

    self.buts = {but1, but2, but3, but4}
    self.words = {}
    local sp = setAnchor(setSize(setPos(addSprite(self.temp, "peopBoard.png"), {333, fixY(sz.height, 392)}), {184, 183}), {0.50, 0.50})
    local sp = setAnchor(setSize(setPos(addSprite(self.temp, "role.png"), {330, fixY(sz.height, 388)}), {162, 161}), {0.50, 0.50})
    local w2 = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="999", size=25, color={248, 181, 81}, font="f2"})), {0.00, 0.50}), {516, fixY(sz.height, 330)})
    local w1 = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="步卒", size=25, color={255, 255, 255}, font="f2"})), {0.00, 0.50}), {447, fixY(sz.height, 329)})
    local w3 = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="12345银币", size=25, color={248, 181, 81}, font="f2"})), {1.00, 0.50}), {780, fixY(sz.height, 328)})
    table.insert(self.words, {w1, w2, w3})

    local w2 = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="658", size=25, color={248, 181, 81}, font="f2"})), {0.00, 0.50}), {516, fixY(sz.height, 372)})
    local w1 = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="弓队", size=25, color={255, 255, 255}, font="f2"})), {0.00, 0.50}), {449, fixY(sz.height, 372)})
    local w3 = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="12345银币", size=25, color={248, 181, 81}, font="f2"})), {1.00, 0.50}), {780, fixY(sz.height, 373)})
    table.insert(self.words, {w1, w2, w3})

    local w1 = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="魔法", size=25, color={255, 255, 255}, font="f2"})), {0.00, 0.50}), {447, fixY(sz.height, 416)})
    local w2 = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="123", size=25, color={248, 181, 81}, font="f2"})), {0.00, 0.50}), {518, fixY(sz.height, 416)})
    local w3 = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="12345银币", size=25, color={254, 7, 1}, font="f2"})), {1.00, 0.50}), {780, fixY(sz.height, 417)})
    table.insert(self.words, {w1, w2, w3})

    local w1 = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="铁骑", size=25, color={149, 149, 149}, font="f2"})), {0.00, 0.50}), {446, fixY(sz.height, 459)})
    local w2 = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="123", size=25, color={248, 181, 81}, font="f2"})), {0.00, 0.50}), {518, fixY(sz.height, 459)})
    local w3 = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="无法运用", size=25, color={149, 149, 149}, font="f2"})), {1.00, 0.50}), {780, fixY(sz.height, 458)})
    table.insert(self.words, {w1, w2, w3})

    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="兵力的增强", size=34, color={102, 66, 42}, font="f1"})), {0.50, 0.50}), {532, fixY(sz.height, 247)})
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="不能再增加了", size=26, color={32, 112, 220}, font="f1"})), {0.50, 0.50}), {524, fixY(sz.height, 529)})
    self.desWord = w

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

