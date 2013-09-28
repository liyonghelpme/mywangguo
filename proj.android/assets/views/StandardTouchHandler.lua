local sim = require "SimpleJson"
StandardTouchHandler = class()
function StandardTouchHandler:ctor()
    self.scaMax = 1.50
    self.scaMin = 0.5
    self.bg = nil
end
--world Points 世界坐标的点
--x y id
function StandardTouchHandler:tBegan(touches)
    --print("tBegan", sim:encode(arg))
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
function StandardTouchHandler:tMoved(touches)
    local oldPos = self.lastPos
    self.lastPos = convertMultiToArr(touches)
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
        self:MoveBack(move[1], move[2])
        self.bg:setScale(oldScale)
        sca = self:ScaleBack(sca)

        newInBg = self.bg:convertToWorldSpace(oldInBg)
        move = {midOld[1]-newInBg.x, midOld[2]-newInBg.y}
        self:MoveBack(move[1], move[2])
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

