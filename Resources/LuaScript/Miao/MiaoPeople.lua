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
    IN_HOME = 7,
    GO_AWAY = 8,
}
function MiaoPeople:ctor(m, data)
    self.map = m
    self.state = PEOPLE_STATE.FREE
    self.health = 0
    self.maxHealth = 5
    self.tired = false
    self.goBack = nil
    self.myHouse = nil
    self.lastState = nil
    self.id = data.id
    self.name = str(math.random(99999))

    self.bg = CCNode:create()
    --不同人物动画的角度也有可能不同
    self.changeDirNode = addSprite(self.bg, "people"..self.id.."_lb_0.png")
    local sz = self.changeDirNode:getContentSize()
    --人物图像向上偏移一半高度 到达块中心位置
    setAnchor(self.changeDirNode, {Logic.people[1].ax/sz.width, (sz.height-Logic.people[1].ay-SIZEY)/sz.height})
    self.stateLabel = ui.newBMFontLabel({text=str(self.state), size=30})
    setPos(self.stateLabel, {0, 100})
    self.bg:addChild(self.stateLabel)
    
    createAnimation("people"..self.id.."_lb", "people"..self.id.."_lb_%d.png", 0, 4, 1, 0.5, false)
    createAnimation("people"..self.id.."_lt", "people"..self.id.."_lt_%d.png", 0, 4, 1, 0.5, false)
    createAnimation("people"..self.id.."_rb", "people"..self.id.."_rb_%d.png", 0, 4, 1, 0.5, false)
    createAnimation("people"..self.id.."_rt", "people"..self.id.."_rt_%d.png", 0, 4, 1, 0.5, false)
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

function MiaoPeople:checkHealth()
    --普通农民才会tired
    if self.state == PEOPLE_STATE.FREE and self.health <= 0 and self.id == 1 then
        self.tired = true
    end
end
--寻找我的住宅

--在家也是工作的一种形式
--dump PeopleState
--dump HouseState
--dump RoadState
--dump SeaState
--dump BuildingState
--只寻找 已经建造好的建筑物作为目标
--农田建筑物的zord 总是比layer 人类要低的所以 用一个farmLayer 添加比较合适
function MiaoPeople:findHouse()
    if self.myHouse == nil then
        local allBuild = self.map.mapGridController.allBuildings
        for k, v in pairs(allBuild) do
            --找house
            if k.owner == nil and k.state == BUILD_STATE.FREE and k.id == 1 then
                self.myHouse = k
                print("findHouse setOwner")
                k:setOwner(self)
                break
            end
        end
    end
    self.predictTarget = self.myHouse
end
function MiaoPeople:findWorkBuilding()
    local allBuild = self.map.mapGridController.allBuildings
    local num = getLen(allBuild)
    for k, v in pairs(allBuild) do
        --休息结束
        --找农田
        local ret = false
        --商人 不需要 占用 建筑物
        if self.id == 2 then
            ret = (k.picName == 'build' and k.id == 2 and k.state == BUILD_STATE.FREE)
        --农民要占用建筑物
        elseif self.id == 1 then
            ret = (k.picName == 'build' and k.owner == nil and k.id == 2 and k.state == BUILD_STATE.FREE) 
        end
        if ret then
            print("findWorkBuilding setOwner")
            --农民才设定要对农田占用 放置别人也来开垦 
            if self.id == 1 then
                k:setOwner(self)
            end
            self.predictTarget = k
            break
        end
    end
end

function MiaoPeople:update(diff)
    self:checkHealth()
    self:findPath(diff)
    self:initFind(diff) 
    self:doFind(diff)
    self:initMove(diff)
    self:doMove(diff)
    self:doWork(diff)
    self.stateLabel:setString(str(self.state))
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
        --local mx, my = cartesianToNormal(p[1], p[2])
        --mx, my = sameOdd(mx, my)
        local mxy = getPosMapFloat(1, 1, p[1], p[2])
        local mx, my = mxy[3], mxy[4]
        
        self.startPoint = {mx, my} 
        self.endPoint = nil
        self.openList = {}
        self.pqDict = {}
        self.closedList = {}
        self.path = {}
        self.cells = {}

        self.predictTarget = nil
        self.predictEnd = nil
        self.realTarget = nil
        
        --寻找最近的建筑物 去工作 使用简单的洪水查找法 不要使用最近建筑物查找法 人物多思考一会即可
        --只在有路的块上面行走 picName == 't'
        --寻找住宅
        if self.tired then
            self:findHouse()
        elseif self.goBack then
            self.predictTarget = self.map.backPoint
        else
            --寻找要去收割的建筑物
            self:findWorkBuilding()
            if self.predictTarget == nil then
                --普通村民
                if self.id == 1 then
                    self:findHouse()
                --商人往回走
                elseif self.id == 2 then
                    self.goBack = true
                end
            end
        end

        --所有cartesianToNormal 全部转化成getBuildMap 来计算
        if self.predictTarget ~= nil then
            local bp = getPos(self.predictTarget.bg)
            --local tx, ty = cartesianToNormal(bp[1], bp[2])
            local txy = getPosMapFloat(1, 1, bp[1], bp[2])
            local tx, ty = txy[3], txy[4]
            self.predictEnd = {tx, ty}

            local sk = getMapKey(mx, my)
            self.cells[sk] = {}
            self.cells[sk].gScore = 0
            self:calcH(mx, my)
            self:calcF(mx, my)
            self:pushQueue(mx, my)

        else
            --没找到可以工作的目标 则回去休息
            self.state = PEOPLE_STATE.START_FIND
        end
    end
end
function MiaoPeople:doFind(diff)
    --寻路访问的节点超过n个 则停止
    if self.state == PEOPLE_STATE.IN_FIND then
        local n = 1
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
                --道路 和 建筑物 都在cell 里面
                if buildCell[key] ~= nil and buildCell[key][#buildCell[key]][1] == self.predictTarget then
                --if buildCell[key] ~= nil and buildCell[key][#buildCell[key]][1] ~= self.oldPredictTarget and buildCell[key][#buildCell[key]][1].picName == 'build' then
                    self.endPoint = {x, y} 
                    self.realTarget = buildCell[key][#buildCell[key]][1]
                    print("findTarget", self.predictTarget.picName, self.realTarget.picName)
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
        if self.endPoint ~= nil then
            print("Find Path Over")
            self.state = PEOPLE_STATE.FIND
            self:getPath()

            self.oldPredictTarget = self.predictTarget
            self.openList = nil
            self.closedList = nil
            self.pqDict = nil
            self.cells = nil
        elseif #self.openList == 0 then
        --无路可走了
            self.state = PEOPLE_STATE.FREE

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

        --开始从房间里面出来了 调整一下初始的位置 people 所在网格靠近附近邻居的位置 中点
        if self.lastState == PEOPLE_STATE.IN_HOME then
            print("init Home Pos", simple.encode(self.path[2]), simple.encode(self.lastEndPoint))
            local mx = (self.path[2][1]+self.lastEndPoint[1])/2
            local my = (self.path[2][2]+self.lastEndPoint[2])/2
            local np = setBuildMap({1, 1, mx, my})
            setPos(self.bg, np)
            self:setZord()
            self.bg:setVisible(true)
            self.lastState = nil
        end

        self.state = PEOPLE_STATE.IN_MOVE
        self.curPoint = 1
        self.passTime = 1

        self.map:updatePath(self.path)
        self.map:switchPathSol()
    end
end
function MiaoPeople:setDir(x, y)
    local p = getPos(self.bg)
    local dx = x-p[1]
    local dy = y-p[2]
    if dx > 0 then
        if dy > 0 then
            self.changeDirNode:stopAllActions()
            local ani = CCAnimationCache:sharedAnimationCache():animationByName("people"..self.id.."_rt")
            self.changeDirNode:runAction(repeatForever(CCAnimate:create(ani)))
        elseif dy < 0 then
            self.changeDirNode:stopAllActions()
            local ani = CCAnimationCache:sharedAnimationCache():animationByName("people"..self.id.."_rb")
            self.changeDirNode:runAction(repeatForever(CCAnimate:create(ani)))
        end
    elseif dx < 0 then
        if dy > 0 then
            self.changeDirNode:stopAllActions()
            local ani = CCAnimationCache:sharedAnimationCache():animationByName("people"..self.id.."_lt")
            self.changeDirNode:runAction(repeatForever(CCAnimate:create(ani)))
        elseif dy < 0 then
            self.changeDirNode:stopAllActions()
            local ani = CCAnimationCache:sharedAnimationCache():animationByName("people"..self.id.."_lb")
            self.changeDirNode:runAction(repeatForever(CCAnimate:create(ani)))
        end
    end
end
function MiaoPeople:doMove(diff)
    if self.state == PEOPLE_STATE.IN_MOVE then
        self.passTime = self.passTime+diff
        if self.passTime > 1 then
            self.passTime = 0
            local nextPoint = self.curPoint+1
            if self.realTarget.deleted then
                self.realTarget = nil
                self.state = PEOPLE_STATE.FREE
            elseif nextPoint > #self.path then
                --去休息
                if self.realTarget ~= nil and self.realTarget.picName == 'build' and self.realTarget.id == 1 then
                    self.state = PEOPLE_STATE.IN_HOME
                    self.restTime = 0
                    self.bg:setVisible(false)
                    local np = setBuildMap({1, 1, self.tempEndPoint[1], self.tempEndPoint[2]})
                    setPos(self.bg, np)
                --移动到了目的点 开始 往回走了
                elseif self.id == 2 then
                    if self.goBack == nil then
                        self.state = PEOPLE_STATE.FREE
                        self.goBack = true
                    else
                        print("GO AWAY Now!")
                        self.state = PEOPLE_STATE.GO_AWAY
                        self.changeDirNode:runAction(sequence({fadeout(1, callfunc(nil, removeSelf, self.bg))}))
                        self.map.mapGridController:removeSoldier(self)
                    end
                else
                    --self.state = PEOPLE_STATE.FREE
                    self.state = PEOPLE_STATE.IN_WORK
                    self.workTime = 0
                end
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
--农田的 3个状态 
--没有农作物
--农作物 阶段1
--农作物 阶段2
--人物播放劳作动画
function MiaoPeople:doWork(diff)
    if self.state == PEOPLE_STATE.IN_WORK then
        self.workTime = self.workTime+diff
        if self.workTime > 1 then
            self.workTime = 0
            self.health = self.health-1
            self.realTarget:changeWorkNum(1)
            --种地的时候 tired 直接 回去即可
            if self.health <= 0 then
                self.state = PEOPLE_STATE.FREE 
                self.realTarget:setOwner(nil)
                self.realTarget = nil
            end
        end
    elseif self.state == PEOPLE_STATE.IN_HOME then
        self.restTime = self.restTime+diff
        if self.restTime > 1 then
            self.restTime = 0
            self.health = self.health +1
        end
        --下一步开始寻路 去工作
        --如果找到可以工作的地方再出现并且根据 目标调整当前位置
        --找到可以去工作的目标 前提满足了出现在门口位置 四处找一个坐标可以移动
        --调整当前的位置 
        --开始行走
        self.health = math.min(self.health, self.maxHealth)
        if self.health >= self.maxHealth then
            self.tired = false
            self.lastState = PEOPLE_STATE.IN_HOME
            self.lastEndPoint = self.tempEndPoint
            self.state = PEOPLE_STATE.FREE
            --self.bg:setVisible(true)
        end
    end
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
    --只允许 正边
    local neibors = {
        --{x, y-2},
        --{x+2, y},
        --{x, y+2},
        --{x-2, y},
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
        --有效范围 受到建造范围的控制
        if cx <= 0 and nv[1] < x then
        elseif cx > 1000 and nv[1] > x then
        elseif cy < 0 and nv[2] < y then
        elseif cy > 1000 and nv[2] > y then
        else
            local inOpen = false
            local nS
            --不在open 表里面
            --首次加入
            --or staticObstacle[key] ~= nil 
            --没有河流阻碍
            --同一个位置 图层逐渐加上去的 所以检测最后一个层是什么类型即可
            --[[
            local hasRiver = false
            if buildCell[key] ~= nil then
                if buildCell[key][#buildCell[key] ][1].picName == 's' then
                    hasRiver = true
                end
            end
            --]]

            --TODO 只有是ROAD 才能走过
            local hasRoad = false
            if buildCell[key] ~= nil then
                local bb = buildCell[key][#buildCell[key]][1]
                --道路或者 桥梁 建造好的建筑物
                if bb.state == BUILD_STATE.FREE and (bb.picName == 't' or (bb.picName == 'build' and bb.id == 3)) then
                    hasRoad = true
                    print("buildCell Kind Road")
                else
                    print("no road")
                end
            else
                print("not Road")
            end
            --未遍历过 这个邻居 
            --没有 硬性阻碍
            --没有河流
            --有道路
            --如果有建筑物 也可以移动 进去
            local hasBuild = false
            --到达自己的目标建筑物
            if buildCell[key] ~= nil and buildCell[key][#buildCell[key]][1]  == self.predictTarget then
                hasBuild = true
            end
            --使用最短路径 更新parent信息  
            if self.cells[key] == nil and staticObstacle[key] == nil  and (hasRoad or hasBuild) then
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
        print("getPath", simple.encode(self.endPoint), simple.encode(path))
        
        --走到房间边缘消失掉
        if self.predictTarget.id == 1 then
            local mx, my = (path[1][1]+path[2][1])/2, (path[1][2]+path[2][2])/2
            table.insert(self.path, {mx, my})
            self.tempEndPoint = {path[1][1], path[1][2]}
        elseif self.predictTarget.id == 2 then
            --进入农田中心去工作
            table.insert(self.path, path[1])
        --商人走到路中心位置
        elseif self.predictTarget.picName == 'backPoint' then
            table.insert(self.path, path[1])
        end
        --设置全局Cell 中此处的权重+10
        if #self.path > 0 then
            self.endPoint = self.path[#self.path]
            --self.map:setCell(self.endPoint)
        end
    end
end
--从房子里面跳出来了
function MiaoPeople:clearHouse()
    print("clearHouse", self.myHouse)
    self.myHouse = nil
    if self.state == PEOPLE_STATE.IN_HOME then
        self.tired = false
        self.state = PEOPLE_STATE.FREE
        self.bg:setVisible(true)
    end
end
function MiaoPeople:clearWork()
    if self.state == PEOPLE_STATE.IN_WORK then
        self.state = PEOPLE_STATE.FREE
    end
end
