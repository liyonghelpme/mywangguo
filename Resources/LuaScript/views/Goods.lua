Goods = class()
function Goods:ctor(s)
    self.store = s

    self.offX = 168
    self.offY = 208
    self.HEIGHT = 314
    self.PAN_PER_ROW = 3

    self.cachePos = {}
    
    self.bg = CCNode:create()
    
    self.cl = Scissor:create()
    self.bg:addChild(self.cl)
    self.cl:setPosition(ccp(271, fixY(nil, 145, self.HEIGHT)))
    self.cl:setContentSize(CCSizeMake(500, self.HEIGHT))

    self.title = setPos(setAnchor(addSprite(self.bg, "images/buyDrug.png"), {0.5, 0.5}), {515, fixY(nil, 112)})

    self.goodNum = {}
    self.flowNode = addNode(self.cl)
    self.flowNode:setPosition(ccp(0, self.HEIGHT))
    self.minPos = 0
    self.selTab = -1
    --切换tab时候 清理数据
    self.data = {}

    self.touch = ui.newTouchLayer({size={500, self.HEIGHT}, delegate=self, touchBegan=self.touchBegan, touchMoved=self.touchMoved, touchEnded=self.touchEnded})
    self.bg:addChild(self.touch.bg)
    setPos(self.touch.bg, {271, fixY(nil, 145, self.HEIGHT)})
end
function Goods:initSameElement(buildData, panel)
    local objKind = buildData[1]
    local objId = buildData[2]
    print(objKind, objId)
    local cost = getCost(objKind, objId)
    local data = getData(objKind, objId)
    local needLevel = getDefault(data, "level", 0)
    local gain = getGain(objKind, objId)

    local buildPicName = replaceStr(KindsPre[objKind], {"[ID]", objId})
    local showaGain = getDefault(data, "showGain", 1)

    --panel is a touchButton or background is a touch zone
    local sz = panel:getContentSize()
    local buildPic = setPos(addSprite(panel, "images/"..buildPicName), {74, fixY(sz.height, 88)})
    local ret
    --灰色建筑图 生成
    --调整图像的 纹理
    if objKind == GOODS_KIND.BUILD then
    end
    local sca
    if showGain == 0 then
        setPos(buildPic, {74, fixY(sz.height, 97)})
        sca = getSca(buildPic, {121, 88})
        setSca(buildPic, sca)
    else
        setPos(buildPic, {74, fixY(sz.height, 88)})
        sca = getSca(buildPic, {121, 71})
        setSca(buildPic, sca)
    end
    local canBuy = 1
    return canBuy
end

function Goods:getShowRange()
    local px, py = self.flowNode:getPosition()
    local upRow = math.max(0, round(-py/self.offY))
    local lowRow = round((-py+self.HEIGHT+self.offY)/self.offY)
    local rows = (#self.goodNum+self.PAN_PER_ROW-1)/self.PAN_PER_ROW
    return {math.max(0, upRow-1), math.min(lowRow+1, rows)}
end

function Goods:updateTab(rg)
    local posX = 0
    --row range 
    local posY = -rg[1]*self.offY
    local ox, oy = self.flowNode:getPosition()
    removeSelf(self.flowNode)
    self.flowNode = setPos(addNode(self.cl), {ox, oy})

    --from top to bottom

    print("updateTab", rg[1], rg[2], #self.goodNum, self.PAN_PER_ROW)
    local i = math.max(0, rg[1]*self.PAN_PER_ROW)
    while i < #self.goodNum and i < rg[2]*self.PAN_PER_ROW do
        --print(i, rg[1], rg[2], #self.goodNum)
        if i % 3 == 0 then
            posX = 0
            posY = posY-self.offY
        else
            posX = posX+self.offX
        end
        local panel = setAnchor(setContentSize(setPos(addNode(self.flowNode), {posX, posY}), {149, 188}), {0, 0})
        local pb = setAnchor(setSize(addSprite(panel, "images/goodPanel.png"), {149, 188}), {0, 0})

        local buildData = self.goodNum[i+1]
        print('buildData', self.selTab, i, buildData)
        local canBuy = self:initSameElement(buildData, panel)
        panel:setTag(i)
        self.data[i] = {self.selTab, i, canBuy}

        print('panelData', panel.data)
        
        if self.curSel ~= nil and self.curSel[2] == i then
            self:showGreenBut(panel)
        end
        i = i+1
    end

    local rows = math.floor((#self.goodNum+self.PAN_PER_ROW-1)/self.PAN_PER_ROW)
    local fHeight = rows*self.offY
    --maxPos 更合适
    self.minPos = math.max(0, fHeight-self.HEIGHT)
end
function Goods:setTab(g)
    self.selTab = g
    self.curSel = nil
    local tex = CCTextureCache:sharedTextureCache():addImage("images/"..self.store.titles[g+1])
    self.title:setTexture(tex)
    
    self.goodNum = self.store.allGoods[self.selTab+1]
    --cache 上次的位置 不同selTab
    removeSelf(self.flowNode)
    self.flowNode = addNode(self.cl)
    if self.cachePos[self.selTab] ~= nil then
        self.flowNode:setPosition(ccp(0, self.cachePos[self.selTab]))
    else
        self.flowNode:setPosition(ccp(0, self.HEIGHT))
    end
    self.data = {}
    local rg = self:getShowRange()
    self:updateTab(rg)
end


function Goods:touchBegan(x, y)
    self.lastPoints = {x, y}
    self.accMove = 0
    self.curSel = nil

end
function Goods:moveBack(dify)
    local ox, oy = self.flowNode:getPosition()
    self.flowNode:setPosition(ccp(ox, oy+dify))
end

function Goods:touchMoved(x, y)
    local oldPoints = self.lastPoints
    self.lastPoints = {x, y}
    local dify = self.lastPoints[2]-oldPoints[2]
    self.accMove = self.accMove+math.abs(dify)
    self:moveBack(dify)
end
function Goods:touchEnded(x, y)
    local newPos = {x, y}
    if self.accMove < 10 then
        local child = checkInChild(self.flowNode, newPos)
        if child ~= nil then
            local buildData = self.data[child:getTag()]
            if buildData[3] == 1 then
                self.curSel = buildData
            end
        end
    end

    local oldPos = getPos(self.flowNode)
    oldPos[2] = oldPos[2]-self.HEIGHT
    oldPos[2] = math.max(0, math.min(self.minPos, oldPos[2]))
    self.flowNode:setPosition(ccp(oldPos[1], oldPos[2]+self.HEIGHT))

    local rg = self:getShowRange()
    self:updateTab(rg)
end
function Goods:showGreenBut(child)
    self.shadow = addNode(child)
    setColor(setSize(setPos(setAnchor(addSprite(self.shadow, "images/storeShadow.png"), {0, 0}), {0, 0}), {151, 191}), {255, 255, 255, 125})
    local but0 = ui.newButton({image="images/greenButton0.png", delegate=self, callback=self.onBuy, param=self.data[child:getTag()]})
    but0.bg:setPosition(ccp(75, fixY(191, 97)))
    but0:setAnchor(0.5, 0.5)
    but0:setContentSize(128, 39)
    self.shadow:addChild(but0.bg)
end
function Goods:onBuy(buildData)
    self.curSel = nil
    self.store:buy(buildData)
end

