require "menu.PeopleInfo"
TrainMenu2 = class()
function TrainMenu2:adjustPos()
    local vs = getVS()
    local ds = global.director.designSize
    local sca = math.min(vs.width/ds[1], vs.height/ds[2])
    local cx, cy = ds[1]/2, ds[2]/2
    local nx, ny = vs.width/2-cx*sca, vs.height/2-cy*sca

    setScale(self.bg, sca)
    setPos(self.bg, {nx, ny})
    self.cl:setContentSize(CCSizeMake(self.listSize.width, self.HEIGHT*sca))
end

function TrainMenu2:ctor()
    local vs = getVS()
    self.bg = CCNode:create()
    local sz = {width=1024, height=768}
    self.temp = setPos(addNode(self.bg), {-26, 3})
    local temp = self.temp
    local sp = setAnchor(setPos(addSprite(self.temp, "dialogA.png"), {538, fixY(sz.height, 387)}), {0.50, 0.50})
    local sp = setAnchor(setSize(setPos(addSprite(self.temp, "dialogB.png"), {535, fixY(sz.height, 421)}), {617, 352}), {0.50, 0.50})
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="角色升级", size=34, color={102, 4, 554}, font="f1"})), {0.50, 0.50}), {545, fixY(sz.height, 153)})

    local listSize = {width=546, height=318}
    self.listSize = listSize
    self.HEIGHT = listSize.height
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

    self:setSel(1)


    --total Height 315
    --pro height 157
    --initX = 78
    local sp = setAnchor(setSize(setPos(addSprite(self.temp, "scrollBack.png"), {817, fixY(sz.height, 420)}), {15, 315}), {0.50, 0.50})
    local pro = setAnchor(setSize(setPos(addSprite(sp, "scrollPro.png"), {0, fixY(315, 0)}), {17, 157}), {0.0, 1})
    self.scrollPro = pro

    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="点击查看详情", size=26, color={32, 7, 220}, font="f1"})), {0.00, 0.50}), {460, fixY(sz.height, 627)})
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="Lv", size=41, color=hexToDec('f8b551'), font="f2"})), {0.00, 0.50}), {332, fixY(sz.height, 216)})
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="费用", size=26, color={32, 7, 220}, font="f1"})), {0.00, 0.50}), {717, fixY(sz.height, 219)})

    --每个屏幕显示6个 单屏幕比总量是高度比例
    --修正滚动条3个像素 根据缩放比例决定
    local total = #self.data
    local pnum = total/6
    local sz = getContentSize(self.scrollPro)
    self.scrollHeight = math.max(math.min(6/total*315, 315), 10)
    local sy = self.scrollHeight/(sz[2]-4)
    setScaleY(self.scrollPro, sy)

    self:adjustPos()
end

function TrainMenu2:updateTab()
    removeSelf(self.flowNode)
    self.flowNode = addNode(self.cl)
    setPos(self.flowNode, {0, self.HEIGHT})
    self.flowHeight = 0

	local initX = 1
	local initY = -57
	local offX = 0
	local offY = 53
	self.data = {}
	local sz = {width=480, height=318}
	--local test = {1, 1, 1, 1, 1, 1, 1}
	local rowWidth = 1
    local sz = {width=546, height=55}
    print("farmPeople!!", #Logic.farmPeople)
	for k, v in ipairs(Logic.farmPeople) do
        print("allPeople")
		local row = math.floor((k-1)/rowWidth)
		local col = (k-1)%rowWidth

        local panel = setPos(addNode(self.flowNode), {initX+col*offX, initY-offY*row})
        panel:setTag(k)
        setContentSize(panel, {sz.width, sz.height})
        local sp = setAnchor(setSize(setPos(addSprite(panel, "listB.png"), {306, fixY(55, 26)}), {479, 52}), {0.50, 0.50})
        setAnchor(setPos(addSprite(panel, "catHead"..v.id..".png"), {27, fixY(55, 27)}), {0.50, 0.50})

        local w1 = setPos(setAnchor(addChild(panel, ui.newTTFLabel({text=v.level+1, size=26, color=hexToDec('fff100'), font="f2"})), {0.00, 0.50}), {87, fixY(sz.height, 27)})
        local w2 = setPos(setAnchor(addChild(panel, ui.newTTFLabel({text=Logic.LevelCost[v.level+1+1].."银币", size=24, color={255, 255, 255}, font="f1"})), {0.00, 0.50}), {421, fixY(sz.height, 27)})
        local w3 = setPos(setAnchor(addChild(panel, ui.newTTFLabel({text=v.data.name, size=24, color={255, 255, 255}, font="f1"})), {0.00, 0.50}), {132, fixY(sz.height, 25)})
        setColor(w1, {240, 196, 92})
        setColor(w2, {240, 196, 92})
        setColor(w3, {240, 196, 92})

		table.insert(self.data, {sp, panel, w1, w2, w3})
        self.flowHeight = self.flowHeight+offY
	end
end

function TrainMenu2:touchBegan(x, y)
    self.lastPoints = {x, y}
    self.accMove = 0
    self.curSel = nil
end

function TrainMenu2:moveBack(dify)
    local ox, oy = self.flowNode:getPosition()
    self.flowNode:setPosition(ccp(ox, oy+dify))

    local sxy = getPos(self.scrollPro)
    local total = #self.data
    local ny = math.max(math.min(sxy[2]+-dify*(315/self.flowHeight), 315), self.scrollHeight)
    --print("scroll", ny, total, (315*(6/total)))
    setPos(self.scrollPro, {sxy[1], ny})
    
end
function TrainMenu2:touchMoved(x, y)
    local oldPoints = self.lastPoints
    self.lastPoints = {x, y}
    local dify = self.lastPoints[2]-oldPoints[2]
    self.accMove = self.accMove+math.abs(dify)
    self:moveBack(dify)
end

function TrainMenu2:setSel(s)
    if #self.data < s then
        return
    end
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
        setColor(word[3], hexToDec('fff100'))
        setColor(word[4], {255, 255, 255})
        setColor(word[5], {255, 255, 255})
    end
end

function TrainMenu2:touchEnded(x, y)
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
                global.director:pushView(PeopleInfo.new(self.selPanel), 1)
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
function TrainMenu2:refreshData()
    self:updateTab()
    self:setSel(self.selPanel)
end
