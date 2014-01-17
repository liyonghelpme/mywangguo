FightPath = class()
--邻居点是从MapEdge 这个表里面获得的
--MapNode 表里面是所有定点数据
--参考MiaoPeople 寻路和 FightPath 
FightPath = class()
function FightPath:ctor(t)
    self.target = t
end
--只有Road 信息
function FightPath:calcG(key)
    local data = self.cells[key]
    local parent = data.parent
    dist = 10
    data.gScore = self.cells[parent].gScore+dist
    self.cells[key] = data
end
--没有启发值都一样
function FightPath:calcH(key)
    local data = self.cells[key]
    data.hScore = 0
    self.cells[key] = data
end
function FightPath:calcF(key)
    local data = self.cells[key]
    data.fScore = data.gScore+data.hScore
end
function FightPath:pushQueue(key)
    local fScore = self.cells[key].fScore
    heapq.heappush(self.openList, fScore)
    local fDict = self.pqDict[fScore]
    if fDict == nil then
        fDict = {}
    end
    table.insert(fDict, key)
    self.pqDict[fScore] = fDict
end

--传入的NodeId MapEdge 里面搜索
--edge
function FightPath:checkNeibor(nid)
    local neibors = MapEdge[nid]
    local curKey = nid
    print("checkNeibor", nid, simple.encode(MapEdge))
    for n, nv in ipairs(neibors) do
        local key = nv
        --找到目标点
        --[[
        if nv == self.attackTarget then
            self.endPoint = nv
            break
        end
        --]]
        --使用最短路径 更新parent信息 第一次邻居信息  
        if self.cells[key] == nil then
            self.cells[key] = {}
            self.cells[key].parent = curKey
            self:calcG(nv)
            self:calcH(nv)
            self:calcF(nv)
            self:pushQueue(nv)
        end
    end
end
--node id
--MapNode
function FightPath:init(nid, tid)
    self.startPoint = nid 
    self.attackTarget = tid
    self.endPoint = nil
    self.openList = {}
    self.pqDict = {}
    self.closedList = {}
    self.path = {}
    self.cells = {}
    self.nearby = {}

    local sk = nid
    self.cells[sk] = {}
    self.cells[sk].gScore = 0
    self:calcH(nid)
    self:calcF(nid)
    self:pushQueue(nid)

    self.searchYet = false
    self.inSearch = true
end


--checkNeibor 不超过10个深度
function FightPath:update()
    local n = 1
    --所有建筑物  水面 道路
    --print("FightPath update")
    while n < 10 do
        if #self.openList == 0 then
            break
        end
        local fScore = heapq.heappop(self.openList)
        local possible = self.pqDict[fScore]
        if #possible > 0 then
            local n = math.random(#possible)
            local point = table.remove(possible, n)
            --找到攻击目标了
            if point == self.attackTarget then
                self.endPoint = point
                break
            end
            self:checkNeibor(point)
        end
        n = n+1
    end

    if #self.openList == 0 or self.endPoint ~= nil then
        self.searchYet = true
        self.inSearch = false
    end
    --print("miaoPath find over", getLen(self.allBuilding))
    --self.map:updateCells(self.cells, self.map.cells)
end

--到该点的路径
function FightPath:getPath()
    if self.endPoint ~= nil then
        local path = {self.endPoint}
        local parent = self.cells[self.endPoint].parent
        while parent ~= nil do
            table.insert(path, parent)
            if parent == self.startPoint then
                break
            end
            parent = self.cells[parent].parent
        end
        --包括最后一个点 只是在行走的时候 调整一下 到最后一个点的时候 要消失 或者每半个作为一个移动单位 
        for i =#path, 1, -1 do
            table.insert(self.path, path[i])
        end
        print("get Map Cat Path", simple.encode(self.endPoint), simple.encode(self.path))
        self.target.scene:updateDebugNode(self.path)
    end
    return self.path
end
