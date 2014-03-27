require "menu.PeopleInfo2"
AttributeMenu2 = class()
function AttributeMenu2:ctor()
    print("AttributeMenu2")
    local vs = getVS()
    self.bg = CCNode:create()
    local sz = {width=1024, height=768}
    self.temp = setPos(addNode(self.bg), {-13.5, fixY(sz.height, 0+sz.height)+4.0})
    local sp = setAnchor(setSize(setPos(addSprite(self.temp, "dialogA.png"), {525, fixY(sz.height, 388)}), {693, 588}), {0.50, 0.50})
    local sp = setAnchor(setSize(setPos(addSprite(self.temp, "dialogB.png"), {523, fixY(sz.height, 423)}), {626, 358}), {0.50, 0.50})
    local sp = setAnchor(setSize(setPos(addSprite(self.temp, "basicAtt.png"), {531, fixY(sz.height, 148)}), {212, 42}), {0.50, 0.50})

    local but = ui.newButton({image="newClose.png", text="", font="f1", size=18, delegate=self, callback=self.onClose, param=self.onClose, shadowColor={0, 0, 0}, color={255, 255, 255}})
    but:setContentSize(80, 82)
    setPos(addChild(self.temp, but.bg), {848, fixY(sz.height, 112)})
    
    local but = ui.newButton({image="atttab.png", text="", font="f1", size=18, delegate=self, callback=self.onBut, param=2, shadowColor={0, 0, 0}, color={255, 255, 255},touchBegan=self.onTab, needScale=false })
    but:setContentSize(101, 127)
    setPos(addChild(self.temp, but.bg), {915, fixY(sz.height, 401)})
    self.skillAtt = but
    local sp = setAnchor(addSprite(but.bg, "skillIcon.png"), {0.50, 0.50})
    local sp = setOpacity(setAnchor(addSprite(but.bg, "atttabdark.png"), {0.50, 0.50}), 128)
    but.attDark = sp

    local but = ui.newButton({image="atttab.png", text="", font="f1", size=18, delegate=self, callback=self.onBut, param=1,  shadowColor={0, 0, 0}, color={255, 255, 255}, touchBegan=self.onTab, needScale=false})
    but:setContentSize(101, 127)
    setPos(addChild(self.temp, but.bg), {916, fixY(sz.height, 252)})
    self.baseAtt = but
    local sp = setAnchor(addSprite(but.bg, "attIcon.png"), {0.50, 0.50})
    local sp = setOpacity(setAnchor(addSprite(but.bg, "atttabdark.png"), {0.50, 0.50}), 128)
    setVisible(sp, false)
    but.attDark = sp
    self.tabs = {self.baseAtt, self.skillAtt}

    self.scrollPro = createScroll(self.temp, sz)

    local listSize = {width=544, height=319}
    self.listSize = listSize
    self.HEIGHT = 319
    self.cl = Scissor:create()
    self.temp:addChild(self.cl)
    setPos(self.cl, {230, fixY(sz.height, 263+listSize.height)})
    setContentSize(self.cl, {listSize.width, listSize.height})
    self.flowNode = addNode(self.cl)
    setPos(self.flowNode, {0, self.HEIGHT})
    self.touch = ui.newTouchLayer({size={listSize.width, self.HEIGHT}, delegate=self, touchBegan=self.touchBegan, touchMoved=self.touchMoved, touchEnded=self.touchEnded})
    self.cl:addChild(self.touch.bg)
    setPos(self.touch.bg, {0, 0})
    self.flowHeight = 0
    --self:updateTab()
    self:setSelect(1)
    --self:setSel(1)

    centerUI(self)
end
--禁止缩放
function AttributeMenu2:onTab(p)
end
function createScroll(temp, sz)
    local myscroll = {}
    local ssz = {width=35, height=327, maxY = 304, minY=28, totalHeight=304-28}
    local banner = setAnchor(setSize(setPos(addSprite(temp, "scrollBack.png"), {806, fixY(sz.height, 423)}), {35, 327}), {0.50, 0.50})
    local sp = setAnchor(setSize(setPos(addSprite(banner, "scrollPro.png"), {ssz.width/2, fixY(ssz.height, 28)}), {49, 45}), {0.50, 0.50})
    myscroll.ssz = ssz
    myscroll.banner = banner
    myscroll.scrollPro = sp
    function myscroll:moveScroll(rate)
        print("moveScroll", rate)
        setPos(self.scrollPro, {ssz.width/2, fixY(ssz.height, lerp(28, 304, math.min(math.max(0, rate), 1)))})
    end
    function myscroll:resetScroll()
        setPos(self.scrollPro, {ssz.width/2, fixY(ssz.height, 28)})
    end
    return myscroll
end

function AttributeMenu2:setView()
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
    --self.total:setString("基本属性"..self.selTab..'/2')
    if self.scrollPro ~= nil then
        --setPos(self.scrollPro, {0, 315})
        self.scrollPro:resetScroll()
    end
end

function AttributeMenu2:initBaseAttView()
    local sz = {width=1024, height=768}
    local temp = CCNode:create()
    --[[
    local w = setPos(setAnchor(addChild(temp, ui.newTTFLabel({text="点击查看详情", size=26, color={32, 112, 220}, font="f1"})), {0.00, 0.50}), {462, fixY(sz.height, 627)})
    local w = setPos(setAnchor(addChild(temp, ui.newTTFLabel({text="Lv", size=41, color={248, 181, 81}, font="f2"})), {0.00, 0.50}), {332, fixY(sz.height, 216)})
    local w = setPos(setAnchor(addChild(temp, ui.newTTFLabel({text="劳动", size=26, color={32, 112, 220}, font="f1"})), {0.00, 0.50}), {720, fixY(sz.height, 219)})
    local w = setPos(setAnchor(addChild(temp, ui.newTTFLabel({text="射击", size=26, color={32, 112, 220}, font="f1"})), {0.00, 0.50}), {642, fixY(sz.height, 219)})
    local w = setPos(setAnchor(addChild(temp, ui.newTTFLabel({text="腕力", size=26, color={32, 112, 220}, font="f1"})), {0.00, 0.50}), {564, fixY(sz.height, 219)})
    local w = setPos(setAnchor(addChild(temp, ui.newTTFLabel({text="体力", size=26, color={32, 112, 220}, font="f1"})), {0.00, 0.50}), {484, fixY(sz.height, 219)})
    --]]

    local w = setPos(setAnchor(addChild(temp, ui.newTTFLabel({text="点击查看详情", size=26, color={32, 112, 220}, font="f2", shadowColor={255, 255, 255}})), {0.50, 0.50}), {528, fixY(sz.height, 625)})
    local w = setPos(setAnchor(addChild(temp, ui.newTTFLabel({text="劳动", size=26, color={32, 112, 220}, font="f2", shadowColor={255, 255, 255}})), {0.00, 0.50}), {711, fixY(sz.height, 215)})
    local w = setPos(setAnchor(addChild(temp, ui.newTTFLabel({text="射击", size=26, color={32, 112, 220}, font="f2", shadowColor={255, 255, 255}})), {0.00, 0.50}), {623, fixY(sz.height, 215)})
    local w = setPos(setAnchor(addChild(temp, ui.newTTFLabel({text="脑力", size=26, color={32, 112, 220}, font="f2", shadowColor={255, 255, 255}})), {0.00, 0.50}), {535, fixY(sz.height, 215)})
    local w = setPos(setAnchor(addChild(temp, ui.newTTFLabel({text="体力", size=26, color={32, 112, 220}, font="f2", shadowColor={255, 255, 255}})), {0.00, 0.50}), {446, fixY(sz.height, 215)})
    local sp = setAnchor(setSize(setPos(addSprite(temp, "lvpng.png"), {339, fixY(sz.height, 216)}), {49, 43}), {0.50, 0.50})


    self.temp:addChild(temp)
    self.selPage = temp
    return temp
end

function AttributeMenu2:initSkillView()
    local sz = {width=1024, height=768}
    local temp = CCNode:create()
    local w = setPos(setAnchor(addChild(temp, ui.newTTFLabel({text="让弓箭完全无效化", size=26, color={32, 112, 220}, font="f2", shadowColor={255, 255, 255}})), {0.50, 0.50}), {528, fixY(sz.height, 625)})
    self.attWord = w
    local sp = setAnchor(setSize(setPos(addSprite(temp, "lvpng.png"), {339, fixY(sz.height, 216)}), {49, 43}), {0.50, 0.50})
    local w = setPos(setAnchor(addChild(temp, ui.newTTFLabel({text="习得技能", size=26, color={32, 112, 220}, font="f2", shadowColor={255, 255, 255}})), {1.00, 0.50}), {757, fixY(sz.height, 215)})
    self.temp:addChild(temp)
    self.selPage = temp
    return temp
end

function AttributeMenu2:updateTab()
    removeSelf(self.flowNode)
    self.flowNode = addNode(self.cl)
    setPos(self.flowNode, {0, self.HEIGHT})
    self.flowHeight = 0

	local initX = 0
	local initY = -60
	local offX = 0
	local offY = 52
	self.data = {}
	local sz = {width=546, height=55}
	local rowWidth = 1
	for k, v in ipairs(Logic.farmPeople) do
		local row = math.floor((k-1)/rowWidth)
		local col = (k-1)%rowWidth

        local panel = setPos(addNode(self.flowNode), {initX+col*offX, initY-offY*row})
        local listback = setAnchor(setSize(setPos(addSprite(panel, "listB.png"), {306, fixY(sz.height, 26)}), {479, 52}), {0.50, 0.50})
        if self.selTab == 1 then
            local pdata = calAttr(v.id, v.level, v)
            local head = setAnchor(setSize(setPos(addSprite(panel, "headBoard.png"), {28, fixY(sz.height, 26)}), {57, 52}), {0.50, 0.50})
            local sp = setAnchor(setPos(addSprite(head, "catHead"..v.id..".png"), {28, 26}), {0.50, 0.50})

            local w0 = setPos(setAnchor(addChild(panel, ui.newTTFLabel({text=v.level+1, size=26, color={255, 241, 0}, font="f2", shadowColor={0, 0, 0}})), {0.00, 0.50}), {90, fixY(sz.height, 25)})
            local w1 = setPos(setAnchor(addChild(panel, ui.newTTFLabel({text=v.data.name, size=24, color={240, 196, 92}, font="f1", shadowColor={0, 0, 0}})), {0.00, 0.50}), {131, fixY(sz.height, 24)})
            local w2 = setPos(setAnchor(addChild(panel, ui.newTTFLabel({text=pdata.health, size=24, color={240, 196, 92}, font="f1", shadowColor={0, 0, 0}})), {0.00, 0.50}), {229, fixY(sz.height, 24)})
            local w3 = setPos(setAnchor(addChild(panel, ui.newTTFLabel({text=pdata.brawn, size=24, color={240, 196, 92}, font="f1", shadowColor={0, 0, 0}})), {0.00, 0.50}), {317, fixY(sz.height, 24)})
            local w4 = setPos(setAnchor(addChild(panel, ui.newTTFLabel({text=pdata.shoot, size=24, color={240, 196, 92}, font="f1", shadowColor={0, 0, 0}})), {0.00, 0.50}), {404, fixY(sz.height, 24)})
            local w5 = setPos(setAnchor(addChild(panel, ui.newTTFLabel({text=pdata.labor, size=24, color={240, 196, 92}, font="f1", shadowColor={0, 0, 0}})), {0.00, 0.50}), {491, fixY(sz.height, 24)})

            table.insert(self.data, {listback, w0, w1, w2, w3, w4, w5})
        else
            local w1 = setPos(setAnchor(addChild(panel, ui.newTTFLabel({text=v.level+1, size=26, color={255, 241, 0}, font="f2", shadowColor={0, 0, 0}})), {0.00, 0.50}), {92, fixY(sz.height, 25)})
            local w2 = setPos(setAnchor(addChild(panel, ui.newTTFLabel({text=v.data.name, size=24, color={240, 196, 92}, font="f1", shadowColor={0, 0, 0}})), {0.00, 0.50}), {133, fixY(sz.height, 24)})
            local w3 = setPos(setAnchor(addChild(panel, ui.newTTFLabel({text=v.data.skillName, size=24, color={240, 196, 92}, font="f1", shadowColor={0, 0, 0}})), {1.00, 0.50}), {531, fixY(sz.height, 24)})

            local head = setAnchor(setSize(setPos(addSprite(panel, "headBoard.png"), {28, fixY(sz.height, 26)}), {57, 52}), {0.50, 0.50})
            local sp = setAnchor(setPos(addSprite(head, "catHead"..v.id..".png"), {28, 26}), {0.50, 0.50})

            local sid = getPeopleSkill(v.id, v.level)
            if sid == 0 then
                w3:setString('')
            else
                local sdata = Logic.allSkill[sid]
                local skillBoard = setAnchor(setPos(addSprite(panel, "skillBoard.png"), {385, fixY(sz.height, 24)}), {76/128, (128-66)/128})

                if sdata.hasLevel > 0 then
                    local sp = setAnchor(setPos(addSprite(skillBoard, "skill"..(sid-(sdata.hasLevel-1))..".png"), {76, 128-66}), {76/128, 66/128})
                    local w = setPos(setAnchor(addChild(panel, ui.newBMFontLabel({text=sdata.hasLevel, size=17, color={255, 255, 255}, font="fonts.fnt", shadowColor={0, 0, 0}})), {0.00, 0.50}), {363, fixY(sz.height, 39)})
                else
                    local sp = setAnchor(setPos(addSprite(skillBoard, "skill"..sid..".png"), {76, 66}), {76/128, (128-66)/128})
                end
                w3:setString(sdata.name)
            end
            table.insert(self.data, {listback, w1, w2, w3})
        end
        panel:setTag(k)
        setContentSize(panel, {sz.width, sz.height})


		self.flowHeight = self.flowHeight+offY
	end
end

function AttributeMenu2:setSelect(s)
    if self.selTab ~= nil then
        --setTexture(self.tabs[self.selTab].sp, "taba.png")
        setVisible(self.tabs[self.selTab].attDark, true)
        self.tabs[self.selTab].bg:setZOrder(-1)
    end
    self.selTab = s
    --setTexture(self.tabs[self.selTab].sp, "tabb.png")
    setVisible(self.tabs[self.selTab].attDark, false)
    self.tabs[self.selTab].bg:setZOrder(1)
    self:setView(s)
end
function AttributeMenu2:onTab(p)
    if self.curSel ~= p then
        self:setSelect(p)
    end
end
function AttributeMenu2:onBut(p)
    --self:setSelect(p)
end

function AttributeMenu2:touchBegan(x, y)
    self.lastPoints = {x, y}
    self.accMove = 0
    self.curSel = nil
end

function AttributeMenu2:moveBack(dify)
    local ox, oy = self.flowNode:getPosition()
    self.flowNode:setPosition(ccp(ox, oy+dify))

    --self.scrollPro:moveScroll()
    if self.flowHeight < self.HEIGHT then
    else
        local dx = self.flowHeight-self.HEIGHT
        print("moveBack", oy, dify, dx)
        self.scrollPro:moveScroll((oy+dify-self.HEIGHT)/dx)
    end
end
function AttributeMenu2:touchMoved(x, y)
    local oldPoints = self.lastPoints
    self.lastPoints = {x, y}
    local dify = self.lastPoints[2]-oldPoints[2]
    self.accMove = self.accMove+math.abs(dify)
    self:moveBack(dify)
end

function AttributeMenu2:setSel(s)
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
                setColor(word[2], {255, 241, 0})
                setColor(word[3], {240, 196, 92})
                setColor(word[4], {240, 196, 92})
                setColor(word[5], {240, 196, 92})
                setColor(word[6], {240, 196, 92})
                setColor(word[7], {240, 196, 92})
            elseif self.selTab == 2 then
                setColor(word[2], {255, 241, 0})
                setColor(word[3], {240, 196, 92})
                setColor(word[4], {240, 196, 92})
            end
        end
        self.selPanel = s
        setTexture(self.data[self.selPanel][1], "listA.png")
        local word = self.data[self.selPanel] 
        if self.selTab == 1 then
            print("selTab", self.selTab)
            setColor(word[2], {40, 172, 255})
            setColor(word[3], {206, 78, 0})
            setColor(word[4], {206, 78, 0})
            setColor(word[5], {206, 78, 0})
            setColor(word[6], {206, 78, 0})
            setColor(word[7], {206, 78, 0})
        elseif self.selTab == 2 then
            setColor(word[2], {40, 172, 255})
            setColor(word[3], {206, 78, 0})
            setColor(word[4], {206, 78, 0})
            
            local pdata = Logic.farmPeople[self.selPanel]
            local sid = getPeopleSkill(pdata.id, pdata.level)
            if sid == 0 then
                self.attWord:setString('')
            else
                local sdata = Logic.skill[sid]
                self.attWord:setString(sdata.attribute)
            end

        end
    --end
end

function AttributeMenu2:touchEnded(x, y)
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
                global.director:pushView(PeopleInfo2.new(self.selPanel, true), 1)
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
function AttributeMenu2:refreshData()
    self:updateTab()
    self:setSel(self.selPanel)
end
function AttributeMenu2:onClose()
    global.director:popView()
end
