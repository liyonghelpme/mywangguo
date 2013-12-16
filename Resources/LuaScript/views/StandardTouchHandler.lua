--越界情况 普通move 确保target move targetScale 设定 targetScale targetMove时检查一下即可
local sim = require "SimpleJson"
StandardTouchHandler = class()
function StandardTouchHandler:ctor()
    local vs = getVS()
    self.scaMax = 1.50
    --确保最小比例 比屏幕大
    self.scaMin = math.max(0.5, math.max(vs.width/MapWidth, vs.height/MapHeight))
    --self.scaMin = 0.5
    self.bg = nil
    self.targetMove = nil
    self.targetScale = nil
    self.targetAnchor = nil
    --追踪所有的touch对象
    self.touchValue = {count=0}
end
--调整状态的函数
function StandardTouchHandler:update(diff)
    if self.targetMove ~= nil then
        local pos = getPos(self.bg)
        local smooth = diff*5
        smooth = math.min(smooth, 1)
        local px = pos[1]*(1-smooth)+self.targetMove[1]*smooth
        local py = pos[2]*(1-smooth)+self.targetMove[2]*smooth
        setPos(self.bg, {px, py})
    end
    if self.targetScale ~= nil then
        local sca = getScale(self.bg)
        local smooth = diff*5
        smooth = math.min(smooth, 1)
        local ns = sca*(1-smooth)+self.targetScale*smooth
        setScale(self.bg, ns)
    end
end
--world Points 世界坐标的点
--x y id
function StandardTouchHandler:tBegan(touches)
    --print("tBegan", sim:encode(touches))
    self.accMove = 0
    local temp1, temp2 = convertMultiToArr(touches)
    updateTouchTable(self.touchValue, temp2)
end

function StandardTouchHandler:fastScale(sca, midOld)
    --print("fastScale", sca, sim:encode(midOld))
    if self.targetScale == nil then
        self.targetScale = self.bg:getScale()
    end
    local newScale = self.targetScale*sca
    
    if newScale >= self.scaMax and sca > 1 then
        newScale = self.targetScale
    end
    if newScale <= self.scaMin and sca < 1 then
        newScale = self.targetScale
    end
    local sz = self.bg:getContentSize() 
    local wid = newScale*sz.width
    local hei = newScale*sz.height
    local vs = getVS()
    local tm = self.targetMove or getPos(self.bg)

    if tm[1]+wid <= vs.width+5 and sca < 1 then
        newScale = self.targetScale 
    end
    if tm[2]+hei <= vs.height+5 and sca < 1 then
        newScale = self.targetScale
    end

    --oldScale oldPos
    local scale = getScale(self.bg)
    local wid, hei = scale*sz.width, scale*sz.height
    local pos = getPos(self.bg)
    local ax, ay = (midOld[1]-pos[1])/wid, (midOld[2]-pos[2])/hei

    local wid, hei = newScale*sz.width, newScale*sz.height
    local px, py = midOld[1]-wid*ax, midOld[2]-hei*ay

    self.targetScale = newScale
    --midOld scale 再加上平移

    --平移anchor点到 newScale 下相同的位置
    if self.targetMove == nil then
        self.targetMove = getPos(self.bg)
    end
    self:MoveBack(px-self.targetMove[1], py-self.targetMove[2])
end

function StandardTouchHandler:setBg(b)
    self.bg = b
end
function StandardTouchHandler:MoveBack(difx, dify)

    if self.targetMove == nil then
        self.targetMove = getPos(self.bg)
    end
    self.targetMove = {self.targetMove[1]+difx, self.targetMove[2]+dify}
    local sz = self.bg:getContentSize() 
    --要使用目标scale
    --local sca = self.bg:getScale()
    local sca = self.targetScale or self.bg:getScale()
    local wid = sca*sz.width
    local hei = sca*sz.height
    local vs = getVS()
    local tm = self.targetMove
    --保护边界
    --print("target Move is ", sim:encode(tm))
    if tm[1] >= 5 and difx > 0 then
        self.targetMove[1] = tm[1]-difx
    end
    if tm[1]+wid <= vs.width+5 and difx < 0  then
        self.targetMove[1] = tm[1]-difx    
    end

    if tm[2] >= 5 and dify > 0 then
        self.targetMove[2] = tm[2]-dify
    end
    if tm[2]+hei <= vs.height+5 and dify < 0 then
        self.targetMove[2] = tm[2]-dify
    end

    --[[
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
    --]]
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
    --print("tMoved", sim:encode(touches))
    local oldPos = copyTouchTable(self.touchValue)
    --local oldPos = self.lastPos
    --self.lastPos = convertMultiToArr(touches)
    local _, temp = convertMultiToArr(touches)
    updateTouchTable(self.touchValue, temp)
    --[[
    if oldPos == nil then
        return
    end
    --]]
    --两个点

    --加入惯性支持 move惯性运动 设定移动目标 检测移动是否越界 可以保守估计范围
    --MapWdith - 20 MapHeight - 20
    if self.touchValue.count == 2 and self.touchValue[0] ~= nil and self.touchValue[1] ~= nil then
        --不足两个点
        if oldPos.count < 2 or oldPos.count > 2 or oldPos[0] == nil or oldPos[1] == nil then
            self.targetMove = getPos(self.bg)
            return
        end
        local oldDis = distance(oldPos[0], oldPos[1])
        local newDis = distance(self.touchValue[0], self.touchValue[1])
        ----print("oldDis newDis", oldDis, newDis)
        --[[
        local sca = (newDis-oldDis)/100
        if math.abs(sca) < 0.03 then
            return
        end
        --]]

        ----print("sca", sca)
        local difx = oldPos[1][1]-oldPos[0][1]
        local dify = oldPos[1][2]-oldPos[0][2]
        --旧的顶点
        local midOld = {(oldPos[0][1]+oldPos[1][1])/2, (oldPos[0][2]+oldPos[1][2])/2}
        local midNew = {(self.touchValue[0][1]+self.touchValue[1][1])/2, (self.touchValue[0][2]+self.touchValue[1][2])/2}
        
        local sca = newDis/oldDis
        self:fastScale(sca, midOld)
        --local oldInBg = self.bg:convertToNodeSpace(ccp(midOld[1], midOld[2]))
        --local oldScale = self.bg:getScale()
        --sca = self:fastScale(sca)
        local move = {midNew[1]-midOld[1], midNew[2]-midOld[2]}
        --print("touch just Move ok?", sim:encode(move))
        self:MoveBack(move[1], move[2])

        --local newInBg = self.bg:convertToWorldSpace(oldInBg)
        --local move = {midOld[1]-newInBg.x, midOld[2]-newInBg.y}
        --[[
        local move = {midNew[1]-midOld[1], midNew[2]-midOld[2]}
        if math.abs(move[1]) > 3 or math.abs(move[2]) > 3 then
            self:MoveBack(move[1], move[2])
        end
        self:adjustMove()
        --]]
        
    elseif self.touchValue.count == 1 and self.touchValue[0] ~= nil then
        if oldPos.count == 1 and oldPos[0] ~= nil then
            local difx = self.touchValue[0][1]-oldPos[0][1]
            local dify = self.touchValue[0][2]-oldPos[0][2]
            --if math.abs(difx)+math.abs(dify) < 200 then
                self:MoveBack(difx, dify)
            --end
        end
    end
end
function StandardTouchHandler:tEnded(touches)
    --print("tEnded", sim:encode(touches))
    local _, temp = convertMultiToArr(touches)
    clearTouchTable(self.touchValue, temp)    
end
function StandardTouchHandler:tCanceled(touches)
    --print("tCanceled", sim:encode(touches))
end

function StandardTouchHandler:scaleToMax(sm)
    self.bg:setScale(sm)
end

