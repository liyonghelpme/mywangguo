require "heapq"
Soldier = class()
SOLDIER_STATE = {
    FREE = 0,
    IN_FIND = 1,
    FIND = 2,
    IN_MOVE = 3,

}
function Soldier:ctor(map, data, pd)
    self.map = map
    self.data = data
    self.privateData = pd
    self.kind = data.id 

    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("soldierm"..self.kind..".plist")

    self.bg = CCNode:create()
    createAnimation("soldierm"..self.kind, "ss"..self.kind.."m%d.png", 0, 6, 1, 0.5, true)
    self.changeDirNode = CCSprite:createWithSpriteFrameName("ss"..self.kind.."m0.png")
    self.bg:addChild(self.changeDirNode)
    self.changeDirNode:setScale(0.7)

    self.bg:setPosition(ccp(100, 200))
    self.state = SOLDIER_STATE.FREE 
    registerUpdate(self)
    registerEnterOrExit(self)

end
function Soldier:setPos(p)
end
function Soldier:update(diff)
    self:findPath(diff)
    self:doMove(diff)
end

function Soldier:calcG(x, y)
    local key = getMapKey(x, y)
    local data = self.cells[key]
    if data == nil then
        data = {}
    end
    local parent = data.parent
    local px, py = getXY(parent)
    local difX = math.abs(px-x)
    local diyY = math.abs(py-y)
    local dist = 10
    if difX > 0 and difY > 0 then
        dist = 14
    end
    data.gScore = self.cells[parent].gScore+dist

    self.cells[key] = data
end
function Soldier:calcH(x, y)
    local key = getMapKey(x, y)
    local data = self.cells[key]
    if data == nil then
        data = {}
    end
    data.hScore = 0
    self.cells[key] = data
end
function Soldier:calcF(x, y)
    local key = getMapKey(x, y)
    local data = self.cells[key]
    data.fScore = data.gScore+data.hScore
end
function Soldier:pushQueue(x, y)
end
function Soldier:checkNeibor(x, y)

end
function Soldier:getPath()
    if self.endPoint ~= nil then
        
        local path = {self.endPoint}
        local parent = self.cells[getMapKey(self.endPoint[1], self.endPoint[2])].parent
        while parent ~= nil do
            local x, y = getXY(parent)
            table.insert(path, {x, y})
            if x == self.startPoint[1] and y == self.startPoint[2] then
                break
            end
            parent = self.cells[parent].parent
        end
        for i =#path, 1, -1 do
            table.insert(self.path, {path[i][1], path[i][2]})
        end
    end
end

--在buildLayer 加入一个zord 超大的node 用于在 所有之后clear寻路 MAX+1 
--只有第一个soldier有机会寻路


--多用内存 多个 寻路可以并行进行 
--后期改进成 只有一个寻路同时进行
--泛洪 寻找最近的建筑物 向那里移动 door 位置
function Soldier:findPath(diff)
    if self.state == SOLDIER_STATE.FREE then
        self.state = SOLDIER_STATE.IN_FIND
        local p = getPos(self.bg)
        local m = getPosMap(1, 1, p[1], p[2])
        
        self.startPoint = {m[3], m[4]} 
        self.endPoint = nil
        self.openList = {}
        self.pqDict = {}
        self.closedList = {}
        self.path = {}
        
        self.cells[getMapKey(m[3], m[4])].gScore = 0
        self:calcH(m[3], m[4])
        self:calcF(m[3], m[4])
        self:pushQueue(m[3], m[4])
    end
    --寻路访问的节点超过n个 则停止
    if self.state == SOLDIER_STATE.IN_FIND then
        local n = 0
        local buildCell = self.map.mapGridController.mapDict
        while n < 100 do
            if #self.openList == 0 then
                break
            end
            local fScore = heapq.heappop(self.openList)
            local possible = self.pqDict[fScore]
            if #possible > 0 then
                local point = table.remove(possible)
                local x, y = getXY(point)
                local key = point
                if buildCell[key] ~= nil then
                    self.endPoint = {x, y} 
                end
            end
            if self.endPoint == nil then
                self:checkNeibor(x, y)
            end
            n = n+1
        end
        --找到路径
        if #self.openList == 0 then
            self.state = SOLDIER_STATE.FIND
            self:getPath()

            self.openList = nil
            self.closedList = nil
            self.pqDict = nil
            self.cells = nil

        --下一帧继续寻路
        else
        end
    end
end

function Soldier:doMove(diff)
    if self.state == SOLDIER_STATE.FIND then
        self.state = SOLDIER_STATE.IN_MOVE
    end
    if self.state == SOLDIER_STATE.IN_MOVE then
    end
end
