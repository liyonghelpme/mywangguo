ChangeGoods = class()
function ChangeGoods:ctor(b)
    self.build = b
local vs = getVS()
self.bg = CCNode:create()
local sz = {width=1024, height=768}
self.temp = setPos(addNode(self.bg), {-13.5, fixY(sz.height, 0+sz.height)+4})
local sp = setOpacity(setAnchor(setSize(setPos(addSprite(self.temp, "dialogA.png"), {525, fixY(sz.height, 388)}), {693, 588}), {0.50, 0.50}), 255)
local sp = setOpacity(setAnchor(setSize(setPos(addSprite(self.temp, "dialogB.png"), {523, fixY(sz.height, 423)}), {626, 358}), {0.50, 0.50}), 255)
local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="点击更改商品", size=26, color={32, 112, 220}, font="f2", shadowColor={255, 255, 255}})), {0.50, 0.50}), {523, fixY(sz.height, 625)})
local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="价格", size=26, color={32, 112, 220}, font="f2", shadowColor={255, 255, 255}})), {0.00, 0.50}), {705, fixY(sz.height, 215)})
local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="材料", size=26, color={32, 112, 220}, font="f2", shadowColor={255, 255, 255}})), {0.00, 0.50}), {511, fixY(sz.height, 215)})
local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="名称", size=26, color={32, 112, 220}, font="f2", shadowColor={255, 255, 255}})), {0.00, 0.50}), {324, fixY(sz.height, 215)})
local but = ui.newButton({image="newClose.png", text="", font="f1", size=18, delegate=self, callback=closeDialog, shadowColor={0, 0, 0}, color={255, 255, 255}})
but:setContentSize(80, 82)
setPos(addChild(self.temp, but.bg), {848, fixY(sz.height, 112)})
local sp = setOpacity(setAnchor(setSize(setPos(addSprite(self.temp, "goodsInfo.png"), {531, fixY(sz.height, 148)}), {212, 42}), {0.50, 0.50}), 255)

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

function ChangeGoods:updateTab()
	local initX = 0
	local initY = -58
	local offX = 0
	local offY = 52
	self.data = {}
    local sz = {width=546, height=52}
	local test = self.build.data.goodsList
	local rowWidth = 1
    --local pos = {325, 282, 238}
    local pos = {251, 309, 368}
    local wpos = {260, 318, 375}
	for k, v in ipairs(test) do
		local row = math.floor((k-1)/rowWidth)
		local col = (k-1)%rowWidth

        local gdata = GoodsName[v]
        --该商品没有拥有呢
        if gdata.condition ~= 0 and not checkResearchYet(1, v) then
            break
        end
        local ic = {'food', 'wood', 'stone'}
        local panel = setPos(addNode(self.flowNode), {initX+col*offX, initY-offY*row})
        local listback = setOpacity(setAnchor(setSize(setPos(addSprite(panel, "listB.png"), {306, fixY(sz.height, 26)}), {479, 52}), {0.50, 0.50}), 255)
        local sp = setOpacity(setAnchor(setSize(setPos(addSprite(panel, "headBoard.png"), {28, fixY(sz.height, 26)}), {57, 52}), {0.50, 0.50}), 255)
        local sp = setOpacity(setAnchor(setSize(setPos(addSprite(panel, "storeGoods"..v..".png"), {28, fixY(sz.height, 25)}), {41, 36}), {0.50, 0.50}), 255)
        local w1 = setPos(setAnchor(addChild(panel, ui.newTTFLabel({text=gdata.name, size=24, color={240, 196, 92}, font="f2", shadowColor={255, 255, 255}})), {0.00, 0.50}), {98, fixY(sz.height, 24)})
        local w2 = setPos(setAnchor(addChild(panel, ui.newTTFLabel({text=gdata.price.."银币", size=24, color={240, 196, 92}, font="f2", shadowColor={255, 255, 255}})), {1.00, 0.50}), {530, fixY(sz.height, 24)})
        local curP = 1
        local gnum = {}
        for gk, gv in ipairs(ic) do
            if gdata[gv] > 0 then
                local sp = setOpacity(setAnchor(setPos(addSprite(panel, gv.."Icon.png"), {pos[curP], fixY(sz.height, 21)}), {0.50, 0.50}), 255)
                local w = setPos(setAnchor(addChild(panel, ui.newTTFLabel({text=gdata[gv], size=24, color={240, 196, 92}, font="f2", shadowColor={255, 255, 255}})), {0.00, 0.50}), {wpos[curP], fixY(sz.height, 35)})
                table.insert(gnum, w)
                curP = curP+1
            end
        end

        panel:setTag(k)
        setContentSize(panel, {sz.width, sz.height})
        
		table.insert(self.data, {listback, w1, w2, gnum})
		self.flowHeight = self.flowHeight+offY
	end
end

function ChangeGoods:touchBegan(x, y)
    self.lastPoints = {x, y}
    self.accMove = 0
    self.curSel = nil
end

function ChangeGoods:moveBack(dify)
    adjustFlow(self, dify)
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
        for k, v in ipairs(word[4]) do
            setColor(v, {240, 196, 92})
        end
    end

    self.selPanel = s
    setTexture(self.data[self.selPanel][1], "listA.png")
    local word = self.data[self.selPanel] 
    setColor(word[2], {206, 78, 0})
    setColor(word[3], {206, 78, 0})
    for k, v in ipairs(word[4]) do
        setColor(v, {206, 78, 0})
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
