require "menu.PeopleInfo"
AttributeMenu = class()
function AttributeMenu:ctor()
    local vs = getVS()
    self.bg = CCNode:create()
    local sz = {width=1024, height=768}
    self.temp = setPos(addNode(self.bg), {-26, 3.5})
    local but = ui.newButton({image="taba.png", text="", font="f1", size=18, delegate=self, callback=self.onBut, param=2, touchBegan=self.onTab})
    but:setContentSize(82, 126)
    setPos(addChild(self.temp, but.bg), {908, fixY(sz.height, 357)})
    but.bg:setZOrder(-1)
    local sp = setAnchor(addSprite(but.bg, "skillIcon.png"), {0.50, 0.50})

    self.skillAtt = but 
    local but = ui.newButton({image="taba.png", text="", font="f1", size=18, delegate=self, callback=self.onBut, param=1, touchBegan=self.onTab})
    but:setContentSize(82, 126)
    setPos(addChild(self.temp, but.bg), {908, fixY(sz.height, 222)})
    but.bg:setZOrder(-1)
    local sp = setAnchor(addSprite(but.bg, "attIcon.png"), {0.50, 0.50})
    self.baseAtt = but
    self.tabs = {self.baseAtt, self.skillAtt}

    local sp = setAnchor(setPos(addSprite(self.temp, "dialogA.png"), {538, fixY(sz.height, 387)}), {0.50, 0.50})
    local sp = setAnchor(setSize(setPos(addSprite(self.temp, "dialogB.png"), {535, fixY(sz.height, 421)}), {617, 352}), {0.50, 0.50})
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="基本属性1/2", size=34, color={102, 66, 42}, font="f1"})), {0.50, 0.50}), {538, fixY(sz.height, 153)})
    self.total = w




    local listSize = {width=546, height=318}
    self.listSize = listSize
    self.HEIGHT = 318
    self.cl = Scissor:create()
    self.temp:addChild(self.cl)
    setPos(self.cl, {246, fixY(sz.height, 262+listSize.height)})
    setContentSize(self.cl, {listSize.width, listSize.height})
    self.flowNode = addNode(self.cl)
    setPos(self.flowNode, {0, self.HEIGHT})
    self.touch = ui.newTouchLayer({size={listSize.width, self.HEIGHT}, delegate=self, touchBegan=self.touchBegan, touchMoved=self.touchMoved, touchEnded=self.touchEnded})
    self.cl:addChild(self.touch.bg)
    setPos(self.touch.bg, {0, 0})
    self.flowHeight = 0
    self:updateTab()


    self:setSelect(1)

    local sp = setAnchor(setSize(setPos(addSprite(self.temp, "scrollBack.png"), {817, fixY(sz.height, 420)}), {15, 315}), {0.50, 0.50})
    local pro = setAnchor(setSize(setPos(addSprite(sp, "scrollPro.png"), {0, fixY(315, 0)}), {17, 157}), {0, 1})
    self.scrollPro = pro
    local total = #self.data
    local sz = getContentSize(self.scrollPro)
    self.scrollHeight = math.max(math.min(6/total*315, 315), 10)
    self.scrollBackHei = 315
    sy = self.scrollHeight/(sz[2]-4)
    setScaleY(self.scrollPro, sy)
    self:setSel(1)
    centerUI(self)
end

function AttributeMenu:setView()
    if self.selPage ~= nil then
        removeSelf(self.selPage)
    end
    if self.selTab == 1 then
        self:initBaseAttView()
    elseif self.selTab == 2 then
        self:initSkillView()
    end
    self:updateTab()
    self.selPanel = nil
    self:setSel(1)
    self.total:setString("基本属性"..self.selTab..'/2')
    if self.scrollPro ~= nil then
        setPos(self.scrollPro, {0, 315})
    end
end


function AttributeMenu:initBaseAttView()
    local sz = {width=1024, height=768}
    local temp = CCNode:create()
    local w = setPos(setAnchor(addChild(temp, ui.newTTFLabel({text="点击查看详情", size=26, color={32, 112, 220}, font="f1"})), {0.00, 0.50}), {462, fixY(sz.height, 627)})
    local w = setPos(setAnchor(addChild(temp, ui.newTTFLabel({text="Lv", size=41, color={248, 181, 81}, font="f2"})), {0.00, 0.50}), {332, fixY(sz.height, 216)})
    local w = setPos(setAnchor(addChild(temp, ui.newTTFLabel({text="劳动", size=26, color={32, 112, 220}, font="f1"})), {0.00, 0.50}), {720, fixY(sz.height, 219)})
    local w = setPos(setAnchor(addChild(temp, ui.newTTFLabel({text="射击", size=26, color={32, 112, 220}, font="f1"})), {0.00, 0.50}), {642, fixY(sz.height, 219)})
    local w = setPos(setAnchor(addChild(temp, ui.newTTFLabel({text="腕力", size=26, color={32, 112, 220}, font="f1"})), {0.00, 0.50}), {564, fixY(sz.height, 219)})
    local w = setPos(setAnchor(addChild(temp, ui.newTTFLabel({text="体力", size=26, color={32, 112, 220}, font="f1"})), {0.00, 0.50}), {484, fixY(sz.height, 219)})
    self.temp:addChild(temp)
    self.selPage = temp
    return temp
end

function AttributeMenu:initSkillView()
    local sz = {width=1024, height=768}
    local temp = CCNode:create()
    local w = setPos(setAnchor(addChild(temp, ui.newTTFLabel({text="让弓箭完全无效化", size=26, color={32, 112, 220}, font="f1"})), {0.50, 0.50}), {557, fixY(sz.height, 627)})
    self.attWord = w
    local w = setPos(setAnchor(addChild(temp, ui.newTTFLabel({text="Lv", size=41, color={248, 181, 81}, font="f2"})), {0.00, 0.50}), {332, fixY(sz.height, 216)})
    local w = setPos(setAnchor(addChild(temp, ui.newTTFLabel({text="习得技能", size=26, color={32, 112, 220}, font="f1"})), {0.00, 0.50}), {676, fixY(sz.height, 219)})
    self.temp:addChild(temp)
    self.selPage = temp
    return temp
end

function AttributeMenu:updateTab()
    removeSelf(self.flowNode)
    self.flowNode = addNode(self.cl)
    setPos(self.flowNode, {0, self.HEIGHT})
    self.flowHeight = 0

	local initX = 0
	local initY = -55
	local offX = 0
	local offY = 52
	self.data = {}
	local sz = {width=546, height=55}
	local rowWidth = 1
	for k, v in ipairs(Logic.farmPeople) do
		local row = math.floor((k-1)/rowWidth)
		local col = (k-1)%rowWidth

        local panel = setPos(addNode(self.flowNode), {initX+col*offX, initY-offY*row})
        panel:setTag(k)
        setContentSize(panel, {sz.width, sz.height})
        local listback = setAnchor(setSize(setPos(addSprite(panel, "listB.png"), {306, fixY(sz.height, 26)}), {479, 52}), {0.50, 0.50})
        
        if self.selTab == 1 then
            local pdata = calAttr(v.id, v.level, v)

            local w = setPos(setAnchor(addChild(panel, ui.newTTFLabel({text=v.level+1, size=26, color={255, 241, 0}, font="f2"})), {0.00, 0.50}), {87, fixY(sz.height, 27)})
            local w1 = setPos(setAnchor(addChild(panel, ui.newTTFLabel({text=pdata.labor, size=24, color={240, 196, 92}, font="f1"})), {0.00, 0.50}), {482, fixY(sz.height, 27)})
            local w2 = setPos(setAnchor(addChild(panel, ui.newTTFLabel({text=pdata.shoot, size=24, color={240, 196, 92}, font="f1"})), {0.00, 0.50}), {408, fixY(sz.height, 26)})
            local w3 = setPos(setAnchor(addChild(panel, ui.newTTFLabel({text=pdata.brawn, size=24, color={240, 196, 92}, font="f1"})), {0.00, 0.50}), {327, fixY(sz.height, 27)})
            local w4 = setPos(setAnchor(addChild(panel, ui.newTTFLabel({text=pdata.health, size=24, color={240, 196, 92}, font="f1"})), {0.00, 0.50}), {253, fixY(sz.height, 26)})
            local w5 = setPos(setAnchor(addChild(panel, ui.newTTFLabel({text=v.data.name, size=24, color={240, 196, 92}, font="f1"})), {0.00, 0.50}), {128, fixY(sz.height, 25)})
            local sp = setAnchor(setPos(addSprite(panel, "catHead"..v.id..".png"), {25, fixY(sz.height, 27)}), {0.50, 0.50})

            table.insert(self.data, {listback, w1, w2, w3, w4, w5})
        else
            local w = setPos(setAnchor(addChild(panel, ui.newTTFLabel({text=v.level+1, size=26, color={255, 241, 0}, font="f2"})), {0.00, 0.50}), {87, fixY(sz.height, 27)})
            local w2 = setPos(setAnchor(addChild(panel, ui.newTTFLabel({text=v.data.skillName, size=24, color={240, 196, 92}, font="f1"})), {0.00, 0.50}), {430, fixY(sz.height, 27)})
            local w1 = setPos(setAnchor(addChild(panel, ui.newTTFLabel({text=v.data.name, size=24, color={240, 196, 92}, font="f1"})), {0.00, 0.50}), {132, fixY(sz.height, 25)})
            local sp = setAnchor(setSize(setPos(addSprite(panel, "goodsIcon.png"), {383, fixY(sz.height, 24)}), {43, 48}), {0.50, 0.50})
            local sp = setAnchor(setPos(addSprite(panel, "catHead"..v.id..".png"), {25, fixY(sz.height, 27)}), {0.50, 0.50})
            table.insert(self.data, {listback, w1, w2})
        end
		self.flowHeight = self.flowHeight+offY
	end
end

function AttributeMenu:setSelect(s)
    if self.selTab ~= nil then
        setTexture(self.tabs[self.selTab].sp, "taba.png")
        self.tabs[self.selTab].bg:setZOrder(-1)
    end
    self.selTab = s
    setTexture(self.tabs[self.selTab].sp, "tabb.png")
    self.tabs[self.selTab].bg:setZOrder(1)
    self:setView(s)
end
function AttributeMenu:onTab(p)
    if self.curSel ~= p then
        self:setSelect(p)
    end
end
function AttributeMenu:onBut(p)
    --self:setSelect(p)
end

function AttributeMenu:touchBegan(x, y)
    self.lastPoints = {x, y}
    self.accMove = 0
    self.curSel = nil
end

function AttributeMenu:moveBack(dify)
    local ox, oy = self.flowNode:getPosition()
    self.flowNode:setPosition(ccp(ox, oy+dify))

    local sxy = getPos(self.scrollPro)
    local total = #self.data
    local ny = math.max(math.min(sxy[2]+-dify*(self.scrollBackHei/self.flowHeight), self.scrollBackHei), self.scrollHeight)
    setPos(self.scrollPro, {sxy[1], ny})
end
function AttributeMenu:touchMoved(x, y)
    local oldPoints = self.lastPoints
    self.lastPoints = {x, y}
    local dify = self.lastPoints[2]-oldPoints[2]
    self.accMove = self.accMove+math.abs(dify)
    self:moveBack(dify)
end

function AttributeMenu:setSel(s)
    if #self.data < s then
        return
    end
    --if self.selPanel ~= s then
        print("self sel", self.selPanel, self.selTab)
        if self.selPanel ~= nil then
            setTexture(self.data[self.selPanel][1], "listB.png")
            local word = self.data[self.selPanel] 
            print("word", #word)
            if self.selTab == 1 then
                setColor(word[2], {240, 196, 92})
                setColor(word[3], {240, 196, 92})
                setColor(word[4], {240, 196, 92})
                setColor(word[5], {240, 196, 92})
                setColor(word[6], {240, 196, 92})
            elseif self.selTab == 2 then
                setColor(word[2], {240, 196, 92})
                setColor(word[3], {240, 196, 92})
            end
        end
        self.selPanel = s
        setTexture(self.data[self.selPanel][1], "listA.png")
        local word = self.data[self.selPanel] 
        if self.selTab == 1 then
            print("selTab", self.selTab)
            setColor(word[2], {255, 255, 255})
            setColor(word[3], {255, 255, 255})
            setColor(word[4], {255, 255, 255})
            setColor(word[5], {255, 255, 255})
            setColor(word[6], {255, 255, 255})
        elseif self.selTab == 2 then
            setColor(word[2], {255, 255, 255})
            setColor(word[3], {255, 255, 255})
            local fp = Logic.farmPeople[self.selPanel].data.skill
            print("skill Num is", skill)
            --print(simple.encode(Logic.skill))
            self.attWord:setString(Logic.skill[fp].attribute)
        end
    --end
end

function AttributeMenu:touchEnded(x, y)
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
                global.director:pushView(PeopleInfo.new(self.selPanel, true), 1)
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
    print("flowHeight ", self.flowHeight, self.minPos, self.HEIGHT, oldPos[2])
end
function AttributeMenu:refreshData()
    self:updateTab()
    self:setSel(self.selPanel)
end
