require "menu.PeopleInfo2"
TrainMenu3 = class()
function TrainMenu3:ctor()
    local vs = getVS()
    self.bg = CCNode:create()
    local sz = {width=1024, height=768}
    self.temp = setPos(addNode(self.bg), {-13.5, fixY(sz.height, 0+sz.height)+4})
    local sp = setOpacity(setAnchor(setSize(setPos(addSprite(self.temp, "dialogA.png"), {525, fixY(sz.height, 388)}), {693, 588}), {0.50, 0.50}), 255)
    local sp = setOpacity(setAnchor(setSize(setPos(addSprite(self.temp, "dialogB.png"), {523, fixY(sz.height, 423)}), {626, 358}), {0.50, 0.50}), 255)
    local but = ui.newButton({image="newClose.png", text="", font="f1", size=18, delegate=self, callback=closeDialog, shadowColor={0, 0, 0}, color={255, 255, 255}})
    but:setContentSize(80, 82)
    setPos(addChild(self.temp, but.bg), {848, fixY(sz.height, 112)})
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="点击升级喵名字", size=26, color={32, 112, 220}, font="f2", shadowColor={255, 255, 255}})), {0.50, 0.50}), {512, fixY(sz.height, 625)})
    self.desWord = w
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="费用", size=26, color={32, 112, 220}, font="f2", shadowColor={255, 255, 255}})), {0.00, 0.50}), {708, fixY(sz.height, 215)})
    local sp = setOpacity(setAnchor(setSize(setPos(addSprite(self.temp, "lvpng.png"), {339, fixY(sz.height, 216)}), {49, 43}), {0.50, 0.50}), 255)
    local sp = setOpacity(setAnchor(setSize(setPos(addSprite(self.temp, "catLevelUp.png"), {531, fixY(sz.height, 148)}), {212, 42}), {0.50, 0.50}), 255)

    self.scrollPro = createScroll(self.temp, sz)


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
function TrainMenu3:updateTab()
    removeSelf(self.flowNode)
    self.flowNode = addNode(self.cl)
    setPos(self.flowNode, {0, self.HEIGHT})
    self.flowHeight = 0

	local initX = 1
	local initY = -60
	local offX = 0
	local offY = 53

    local sz = {width=546, height=52}
	local rowWidth = 1
	self.data = {}
    
	for k, v in ipairs(Logic.farmPeople) do
		local row = math.floor((k-1)/rowWidth)
		local col = (k-1)%rowWidth

        local panel = setPos(addNode(self.flowNode), {initX+col*offX, initY-offY*row})
        local back = setOpacity(setAnchor(setSize(setPos(addSprite(panel, "listB.png"), {306, fixY(sz.height, 26)}), {479, 52}), {0.50, 0.50}), 255)
        local sp = setOpacity(setAnchor(setSize(setPos(addSprite(panel, "headBoard.png"), {28, fixY(sz.height, 26)}), {57, 52}), {0.50, 0.50}), 255)
        local sp = setOpacity(setAnchor(setSize(setPos(addSprite(panel, "catHead"..v.id..".png"), {28, fixY(sz.height, 24)}), {52, 45}), {0.50, 0.50}), 255)
        local w1 = setPos(setAnchor(addChild(panel, ui.newTTFLabel({text=v.level+1, size=26, color={255, 241, 0}, font="f2", shadowColor={255, 255, 255}})), {0.00, 0.50}), {92, fixY(sz.height, 25)})
        local w2 = setPos(setAnchor(addChild(panel, ui.newTTFLabel({text=Logic.LevelCost[v.level+1+1].."银币", size=24, color={240, 196, 92}, font="f2", shadowColor={255, 255, 255}})), {1.00, 0.50}), {529, fixY(sz.height, 24)})
        local w3 = setPos(setAnchor(addChild(panel, ui.newTTFLabel({text=v.data.name, size=24, color={240, 196, 92}, font="f2", shadowColor={255, 255, 255}})), {0.00, 0.50}), {133, fixY(sz.height, 24)})
        panel:setTag(k)
        setContentSize(panel, {sz.width, sz.height})

		table.insert(self.data, {back, panel, w1, w2, w3, name=v.data.name})
        self.flowHeight = self.flowHeight+offY
	end
end


function TrainMenu3:touchBegan(x, y)
    self.lastPoints = {x, y}
    self.accMove = 0
    self.curSel = nil
end

function TrainMenu3:moveBack(dify)
    adjustFlow(self, dify)
end
function TrainMenu3:touchMoved(x, y)
    local oldPoints = self.lastPoints
    self.lastPoints = {x, y}
    local dify = self.lastPoints[2]-oldPoints[2]
    self.accMove = self.accMove+math.abs(dify)
    self:moveBack(dify)
end

function TrainMenu3:setSel(s)
    if #self.data < s then
        return
    end
    if self.selPanel ~= nil then
        setTexture(self.data[self.selPanel][1], "listB.png")
        local word = self.data[self.selPanel] 
        setColor(word[3], {255, 241, 0})
        setColor(word[4], {240, 196, 92})
        setColor(word[5], {240, 196, 92})
    end
    self.selPanel = s
    setTexture(self.data[self.selPanel][1], "listA.png")
    local word = self.data[self.selPanel] 
    setColor(word[3], {40, 172, 255})
    setColor(word[4], {206, 78, 0})
    setColor(word[5], {206, 78, 0})
    self.desWord:setString("点击升级"..self.data[self.selPanel].name)
end

function TrainMenu3:touchEnded(x, y)
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
                global.director:pushView(PeopleInfo2.new(self.selPanel), 1)
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
function TrainMenu3:refreshData()
    self:updateTab()
    self:setSel(self.selPanel)
end
