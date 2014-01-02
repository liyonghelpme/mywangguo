ChangeGoods = class()
function ChangeGoods:ctor(b)
    self.build = b
    local vs = getVS()
    self.bg = CCNode:create()
    local sz = {width=1024, height=768}
    self.temp = setPos(addNode(self.bg), {-26.0, fixY(sz.height, 0+sz.height)+3.5})
    local sp = setAnchor(setPos(addSprite(self.temp, "dialogA.png"), {538, fixY(sz.height, 387)}), {0.50, 0.50})
    local sp = setAnchor(setSize(setPos(addSprite(self.temp, "dialogC.png"), {537, fixY(sz.height, 400)}), {617, 396}), {0.50, 0.50})
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="点击更改商品", size=26, color={32, 112, 220}, font="f1"})), {0.00, 0.50}), {467, fixY(sz.height, 626)})
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="商品一览", size=34, color={102, 66, 42}, font="f1"})), {0.50, 0.50}), {529, fixY(sz.height, 153)})


    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="材料", size=25, color={32, 112, 220}, font="f1"})), {0.00, 0.50}), {504, fixY(sz.height, 240)})
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="价格", size=25, color={32, 112, 220}, font="f1"})), {0.00, 0.50}), {691, fixY(sz.height, 240)})
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="材料", size=25, color={32, 112, 220}, font="f1"})), {0.00, 0.50}), {285, fixY(sz.height, 564)})
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="食材", size=25, color={32, 112, 220}, font="f1"})), {0.00, 0.50}), {434, fixY(sz.height, 563)})
    self.food = w
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="s1个", size=20, color={255, 255, 255}, font="f1"})), {0.00, 0.50}), {498, fixY(sz.height, 564)})
    self.foodN = w
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="木材", size=25, color={32, 112, 220}, font="f1"})), {0.00, 0.50}), {539, fixY(sz.height, 563)})
    self.wood = w
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="m1个", size=20, color={255, 255, 255}, font="f1"})), {0.00, 0.50}), {603, fixY(sz.height, 564)})
    self.woodN = w
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="石材", size=25, color={32, 112, 220}, font="f1"})), {0.00, 0.50}), {644, fixY(sz.height, 563)})
    self.stone = w
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="st1个", size=20, color={255, 255, 255}, font="f1"})), {0.00, 0.50}), {708, fixY(sz.height, 564)})
    self.stoneN = w


    local listSize = {width=537, height=269}
    self.listSize = listSize
    self.HEIGHT = 269
    self.cl = Scissor:create()
    self.temp:addChild(self.cl)
    setPos(self.cl, {258, fixY(sz.height, 263+listSize.height)})
    setContentSize(self.cl, {listSize.width, listSize.height})
    self.flowNode = addNode(self.cl)
    setPos(self.flowNode, {0, self.HEIGHT})
    self.touch = ui.newTouchLayer({size={listSize.width, self.HEIGHT}, delegate=self, touchBegan=self.touchBegan, touchMoved=self.touchMoved, touchEnded=self.touchEnded})
    self.cl:addChild(self.touch.bg)
    setPos(self.touch.bg, {0, 0})
    self.flowHeight = 0
    self:updateTab()
    self:setSel(1)

    local sp = setAnchor(setSize(setPos(addSprite(self.temp, "scrollBack.png"), {820, fixY(sz.height, 398)}), {15, 260}), {0.50, 0.50})
    local pro = setAnchor(setSize(setPos(addSprite(sp, "scrollPro.png"), {0, fixY(315, 0)}), {17, 157}), {0, 1})
    self.scrollPro = pro
    local total = #self.data
    local sz = getContentSize(self.scrollPro)
    self.scrollHeight = math.max(math.min(6/total*315, 315), 10)
    self.scrollBackHei = 315
    sy = self.scrollHeight/(sz[2]-4)
    setScaleY(self.scrollPro, sy)
    
    centerUI(self)
end

function ChangeGoods:updateTab()
	local initX = 0
	local initY = -58
	local offX = 0
	local offY = 52
	self.data = {}
	local sz = {width=537, height=58}
	local test = self.build.data.goodsList
	local rowWidth = 1
    local pos = {325, 282, 238}
	for k, v in ipairs(test) do
		local row = math.floor((k-1)/rowWidth)
		local col = (k-1)%rowWidth

        local gdata = GoodsName[v]
        --该商品没有拥有呢
        if gdata.condition ~= 0 and not checkResearchYet(1, v) then
            break
        end

        local panel = setPos(addNode(self.flowNode), {initX+col*offX, initY-offY*row})
        local listback = setAnchor(setSize(setPos(addSprite(panel, "listB.png"), {297, fixY(sz.height, 30)}), {479, 52}), {0.50, 0.50})
        local sp = setAnchor(setSize(setPos(addSprite(panel, "weaponIcon.png"), {27, fixY(sz.height, 31)}), {54, 54}), {0.50, 0.50})
        local sp = setAnchor(setSize(setPos(addSprite(panel, "goodsIcon.png"), {24, fixY(sz.height, 26)}), {48, 53}), {0.50, 0.50})
        local w1 = setPos(setAnchor(addChild(panel, ui.newTTFLabel({text=gdata.name, size=20, color={240, 196, 92}, font="f1"})), {0.00, 0.50}), {75, fixY(sz.height, 30)})
        local w2 = setPos(setAnchor(addChild(panel, ui.newTTFLabel({text=gdata.price.."银币", size=20, color={240, 196, 92}, font="f1"})), {1.00, 0.50}), {514, fixY(sz.height, 30)})
        local curP = 1
        if gdata.food > 0 then
            local sp = setAnchor(setSize(setPos(addSprite(panel, "foodIcon.png"), {pos[curP], fixY(sz.height, 29)}), {37, 37}), {0.50, 0.50})
            curP = curP+1
        end
        if gdata.wood > 0 then
            local sp = setAnchor(setSize(setPos(addSprite(panel, "woodIcon.png"), {pos[curP], fixY(sz.height, 29)}), {37, 37}), {0.50, 0.50})
            curP = curP+1
        end
        if gdata.stone > 0 then
            local sp = setAnchor(setSize(setPos(addSprite(panel, "stoneIcon.png"), {pos[curP], fixY(sz.height, 29)}), {37, 37}), {0.50, 0.50})
            curP = curP+1
        end

        panel:setTag(k)
        setContentSize(panel, {sz.width, sz.height})

		table.insert(self.data, {listback, w1, w2})
		self.flowHeight = self.flowHeight+offY
	end
end

function ChangeGoods:touchBegan(x, y)
    self.lastPoints = {x, y}
    self.accMove = 0
    self.curSel = nil
end

function ChangeGoods:moveBack(dify)
    local ox, oy = self.flowNode:getPosition()
    self.flowNode:setPosition(ccp(ox, oy+dify))

    local sxy = getPos(self.scrollPro)
    local total = #self.data
    local ny = math.max(math.min(sxy[2]+-dify*(self.scrollBackHei/self.flowHeight), self.scrollBackHei), self.scrollHeight)
    setPos(self.scrollPro, {sxy[1], ny})
end
function ChangeGoods:touchMoved(x, y)
    local oldPoints = self.lastPoints
    self.lastPoints = {x, y}
    local dify = self.lastPoints[2]-oldPoints[2]
    self.accMove = self.accMove+math.abs(dify)
    self:moveBack(dify)
end

function ChangeGoods:setSel(s)
    if #self.data < s then
        return
    end
    
    if self.selPanel ~= nil then
        setTexture(self.data[self.selPanel][1], "listB.png")
        local word = self.data[self.selPanel] 
        setColor(word[2], {240, 196, 92})
        setColor(word[3], {240, 196, 92})
    end

    self.selPanel = s
    setTexture(self.data[self.selPanel][1], "listA.png")
    local word = self.data[self.selPanel] 
    setColor(word[2], {255, 255, 255})
    setColor(word[3], {255, 255, 255})

    local gdata = GoodsName[self.build.data.goodsList[self.selPanel]]
    local allt = {self.food, self.wood, self.stone}
    local allN = {self.foodN, self.woodN, self.stoneN}
    local curPos = 1
    if gdata.food > 0 then
        allt[curPos]:setString("食材")
        allN[curPos]:setString(gdata.food..'个')
        curPos = curPos+1
    end

    if gdata.wood > 0 then
        allt[curPos]:setString("木材")
        allN[curPos]:setString(gdata.wood..'个')
        curPos = curPos+1
    end

    if gdata.stone > 0 then
        allt[curPos]:setString("石材")
        allN[curPos]:setString(gdata.stone..'个')
        curPos = curPos+1
    end

    for c = curPos, 3, 1 do
        allt[c]:setString('')
        allN[c]:setString('')
    end
end

function ChangeGoods:touchEnded(x, y)
    local newPos = {x, y}
    if self.accMove < 10 then
        local child = checkInChild(self.flowNode, newPos)
        if child ~= nil then
            print("touch child", child:getTag())
            local t = child:getTag()
            if self.selPanel ~= t then
                self:setSel(t)
            else
                self.build:setGoodsKind(self.build.data.goodsList[self.selPanel])
                global.director:popView()
                return
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
