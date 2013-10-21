require "heapq"
require "views.Arrow"
Soldier = class()
SOLDIER_STATE = {
    FREE = 0,
    START_FIND = 1,
    IN_FIND = 2,
    FIND = 3,
    IN_MOVE = 4,
    START_ATTACK = 5,
    IN_ATTACK = 6,
}
function Soldier:ctor(map, data, pd)
    self.map = map
    self.data = data
    self.privateData = pd
    self.kind = data.id 
    self.dead = false
    --在mapGridController 中的编号

    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("soldierm"..self.kind..".plist")

    self.bg = setAnchor(CCNode:create(), {0.5, 0.5})
    createAnimation("soldierm"..self.kind, "ss"..self.kind.."m%d.png", 0, 6, 1, 0.5, true)
    if BattleLogic.inBattle then
        --print("init Attack")
        --Don't forget to load plist first
        CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("soldiera"..self.kind..".plist")
        createAnimation("soldiera"..self.kind, "ss"..self.kind.."a%d.png", 0, 7, 1, 1, true) 
    end
    self.changeDirNode = setAnchor(CCSprite:createWithSpriteFrameName("ss"..self.kind.."m0.png"), {0.5, 0})
    self.bg:addChild(self.changeDirNode)
    self.changeDirNode:setScale(0.7)
    --self.bg:setContentSize(self.changeDirNode:getContentSize())

    local animation = CCAnimationCache:sharedAnimationCache():animationByName("soldierm"..self.kind)
    self.changeDirNode:runAction(repeatForever(CCAnimate:create(animation)))

    self.bg:setPosition(ccp(100, 200))
    self.state = SOLDIER_STATE.FREE 
    self.passTime = 0
    self.waitTime = 0
    self.oldPredictTarget = nil
    self.health = 100
    self.maxHealth = 100
    
    if BattleLogic.inBattle then
        local sz = self.changeDirNode:getContentSize()
        local rh = math.max(sz.height, 50)
        self.healthBar = setScale(setPos(CCSprite:create("mapSolBloodBar1.png"), {0, rh}), 0.4)
        
        self.bg:addChild(self.healthBar)
        self.innerBar = setAnchor(setPos(addSprite(self.healthBar, "mapSolBloodRed1.png"), {2, 2}), {0, 0})
    
        self.healthBar:setVisible(false)
    end

    registerEnterOrExit(self)

end
function Soldier:enterScene()
    registerUpdate(self)
end
function Soldier:exitScene()
end
function Soldier:setPos(p)
end
--寻到到目的建筑物的路径之后
--开始移动
function Soldier:update(diff)
    if not self.dead and not BattleLogic.paused then
        self:findPath(diff)
        self:doMove(diff)
        self:doAttack(diff)
    end
end
function Soldier:doAttack(diff)
    if self.state == SOLDIER_STATE.START_ATTACK then
        self.state = SOLDIER_STATE.IN_ATTACK
        self.changeDirNode:stopAllActions()
        local animation = CCAnimationCache:sharedAnimationCache():animationByName("soldiera"..self.kind)
        print("animation", animation)
        self.changeDirNode:runAction(repeatForever(CCAnimate:create(animation)))
        self.attackTime = 0
        self.attackTarget = self.predictTarget
    end
    if self.state == SOLDIER_STATE.IN_ATTACK then
        if self.attackTarget.broken == true then
            self.state = SOLDIER_STATE.FREE
            self.map:clearCell(self.endPoint)
            self.changeDirNode:stopAllActions()
            local animation = CCAnimationCache:sharedAnimationCache():animationByName("soldierm"..self.kind)
            self.changeDirNode:runAction(repeatForever(CCAnimate:create(animation)))
            return
        end
        self.attackTime = self.attackTime+diff
        if self.attackTime >= 1 then
            self.attackTime = self.attackTime - 1
            --弓箭手 发射弓箭
            if self.kind == 23 then
                local start = getPos(self.bg)
                start[2] = start[2]+15
                local over = getPos(self.attackTarget.bg)
                over[1] = over[1]+math.random(20)-10
                over[2] = over[2]+math.random(20)+20
                self.map.bg:addChild(Arrow.new(self, self.attackTarget, start, over).bg, MAX_BUILD_ZORD)
            else
                self.attackTarget:doHarm(10)
            end
        end
    end
end
--保证所有计算之前先给cells 赋值
function Soldier:calcG(x, y)
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
    if buildCell[key] ~= nil then
        dist = 30
    end
    if self.map.cells[key] == true then
        dist = 200
    end

    data.gScore = self.cells[parent].gScore+dist

    self.cells[key] = data
end
function Soldier:calcH(x, y)
    local key = getMapKey(x, y)
    local data = self.cells[key]
    --if data == nil then
    --    data = {}
    --end

    data.hScore = 10*(math.abs(x-self.predictEnd[1])+math.abs(y-self.predictEnd[2]))
    self.cells[key] = data
end
function Soldier:calcF(x, y)
    local key = getMapKey(x, y)
    local data = self.cells[key]
    data.fScore = data.gScore+data.hScore
end
function Soldier:pushQueue(x, y)
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
function Soldier:checkNeibor(x, y)
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
    for n, nv in ipairs(neibors) do
        local key = getMapKey(nv[1], nv[2])
        local cx, cy = normalToCartesian(nv[1], nv[2])
        --小于左边界 则 只能+x
        if cx <= 100 and nv[1] < x then

        elseif cx > 3000 and nv[1] > x then
        elseif cy < 100 and nv[2] < y then
        elseif cy > 700 and nv[2] > y then
        
        else
            local inOpen = false
            local nS
            --不在open 表里面
            --首次加入
            --or staticObstacle[key] ~= nil 
            --没有河流阻碍
            if self.cells[key] == nil and staticObstacle[key] == nil then
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

--在buildLayer 加入一个zord 超大的node 用于在 所有之后clear寻路 MAX+1 
--只有第一个soldier有机会寻路


--多用内存 多个 寻路可以并行进行 
--后期改进成 只有一个寻路同时进行
--泛洪 寻找最近的建筑物 向那里移动 door 位置
--
--
--寻路使用正则坐标
--建筑物使用仿射坐标
--将正则坐标转换成仿射坐标进行碰撞检测
--
--
--mapDict 里面存的也是建筑物的normal坐标 不过是建筑物 最下面一个菱形块的中心坐标
function Soldier:findPath(diff)
    if self.state == SOLDIER_STATE.FREE then
        --如果 当前抢占的寻路对象没有在寻路 那么 就抢占它
        if self.map.curSol == nil or self.map.curSol == self or self.map.curSol.state ~= SOLDIER_STATE.IN_FIND then
            self.map.curSol = self
            self.state = SOLDIER_STATE.START_FIND
        end
    end
    if self.state == SOLDIER_STATE.START_FIND then
        self.state = SOLDIER_STATE.IN_FIND
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
        
        --攻击的时候 寻找最近的建筑物
        if BattleLogic.inBattle then
            local allBuild = self.map.mapGridController.allBuildings
            local minDis = 99999999
            for k, v in pairs(allBuild) do
                --建筑物未被摧毁
                if k.broken == false then
                    local bp = getPos(k.bg) 
                    local d = distance2(p, bp)
                    if d < minDis then
                        minDis = d
                        self.predictTarget = k
                    end
                end
            end
        --经营随便找一个建筑物
        else
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
        end
        --[[
        --3000 * 3000 = 90000
        --]]


        if self.predictTarget ~= nil then
            --self.oldPredictTarget = self.predictTarget
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
            self.state = SOLDIER_STATE.START_FIND
        end
    end
    --寻路访问的节点超过n个 则停止
    if self.state == SOLDIER_STATE.IN_FIND then
        local n = 0
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
                if buildCell[key] ~= nil and buildCell[key][1][1] ~= self.oldPredictTarget and buildCell[key][1][1].broken == false then
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
            self.state = SOLDIER_STATE.FIND
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

function Soldier:setDir(cx, cy)
    local p = getPos(self.bg)
    if p[1]-cx < 0 then
        self.changeDirNode:setScaleX(-0.7)
    elseif p[1]-cx > 0 then
        self.changeDirNode:setScaleX(0.7)
    end
end
function Soldier:setZord()
    local p = getPos(self.bg)
    local zOrd = MAX_BUILD_ZORD-p[2]
    self.bg:setZOrder(zOrd)
end
function Soldier:doMove(diff)
    if self.state == SOLDIER_STATE.FIND then
        self.state = SOLDIER_STATE.IN_MOVE
        self.curPoint = 1
        self.passTime = 1

        --print("myPath", simple.encode(self.path))
        self.map:updatePath(self.path)
        
        self.map:switchPathSol()
    end

    if self.state == SOLDIER_STATE.IN_MOVE then
        self.passTime = self.passTime+diff
        if self.passTime > 1 then
            self.passTime = 0
            if BattleLogic.inBattle then
                local curPos = getPos(self.bg)
                local endPos = setBuildMap({1, 1, self.endPoint[1], self.endPoint[2]})
                local attR = (self.data.range)*(self.data.range)*32*32 
                if distance2(curPos, endPos) < attR then
                    self.state = SOLDIER_STATE.START_ATTACK 
                    self.map:clearCell(self.endPoint)
                    self:setZord()
                    return 
                end
            end

            local nextPoint = self.curPoint+1
            if nextPoint > #self.path then
                if BattleLogic.inBattle == false then
                    self.state = SOLDIER_STATE.FREE
                else
                    --开始攻击则清理cell 数据
                    self.state = SOLDIER_STATE.START_ATTACK
                    self.map:clearCell(self.endPoint)
                end
                --移动到目的地调整zord
                self:setZord()
            else
                local np = self.path[nextPoint]
                local cxy = setBuildMap({1, 1, np[1], np[2]})
                --local cx, cy = normalToCartesian(np[1], np[2])
                --cxy = {cx, cy}
                self.bg:runAction(moveto(1, cxy[1], cxy[2]))    
                self:setDir(cxy[1], cxy[2])
                self:setZord()
                self.curPoint = self.curPoint+1
            end
        end
        --[[
        self.passTime = self.passTime+diff
        if self.passTime > 3 then
            self.passTime = 0
            print("myPath", simple.encode(self.path))
            self.map:updatePath(self.path)
        end
        --]]
    end
end
function Soldier:doHarm(n)
    if self.dead then
        return
    end
    self.health = self.health - n
    self.health = math.max(self.health, 0)
    if self.health <= 0 then
        self.dead = true
    end

    local vs = self.healthBar:isVisible()
    if not vs then
        self.healthBar:setVisible(true)
        self.healthBar:runAction(fadein(0.5))
        self.innerBar:runAction(fadein(0.5))
    end
    local b = self.health/self.maxHealth
    self.innerBar:runAction(scaleto(0.2, b, 1)) 
    if self.dead then
        self.healthBar:setVisible(false)
        local function fadeAll(bg)
            local child = bg:getChildren()
            local n = bg:getChildrenCount()
            if n > 0 then
                for i=0, n-1, 1 do
                    local c = child:objectAtIndex(i)
                    --print("whos c", c)
                    if c.runAction ~= nil then
                        c:runAction(fadeout(0.4))
                        fadeAll(c)
                    end
                end
            end
        end
        BattleLogic.killKind(self.kind)
        global.user:killSoldier(self.kind)
        self.bg:runAction(callfunc(nil, fadeAll, self.bg))
    end
end

