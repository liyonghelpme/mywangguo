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
    self.minPos = 0
    self.selTab = -1
    
    
    self.touch = ui.newTouchLayer({size={500, self.HEIGHT}, delegate=self, touchBegan=self.touchBegan, touchMoved=self.touchMoved, touchEnded=self.touchEnded})
    self.bg:addChild(self.touch.bg)
    setPos(self.touch.bg, {271, fixY(nil, 145, self.HEIGHT)})
    self.goodNum = storeSoldier
    self:updateTab()
end

function SoldierGoods:geRange()
    local op = getPos(self.flowNode)
    local upRow = math.max(0, round(-op[1]/self.OFFY))
    local lowRow = round((-op[1]+self.HEIGHT+self.OFFY)/self.OFFY)
    local rows = (#self.goodNum+self.PAN_PER_ROW-1)/self.PAN_PER_ROW
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

    local userLevel = global.user:getValue("level")
    local rg = self:getRange()
    for i=rg[1], rg[2]-1, 1 do
        for j=0, self.PAN_PER_ROW-1, 1 do
            local curNum = i*self.PAN_PER_ROW+j
            if curNum >= #self.goodNum then
                break
            end
            local posX = j*self.OFFX
            local posY = i*self.OFFY

            local panel = setAnchor(setContentSize(setPos(addNode(self.flowNode), {posX, posY}), {149, 188}), {0, 0})
            local pb = setAnchor(setSize(addSprite(panel, "goodPanel.png"), {149, 188}), {0, 0})
            
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
        end
    end

end


function SoldierGoods:touchBegan(x, y)
end
function SoldierGoods:touchMoved(x, y)
end
function SoldierGoods:touchEnded(x, y)
end
