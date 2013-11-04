Monster = class()
function Monster:ctor(m)
    self.map = m
    self.kind = 190
    self.data = getData(GOODS_KIND.SOLDIER, self.kind) 
    self.state = SOLDIER_STATE.FREE
    self.dead = false
    self.inattack = false
    --应该奖励多少水晶和经验呢
    self.health = self.data.healthBoundary
    self.maxHealth = self.data.healthBoundary
    --攻击怪兽的士兵
    self.attackerList = {}
    self.safeTime = 0

    self.bg = setAnchor(CCLayer:create(), {0.5, 0.5})
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("soldierm"..self.kind..".plist")
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("soldiera"..self.kind..".plist")

    createAnimation("soldierm"..self.kind, "ss"..self.kind.."m%d.png", 0, 6, 1, 0.5, true)
    createAnimation("soldiera"..self.kind, "ss"..self.kind.."a%d.png", 0, 6, 1, 0.5, true)
    self.changeDirNode = setAnchor(CCSprite:createWithSpriteFrameName("ss"..self.kind.."m0.png"), {0.5, 0})
    self.bg:addChild(self.changeDirNode)
    self.changeDirNode:setScale(0.7)
    
    local animation = CCAnimationCache:sharedAnimationCache():animationByName("soldierm"..self.kind)
    self.moveAni = repeatForever(CCAnimate:create(animation))
    self.changeDirNode:runAction(self.moveAni)
    self.shadow = addSprite(self.bg, "roleShadow.png")

    local rx = math.random(400)-200
    local ry = math.random(200)-100
    self.bg:setPosition(ccp(2500+rx, 300+ry))

    local sz = self.changeDirNode:getContentSize()
    local rh = math.max(sz.height, 50)
    self.healthBar = setScale(setPos(CCSprite:create("mapSolBloodBar1.png"), {0, rh}), 0.4)
    
    self.bg:addChild(self.healthBar)
    self.innerBar = setAnchor(setPos(addSprite(self.healthBar, "mapSolBloodRed1.png"), {2, 2}), {0, 0})

    self.healthBar:setVisible(false)
    
    registerEnterOrExit(self)
    self.idleTime = 0
    
    registerTouch(self)
end
function Monster:addAttacker(a)
    table.insert(self.attackerList, a)
end
function Monster:touchBegan(x, y)
    local p = getPos(self.bg)
    local map = getPosMapFloat(1, 1, p[1], p[2])
    local mp = self.map.bg:convertToNodeSpace(ccp(x, y))
    local tp = getPosMapFloat(1, 1, mp.x, mp.y-SIZEY)
    if tp[3] == map[3] and tp[4] == map[4] then
        return true
    end
    return false
end
function Monster:touchMoved(x, y)
end

function Monster:touchEnded(x, y)
    local att = ui.newBMFontLabel({text="ATTACK!!!", size=40, color={102, 0, 0}})
    global.director.curScene.bg:addChild(att, MAX_BUILD_ZORD)
    setPos(att, {x, y})
    att:runAction(sequence({fadein(0.4), repeatN(sequence({moveby(0.1, -5, 0), moveby(0.1, 5, 0)}), 4), fadeout(0.2), callfunc(nil, removeSelf, att)}))
    --设定士兵攻击某个怪兽
    Event:sendMsg(EVENT_TYPE.ATTACK_ME, self)
end

function Monster:enterScene()
    registerUpdate(self)
    Event:registerEvent(EVENT_TYPE.ATTACK_ME, self)
end
function Monster:receiveMsg(name, msg)
    if name == EVENT_TYPE.ATTACK_ME then
        if msg ~= self then
            --没有在战斗过程中 则 可以取消攻击
            --如果在战斗过程中则 继续攻击
            if self.state ~= SOLDIER_STATE.IN_ATTACK then
                self.inattack = false
                self.attackerList = {}
            end
        --准备接受士兵的攻击
        else
            self.inattack = true
        end
    end
end
function Monster:exitScene()
    Event:unregisterEvent(EVENT_TYPE.ATTACK_ME, self)
end
function Monster:update(diff)
    self.safeTime = self.safeTime+diff
    if not self.dead then
        self:findPath(diff)
        self:doMove(diff)
        self:doAttack(diff)
        if self.safeTime > 20 then
            self.safeTime = 0
            local vs = getVS()
            self:touchEnded(vs.width/2, vs.height/2)
        end
    end
end
--超过一定的空闲时间
function Monster:findPath(diff)
    if self.state == SOLDIER_STATE.FREE then
        self.idleTime = self.idleTime+diff
        if self.map.curSol == nil or self.map.curSol == self or self.map.curSol.state ~= SOLDIER_STATE.IN_FIND then

            if self.idleTime > 6 and self.inattack == false then
                self.idleTime = 0
                self.map.curSol = self
                self.state = SOLDIER_STATE.START_FIND
            else
                if self.idleAct == nil then
                    local function ci()
                        self.idleAct = nil
                    end
                    self.idleAct = sequence({jumpBy(1, 10, 0, 20, 1), jumpBy(1, -10, -0, 20, 1), callfunc(nil, ci)})
                    self.shadow:runAction(
                        sequence({
                            spawn({moveby(1, 5, 0), sequence({scaleto(0.5, 0.7, 0.7), scaleto(0.5, 1, 1)})}), 
                            spawn({moveby(1, -5, 0), sequence({scaleto(0.5, 0.7, 0.7), scaleto(0.5, 1, 1)})})
                        })
                    )
                    self.changeDirNode:runAction(self.idleAct)
                end
            end
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
        self.totalFind = 0
        self.minPoint = nil --到达目标最近的点

        self.predictTarget = nil
        self.predictEnd = nil
        
        --攻击的时候 寻找最近的建筑物
        --导出瞎走 不要超出地图边界 +-50*+-50 的周围范围
        local dx = math.random(100)+100
        local dir = math.random(2)
        if dir == 1 then
            dx = -dx
        end
        local dy = math.random(100)+100
        dir = math.random(2)
        if dir == 1 then
            dy = -dy
        end
        local tx, ty = p[1]+dx, p[2]+dy
        local map = getPosMapFloat(1, 1, tx, ty)
        self.predictTarget = {map[3], map[4]}
        self.predictEnd = {map[3], map[4]}
        --当前点
        self.minPoint = {mx, my}


        local sk = getMapKey(mx, my)
        self.cells[sk] = {}
        self.cells[sk].gScore = 0
        self:calcH(mx, my)
        self:calcF(mx, my)
        self:pushQueue(mx, my)
        self.minHScore = self.cells[sk].hScore 
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
                --该格子是一个建筑物
                --该点到目标点的距离比较近 上一个点是当前点的父亲也可以
                local hScore = self.cells[key].hScore
                if hScore <= self.minHScore then
                    self.minHScore = hScore
                    self.minPoint = {x, y} 
                end

                if (x == self.predictEnd[1] and y == self.predictEnd[2]) or self.totalFind >= 100 then
                    --self.endPoint = {x, y} 
                    --找到建筑了
                    self.endPoint = self.minPoint
                    break
                end
                if self.endPoint == nil then
                    self:checkNeibor(x, y)
                end
            end
            n = n+1
        end
        self.map:updateCells(self.cells, self.map.cells, self.predictEnd)
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
        self.totalFind = self.totalFind+n
    end
end
function Monster:doMove(diff)
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
            --被攻击就不要移动了
            if self.inattack then
                self.state = SOLDIER_STATE.FREE
                self:setZord()
                self.map:clearCell(self.endPoint)
            else
                local nextPoint = self.curPoint+1
                if nextPoint > #self.path then
                    self.state = SOLDIER_STATE.FREE
                    --移动到目的地调整zord
                    self:setZord()
                    self.map:clearCell(self.endPoint)
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
        end
    end
end
--后期优化可以通过cell 来判定是否有附近的
function Monster:doAttack(diff)
    if self.state == SOLDIER_STATE.FREE then
        if self.inattack then
            local p = getPos(self.bg)
            local myMap = getPosMapFloat(1, 1, p[1], p[2])
            for k, v in ipairs(self.attackerList) do
                if not v.dead then
                    local kp = getPos(v.bg)
                    local omap = getPosMapFloat(1, 1, kp[1], kp[2])
                    local dx = math.abs(myMap[1]-omap[1])
                    local dy = math.abs(myMap[2]-omap[2])
                    if math.abs(dx)+math.abs(dy) <= 2 then
                        self.state = SOLDIER_STATE.START_ATTACK                
                        self.attackTarget = v
                        self.attackTime = 0
                        self:setDir(kp[1], kp[2])
                        self:setZord()
                        break
                    end
                end
            end
        end
    end
    if self.state == SOLDIER_STATE.START_ATTACK then
        self.state = SOLDIER_STATE.IN_ATTACK
        --self.changeDirNode:stopAllActions()
        if self.moveAni ~= nil then
            self.changeDirNode:stopAction(self.moveAni)
            self.moveAni = nil
        end
        if self.attAni ~= nil then
            self.changeDirNode:stopAction(self.attAni)
            self.attAni = nil
        end
        local animation = CCAnimationCache:sharedAnimationCache():animationByName("soldiera"..self.kind)
        --print("animation", animation)
        self.attAni = repeatForever(CCAnimate:create(animation))
        self.changeDirNode:runAction(self.attAni)
        self.attackTime = 0
    end
    if self.state == SOLDIER_STATE.IN_ATTACK then
        if self.attackTarget.dead then
            self.state = SOLDIER_STATE.FREE
            self.map:clearCell(self.endPoint)
            if self.attAni ~= nil then
                self.changeDirNode:stopAction(self.attAni)
                self.attAni = nil
            end
            if self.moveAni ~= nil then
                self.changeDirNode:stopAction(self.moveAni)
                self.moveAni = nil
            end
            local animation = CCAnimationCache:sharedAnimationCache():animationByName("soldierm"..self.kind)
            self.moveAni = repeatForever(CCAnimate:create(animation))
            self.changeDirNode:runAction(self.moveAni)
        else
            self.attackTime = self.attackTime+diff
            if self.attackTime >= self.data.attSpeed then
                self.attackTime = 0
                self.attackTarget:doHarm(self.data.attack)
            end
        end
    end
end



--保证所有计算之前先给cells 赋值
function Monster:calcG(x, y)
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
    --建筑物 阻挡移动的块 和 阻挡放置的块不同
    if buildCell[key] ~= nil and buildCell[key][1][2] == 1 then
        dist = 30
    end
    if self.map.cells[key] == true then
        dist = 200
    end

    data.gScore = self.cells[parent].gScore+dist

    self.cells[key] = data
end
function Monster:calcH(x, y)
    local key = getMapKey(x, y)
    local data = self.cells[key]
    --if data == nil then
    --    data = {}
    --end

    data.hScore = 10*(math.abs(x-self.predictEnd[1])+math.abs(y-self.predictEnd[2]))
    self.cells[key] = data
end
function Monster:calcF(x, y)
    local key = getMapKey(x, y)
    local data = self.cells[key]
    data.fScore = data.gScore+data.hScore
end
function Monster:pushQueue(x, y)
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
function Monster:checkNeibor(x, y)
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
        if cx <= 2000 and nv[1] < x then

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
function Monster:getPath()
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

function Monster:setZord()
    local p = getPos(self.bg)
    local zOrd = MAX_BUILD_ZORD-p[2]
    self.bg:setZOrder(zOrd)
end

function Monster:setDir(cx, cy)
    local p = getPos(self.bg)
    if p[1]-cx < 0 then
        self.changeDirNode:setScaleX(-0.7)
    elseif p[1]-cx > 0 then
        self.changeDirNode:setScaleX(0.7)
    end
end

function Monster:doHarm(n)
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
        self.bg:runAction(sequence({callfunc(nil, fadeAll, self.bg), delaytime(1), callfunc(self.map.mapGridController, self.map.mapGridController.removeSoldier, self)}))

        local k = math.random(2)
        local rw = 'silver'
        if k == 1 then
            rw = 'crystal'
        end
        --杀死一只怪兽 就清理一次killSol 还是士兵死亡了就同步一次士兵
        local gain = dict({{rw, self.data.crystal}, {'exp', self.data.crystal}})
        global.user:doAdd(gain)
        global.director.curScene.bg:addChild(FlyObject.new(self.changeDirNode, gain, nil, nil).bg)
        sendReq("killMonster", dict({{"uid", global.user.uid}, {"gain", simple.encode(gain)}}))
    end
end
