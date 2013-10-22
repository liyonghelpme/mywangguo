require "heapq"
MiaoPeople = class()
PEOPLE_STATE = {
    FREE = 0,
    START_FIND = 1,
    IN_FIND = 2,
    FIND = 3,
    IN_MOVE = 4,
    START_WORK = 5,
    IN_WORK = 6,
}
function MiaoPeople:ctor(m)
    self.map = m
    self.bg = CCNode:create()
    self.changeDirNode = addSprite(self.bg, "people1_lb_0.png")
    self.state = PEOPLE_STATE.FREE
    createAnimation("people1_lb", "people1_lb_%d.png", 0, 4, 1, 0.5, false)
    createAnimation("people1_lt", "people1_lt_%d.png", 0, 4, 1, 0.5, false)
    createAnimation("people1_rb", "people1_rb_%d.png", 0, 4, 1, 0.5, false)
    createAnimation("people1_rt", "people1_rt_%d.png", 0, 4, 1, 0.5, false)
    registerEnterOrExit(self)
end
function MiaoPeople:setZord()
    local p = getPos(self.bg)
    local zOrd = MAX_BUILD_ZORD-p[2]
    self.bg:setZOrder(zOrd)
end
function MiaoPeople:enterScene()
    registerUpdate(self)
end
function MiaoPeople:exitScene()
end
function MiaoPeople:update(diff)
    self:findPath(diff)
    self:initFind(diff) 
    self:doFind(diff)
    self:initMove(diff)
    self:doMove(diff)
    self:doWork(diff)
end
function MiaoPeople:findPath(diff)
    if self.state == PEOPLE_STATE.FREE then
        if self.map.curSol == nil or self.map.curSol == self or self.map.curSol.state ~= PEOPLE_STATE.IN_FIND then
            self.map.curSol = self
            self.state = PEOPLE_STATE.START_FIND
        end
    end
end
function MiaoPeople:initFind(diff)
    if self.state == PEOPLE_STATE.START_FIND then
        self.state = PEOPLE_STATE.IN_FIND
        local p = getPos(self.bg)
        local mx, my = cartesianToNormal(p[1], p[2])
        mx, my = sameOdd(mx, my)
        
        self.startPoint = {mx, my} 
        self.endPoint = nil
        self.openList = {}
        self.pqDict = {}
        self.closedList = {}
        self.path = {}
        self.cells = {}

        self.predictTarget = nil
        self.predictEnd = nil
        
        --寻找最近的建筑物 去工作 使用简单的洪水查找法 不要使用最近建筑物查找法 人物多思考一会即可
        --只在有路的块上面行走 picName == 't'
        --[[
        local allBuild = self.map.mapGridController.allBuildings
        local minDis = 99999999
        for k, v in pairs(allBuild) do
            --建筑物未被摧毁
            if k.picName == 'build' then
                local bp = getPos(k.bg) 
                local d = distance2(p, bp)
                if d < minDis then
                    minDis = d
                    self.predictTarget = k
                end
            end
        end
        --]]
        --只找经营建筑物
        local allBuild = self.map.mapGridController.allBuildings
        local num = getLen(allBuild)
        local s = math.random(num)
        local i = 1
        for k, v in pairs(allBuild) do
            if i == s then
                self.predictTarget = k
                break
            end
            i = i+1
        end

        if self.predictTarget ~= nil then
            local bp = getPos(self.predictTarget.bg)
            local tx, ty = cartesianToNormal(bp[1], bp[2])
            self.predictEnd = {tx, ty}

            local sk = getMapKey(mx, my)
            self.cells[sk] = {}
            self.cells[sk].gScore = 0
            self:calcH(mx, my)
            self:calcF(mx, my)
            self:pushQueue(mx, my)
        else
            self.state = PEOPLE_STATE.START_FIND
        end
    end
end
function MiaoPeople:doFind(diff)
    --寻路访问的节点超过n个 则停止
    if self.state == PEOPLE_STATE.IN_FIND then
        local n = 0
        --所有建筑物  水面 道路
        local buildCell = self.map.mapGridController.mapDict
        local staticObstacle = self.map.staticObstacle 
        while n < 50 do
            if #self.openList == 0 then
                break
            end
            local fScore = heapq.heappop(self.openList)
            local possible = self.pqDict[fScore]
            if #possible > 0 then
                --print("possible", simple.encode(possible))
                local n = math.random(#possible)
                local point = table.remove(possible, n)
                --local point = table.remove(possible)
                --print("point", point)
                local x, y = getXY(point)
                --print("x, y", x, y)
                --仿射坐标
                --local ax, ay = normalToAffine(x, y)
                local key = getMapKey(x, y)
                --普通建筑物则是终点
                --行走的时候 可以绕过建筑物的 如果士兵跑到建筑物里面去了 
                --不是上次的目标
                --走到一个建筑物附近了
                if buildCell[key] ~= nil and buildCell[key][1][1] ~= self.oldPredictTarget and buildCell[key][#buildCell[key]][1].picName == 'build' then
                    self.endPoint = {x, y} 
                    --找到建筑了
                    break
                end

                if self.endPoint == nil then
                    self:checkNeibor(x, y)
                end
            end
            n = n+1
        end
        self.map:updateCells(self.cells, self.map.cells)
        --找到路径
        if #self.openList == 0 or self.endPoint ~= nil then
            self.state = PEOPLE_STATE.FIND
            self:getPath()

            self.oldPredictTarget = self.predictTarget
            self.openList = nil
            self.closedList = nil
            self.pqDict = nil
            self.cells = nil
        --下一帧继续寻路
        else
        end
    end
end
function MiaoPeople:initMove(diff)
    if self.state == PEOPLE_STATE.FIND then
        self.state = PEOPLE_STATE.IN_MOVE
        self.curPoint = 1
        self.passTime = 1

        self.map:updatePath(self.path)
        self.map:switchPathSol()
    end
end
function MiaoPeople:setDir(x, y)
end
function MiaoPeople:doMove(diff)
    if self.state == PEOPLE_STATE.IN_MOVE then
        self.passTime = self.passTime+diff
        if self.passTime > 1 then
            self.passTime = 0
            local nextPoint = self.curPoint+1
            if nextPoint > #self.path then
                self.state = PEOPLE_STATE.FREE
                self:setZord()
            else
                local np = self.path[nextPoint]
                local cxy = setBuildMap({1, 1, np[1], np[2]})
                self.bg:runAction(moveto(1, cxy[1], cxy[2]))    
                self:setDir(cxy[1], cxy[2])
                self:setZord()
                self.curPoint = self.curPoint+1
            end
        end
    end
end
function MiaoPeople:doWork(diff)
end


--保证所有计算之前先给cells 赋值
function MiaoPeople:calcG(x, y)
    local key = getMapKey(x, y)
    local data = self.cells[key]

    --if data == nil then
    --    data = {}
    --end
    local parent = data.parent
    local px, py = getXY(parent)
    local difX = math.abs(px-x)
    local difY = math.abs(py-y)
    local dist = 14
    if difX > 0 and difY > 0 then
        dist = 10
    end

    --此块有建筑物 要绕过
    local buildCell = self.map.mapGridController.mapDict
    --是建筑物 不能穿过
    if buildCell[key] ~= nil and buildCell[key][1][1].picName == 'build' then
        dist = 30
    end
    --多个人走到一个cell上面
    if self.map.cells[key] == true then
        dist = 200
    end

    data.gScore = self.cells[parent].gScore+dist

    self.cells[key] = data
end
--寻找的工作目标 空闲建筑物 锁定
function MiaoPeople:calcH(x, y)
    local key = getMapKey(x, y)
    local data = self.cells[key]

    data.hScore = 10*(math.abs(x-self.predictEnd[1])+math.abs(y-self.predictEnd[2]))
    self.cells[key] = data
end
function MiaoPeople:calcF(x, y)
    local key = getMapKey(x, y)
    local data = self.cells[key]
    data.fScore = data.gScore+data.hScore
end
function MiaoPeople:pushQueue(x, y)
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
function MiaoPeople:checkNeibor(x, y)
    --近的邻居先访问
    local neibors = {
        {x, y-2},
        {x+2, y},
        {x, y+2},
        {x-2, y},
        {x-1, y-1},
        {x+1, y-1},
        {x+1, y+1},
        {x-1, y+1},
    }
    local curKey = getMapKey(x, y)
    --TrainZone 100 100 2400 400
    local staticObstacle = self.map.staticObstacle 
    local buildCell = self.map.mapGridController.mapDict
    --多个layer 的数据 海水是一个Layer initCell staticObstacle bridge 其它建筑物是另外的cell 
    for n, nv in ipairs(neibors) do
        local key = getMapKey(nv[1], nv[2])
        local cx, cy = normalToCartesian(nv[1], nv[2])
        --小于左边界 则 只能+x
        if cx <= 100 and nv[1] < x then
        elseif cx > 1000 and nv[1] > x then
        elseif cy < 100 and nv[2] < y then
        elseif cy > 1000 and nv[2] > y then
        
        else
            local inOpen = false
            local nS
            --不在open 表里面
            --首次加入
            --or staticObstacle[key] ~= nil 
            --没有河流阻碍
            local hasRiver = false
            --同一个位置 图层逐渐加上去的 所以检测最后一个层是什么类型即可
            if buildCell[key] ~= nil then
                if buildCell[key][#buildCell[key]][1].picName == 's' then
                    hasRiver = true
                end
            end
            --TODO 只有是ROAD 才能走过
            local hasRoad = false
            if self.cells[key] == nil and staticObstacle[key] == nil and not hasRiver then
                self.cells[key] = {}
                self.cells[key].parent = curKey
                self:calcG(nv[1], nv[2])
                self:calcH(nv[1], nv[2])
                self:calcF(nv[1], nv[2])
                self:pushQueue(nv[1], nv[2])
            --已经在open表里面了 不用再加入了
            else
            end
        end
    end

end
--根据endPoint cells 逆向找到回去的路径
function MiaoPeople:getPath()
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
        for i =#path, 2, -1 do
            table.insert(self.path, {path[i][1], path[i][2]})
        end
        --设置全局Cell 中此处的权重+10
        if #self.path > 0 then
            self.endPoint = self.path[#self.path]
            self.map:setCell(self.endPoint)
        end
    end
end
