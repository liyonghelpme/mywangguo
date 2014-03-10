ArmyMenu = class()
function ArmyMenu:ctor()
    local vs = getVS()
    self.bg = CCNode:create()
    local sz = {width=1024, height=768}
    self.temp = setPos(addNode(self.bg), {0, fixY(sz.height, 0+sz.height)+0})
    local sp = setOpacity(setAnchor(setSize(setPos(addSprite(self.temp, "dialogA.png"), {525, fixY(sz.height, 388)}), {693, 588}), {0.50, 0.50}), 255)
    local sp = setAnchor(setPos(addChild(self.temp, createDialogB()), {523, fixY(sz.height, 423)}), {0.50, 0.50})
    local but = ui.newButton({image="newClose.png", text="", font="f1", size=18, delegate=self, callback=closeDialog, shadowColor={0, 0, 0}, color={255, 255, 255}})
    but:setContentSize(80, 82)
    setPos(addChild(self.temp, but.bg), {848, fixY(sz.height, 112)})
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="步兵体力30攻击30技能防御UP", size=26, color={32, 112, 220}, font="f2", shadowColor={255, 255, 255}})), {0.50, 0.50}), {538, fixY(sz.height, 625)})
    self.desWord = w
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="配置场地", size=26, color={32, 112, 220}, font="f2", shadowColor={255, 255, 255}})), {1.00, 0.50}), {764, fixY(sz.height, 215)})
    local sp = setOpacity(setAnchor(setSize(setPos(addSprite(self.temp, "lvpng.png"), {339, fixY(sz.height, 216)}), {49, 43}), {0.50, 0.50}), 255)
    local sp = setOpacity(setAnchor(setSize(setPos(addSprite(self.temp, "armyTitle.png"), {533, fixY(sz.height, 147)}), {212, 41}), {0.50, 0.50}), 255)

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
function ArmyMenu:updateTab()
	local initX = 0
	local initY = -55
	local offX = 0
	local offY = 52
	self.data = {}
    local sz = {width=546, height=52}
    local rowWidth = 1
    for k, av in ipairs(Logic.attendHero) do
        local v = Logic.farmPeople[av.id]

		local row = math.floor((k-1)/rowWidth)
		local col = (k-1)%rowWidth

        local pdata = calAttr(v.id, v.level, v)

        local panel = setPos(addNode(self.flowNode), {initX+col*offX, initY-offY*row})
        local listback = setOpacity(setAnchor(setSize(setPos(addSprite(panel, "listB.png"), {306, fixY(sz.height, 26)}), {479, 52}), {0.50, 0.50}), 255)
        local w1 = setPos(setAnchor(addChild(panel, ui.newTTFLabel({text=v.level+1, size=26, color={255, 241, 0}, font="f2", shadowColor={255, 255, 255}})), {0.00, 0.50}), {92, fixY(sz.height, 25)})
        local w2 = setPos(setAnchor(addChild(panel, ui.newTTFLabel({text=v.data.name, size=24, color={240, 196, 92}, font="f2", shadowColor={255, 255, 255}})), {0.00, 0.50}), {133, fixY(sz.height, 24)})
        local w3 = setPos(setAnchor(addChild(panel, ui.newTTFLabel({text="前", size=24, color={240, 196, 92}, font="f2", shadowColor={255, 255, 255}})), {0.50, 0.50}), {468, fixY(sz.height, 24)})
        if av.pos == 0 then
            w3:setString("前")
        elseif av.pos == 1 then
            w3:setString("中")
        elseif av.pos == 2 then
            w3:setString("后")
        end
        local but = ui.newButton({image="lefta.png", text="", font="f1", size=18, delegate=self, callback=self.onLeft, param=k, shadowColor={0, 0, 0}, color={255, 255, 255}})
        setScriptTouchPriority(but.bg, -256)
        but:setContentSize(45, 51)
        setPos(addChild(panel, but.bg), {420, fixY(sz.height, 26)})
        local but = ui.newButton({image="righta.png", text="", font="f1", size=18, delegate=self, callback=self.onRight, param=k, shadowColor={0, 0, 0}, color={255, 255, 255}})
        setScriptTouchPriority(but.bg, -256)
        but:setContentSize(45, 51)
        setPos(addChild(panel, but.bg), {516, fixY(sz.height, 26)})
        local sp = setOpacity(setAnchor(setSize(setPos(addSprite(panel, "headBoard.png"), {28, fixY(sz.height, 26)}), {57, 52}), {0.50, 0.50}), 255)
        local sp = setOpacity(setAnchor(setSize(setPos(addSprite(panel, "catHead"..v.id..".png"), {28, fixY(sz.height, 24)}), {52, 45}), {0.50, 0.50}), 255)
        panel:setTag(k)
        setContentSize(panel, {sz.width, sz.height})

        --0 1 2
        table.insert(self.data, {listback, w1, w2, w3, pdata=pdata, vdata=v, pos=av.pos})
		self.flowHeight = self.flowHeight+offY
    end
end

function ArmyMenu:onLeft(p)
    local word = self.data[p]
    local n = {'前', '中', '后'}
    word.pos = word.pos-1
    word.pos = word.pos%3
    Logic.attendHero[p].pos = word.pos 
    word[4]:setString(n[word.pos+1])
    updateAttend()
end
function ArmyMenu:onRight(p)
    local word = self.data[p]
    local n = {'前', '中', '后'}
    word.pos = word.pos+1
    word.pos = word.pos%3
    Logic.attendHero[p].pos = word.pos 
    word[4]:setString(n[word.pos+1])
    updateAttend()
end

function ArmyMenu:touchBegan(x, y)
    self.lastPoints = {x, y}
    self.accMove = 0
    self.curSel = nil
end

function ArmyMenu:moveBack(dify)
    adjustFlow(self, dify)
end
function ArmyMenu:touchMoved(x, y)
    local oldPoints = self.lastPoints
    self.lastPoints = {x, y}
    local dify = self.lastPoints[2]-oldPoints[2]
    self.accMove = self.accMove+math.abs(dify)
    self:moveBack(dify)
end

function ArmyMenu:touchEnded(x, y)
    local newPos = {x, y}
    if self.accMove < 10 then
        local child = checkInChild(self.flowNode, newPos)
        if child ~= nil then
            print("touch child", child:getTag())
            local t = child:getTag()
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

function ArmyMenu:setSel(s)
    if #self.data < s then
        return
    end
    --if self.selPanel ~= s then
        print("self sel", self.selPanel, self.selTab)
        if self.selPanel ~= nil then
            setTexture(self.data[self.selPanel][1], "listB.png")
            local word = self.data[self.selPanel] 
            print("word", #word)
            setColor(word[2], {255, 241, 0})
            setColor(word[3], {240, 196, 92})
            setColor(word[4], {240, 196, 92})
        end
        self.selPanel = s
        setTexture(self.data[self.selPanel][1], "listA.png")
        local word = self.data[self.selPanel] 
        setColor(word[2], {40, 172, 255})
        setColor(word[3], {206, 78, 0})
        setColor(word[4], {206, 78, 0})
        
        local fp = Logic.farmPeople[self.selPanel].data.skill
        print("skill Num is", skill)
        --print(simple.encode(Logic.skill))
        --self.attWord:setString(Logic.skill[fp].attribute)
        local vdata = word.vdata
        local sid = getPeopleSkill(vdata.id, vdata.level)
        local pdata = word.pdata 

        if sid == 0 then
            self.desWord:setString("步兵 "..'体力 '..pdata.health.." 攻击 "..pdata.attack)
        else
            local sdata = Logic.allSkill[sid]
            self.desWord:setString("步兵 "..'体力 '..pdata.health.." 攻击 "..pdata.attack..' 技能 '..sdata.name)
        end
    --end
end
