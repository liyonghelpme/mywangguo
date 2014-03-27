require "menu.EquipChangeMenu2"
EquipMenu3 = class()
function EquipMenu3:ctor()
    local vs = getVS()
    self.bg = CCNode:create()
    local sz = {width=1024, height=768}
    self.temp = setPos(addNode(self.bg), {-13.5, fixY(sz.height, 0+sz.height)+4.0})
    local sp = setOpacity(setAnchor(setSize(setPos(addSprite(self.temp, "dialogA.png"), {525, fixY(sz.height, 388)}), {693, 588}), {0.50, 0.50}), 255)
    local sp = setOpacity(setAnchor(setSize(setPos(addSprite(self.temp, "dialogB.png"), {523, fixY(sz.height, 423)}), {626, 358}), {0.50, 0.50}), 255)
    local but = ui.newButton({image="newClose.png", text="", font="f1", size=18, delegate=self, callback=closeDialog, shadowColor={0, 0, 0}, color={255, 255, 255}})
    but:setContentSize(80, 82)
    setPos(addChild(self.temp, but.bg), {848, fixY(sz.height, 112)})
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="点击查看详情", size=26, color={32, 112, 220}, font="f2", shadowColor={255, 255, 255}})), {0.50, 0.50}), {512, fixY(sz.height, 625)})
    self.desWord = w
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="特", size=26, color={32, 112, 220}, font="f2", shadowColor={255, 255, 255}})), {0.00, 0.50}), {736, fixY(sz.height, 215)})
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="体", size=26, color={32, 112, 220}, font="f2", shadowColor={255, 255, 255}})), {0.00, 0.50}), {685, fixY(sz.height, 215)})
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="头", size=26, color={32, 112, 220}, font="f2", shadowColor={255, 255, 255}})), {0.00, 0.50}), {639, fixY(sz.height, 215)})
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="武", size=26, color={32, 112, 220}, font="f2", shadowColor={255, 255, 255}})), {0.00, 0.50}), {591, fixY(sz.height, 215)})
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="防", size=26, color={32, 112, 220}, font="f2", shadowColor={255, 255, 255}})), {0.00, 0.50}), {523, fixY(sz.height, 215)})
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="攻", size=26, color={32, 112, 220}, font="f2", shadowColor={255, 255, 255}})), {0.00, 0.50}), {458, fixY(sz.height, 215)})
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="体", size=26, color={32, 112, 220}, font="f2", shadowColor={255, 255, 255}})), {0.00, 0.50}), {394, fixY(sz.height, 215)})
    local sp = setOpacity(setAnchor(setSize(setPos(addSprite(self.temp, "lvpng.png"), {339, fixY(sz.height, 216)}), {49, 43}), {0.50, 0.50}), 255)
    local sp = setOpacity(setAnchor(setSize(setPos(addSprite(self.temp, "equipTitle.png"), {529, fixY(sz.height, 148)}), {97, 42}), {0.50, 0.50}), 255)

    local listSize = {width=546, height=304}
    self.listSize = listSize
    self.HEIGHT = 304
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

    self.scrollPro = createScroll(self.temp, sz)
    centerUI(self)
end

function EquipMenu3:setSel(s)
    if #self.data < s then
        return
    end
    --if self.selPanel ~= s then
        if self.selPanel ~= nil then
            setTexture(self.data[self.selPanel][1], "listB.png")
            local word = self.data[self.selPanel] 
            setColor(word.w1, {255, 241, 0})
            setColor(word[3], {240, 196, 92})
            setColor(word[4], {240, 196, 92})
            setColor(word[5], {240, 196, 92})
        end
        self.selPanel = s
        setTexture(self.data[self.selPanel][1], "listA.png")
        local word = self.data[self.selPanel] 
        setColor(word.w1, {40, 172, 255})
        setColor(word[3], {206, 78, 0})
        setColor(word[4], {206, 78, 0})
        setColor(word[5], {206, 78, 0})
        local pdata = self.data[self.selPanel].pdata
        local bi = self.data[self.selPanel].baseInfo
        self.desWord:setString(bi.name.." ".."腕力 "..pdata.brawn.." 射击 "..pdata.shoot)
    --end
end
function EquipMenu3:updateTab()
    removeSelf(self.flowNode)
    self.flowNode = addNode(self.cl)
    setPos(self.flowNode, {0, self.HEIGHT})
    self.flowHeight = 0

	local initX = 0
	local initY = -60
	local offX = 0
	local offY = 55
	self.data = {}
    local sz = {width=546, height=61}
	local rowWidth = 1
	for k, v in ipairs(Logic.farmPeople) do
		local row = math.floor((k-1)/rowWidth)
		local col = (k-1)%rowWidth
        --考虑装备属性 
        local pdata = calAttr(v.id, v.level, v)
        local panel = setPos(addNode(self.flowNode), {initX+col*offX, initY-offY*row})
        local list = setOpacity(setAnchor(setSize(setPos(addSprite(panel, "listB.png"), {306, fixY(sz.height, 30)}), {479, 52}), {0.50, 0.50}), 255)
        local w1 = setPos(setAnchor(addChild(panel, ui.newTTFLabel({text=v.level+1, size=26, color={255, 241, 0}, font="f2", shadowColor={255, 255, 255}})), {0.00, 0.50}), {102, fixY(sz.height, 29)})
        local w2 = setPos(setAnchor(addChild(panel, ui.newTTFLabel({text=pdata.health, size=24, color={240, 196, 92}, font="f2", shadowColor={255, 255, 255}})), {0.00, 0.50}), {166, fixY(sz.height, 28)})
        local w3 = setPos(setAnchor(addChild(panel, ui.newTTFLabel({text=pdata.attack, size=24, color={240, 196, 92}, font="f2", shadowColor={255, 255, 255}})), {0.00, 0.50}), {228, fixY(sz.height, 28)})
        local w4 = setPos(setAnchor(addChild(panel, ui.newTTFLabel({text=pdata.defense, size=24, color={240, 196, 92}, font="f2", shadowColor={255, 255, 255}})), {0.00, 0.50}), {293, fixY(sz.height, 28)})
        local sp = setOpacity(setAnchor(setSize(setPos(addSprite(panel, "headBoard.png"), {28, fixY(sz.height, 30)}), {57, 52}), {0.50, 0.50}), 255)
        local sp = setOpacity(setAnchor(setSize(setPos(addSprite(panel, "catHead"..v.id..".png"), {28, fixY(sz.height, 28)}), {52, 45}), {0.50, 0.50}), 255)
        local sp4 = setOpacity(setAnchor(setSize(setPos(addSprite(panel, "speIcon.png"), {518, fixY(sz.height, 29)}), {55, 58}), {0.50, 0.50}), 255)
        local sp3 = setOpacity(setAnchor(setSize(setPos(addSprite(panel, "bodyIcon.png"), {471, fixY(sz.height, 29)}), {59, 58}), {0.50, 0.50}), 255)
        local sp2 = setOpacity(setAnchor(setSize(setPos(addSprite(panel, "topIcon.png"), {421, fixY(sz.height, 32)}), {60, 57}), {0.50, 0.50}), 255)
        local sp1 = setOpacity(setAnchor(setSize(setPos(addSprite(panel, "weaponIcon.png"), {375, fixY(sz.height, 31)}), {54, 54}), {0.50, 0.50}), 255)
        sp1.id = 1
        sp2.id = 2
        sp3.id = 3
        sp4.id = 4

        if v.weapon then
            local sp = setAnchor(setPos(addSprite(sp1, "equip"..v.weapon..".png"), {28, 28}), {0.50, 0.50})
        end

        if v.head then
            local sp = setAnchor(setPos(addSprite(sp2, "equip"..v.head..".png"), {28, 28}), {0.50, 0.50})
        end

        if v.body then
            local sp = setAnchor(setPos(addSprite(sp3, "equip"..v.body..".png"), {28, 28}), {0.50, 0.50})
        end

        if v.spe then
            local sp = setAnchor(setPos(addSprite(sp4, "equip"..v.spe..".png"), {28, 28}), {0.50, 0.50})
        end
        panel:setTag(k)
        setContentSize(panel, {sz.width, sz.height})

		table.insert(self.data, {list, true, w2, w3, w4, sp1, sp2, sp3, sp4, w1=w1, pdata=pdata, baseInfo=v.data})
        self.flowHeight = self.flowHeight+offY
	end
end

function EquipMenu3:touchBegan(x, y)
    self.lastPoints = {x, y}
    self.accMove = 0
    self.curSel = nil
end

function EquipMenu3:moveBack(dify)
    adjustFlow(self, dify)
end
function EquipMenu3:touchMoved(x, y)
    local oldPoints = self.lastPoints
    self.lastPoints = {x, y}
    local dify = self.lastPoints[2]-oldPoints[2]
    self.accMove = self.accMove+math.abs(dify)
    self:moveBack(dify)
end


function checkInPanel(bg, pos)
    local sub = bg:getChildren()
    local count = bg:getChildrenCount()
    for i=0, count-1, 1 do
        local child = tolua.cast(sub:objectAtIndex(i), 'CCNode')
        local np = child:convertToNodeSpace(ccp(pos[1], pos[2]))
        --print("child is what", np.x, np.y, simple.encode(getContentSize(child)))
        if child.id ~= nil and checkIn(np.x, np.y, child:getContentSize()) then
            print('child', child:getTag(), child.id)
            return child
        end
    end
    return nil
end
function EquipMenu3:touchEnded(x, y)
    local newPos = {x, y}
    if self.accMove < 10 then
        local child = checkInChild(self.flowNode, newPos)
        if child ~= nil then
            print("touch child", child:getTag())
            local t = child:getTag()
            if self.selPanel ~= t then
                self:setSel(t)
            else
                local icon = checkInPanel(child, newPos)
                local sdata = self.data[self.selPanel]
                if icon ~= nil then
                    print("sdata is what", sdata)
                    for i=6, 9, 1 do
                        print("icon is ", icon.id, sdata[i].id)
                        if sdata[i].id == icon.id then
                            --global.director:popView()
                            global.director:pushView(EquipChangeMenu2.new(Logic.farmPeople[self.selPanel], icon.id), 1)
                            --return
                            break
                        end
                    end
                else
                    global.director:pushView(EquipChangeMenu2.new(Logic.farmPeople[self.selPanel], 1), 1)
                end
                --global.director:popView()
                --global.director:pushView(PeopleInfo.new(self.selPanel), 1)
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
--keep Select keep View 保证选择 保证view
function EquipMenu3:refreshData()
    self:updateTab()
    self:setSel(self.selPanel)
end

