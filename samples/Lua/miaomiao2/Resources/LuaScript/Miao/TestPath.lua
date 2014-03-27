TestPath = class()
function TestPath:ctor(tar)
    self.target = tar
end

function TestPath:calcG(x, y)
    local key = getMapKey(x, y)
    local data = self.cells[key]
    local parent = data.parent
    local px, py = getXY(parent)
    dist = 10
    data.gScore = self.cells[parent].gScore+dist
    self.cells[key] = data
end
function TestPath:calcH(x, y)
    local key = getMapKey(x, y)
    local data = self.cells[key]
    local dx = math.abs(self.overPos[1]-x)
    local dy = math.abs(self.overPos[2]-y)
    data.hScore = dx+dy
    self.cells[key] = data
end
function TestPath:calcF(x, y)
    local key = getMapKey(x, y)
    local data = self.cells[key]
    data.fScore = data.gScore+data.hScore
end
function TestPath:pushQueue(x, y)
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
function TestPath:init(mx, my, ex, ey)
    self.startPoint = {mx, my} 
    self.overPos = {ex, ey}
    self.endPoint = nil
    self.openList = {}
    self.pqDict = {}
    self.closedList = {}
    self.path = {}
    self.cells = {}
    
    local sk = getMapKey(mx, my)
    self.cells[sk] = {}
    self.cells[sk].gScore = 0
    self:calcH(mx, my)
    self:calcF(mx, my)
    self:pushQueue(mx, my)
    self.searchYet = false
end

--有道路才能行走
--或者直接在游戏中就把路径生成好了
function TestPath:checkNeibor(x, y)
    --近的邻居先访问
    --只允许 正边
    local neibors = {
        {x-1, y-1},
        {x+1, y-1},
        {x+1, y+1},
        {x-1, y+1},
    }
    local curKey = getMapKey(x, y)
    --TrainZone 100 100 2400 400
    local buildCell = self.target.map.mapGridController.mapDict
    for n, nv in ipairs(neibors) do
        local key = getMapKey(nv[1], nv[2])
        --小于左边界 则 只能+x
        --有效范围 受到建造范围的控制
        local inOpen = false
        local nS

        local hasRoad = false
        if buildCell[key] ~= nil then
            print("go along road")
            hasRoad = true
        else
            print("not Road")
        end

        --使用最短路径 更新parent信息  
        if self.closedList[key] == nil and hasRoad then
            if self.cells[key] == nil then
                self.cells[key] = {}
                self.cells[key].parent = curKey
                self:calcG(nv[1], nv[2])
                self:calcH(nv[1], nv[2])
                self:calcF(nv[1], nv[2])
                self:pushQueue(nv[1], nv[2])
            else
                local oldParent = self.cells[key]['parent']
                local oldGScore = self.cells[key]['gScore']
                local oldFScore = self.cells[key]['fScore']

                self.cells[key].parent = curKey
                self:calcG(nv[1], nv[2])
                if self.cells[key].gScore >= oldGScore then
                    self.cells[key]['parent'] = oldParent
                    self.cells[key]['gScore'] = oldGScore
                else
                    self:calcH(nv[1], nv[2])
                    self:calcF(nv[1], nv[2])
                    --从旧的possible 中删除对象 
                    local oldPossible = self.pqDict[oldFScore]
                    for k, v in ipairs(oldPossible) do
                        if v == key then
                            table.remove(oldPossible, k)
                            break
                        end
                    end
                    self:pushQueue(nv[1], nv[2])
                end
            end
        end
    end

    self.closedList[curKey] = true
end

function TestPath:update()
    local n = 1
    while n < 50 do
        if #self.openList == 0 then
            break
        end
        local fScore = heapq.heappop(self.openList)
        local possible = self.pqDict[fScore]
        if #possible > 0 then
            local n = math.random(#possible)
            local point = table.remove(possible, n)
            local x, y = getXY(point)
            if x == self.overPos[1] and y == self.overPos[2] then
                self.endPoint = self.overPos
            else
                self:checkNeibor(x, y)
            end
        end
        n = n+1
    end

    if #self.openList == 0 then
        self.searchYet = true
    end
end

function TestPath:getPath()
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
        --不包括最后一个点
        for i =#path, 1, -1 do
            table.insert(self.path, {path[i][1], path[i][2]})
        end
        print("getPath", simple.encode(self.endPoint), simple.encode(path))
    end
    return self.path
end
