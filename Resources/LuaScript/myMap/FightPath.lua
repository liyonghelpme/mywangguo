FightPath = class()
--邻居点是从MapEdge 这个表里面获得的
--MapNode 表里面是所有定点数据
--参考MiaoPeople 寻路和 FightPath 
FightPath = class()
function FightPath:ctor(t)
    self.target = t
end
--只有Road 信息
function FightPath:calcG(x, y)
    local key = getMapKey(x, y)
    local data = self.cells[key]
    local parent = data.parent
    local px, py = getXY(parent)
    dist = 10
    data.gScore = self.cells[parent].gScore+dist
    self.cells[key] = data
end
--没有启发值都一样
function FightPath:calcH(x, y)
    local key = getMapKey(x, y)
    local data = self.cells[key]
    data.hScore = 0
    self.cells[key] = data
end
function FightPath:calcF(x, y)
    local key = getMapKey(x, y)
    local data = self.cells[key]
    data.fScore = data.gScore+data.hScore
end
function FightPath:pushQueue(x, y)
    local key = getMapKey(x, y)
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
function FightPath:checkNeibor(x, y)
    --近的邻居先访问
    --只允许 正边
    local neibors = {
        {x-1, y-1},
        {x+1, y-1},
        {x+1, y+1},
        {x-1, y+1},
    }

    --不能是开始网格的Start只能连接道路 以开始网格附近的道路为条件开始搜索的
    local isStart = false
    if x == self.startPoint[1] and y == self.startPoint[2] then
        isStart = true
    end

    local curKey = getMapKey(x, y)
    --TrainZone 100 100 2400 400
    local buildCell = self.map.mapGridController.mapDict
    if self.cells[curKey].gScore >= 100 then
        return
    end
    for n, nv in ipairs(neibors) do
        local key = getMapKey(nv[1], nv[2])
        local cx, cy = normalToCartesian(nv[1], nv[2])
        --小于左边界 则 只能+x
        --有效范围 受到建造范围的控制
        if cx <= 0 and nv[1] < x then
        elseif cx > MapWidth and nv[1] > x then
        elseif cy < 0 and nv[2] < y then
        elseif cy > MapHeight and nv[2] > y then
        else
            local inOpen = false
            local nS

            local hasRoad = false
            if buildCell[key] ~= nil then
                local bb = buildCell[key][#buildCell[key]][1]
                --道路或者 桥梁 建造好的建筑物
                if bb.picName == 't' then
                    hasRoad = true
                    --print("buildCell Kind Road")
                --同一个建筑物不能多次插入
                --可以到达工厂
                --就近的工厂
                elseif not isStart and bb.picName == 'build' and bb.data.kind == 0 then
                    --是一个可以到达的 去工作的建筑物
                    --建筑物不能贯通周围邻居
                    local oldDist = self.nearby[bb] or 999999
                    self.nearby[bb] = math.min(oldDist, self.cells[curKey].gScore+10)
                    --print("add Building ", bb.id, bb.picName)
                    table.insert(bb.belong, self.target.name)
                    if #bb.belong > 3 then
                        table.remove(bb.belong, 1)
                    end
                    --是自己建筑物的一个网格  加入寻路中
                else
                    --print("no road")
                end
                if bb == self.target then
                    hasRoad = true
                end
            else
                --print("not Road")
            end

            --使用最短路径 更新parent信息  
            if self.cells[key] == nil and hasRoad then
                self.cells[key] = {}
                self.cells[key].parent = curKey
                self:calcG(nv[1], nv[2])
                self:calcH(nv[1], nv[2])
                self:calcF(nv[1], nv[2])
                self:pushQueue(nv[1], nv[2])
            end
        end
    end
end

function FightPath:init(mx, my)
    self.startPoint = {mx, my} 
    self.endPoint = nil
    self.openList = {}
    self.pqDict = {}
    self.closedList = {}
    self.path = {}
    self.cells = {}
    self.nearby = {}

    local sk = getMapKey(mx, my)
    self.cells[sk] = {}
    self.cells[sk].gScore = 0
    self:calcH(mx, my)
    self:calcF(mx, my)
    self:pushQueue(mx, my)

    self.searchYet = false
    self.inSearch = true
end


--checkNeibor 不超过10个深度
function FightPath:update()
    local n = 1
    --所有建筑物  水面 道路
    local buildCell = self.target.map.mapGridController.mapDict
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
            local x, y = getXY(point)
            self:checkNeibor(x, y)
        end
        n = n+1
    end

    if #self.openList == 0 then
        self.searchYet = true
        self.inSearch = false
    end
    --print("miaoPath find over", getLen(self.allBuilding))

    self.map:updateCells(self.cells, self.map.cells)
end
function FightPath:getAllFreeFactory()
    local temp = {}
    local count = 0
    for k, v in pairs(self.nearby) do
        if k.id == 5 and k.owner == nil then
            --table.insert(temp, k)
            temp[k] = true
            count = count+1
        end
    end
    print("free factory ", count)
    return temp
end

--不同类型的建筑物 考量的目标 是不同的 
--对于采矿场来讲 只考虑 附近的 工厂 和 矿坑即可
--不空闲的Mine 也可以
--后续可以考虑距离因素 最近的矿坑
function FightPath:getAllFreeMine()
    local temp = {}
    local count = 0
    for k, v in pairs(self.nearby) do
        if k.id == 28 and k.owner == nil then
            temp[k] = true
            count = count+1
        end
    end
    return temp, count
end

function FightPath:getAllFreeTree()
    local temp = {}
    local count = 0
    for k, v in pairs(self.nearby) do
        --树木成熟状态
        if k.id == 29 and k.owner == nil and k.funcBuild.showState == 3 then
            temp[k] = true
            count = count+1
        end
    end
    return temp, count
end
