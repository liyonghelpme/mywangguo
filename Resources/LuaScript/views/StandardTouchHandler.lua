local sim = require "SimpleJson"
StandardTouchHandler = class()
function StandardTouchHandler:ctor()
    local vs = getVS()
    self.scaMax = 1.50
    --确保最小比例 比屏幕大
    self.scaMin = math.max(0.5, math.max(vs.width/MapWidth, vs.height/MapHeight))
    --self.scaMin = 0.5
    self.bg = nil
end
--world Points 世界坐标的点
--x y id
function StandardTouchHandler:tBegan(touches)
    --print("tBegan", sim:encode(arg))
    self.accMove = 0
    self.lastPos = convertMultiToArr(touches)
end

function StandardTouchHandler:fastScale(sca)
    local oldScale = self.bg:getScale()
    if oldScale+sca >= self.scaMax or oldScale+sca <= self.scaMin then
        return 0
    end
    self.bg:setScale(oldScale+sca)
    return sca
end
function StandardTouchHandler:MoveBack(difx, dify)
    local ox, oy = self.bg:getPosition()
    self.bg:setPosition(ccp(ox+difx, oy+dify))
    local leftBottom = self.bg:convertToNodeSpace(ccp(0, 0))
    local rightTop = self.bg:convertToNodeSpace(ccp(global.director.disSize[1], global.director.disSize[2]))
    if leftBottom.x < 0 and difx > 0 then
        difx = 0
    end
    if leftBottom.y < 0 and dify > 0 then
        dify = 0
    end
    local sz = self.bg:getContentSize()
    if rightTop.x > sz.width and difx < 0 then
        difx = 0
    end
    if rightTop.y > sz.height and dify < 0 then
        dify = 0
    end
    if self.accMove == nil then
        self.accMove = 0
    end
    self.accMove = self.accMove+math.abs(difx)+math.abs(dify)
    self.bg:setPosition(ccp(ox+difx, oy+dify))
end
function StandardTouchHandler:ScaleBack(sca)
    local oldScale = self.bg:getScale()
    if oldScale >= self.scaMax and sca > 0 then
        sca = 0
        return sca
    end
    if oldScale <= self.scaMin and sca < 0 then
        sca = 0
        return sca
    end
    self.bg:setScale(oldScale+sca)

    local leftBottom = self.bg:convertToNodeSpace(ccp(0, 0))
    local rightTop = self.bg:convertToNodeSpace(ccp(global.director.disSize[1], global.director.disSize[2]))
    local sz = self.bg:getContentSize()
    if leftBottom.x < 0 and sca < 0 then
        sca = 0
    end
    if leftBottom.y < 0 and sca < 0 then
        sca = 0
    end
    if rightTop.x > sz.width and sca < 0 then
        sca = 0
    end
    if rightTop.y > sz.height and sca < 0 then
        sca = 0
    end
    self.bg:setScale(oldScale+sca)
    return sca
end
function StandardTouchHandler:adjustMove()
    local leftTop = self.bg:convertToWorldSpace(ccp(0, 0))
    local sz = self.bg:getContentSize()
    local rightBottom = self.bg:convertToWorldSpace(ccp(sz.width, sz.height))
    local difX = 0;
    local difY = 0;
    if leftTop.x > 0 then
        difX = -leftTop.x
    end
    if leftTop.y > 0 then
        difY = -leftTop.y
    end

    local disSize = global.director.disSize
    if rightBottom.x < disSize[1] then
        difX = disSize[1]-rightBottom.x
    end
    if rightBottom.y < disSize[2] then
        difY = disSize[2]-rightBottom.y
    end
    local oldPos = getPos(self.bg)
    setPos(self.bg, {oldPos[1]+difX, oldPos[2]+difY})
end

function StandardTouchHandler:tMoved(touches)
    local oldPos = self.lastPos
    self.lastPos = convertMultiToArr(touches)
    if oldPos == nil then
        return
    end
    --两个点

    if self.lastPos.count >= 2 then
        --不足两个点
        if oldPos.count < 2 then
            return
        end
        local oldDis = distance(oldPos[0], oldPos[1])
        local newDis = distance(self.lastPos[0], self.lastPos[1])
        --print("oldDis newDis", oldDis, newDis)
        local sca = (newDis-oldDis)/100
        if math.abs(sca) < 0.03 then
            return
        end

        --print("sca", sca)
        local difx = oldPos[1][1]-oldPos[0][1]
        local dify = oldPos[1][2]-oldPos[0][2]
        --旧的顶点
        local midOld = {oldPos[0][1]+difx/2, oldPos[0][2]+dify/2}
        
        local oldInBg = self.bg:convertToNodeSpace(ccp(midOld[1], midOld[2]))
        local oldScale = self.bg:getScale()
        sca = self:fastScale(sca)
        local newInBg = self.bg:convertToWorldSpace(oldInBg)
        local move = {midOld[1]-newInBg.x, midOld[2]-newInBg.y}
        if math.abs(move[1]) > 3 or math.abs(move[2]) > 3 then
            self:MoveBack(move[1], move[2])
        end
        self:adjustMove()
        
        --[[
        self.bg:setScale(oldScale)
        sca = self:ScaleBack(sca)

        newInBg = self.bg:convertToWorldSpace(oldInBg)
        move = {midOld[1]-newInBg.x, midOld[2]-newInBg.y}
        self:MoveBack(move[1], move[2])
        --]]
    elseif self.lastPos.count == 1 then
        if oldPos.count >= 1 then
            local difx = self.lastPos[0][1]-oldPos[0][1]
            local dify = self.lastPos[0][2]-oldPos[0][2]
            self:MoveBack(difx, dify)
        end
    end
end
function StandardTouchHandler:tEnded(touches)
    --print("tEnded", sim:encode(touches))

end
function StandardTouchHandler:scaleToMax(sm)
    self.bg:setScale(sm)
end

