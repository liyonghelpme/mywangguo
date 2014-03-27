require "heapq"
MiaoPath = class()
--泛滥洪水 方法搜索
--统计所有遍历的kind == 0 的建筑物
function MiaoPath:ctor(tar)
    self.target = tar
    self.map = self.target.map
    --public 设置为dirty
    self.dirty = false
end

--保证所有计算之前先给cells 赋值
function MiaoPath:calcG(x, y)
    local key = getMapKey(x, y)
    local data = self.cells[key]
    local parent = data.parent
    local px, py = getXY(parent)
    dist = 10
    data.gScore = self.cells[parent].gScore+dist
    self.cells[key] = data
end
--没有启发值都一样
function MiaoPath:calcH(x, y)
    local key = getMapKey(x, y)
    local data = self.cells[key]
    data.hScore = 0
    self.cells[key] = data
end
function MiaoPath:calcF(x, y)
    local key = getMapKey(x, y)
    local data = self.cells[key]
    data.fScore = data.gScore+data.hScore
end
function MiaoPath:pushQueue(x, y)
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
--先检测近的邻居 再检测远的邻居
function MiaoPath:checkNeibor(x, y)
    --近的邻居先访问
    --只允许 正边
    local neibors = {
        {x-1, y-1},
        {x+1, y-1},
        {x+1, y+1},
        {x-1, y+1},
    }
    local isStart = false
    if x == self.startPoint[1] and y == self.startPoint[2] then
        isStart = true
    end
    local curKey = getMapKey(x, y)
    local curRoad = self.cells[curKey].road

    --TrainZone 100 100 2400 400
    local staticObstacle = self.map.staticObstacle 
    local buildCell = self.map.mapGridController.mapDict
    --农民不能超过10格 商人无限制
    if self.cells[curKey].gScore >= 100 and self.target.data.kind == 1 then
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
            local bb
            if buildCell[key] ~= nil then
                bb = buildCell[key][#buildCell[key]][1]
                --道路或者 桥梁 建造好的建筑物
                if bb.state == BUILD_STATE.FREE and (bb.picName == 't' or (bb.picName == 'build' and bb.id == 3)) then
                    hasRoad = true
                    --print("buildCell Kind Road")
                --同一个建筑物不能多次插入
                elseif not isStart and  bb.picName == 'build' and bb.data.kind == 0 then
                    --是一个可以到达的 去工作的建筑物
                    --建筑物不能贯通周围邻居
                    --矿坑 检查道路是在斜坡上面 还是下面
                    local mineOk = true
                    if bb.id == 28 then
                        local ax, ay, height = bb:getAxAyHeight() 
                        print("curRoad is ", curRoad)
                        if curRoad ~= nil then
                            local rax, ray, rhei = curRoad:getAxAyHeight()
                            print("my height road height", ax, ay, height, rax, ray, rhei)
                            --矿点和道路不在同一高度 
                            if height ~= rhei then
                                mineOk = false
                                print("mine not ok")
                            end
                        --矿点没有道路？
                        else
                            mineOk = false
                        end
                    end
                    if mineOk then
                        local oldDist = self.allBuilding[bb] or 999999
                        self.allBuilding[bb] = math.min(oldDist, self.cells[curKey].gScore+10)
                        table.insert(bb.belong, self.target.name)
                        if #bb.belong > 3 then
                            table.remove(bb.belong, 1)
                        end
                    else
                        print("mine not belong")
                    end
                    --print("add Building ", bb.id, bb.picName)
                else
                    --print("no road")
                end
            else
                --print("not Road")
            end

            --使用最短路径 更新parent信息  
            if self.cells[key] == nil and staticObstacle[key] == nil  and hasRoad then
                self.cells[key] = {}
                self.cells[key].parent = curKey
                --该点对应的road 对象
                self.cells[key].road = bb
                self:calcG(nv[1], nv[2])
                self:calcH(nv[1], nv[2])
                self:calcF(nv[1], nv[2])
                self:pushQueue(nv[1], nv[2])
            end
        end
    end
end

function MiaoPath:init(mx, my)
    self.startPoint = {mx, my} 
    self.endPoint = nil
    self.openList = {}
    self.pqDict = {}
    self.closedList = {}
    self.path = {}
    self.cells = {}

    self.allBuilding = {}

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
function MiaoPath:update()
    local n = 1
    --所有建筑物  水面 道路
    local buildCell = self.target.map.mapGridController.mapDict
    local staticObstacle = self.target.map.staticObstacle 
    --print("MiaoPath update")
    while n < 2 do
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

publicMiaoPath = nil  
