ChooseMenu = class()
--选择士兵出战
function ChooseMenu:ctor()
    local vs = getVS()
    self.bg = CCNode:create()
    local sz = {width=1024, height=768}
    self.temp = setPos(addNode(self.bg), {0, fixY(sz.height, 0+sz.height)+0})
    local sp = setOpacity(setAnchor(setSize(setPos(addSprite(self.temp, "dialogA.png"), {525, fixY(sz.height, 388)}), {693, 588}), {0.50, 0.50}), 255)
    local sp = setAnchor(setPos(addChild(self.temp, createDialogB()), {523, fixY(sz.height, 423)}), {0.50, 0.50})
    local but = ui.newButton({image="newClose.png", text="", font="f1", size=18, delegate=self, callback=closeDialog, shadowColor={0, 0, 0}, color={255, 255, 255}})
    but:setContentSize(80, 82)
    setPos(addChild(self.temp, but.bg), {848, fixY(sz.height, 112)})
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="最多选择"..Logic.fightNum.."个英雄参加", size=26, color={32, 112, 220}, font="f2", shadowColor={255, 255, 255}})), {0.50, 0.50}), {533, fixY(sz.height, 625)})
    
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="费用", size=26, color={32, 112, 220}, font="f2", shadowColor={255, 255, 255}})), {0.00, 0.50}), {673, fixY(sz.height, 217)})
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="配属", size=26, color={32, 112, 220}, font="f2", shadowColor={255, 255, 255}})), {0.00, 0.50}), {593, fixY(sz.height, 217)})
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="防", size=26, color={32, 112, 220}, font="f2", shadowColor={255, 255, 255}})), {0.00, 0.50}), {547, fixY(sz.height, 216)})
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="攻", size=26, color={32, 112, 220}, font="f2", shadowColor={255, 255, 255}})), {0.00, 0.50}), {498, fixY(sz.height, 215)})
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="体力", size=26, color={32, 112, 220}, font="f2", shadowColor={255, 255, 255}})), {0.00, 0.50}), {445, fixY(sz.height, 215)})
    local sp = setOpacity(setAnchor(setSize(setPos(addSprite(self.temp, "lvpng.png"), {332, fixY(sz.height, 216)}), {49, 43}), {0.50, 0.50}), 255)
    local sp = setOpacity(setAnchor(setSize(setPos(addSprite(self.temp, "chooseTitle.png"), {539, fixY(sz.height, 147)}), {270, 41}), {0.50, 0.50}), 255)

    self.scrollPro = createScroll(self.temp, sz, self)

    local listSize = {width=546, height=319}
    self.listSize = listSize
    self.HEIGHT = 319
    self.cl = Scissor:create()
    self.temp:addChild(self.cl)
    setPos(self.cl, {228, fixY(sz.height, 263+listSize.height)})
    setContentSize(self.cl, {listSize.width, listSize.height})
    self.flowNode = addNode(self.cl)
    setPos(self.flowNode, {0, self.HEIGHT})
    self.touch = ui.newTouchLayer({size={listSize.width, self.HEIGHT}, delegate=self, touchBegan=self.touchBegan, touchMoved=self.touchMoved, touchEnded=self.touchEnded})
    self.cl:addChild(self.touch.bg)
    setPos(self.touch.bg, {0, 0})
    self.flowHeight = 0
    self:updateTab()
    self:setSel(1)

    centerUI(self)
end
function ChooseMenu:updateTab()
	local initX = 0
	local initY = -55
	local offX = 0
	local offY = 52
    local rowWidth = 1

    local sz = {width=546, height=53}
	self.data = {}
    local att = Logic.attendHero
    local aYet = {}
    for k, v in ipairs(att) do
        aYet[v.id] = true 
    end

    for k, v in ipairs(Logic.farmPeople) do
		local row = math.floor((k-1)/rowWidth)
		local col = (k-1)%rowWidth
        local pdata = calAttr(v.id, v.level, v)

        local panel = setPos(addNode(self.flowNode), {initX+col*offX, initY-offY*row})
        local listback = setOpacity(setAnchor(setSize(setPos(addSprite(panel, "listB.png"), {306, fixY(sz.height, 26)}), {479, 52}), {0.50, 0.50}), 255)
        local sp = setOpacity(setAnchor(setSize(setPos(addSprite(panel, "headBoard.png"), {28, fixY(sz.height, 26)}), {57, 52}), {0.50, 0.50}), 255)
        local sp = setOpacity(setAnchor(setSize(setPos(addSprite(panel, "catHead"..v.id..".png"), {28, fixY(sz.height, 24)}), {52, 45}), {0.50, 0.50}), 255)
        local attend = setOpacity(setAnchor(setSize(setPos(addSprite(panel, "attend.png"), {48, fixY(sz.height, 40)}), {23, 25}), {0.50, 0.50}), 255)
        if aYet[k] then
            setVisible(attend, true)
        else
            setVisible(attend, false)
        end

        local w1 = setPos(setAnchor(addChild(panel, ui.newTTFLabel({text=v.level+1, size=25, color={255, 241, 0}, font="f2", shadowColor={255, 255, 255}})), {0.00, 0.50}), {84, fixY(sz.height, 25)})
        local w2 = setPos(setAnchor(addChild(panel, ui.newTTFLabel({text=v.data.name, size=23, color={240, 196, 92}, font="f2", shadowColor={255, 255, 255}})), {0.00, 0.50}), {124, fixY(sz.height, 25)})
        local w3 = setPos(setAnchor(addChild(panel, ui.newTTFLabel({text=pdata.health, size=23, color={240, 196, 92}, font="f2", shadowColor={255, 255, 255}})), {0.00, 0.50}), {220, fixY(sz.height, 24)})
        local w4 = setPos(setAnchor(addChild(panel, ui.newTTFLabel({text=pdata.attack, size=23, color={240, 196, 92}, font="f2", shadowColor={255, 255, 255}})), {0.00, 0.50}), {271, fixY(sz.height, 24)})
        local w5 = setPos(setAnchor(addChild(panel, ui.newTTFLabel({text=pdata.defense, size=23, color={240, 196, 92}, font="f2", shadowColor={255, 255, 255}})), {0.00, 0.50}), {319, fixY(sz.height, 24)})
        local w6 = setPos(setAnchor(addChild(panel, ui.newTTFLabel({text="步兵", size=23, color={240, 196, 92}, font="f2", shadowColor={255, 255, 255}})), {0.00, 0.50}), {369, fixY(sz.height, 24)})
        local w7 = setPos(setAnchor(addChild(panel, ui.newTTFLabel({text="10银币", size=23, color={240, 196, 92}, font="f2", shadowColor={255, 255, 255}})), {1.00, 0.50}), {541, fixY(sz.height, 24)})
        panel:setTag(k)
        setContentSize(panel, {sz.width, sz.height})

        table.insert(self.data, {listback, w1, w2, w3, w4, w5, w6, w7, attend=attend, pdata=pdata, vdata=v, pos=0})
		self.flowHeight = self.flowHeight+offY
    end
end


function ChooseMenu:touchBegan(x, y)
    self.lastPoints = {x, y}
    self.accMove = 0
    self.curSel = nil
end

function ChooseMenu:moveBack(dify)
    adjustFlow(self, dify)
end
function ChooseMenu:touchMoved(x, y)
    local oldPoints = self.lastPoints
    self.lastPoints = {x, y}
    local dify = self.lastPoints[2]-oldPoints[2]
    self.accMove = self.accMove+math.abs(dify)
    self:moveBack(dify)
end

function ChooseMenu:touchEnded(x, y)
    local newPos = {x, y}
    if self.accMove < 10 then
        local child = checkInChild(self.flowNode, newPos)
        if child ~= nil then
            print("touch child", child:getTag())
            local t = child:getTag()
            self:adjustAttend(t)
            if self.selPanel ~= t then
                self:setSel(t)
            else
                --global.director:popView()
                --global.director:pushView(PeopleInfo.new(self.selPanel, true), 1)
                --return
            end
        end
    end


    if self.flowHeight < self.HEIGHT then
        self.minPos = 0
    else
        self.minPos = self.flowHeight-self.HEIGHT
    end


    local oldPos = getPos(self.flowNode)
    oldPos[2] = oldPos[2]-self.HEIGHT
    oldPos[2] = math.max(0, math.min(self.minPos, oldPos[2]))
    self.flowNode:setPosition(ccp(oldPos[1], oldPos[2]+self.HEIGHT))
    --print("flowHeight ", self.flowHeight, self.minPos, self.HEIGHT, oldPos[2])
end

function ChooseMenu:adjustAttend(t)
    local word =  self.data[t]
    local v = word.attend:isVisible()
    if not v then
        if #Logic.attendHero >= Logic.fightNum then
            addBanner("参战人数不能超过"..Logic.fightNum)
            return
        end
    end

    if v then
        for ak, av in ipairs(Logic.attendHero) do
            if av.id == t then
                table.remove(Logic.attendHero, ak)
                break
            end
        end
    else
        table.insert(Logic.attendHero, {id=t, pos=0})
    end
    setVisible(word.attend, not v)
end
function ChooseMenu:setSel(s)
    if #self.data < s then
        return
    end
    print("self sel", self.selPanel, self.selTab)
    if self.selPanel ~= nil then
        setTexture(self.data[self.selPanel][1], "listB.png")
        local word = self.data[self.selPanel] 
        print("word", #word)
        setColor(word[2], {255, 241, 0})
        setColor(word[3], {240, 196, 92})
        setColor(word[4], {240, 196, 92})
        setColor(word[5], {240, 196, 92})
        setColor(word[6], {240, 196, 92})
        setColor(word[7], {240, 196, 92})
        setColor(word[8], {240, 196, 92})
    end
    self.selPanel = s
    setTexture(self.data[self.selPanel][1], "listA.png")
    local word = self.data[self.selPanel] 
    setColor(word[2], {40, 172, 255})
    setColor(word[3], {206, 78, 0})
    setColor(word[4], {206, 78, 0})
    setColor(word[5], {206, 78, 0})
    setColor(word[6], {206, 78, 0})
    setColor(word[7], {206, 78, 0})
    setColor(word[8], {206, 78, 0})
        
end
