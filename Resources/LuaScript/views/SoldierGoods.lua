SoldierGoods = class()
function SoldierGoods:ctor(s)
    self.HEIGHT = 323
    self.OFFY = 215 
    self.OFFX = 160 
    self.PAN_PER_ROW = 3
    self.PANEL_WIDTH = 149
    self.PANEL_HEIGHT = 188

    self.store = s
    self.bg = CCNode:create()
    self.cl = Scissor:create()
    self.bg:addChild(self.cl)
    
    self.cl:setPosition(ccp(271, fixY(nil, 145, self.HEIGHT)))
    self.cl:setContentSize(CCSizeMake(500, self.HEIGHT))
    
    self.flowNode = addNode(self.cl)
    setPos(self.flowNode, {0, self.HEIGHT})
    
    self.data = {}
    
    self.touch = ui.newTouchLayer({size={500, self.HEIGHT}, delegate=self, touchBegan=self.touchBegan, touchMoved=self.touchMoved, touchEnded=self.touchEnded})
    self.bg:addChild(self.touch.bg)
    setPos(self.touch.bg, {271, fixY(nil, 145, self.HEIGHT)})
    self.goodNum = storeSoldier
    self:updateTab()

    local rows = math.floor((#self.goodNum+self.PAN_PER_ROW-1)/self.PAN_PER_ROW)
    local fHeight = rows*self.OFFY
    self.minPos = math.max(0, fHeight-self.HEIGHT)
end

function SoldierGoods:getRange()
    local op = getPos(self.flowNode)
    local upRow = math.max(0, round((op[2]-self.HEIGHT)/self.OFFY))
    local lowRow = round((op[2]+self.OFFY)/self.OFFY)
    local rows = (#self.goodNum+self.PAN_PER_ROW-1)/self.PAN_PER_ROW
    print("upRow", simple.encode(op), upRow, lowRow)
    return {math.max(0, upRow-1), math.min(lowRow+1, rows)}
end

function SoldierGoods:updateTab()
    local but0
    local line
    local temp
    local sca

    local oldPos = getPos(self.flowNode)
    removeSelf(self.flowNode)
    self.flowNode = setPos(addNode(self.cl), oldPos)
    print("flowNode", simple.encode(oldPos))

    local userLevel = global.user:getValue("level")
    local rg = self:getRange()
    print("getRange", simple.encode(rg))
    local posX = 0
    local posY = -rg[1]*self.OFFY
    for i=rg[1], rg[2]-1, 1 do
        for j=0, self.PAN_PER_ROW-1, 1 do
            local curNum = i*self.PAN_PER_ROW+j
            if curNum >= #self.goodNum then
                break
            end

            if curNum % 3 == 0 then
                posX = 0
                posY = posY-self.OFFY
            else
                posX = posX+self.OFFX
            end

            local panel = setAnchor(setContentSize(setPos(addNode(self.flowNode), {posX, posY}), {149, 188}), {0, 0})
            local pb = setPos(setAnchor(setSize(addSprite(panel, "goodPanel.png"), {149, 188}), {0.5, 0.5}), {74, 94})
            local sz = panel:getContentSize()
            
            local id = self.goodNum[curNum+1]
            local sData = getData(GOODS_KIND.SOLDIER, id)
            local cost = getCost(GOODS_KIND.SOLDIER, id)
            local needLevel = sData.level
            local canBuy = 1
            if needLevel > userLevel then
                canBuy = 0
            end
            local solPic
            if canBuy == 0 then
                solPic = setColor(setPos(addSprite(panel, "soldier"..id..".png"), {73, 95}), {0, 0, 0})
            else
                solPic = setPos(addSprite(panel, "soldier"..id..".png"), {73, 95})
            end
            local sca = getSca(solPic, {125, 96})
            setScale(solPic, sca)
            print("solCost", simple.encode(cost), sData.crystal)
            for k, v in pairs(cost) do
                local picName = k..".png"
                local valNum = str(v)
                local buyable = global.user:checkCost(cost)
                local c = {255, 255, 255}
                if buyable.ok == 0 then
                    c = {208, 70, 72}
                end
                local temp = setSize(setPos(addSprite(panel, picName), {32, fixY(sz.height, 169)}), {30, 30})
                temp = setPos(ui.newBMFontLabel({text=valNum, color=c, font="bound.fnt", size=20}), {89, fixY(sz.height, 169)})
                panel:addChild(temp)
                break
            end
            local name = setColor(setPos(ui.newTTFLabel({text=sData.name, size=21}), {74, fixY(sz.height, 25)}), {210, 125, 44})
            panel:addChild(name)

            panel:setTag(curNum)
            --当前选择的tab  当前士兵在goodNum数组中的位置 是否等级足够可以购买
            self.data[curNum] = {self.selTab, curNum+1, canBuy}

            if self.curSel ~= nil and self.curSel[2] == curNum+1 then
                self:showGreenBut(panel)
            end
        end
    end

    self.selTab = -1
end
function SoldierGoods:onBuy(buildData)
    self.store:setSoldier(buildData)
    self.store:sureToCall()
end

function SoldierGoods:showGreenBut(child)
    self.shadow = addNode(child)
    setColor(setSize(setPos(setAnchor(addSprite(self.shadow, "storeShadow.png"), {0, 0}), {0, 0}), {151, 191}), {255, 255, 255, 125})
    local but0 = ui.newButton({image="greenButton0.png", delegate=self, callback=self.onBuy, param=self.data[child:getTag()]})
    but0.bg:setPosition(ccp(75, fixY(191, 97)))
    but0:setAnchor(0.5, 0.5)
    but0:setContentSize(128, 39)
    self.shadow:addChild(but0.bg)
    local sz = but0.bg:getContentSize()
    local label = setAnchor(setPos(addLabel(but0.bg, getStr("sureToBuy"), "", 20), {0, 0}), {0.5, 0.5})
end


function SoldierGoods:touchBegan(x, y)
    self.lastPoints = {x, y}
    self.accMove = 0
    self.curSel = nil
end

function SoldierGoods:moveBack(dify)
    local ox, oy = self.flowNode:getPosition()
    self.flowNode:setPosition(ccp(ox, oy+dify))
end
function SoldierGoods:touchMoved(x, y)
    local oldPoints = self.lastPoints
    self.lastPoints = {x, y}
    local dify = self.lastPoints[2]-oldPoints[2]
    self.accMove = self.accMove+math.abs(dify)
    self:moveBack(dify)
end
function SoldierGoods:touchEnded(x, y)
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

    self:updateTab()
end
