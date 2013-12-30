require "menu.EquipChangeMenu"
EquipMenu2 = class()
function EquipMenu2:ctor()
    local vs = getVS()
    self.bg = CCNode:create()
    local sz = {width=1024, height=768}
    self.temp = setPos(addNode(self.bg), {-30.5, 38})
    local sp = setAnchor(setPos(addSprite(self.temp, "dialogA.png"), {543, fixY(sz.height, 422)}), {0.50, 0.50})
    local sp = setAnchor(setSize(setPos(addSprite(self.temp, "dialogB.png"), {540, fixY(sz.height, 456)}), {617, 352}), {0.50, 0.50})
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="Lv", size=41, color={248, 181, 81}, font="f2"})), {0.00, 0.50}), {336, fixY(sz.height, 252)})
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="防", size=25, color={32, 112, 220}, font="f1"})), {0.00, 0.50}), {542, fixY(sz.height, 253)})
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="体", size=25, color={32, 112, 220}, font="f1"})), {0.00, 0.50}), {413, fixY(sz.height, 254)})
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="武", size=25, color={32, 112, 220}, font="f1"})), {0.00, 0.50}), {605, fixY(sz.height, 254)})
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="攻", size=25, color={32, 112, 220}, font="f1"})), {0.00, 0.50}), {478, fixY(sz.height, 254)})
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="特", size=25, color={32, 112, 220}, font="f1"})), {0.00, 0.50}), {763, fixY(sz.height, 255)})
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="体", size=25, color={32, 112, 220}, font="f1"})), {0.00, 0.50}), {711, fixY(sz.height, 254)})
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="头", size=25, color={32, 112, 220}, font="f1"})), {0.00, 0.50}), {657, fixY(sz.height, 255)})
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="装备", size=34, color={102, 66, 42}, font="f1"})), {0.50, 0.50}), {542, fixY(sz.height, 187)})
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="点击查看详情", size=26, color={32, 112, 220}, font="f1"})), {0.50, 0.50}), {551, fixY(sz.height, 657)})



    local listSize = {width=551, height=325}
    self.listSize = listSize
    self.HEIGHT = 325
    self.cl = Scissor:create()
    self.temp:addChild(self.cl)
    setPos(self.cl, {250, fixY(sz.height, 297+listSize.height)})
    setContentSize(self.cl, {listSize.width, listSize.height})
    self.flowNode = addNode(self.cl)
    setPos(self.flowNode, {0, self.HEIGHT})
    self.touch = ui.newTouchLayer({size={listSize.width, self.HEIGHT}, delegate=self, touchBegan=self.touchBegan, touchMoved=self.touchMoved, touchEnded=self.touchEnded})
    self.cl:addChild(self.touch.bg)
    setPos(self.touch.bg, {0, 0})
    self.flowHeight = 0
    self:updateTab()

    self:setSel(1)

    local sp = setAnchor(setSize(setPos(addSprite(self.temp, "scrollBack.png"), {821, fixY(sz.height, 454)}), {15, 315}), {0.50, 0.50})
    local pro = setAnchor(setSize(setPos(addSprite(sp, "scrollPro.png"), {0, fixY(315, 0)}), {17, 157}), {0.0, 1})
    self.scrollPro = pro

    local total = #self.data
    local sz = getContentSize(self.scrollPro)
    self.scrollHeight = math.max(math.min(6/total*315, 315), 10)
    sy = self.scrollHeight/(sz[2]-4)
    setScaleY(self.scrollPro, sy)
    centerUI(self)
end

function EquipMenu2:setSel(s)
    if self.selPanel ~= s then
        if self.selPanel ~= nil then
            setTexture(self.data[self.selPanel][1], "listB.png")
            local word = self.data[self.selPanel] 
            setColor(word[3], {240, 196, 92})
            setColor(word[4], {240, 196, 92})
            setColor(word[5], {240, 196, 92})
        end
        self.selPanel = s
        setTexture(self.data[self.selPanel][1], "listA.png")
        local word = self.data[self.selPanel] 
        setColor(word[3], {255, 255, 255})
        setColor(word[4], {255, 255, 255})
        setColor(word[5], {255, 255, 255})
    end
end
function EquipMenu2:updateTab()
	local initX = 0
	local initY = -60
	local offX = 0
	local offY = 55
	self.data = {}
	local sz = {width=551, height=61}
	--local test = {1, 1, 1, 1, 1, 1, 1}
	local rowWidth = 1
	for k, v in ipairs(Logic.farmPeople) do
		local row = math.floor((k-1)/rowWidth)
		local col = (k-1)%rowWidth
        --[[
		local sp = CCSprite:create("listB.png")
		self.flowNode:addChild(sp)
		setAnchor(setPos(sp, {initX+col*offX, initY-offY*row}), {0, 0})
		sp:setTag(k)
        --]]

        local panel = setPos(addNode(self.flowNode), {initX+col*offX, initY-offY*row})
        panel:setTag(k)
        setContentSize(panel, {sz.width, sz.height})

        local sp = setAnchor(setSize(setPos(addSprite(panel, "listB.png"), {193, fixY(sz.height, 29)}), {263, 52}), {0.50, 0.50})
        local list = sp
        local sp = setAnchor(setSize(setPos(addSprite(panel, "headIcon.png"), {25, fixY(sz.height, 30)}), {50, 55}), {0.50, 0.50})

        --装备的属性
        local pdata = calAttr(v.id, v.level)
        local w = setPos(setAnchor(addChild(panel, ui.newTTFLabel({text=v.level+1, size=26, color={255, 241, 0}, font="f2"})), {0.00, 0.50}), {83, fixY(sz.height, 30)})
        local w1 = w
        local w = setPos(setAnchor(addChild(panel, ui.newTTFLabel({text=pdata.health, size=24, color={240, 196, 192}, font="f1"})), {0.00, 0.50}), {162, fixY(sz.height, 29)})
        local w2 = w
        local w = setPos(setAnchor(addChild(panel, ui.newTTFLabel({text=pdata.attack, size=24, color={240, 196, 192}, font="f1"})), {0.00, 0.50}), {226, fixY(sz.height, 30)})
        local w3 = w
        local w = setPos(setAnchor(addChild(panel, ui.newTTFLabel({text=pdata.defense, size=24, color={240, 196, 192}, font="f1"})), {0.00, 0.50}), {288, fixY(sz.height, 29)})
        local w4 = w

        --装备的图片
        local spe = setAnchor(setSize(setPos(addSprite(panel, "speIcon.png"), {523, fixY(sz.height, 29)}), {55, 58}), {0.50, 0.50})
        local body = setAnchor(setSize(setPos(addSprite(panel, "bodyIcon.png"), {472, fixY(sz.height, 29)}), {59, 58}), {0.50, 0.50})
        local top = setAnchor(setSize(setPos(addSprite(panel, "topIcon.png"), {418, fixY(sz.height, 32)}), {60, 57}), {0.50, 0.50})
        local weapon = setAnchor(setSize(setPos(addSprite(panel, "weaponIcon.png"), {368, fixY(sz.height, 31)}), {54, 54}), {0.50, 0.50})

        if v.weapon then
            local sp = setAnchor(setSize(setPos(addSprite(panel, "equip"..v.weapon..".png"), {365, fixY(sz.height, 26)}), {48, 53}), {0.50, 0.50})
        end

        if v.head then
            local sp = setAnchor(setSize(setPos(addSprite(panel, "equip"..v.head..".png"), {418, fixY(sz.height, 26)}), {48, 53}), {0.50, 0.50})
        end

        if v.body then
            local sp = setAnchor(setSize(setPos(addSprite(panel, "equip"..v.body..".png"), {472, fixY(sz.height, 26)}), {48, 53}), {0.50, 0.50})
        end

        if v.spe then
            local sp = setAnchor(setSize(setPos(addSprite(panel, "equip"..v.spe..".png"), {523, fixY(sz.height, 26)}), {48, 53}), {0.50, 0.50})
        end

		table.insert(self.data, {list, true, w2, w3, w4, weapon, top, body, spe})
        self.flowHeight = self.flowHeight+offY
	end
end

function EquipMenu2:touchBegan(x, y)
    self.lastPoints = {x, y}
    self.accMove = 0
    self.curSel = nil
end

function EquipMenu2:moveBack(dify)
    local ox, oy = self.flowNode:getPosition()
    self.flowNode:setPosition(ccp(ox, oy+dify))

    local sxy = getPos(self.scrollPro)
    local total = #self.data
    local ny = math.max(math.min(sxy[2]+-dify*(315/self.flowHeight), 315), self.scrollHeight)
    --print("scroll", ny, total, (315*(6/total)))
    setPos(self.scrollPro, {sxy[1], ny})
end
function EquipMenu2:touchMoved(x, y)
    local oldPoints = self.lastPoints
    self.lastPoints = {x, y}
    local dify = self.lastPoints[2]-oldPoints[2]
    self.accMove = self.accMove+math.abs(dify)
    self:moveBack(dify)
end


function EquipMenu2:touchEnded(x, y)
    local newPos = {x, y}
    if self.accMove < 10 then
        local child = checkInChild(self.flowNode, newPos)
        if child ~= nil then
            print("touch child", child:getTag())
            local t = child:getTag()
            if self.selPanel ~= t then
                self:setSel(t)
            else
                local icon = checkInChild(child, newPos)
                local sdata = self.data[self.selPanel]
                for i=6, 9, 1 do
                    if sdata[i] == icon then
                        --global.director:popView()
                        global.director:pushView(EquipChangeMenu.new(Logic.farmPeople[self.selPanel], i-5), 1)
                        return
                    end
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
