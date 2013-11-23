require "heapq"
require "views.Arrow"
require "views.SoldierFunc"
require "views.Archer"
require "views.Warrior"
require "views.Magic"
require "views.BirdMan"

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
    self.tryAttackTarget = nil
    --士兵空闲状态下 就会以这个tryAttackTarget 为目标移动的

    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("soldierm"..self.kind..".plist")

    self.bg = setAnchor(CCNode:create(), {0.5, 0.5})
    createAnimation("soldierm"..self.kind, "ss"..self.kind.."m%d.png", 0, 6, 1, 0.5, true)
    --if BattleLogic.inBattle then
        --print("init Attack")
        --Don't forget to load plist first
    --end
    self.changeDirNode = setAnchor(CCSprite:createWithSpriteFrameName("ss"..self.kind.."m0.png"), {0.5, 0})
    self.bg:addChild(self.changeDirNode)
    self.changeDirNode:setScale(0.7)
    --self.bg:setContentSize(self.changeDirNode:getContentSize())

    local animation = CCAnimationCache:sharedAnimationCache():animationByName("soldierm"..self.kind)
    self.changeDirNode:runAction(repeatForever(CCAnimate:create(animation)))
    local shadow = addSprite(self.bg, "roleShadow.png")

    local dx = math.random(100)+100
    local dy = math.random(100)+100
    self.bg:setPosition(ccp(2200+dx, 100+dy))
    self.state = SOLDIER_STATE.FREE 
    self.passTime = 0
    self.waitTime = 0
    self.oldPredictTarget = nil
    self.health = self.data.healthBoundary
    self.maxHealth = self.data.healthBoundary
    
    --if BattleLogic.inBattle then
        local sz = self.changeDirNode:getContentSize()
        local rh = math.max(sz.height, 50)
        self.healthBar = setScale(setPos(CCSprite:create("mapSolBloodBar1.png"), {0, rh}), 0.4)
        
        self.bg:addChild(self.healthBar)
        self.innerBar = setAnchor(setPos(addSprite(self.healthBar, "mapSolBloodRed1.png"), {2, 2}), {0, 0})
    
        self.healthBar:setVisible(false)
    --end
    if self.kind == 23 then
        self.funcSoldier = Archer.new(self)
    elseif self.kind == 3 then
        self.funcSoldier = Warrior.new(self)
    elseif self.kind == 493 then
        self.funcSoldier = Magic.new(self)
    elseif self.kind == 1130 then
        self.funcSoldier = BirdMan.new(self)
    else
        self.funcSoldier = SoldierFunc.new(self)
    end
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("soldiera"..self.kind..".plist")
    local at = self.funcSoldier:getAttTime()
    createAnimation("soldiera"..self.kind, "ss"..self.kind.."a%d.png", 0, 7, 1, at, true) 

    registerEnterOrExit(self)
    if DEBUG then
        self.stateStr = ui.newBMFontLabel({text="0", size=20})
        self.bg:addChild(self.stateStr)
    end
    self.funcSoldier:adjustHeight()
end
function Soldier:enterScene()
    registerUpdate(self)
    Event:registerEvent(EVENT_TYPE.ATTACK_ME, self)
end
function Soldier:receiveMsg(name, msg)
    if name == EVENT_TYPE.ATTACK_ME then
        self.tryAttackTarget = msg
    end
end

function Soldier:exitScene()
    Event:unregisterEvent(EVENT_TYPE.ATTACK_ME, self)
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
        if DEBUG then
            self.stateStr:setString(str(self.state).." "..STR(BattleLogic.inBattle).." time "..self.passTime)
        end
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
        self.funcSoldier:showAttack()  
        --setDir 
        if self.predictMon ~= nil then
            self.attackTarget = self.predictMon
            self.predictMon:addAttacker(self)
            if not self.predictMon.dead then
                local p = getPos(self.predictMon.bg)
                self:setDir(p[1], p[2])
            end
        else
            self.attackTarget = self.predictTarget
            local p = getPos(self.attackTarget.bg)
            self:setDir(p[1], p[2])
        end
    end
    if self.state == SOLDIER_STATE.IN_ATTACK then
        if self.attackTarget.dead == true then
            self.state = SOLDIER_STATE.FREE
            self.funcSoldier:finishAttack()
            self.map:clearCell(self.endPoint)
            self.changeDirNode:stopAllActions()
            local animation = CCAnimationCache:sharedAnimationCache():animationByName("soldierm"..self.kind)
            self.changeDirNode:runAction(repeatForever(CCAnimate:create(animation)))
            return
        elseif self.attackTarget.broken == true then
            self.state = SOLDIER_STATE.FREE
            self.funcSoldier:finishAttack()
            self.map:clearCell(self.endPoint)
            self.changeDirNode:stopAllActions()
            local animation = CCAnimationCache:sharedAnimationCache():animationByName("soldierm"..self.kind)
            self.changeDirNode:runAction(repeatForever(CCAnimate:create(animation)))
            return
        end
        self.attackTime = self.attackTime+diff
        if self.attackTime >= self.data.attSpeed then
            self.attackTime = self.attackTime - self.data.attSpeed
            if self.predictMon ~= nil then
                self.attackTarget:doHarm(self.data.attack)
            else
                self.funcSoldier:doAttack()
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
    local ignore = self.funcSoldier:ignoreGround()
    --建筑物 阻挡移动的块 和 阻挡放置的块不同
    if not ignore and buildCell[key] ~= nil and buildCell[key][1][2] == 1 then
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
    --不允许斜向走
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
    local ignore = self.funcSoldier:ignoreGround()
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
            --没有河流阻碍 没有遍历过
            if (ignore or staticObstacle[key] == nil) and self.closedList[key] == nil then
                --不在open表里面 如果在open表里面那么 值不为nil
                --在open表里面 值一定不为nil
                if self.cells[key] == nil then
                    self.cells[key] = {}
                    self.cells[key].parent = curKey
                    self:calcG(nv[1], nv[2])
                    self:calcH(nv[1], nv[2])
                    self:calcF(nv[1], nv[2])
                    self:pushQueue(nv[1], nv[2])
                --已经在open表里面了 不用再加入了
                else
                    local oldParent = self.cells[key]['parent']
                    local oldGScore = self.cells[key]['gScore']
                    local oldFScore = self.cells[key]['fScore']

                    self.cells[key].parent = curKey
                    self:calcG(nv[1], nv[2])
                    if self.cells[key].gScore > oldGScore then
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
    end
    self.closedList[curKey] = true
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
        --print("startFind")
        self.state = SOLDIER_STATE.IN_FIND
        local p = getPos(self.bg)
        local mxy = getPosMapFloat(1, 1, p[1], p[2])
        local mx, my = mxy[3], mxy[4]
        
        self.startPoint = {mx, my} 
        self.endPoint = nil
        self.openList = {}
        self.pqDict = {}
        self.closedList = {}
        self.path = {}
        self.cells = {}

        self.predictMon = nil
        self.predictTarget = nil
        self.predictEnd = nil
        self.minPoint = nil
        self.totalFind = 0
        
        --攻击的时候 寻找最近的建筑物
        if BattleLogic.inBattle then
            local allBuild = self.map.mapGridController.allBuildings
            local minDis = 99999999

            local minFDist = 99999999
            local minFTar = nil
            for k, v in pairs(allBuild) do
                --建筑物未被摧毁
                if k.broken == false then
                    local bp = getPos(k.bg) 
                    local d = distance2(p, bp)
                    local favor = self.funcSoldier:checkFavorite(k)
                    if d < minDis then
                        minDis = d
                        self.predictTarget = k
                    end
                    if d < minFDist and favor then
                        minFDist = d
                        minFTar = k
                    end
                end
            end
            --有最喜欢的建筑物 则移动去攻击这个建筑物
            if minFTar ~= nil then
                self.predictTarget = minFTar
            end
        --攻击骷髅 当骷髅处于静止状态的时候 向骷髅移动
        elseif self.tryAttackTarget ~= nil and not self.tryAttackTarget.dead and self.tryAttackTarget.state == SOLDIER_STATE.FREE then
            self.predictMon = self.tryAttackTarget
            print("findMonster")
        --经营随便找一个建筑物
        else
            self.tryAttackTarget = nil
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

        if self.predictMon ~= nil and not self.predictMon.dead then
            local mp = getPos(self.predictMon.bg) 
            local map = getPosMapFloat(1, 1, mp[1], mp[2])
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

        elseif self.predictTarget ~= nil then
            --self.oldPredictTarget = self.predictTarget
            local bp = getPos(self.predictTarget.bg)
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
                --该格子是一个建筑物

                if self.predictMon ~= nil then
                    local hScore = self.cells[key].hScore
                    if hScore <= self.minHScore then
                        self.minHScore = hScore
                        self.minPoint = {x, y}
                    end
                    if (x == self.predictEnd[1] and y == self.predictEnd[2]) or self.totalFind >= 100 then
                        self.endPoint = self.minPoint
                        break
                    end
                else
                    --走到某个建筑物块上面了 要求并且是实际的攻击目标 mapDict 只有可攻击目标
                    if buildCell[key] ~= nil and buildCell[key][1][2] == 1 and buildCell[key][1][1] == self.predictTarget and buildCell[key][1][1].broken == false then
                        self.endPoint = {x, y} 
                        --找到建筑了
                        break
                    end
                end

                if self.endPoint == nil then
                    self:checkNeibor(x, y)
                end
            end
            n = n+1
        end
        self.totalFind = self.totalFind+n
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
    self.funcSoldier:setZord()
end
--如果和怪兽足够靠近的话 攻击怪兽
function Soldier:doMove(diff)
    if self.state == SOLDIER_STATE.FIND then
        self.state = SOLDIER_STATE.IN_MOVE
        self.curPoint = 1
        self.passTime = self.data.moveSpeed

        --print("myPath", simple.encode(self.path))
        self.map:updatePath(self.path)
        
        self.map:switchPathSol()
    end
    if self.state == SOLDIER_STATE.IN_MOVE then
        self.passTime = self.passTime+diff
        if self.passTime > self.data.moveSpeed then
            self.passTime = 0
            local nextPoint = self.curPoint+1

            if BattleLogic.inBattle then
                local curPos = getPos(self.bg)
                local endPos = setBuildMap({1, 1, self.endPoint[1], self.endPoint[2]})
                local attR = (self.data.range)*(self.data.range)*32*32 

                local stopNow = false
                --如果行走到建筑物的边界上面则停止行走
                if nextPoint <= #self.path then
                    local np = self.path[nextPoint]
                    local mapDict = self.map.mapGridController.mapDict
                    local key = getMapKey(np[1], np[2])
                    if mapDict[key] ~= nil and mapDict[key][#mapDict[key]][1] == self.predictTarget then
                        stopNow = true
                    end
                end
                if distance2(curPos, endPos) < attR then
                    stopNow = true
                end
                if self.predictTarget.broken then
                    stopNow = true
                end
                if stopNow then
                    self.state = SOLDIER_STATE.START_ATTACK 
                    self.map:clearCell(self.endPoint)
                    self:setZord()
                    return
                end
            end

            if self.tryAttackTarget ~= nil and self.predictMon == nil and not self.tryAttackTarget.dead then
                self.state = SOLDIER_STATE.FREE
                self.map:clearCell(self.endPoint)
                self:setZord()
                return
            end

            if nextPoint > #self.path then
                if self.predictMon ~= nil then
                    if not self.predictMon.dead then
                        --骷髅静止了 所以可以攻击了
                        local p = getPos(self.bg)
                        local map = getPosMapFloat(1, 1, p[1], p[2])
                        local op = getPos(self.predictMon.bg)
                        local oMap = getPosMapFloat(1, 1, op[1], op[2])
                        local dx, dy = math.abs(map[3]-oMap[3]), math.abs(map[4]-oMap[4])
                        if dx+dy <= 3 then
                            self.state = SOLDIER_STATE.START_ATTACK
                        else
                            self.state = SOLDIER_STATE.FREE
                        end
                    else
                        self.state = SOLDIER_STATE.FREE
                    end
                elseif BattleLogic.inBattle == false then
                    self.state = SOLDIER_STATE.FREE
                else
                    --开始攻击则清理cell 数据
                    self.state = SOLDIER_STATE.START_ATTACK
                end
                self.map:clearCell(self.endPoint)
                --移动到目的地调整zord
                self:setZord()
            else
                local np = self.path[nextPoint]
                local cxy = setBuildMap({1, 1, np[1], np[2]})
                self.bg:runAction(moveto(self.data.moveSpeed, cxy[1], cxy[2]))    
                self:setDir(cxy[1], cxy[2])
                self:setZord()
                self.curPoint = self.curPoint+1
            end
        end
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
        self.funcSoldier:finishAttack()
    end

    local vs = self.healthBar:isVisible()
    if not vs then
        self.healthBar:setVisible(true)
        self.healthBar:runAction(fadein(0.5))
        self.innerBar:runAction(fadein(0.5))
    end
    local b = self.health/self.maxHealth
    self.innerBar:runAction(scaleto(0.2, b, 1)) 

    if not self.dead then
        if self.blood == nil then
            self.blood = CCParticleSystemQuad:create("solBlood.plist")
            self.bg:addChild(self.blood)
            setPos(self.blood, {0, 20})
            local function clearBlood()
                removeSelf(self.blood)
                self.blood = nil
            end
            self.blood:runAction(sequence({delaytime(0.4), callfunc(nil, clearBlood)}))
        end
    end

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
        --干不过怪兽怎么办？ 自杀？
        --干过怪兽获得 银币 水晶 和 经验 100 水晶
        if BattleLogic.inBattle then  
            BattleLogic.killKind(self.kind)
            global.user:killSoldier(self.kind)

            local has = false
            for k, v in pairs(global.user.soldiers) do
                if v > 0 then
                    has = true
                    break
                end
            end
            if not has then
                global.director:pushView(ChallengeOver.new(global.director.curScene, {suc=false}), 1, 0)
            end
        end
        self.bg:runAction(sequence({callfunc(nil, fadeAll, self.bg), delaytime(1), callfunc(self.map.mapGridController, self.map.mapGridController.removeSoldier, self)}))
        --经营场景
        if not BattleLogic.inBattle then
            --table.insert(MonsterLogic.killSol, self.kind)
            global.user:killSoldier(self.kind)
            sendReq("soldierDead", dict({{"uid", global.user.uid}, {"kind", self.kind}}))
        end
    end
end

