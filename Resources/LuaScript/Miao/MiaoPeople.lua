require "heapq"
require "Miao.FuncPeople"
require "Miao.Worker"

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
    PAUSED = 9,
}
function MiaoPeople:ctor(m, data)
    self.map = m
    self.state = PEOPLE_STATE.FREE
    self.health = 0
    self.maxHealth = 15
    self.tired = false
    self.goBack = nil
    self.myHouse = nil
    self.lastState = nil
    self.id = data.id
    self.name = str(math.random(99999))
    self.stone = 0

    self.bg = CCNode:create()

    --不同人物动画的角度也有可能不同
    self.changeDirNode = addSprite(self.bg, "people"..self.id.."_lb_0.png")
    local sz = self.changeDirNode:getContentSize()
    --人物图像向上偏移一半高度 到达块中心位置
    setAnchor(self.changeDirNode, {Logic.people[1].ax/sz.width, (sz.height-Logic.people[1].ay-SIZEY)/sz.height})
    self.stateLabel = ui.newBMFontLabel({text=str(self.state), size=20})
    setPos(self.stateLabel, {0, 100})
    self.bg:addChild(self.stateLabel)
    if self.id == 1 then
        self.funcPeople = Worker.new(self)
    elseif self.id == 2 then
        self.funcPeople = Merchant.new(self) 
    end
    
    createAnimation("people"..self.id.."_lb", "people"..self.id.."_lb_%d.png", 0, 4, 1, 0.5, false)
    createAnimation("people"..self.id.."_lt", "people"..self.id.."_lt_%d.png", 0, 4, 1, 0.5, false)
    createAnimation("people"..self.id.."_rb", "people"..self.id.."_rb_%d.png", 0, 4, 1, 0.5, false)
    createAnimation("people"..self.id.."_rt", "people"..self.id.."_rt_%d.png", 0, 4, 1, 0.5, false)
    createAnimation("peopleSend", "people3_%d.png", 1, 11, 1, 1, false)
    registerEnterOrExit(self)
end
function MiaoPeople:enterScene()
    registerUpdate(self)
    Event:registerEvent(EVENT_TYPE.ROAD_CHANGED, self)
end
function MiaoPeople:receiveMsg(name, msg)
    if name == EVENT_TYPE.ROAD_CHANGED then
    end
end
function MiaoPeople:exitScene()
    Event:unregisterEvent(EVENT_TYPE.ROAD_CHANGED, self)
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
    --房间被拆除了也不行
    if self.myHouse == nil or self.myHouse.deleted then
        self.myHouse = nil
        local allBuild = self.map.mapGridController.allBuildings
        for k, v in pairs(allBuild) do
            --找house
            if k.owner == nil and k.state == BUILD_STATE.FREE and k.id == 1 and k.deleted == false then
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
    local allPossible = {}
    local allFreeFactory = {}
    local allFreeStore = {}
    local allFreeMine = {}
    local allFreeSmith = {}

    for k, v in pairs(allBuild) do
        --休息结束
        --找农田
        local ret = false
        --商人 不需要 占用 建筑物

        if self.id == 2 and k.deleted == false then
            --农田没有购买者 走到后发现目标被移除了就取消工作 
            --移动建筑物相当于新建一个建筑物 broken = true
            --避免抢占 owner == nil
            --去农田
            ret = (k.picName == 'build' and k.id == 2 and k.state == BUILD_STATE.FREE and k.workNum > 0 and k.owner == nil)
            --去商店
            if not ret then
                ret = (k.picName == 'build' and k.id == 6 and k.state == BUILD_STATE.FREE and k.workNum > 0 and k.owner == nil)
            end
            --采矿场
            if not ret then
                print("stone ", k.stone)
                ret = (k.picName == 'build' and k.id == 12 and k.state == BUILD_STATE.FREE and k.stone > 0 and k.owner == nil)
            end
            --铁匠铺
            if not ret then
                ret = (k.picName == 'build' and k.id == 13 and k.state == BUILD_STATE.FREE and k.workNum > 0 and k.owner == nil)
            end
        --农民要占用建筑物
        elseif self.id == 1 and k.deleted == false then
            --两种情况 给 其它工厂运输农作物 丰收状态 
            --生产农作物
            --先不允许并行处理
            if k.picName == 'build' and k.owner == nil then
                if k.id == 2 then
                    ret = (k.state == BUILD_STATE.FREE and k.workNum < 10)
                    if not ret then
                    --可以运送到工厂了 寻找最近的工厂 拉着拉着 没有工厂了怎么办？ 到目标地发现建筑物不在了则停止
                        ret = (k.state == BUILD_STATE.FREE and k.workNum >= 10)
                    end
                    --一条链路

                --去工厂生产产品 运送粮食到工厂 或者 到工厂生产产品
                --运送物资到工厂 如果工厂 的 stone > 0 就可以开始生产了  
                --或者将生产好的产品运送到 商店
                --没有直接去工厂的说法
                --[[
                elseif k.id == 5 then
                    ret = (k.food > 0 and getDefault(k.product, 1, 0) < 10)
                    ret = (k.stone > 0 and getDefault(k.product, 2, 0) < 10)
                    --生产好食物
                    if not ret then
                        ret = (getDefault(k.product, 1, 0) > 0)
                    end
                    --生产好铁器
                    if not ret then
                        ret = (getDefault(k.product, 2, 0) > 0)
                    end
                --]]
                --采矿场
                elseif k.id == 12 then
                    ret = k.stone < 10 
                    --运送矿石到 商店 不同类型商店经营物品不同
                    if not ret then
                        ret = k.stone >= 10
                    end
                elseif k.id == 11 then
                    --ret = k.stone ~= nil and k.stone > 0 
                end
                --工厂 空闲状态 没有粮食储备 且没有其它用户 
            end
            print("build kind ", k.id, k.food, k.owner)
            --空闲工厂 没有生产产品
            --工厂就只管生产产品就得了
            if k.id == 5 and k.owner == nil then
                print("free factory")
                table.insert(allFreeFactory, k)
            end

            --按照大区块划分的AI 区域
            if k.id == 6 and k.workNum < 10 and k.owner == nil then
                table.insert(allFreeStore, k)
            end
            --矿坑
            if k.id == 11 and k.owner == nil then
                table.insert(allFreeMine, k)
            end
            --铁匠铺 卖出武器
            if k.id == 13 and k.workNum < 10 and k.owner == nil then
                table.insert(allFreeSmith, k)
            end
        end

        --print("building state", ret)
        if ret then
            table.insert(allPossible, k)
        end
    end
    print("allPossible", #allPossible)
    print("allFreeFactory num", #allFreeFactory)
    print("allFreeStore num", #allFreeStore)
    print("allFreeSmith num", #allFreeSmith)
    if #allPossible > 0 then
        local rd = math.random(#allPossible)
        local k = allPossible[rd]
        --基本潜质
        --工作种类
        if self.id == 1 then
            --寻找空闲的工厂 运送物资过去
            --寻找最近的工厂运送过去  行为转变了
            if k.id == 2 and k.workNum >= 10 then
                --锁定了农田和 工厂的 使用者
                if #allFreeFactory > 0 and #allFreeStore > 0 then
                    self.stateLabel:setString("findFactory!!!")
                    self.predictFactory = allFreeFactory[1]
                    self.predictFactory:setOwner(self) 
                    self.predictStore = allFreeStore[1]
                    self.predictStore:setOwner(self)
                    k:setOwner(self)
                    self.predictTarget = k
                    print("find Factory !!!!!!!!!!!!!!!!!!!!!", self.predictFactory)
                end
                --种地去
            elseif k.id == 2 and k.workNum < 10 then
                k:setOwner(self)
                self.predictTarget = k
            elseif k.id == 5 then
                --开始生产了
                --还有剩余粮食
                if k.food > 0 then
                    k:setOwner(self)
                    self.predictTarget = k
                --只有生产好的商品
                else
                    if #allFreeStore > 0 then
                        self.predictStore = allFreeStore[1]
                        self.predictStore:setOwner(self)
                        k:setOwner(self)
                        self.predictTarget = k
                    end
                end
            --采矿场
            elseif k.id == 12 then
                --还可以采集石头
                if k.stone < 10 then
                    if #allFreeMine > 0 then
                        self.predictMine = allFreeMine[1]
                        self.predictMine:setOwner(self)
                        self.predictTarget = k
                        k:setOwner(self)
                    end
                --准备生产铁器
                elseif k.stone >= 10 then
                    if #allFreeSmith > 0 and #allFreeFactory > 0 then
                        self.predictFactory = allFreeFactory[1] 
                        self.predictFactory:setOwner(self)
                        self.predictSmith = allFreeSmith[1]
                        self.predictSmith:setOwner(self)
                        self.predictTarget = k
                        k:setOwner(self)
                    end
                end
            end
        --购买粮食
        elseif self.id == 2 then
            --一块农田只有一个购买者
            --购买结束需要clearBuyer
            --一次购买不成功 还会尝试去购买别的
            --去商店购买
            k:setOwner(self)
            self.predictTarget = k
        end
    end 
end

function MiaoPeople:update(diff)
    if Logic.paused then
        return
    end

    self:checkHealth()
    self:findPath(diff)
    self:initFind(diff) 
    self:doFind(diff)
    self:initMove(diff)
    self:doMove(diff)
    self:doWork(diff)
    self:doPaused(diff)
    if self.predictTarget ~= nil then
        self.stateLabel:setString(str(self.state).."target  "..str(self.predictTarget.id).." hea "..self.health)
    else
        self.stateLabel:setString(str(self.state).." hea "..self.health)
    end
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
        self.predictFactory = nil
        self.predictStore = nil
        self.predictMine = nil
        self.predictSmith = nil

        self.predictEnd = nil
        self.realTarget = nil
        
        --寻找最近的建筑物 去工作 使用简单的洪水查找法 不要使用最近建筑物查找法 人物多思考一会即可
        --只在有路的块上面行走 picName == 't'
        --tired 不能中断操作
        if self.goSmith then
            self.predictTarget = self.tempSmith
            self.goSmith = false
        elseif self.goBack then
            self.predictTarget = self.map.backPoint
            print("goBack now")
        elseif self.goStore then
            self.predictTarget = self.tempStore
            self.goStore = false
        elseif self.goMine then
            self.predictTarget = self.tempMine
            self.goMine = false
        --因为角色还占用着 矿场的 工具呢 所以需要返回
        elseif self.goQuarry then
            self.predictTarget = self.predictQuarry
            self.predictQuarry = nil
            self.goQuarry = false
        elseif self.goFactory then
            print("goFactory !!!!!")
            self.predictTarget = self.tempFactory
            self.goFactory = false
        --寻找住宅
        elseif self.tired then
            self:findHouse()
        else
            --寻找要去收割的建筑物
            self:findWorkBuilding()
            --没有找到工作地点 或者 购买物品的地点
            if self.predictTarget == nil then
                --普通村民 没有呆在房间内 则回到房间内
                if self.id == 1 and self.lastState ~= PEOPLE_STATE.IN_HOME then
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
            --暂停寻路 再去寻找回去的路 id == 1  
            if self.tired then
                self.state = PEOPLE_STATE.PAUSED 
                self.pausedTime = 0
            else
                self.state = PEOPLE_STATE.START_FIND
            end
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
        --回家无路可走了 休息 
            if self.tired then
                self.state = PEOPLE_STATE.PAUSED 
                self.pausedTime = 0
            else
                self.state = PEOPLE_STATE.FREE
            end

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
    --print("initMove")
    if self.state == PEOPLE_STATE.FIND then
        --开始从房间里面出来了 调整一下初始的位置 people 所在网格靠近附近邻居的位置 中点
        if self.lastState == PEOPLE_STATE.IN_HOME then
            print("init Home Pos", #self.path, simple.encode(self.path[2]), simple.encode(self.lastEndPoint))
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
function MiaoPeople:doMove(diff)
    if self.state == PEOPLE_STATE.IN_MOVE then
        self.passTime = self.passTime+diff
        if self.passTime > 1 then
            self.passTime = 0
            local nextPoint = self.curPoint+1
            if nextPoint > #self.path then
                --去休息
                if self.realTarget ~= nil and self.realTarget.picName == 'build' and self.realTarget.id == 1 then
                    self.state = PEOPLE_STATE.IN_HOME
                    self.restTime = 0
                    --self.bg:setVisible(false)

                    local np = setBuildMap({1, 1, self.tempEndPoint[1], self.tempEndPoint[2]})
                    setPos(self.bg, np)
                --商人 工作移动到了目的点 开始 往回走了
                elseif self.id == 2 then
                    --收获农作物 商店资源
                    if self.goBack == nil then
                        self.state = PEOPLE_STATE.FREE
                        self.goBack = true
                        self.realTarget:setOwner(nil)
                        --开始交易 回家啦
                        --去采矿场
                        if self.predictTarget.stone > 0 then
                            local sp = CCSprite:create("silver.png")
                            local p = getPos(self.predictTarget.bg)
                            self.map.bg:addChild(sp)
                            setPos(sp, p)
                            local rx = math.random(20)-10
                            sp:runAction(sequence({jumpBy(1, rx, 10, 40, 1), fadeout(0.2), callfunc(nil, removeSelf, sp)}))
                            local pay = self.predictTarget.stone*math.floor(self.predictTarget.rate+1)
                            local num = ui.newBMFontLabel({text=str(pay), font="bound.fnt", size=30})
                            sp:addChild(num)
                            setPos(num, {50, 0})
                            doGain({silver=pay})
                            self.predictTarget.workNum = 0
                        --去农田
                        --去商店
                        --去铁匠铺
                        elseif self.predictTarget.workNum > 0 then
                            local sp = CCSprite:create("silver.png")
                            local p = getPos(self.predictTarget.bg)
                            self.map.bg:addChild(sp)
                            setPos(sp, p)
                            local rx = math.random(20)-10
                            sp:runAction(sequence({jumpBy(1, rx, 10, 40, 1), fadeout(0.2), callfunc(nil, removeSelf, sp)}))
                            local num = ui.newBMFontLabel({text=str(self.predictTarget.workNum*math.floor(self.predictTarget.rate+1)), font="bound.fnt", size=30})
                            sp:addChild(num)
                            setPos(num, {50, 0})
                            doGain({silver=self.predictTarget.workNum*math.floor(self.predictTarget.rate+1)})
                            self.predictTarget.workNum = 0
                        end
                    else
                        print("GO AWAY Now!")
                        self.state = PEOPLE_STATE.GO_AWAY
                        self.changeDirNode:runAction(sequence({fadeout(1, callfunc(nil, removeSelf, self.bg))}))
                        self.map.mapGridController:removeSoldier(self)
                    end
                else
                    --运送物资到工厂 带走农田产量
                    --之前的是农田 并且 农田已经 种植好了 则 走向 工厂
                    if self.realTarget.id == 2 then
                        self:handleFarm()
                    --向工厂前进
                    elseif self.realTarget.id == 5 then
                        self:handleFactory()
                    --商店产品
                    elseif self.realTarget.id == 6 then
                        self.realTarget.workNum = self.realTarget.workNum +self.product
                        self.realTarget:setOwner(nil)
                        self.realTarget = nil
                        self.state = PEOPLE_STATE.FREE
                    --去采矿场工作
                    elseif self.realTarget.id == 12 then
                        if self.stone == 0 then
                            --获取工具去采矿
                            if self.predictMine ~= nil then
                                --owner 还是 该用户 直到回家休息才放弃owner权限
                                self.predictQuarry = self.realTarget
                                self.tempMine = self.predictMine
                                self.goMine = true
                                self.state = PEOPLE_STATE.FREE
                            --将矿石运往工厂 生产结束后 运往铁匠铺
                            elseif self.predictSmith ~= nil then
                                self.stone = self.predictTarget.stone
                                self.predictTarget.stone = 0
                                self.predictTarget:setOwner(nil)
                                self.predictTarget = nil
                                self.goFactory = true
                                self.tempFactory = self.predictFactory
                                self.tempSmith = self.predictSmith
                                self.state = PEOPLE_STATE.FREE
                            end
                        --运送矿石回来
                        else
                            self.realTarget.stone = self.realTarget.stone+self.stone
                            self.stone = 0
                            --不要占用采矿场了
                            self.realTarget:setOwner(nil)
                            self.state = PEOPLE_STATE.FREE
                        end
                    --去矿坑工作
                    elseif self.realTarget.id == 11 then
                        self.state = PEOPLE_STATE.IN_WORK
                        self.workTime = 0
                        --矿坑stone 保持
                        --self.realTarget.stone = 0
                    --去农田种植
                    elseif self.realTarget.id == 2 then
                        self.state = PEOPLE_STATE.IN_WORK
                        self.workTime = 0
                    --将货物放到 铁匠铺里面
                    elseif self.realTarget.id == 13 then
                        self.realTarget.workNum = self.realTarget.workNum +self.product
                        self.realTarget:setOwner(nil)
                        self.realTarget = nil
                        self.product = 0
                        self.state = PEOPLE_STATE.FREE
                    end
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
        --工厂工作
        if self.realTarget.id == 5 then
            if self.workTime > 1 then
                self.workTime = 0
                self.health = self.health -1
                --生产食物
                if self.realTarget.food > 0 then
                    self.realTarget.food = self.realTarget.food - 1
                    changeTable(self.realTarget.product, 1, 1)
                    --如果工厂生产数量超过上限 就不要生产了
                    --运送生产物到商店里面
                    if getDefault(self.realTarget.product, 1, 0) >= 10 or self.realTarget.food <= 0 then
                        self.state = PEOPLE_STATE.FREE
                        self.realTarget:setOwner(nil)
                        self.product = self.realTarget.product[1]
                        self.realTarget = nil
                        self.goStore = true
                        return
                    end
                --生产铁器
                elseif self.realTarget.stone > 0 then
                    self.realTarget.stone = self.realTarget.stone - 1
                    changeTable(self.realTarget.product, 2, 1)
                    --铁器数量
                    if getDefault(self.realTarget.product, 2, 0) >= 10 or self.realTarget.stone <= 0 then
                        self.state = PEOPLE_STATE.FREE
                        self.realTarget:setOwner(nil)
                        self.product = self.realTarget.product[2]
                        self.realTarget = nil
                        --运输铁器到商店里面
                        self.goSmith = true
                        return
                    end
                end
                --生产结束 直到运送到工厂
                --[[
                if self.health <= 0 then
                    self.state = PEOPLE_STATE.FREE
                    self.realTarget:setOwner(nil)
                    self.realTarget = nil
                end
                --]]
            end
        --在采石场工作
        elseif self.realTarget.id == 11 then
            if self.workTime > 1 then
                self.workTime = 0
                self.health = self.health -1
                self.realTarget.stone = self.realTarget.stone + 1
                --如果工厂生产数量超过上限 就不要生产了
                --离开矿坑 但是predictQuarry 不会消除
                if self.realTarget.stone >= 10 then
                    self.state = PEOPLE_STATE.FREE
                    self.stone = self.realTarget.stone
                    self.realTarget.stone = 0

                    self.realTarget:setOwner(nil)
                    self.realTarget = nil
                    self.goQuarry = true
                    return
                end
                --正在工作的时候不要去休息
                --[[
                if self.health <= 0 then
                    self.state = PEOPLE_STATE.FREE
                    self.realTarget:setOwner(nil)
                    self.realTarget = nil
                end
                --]]
            end
        --农田工作 
        elseif self.realTarget.id == 2 then
            if self.workTime > 1 then
                self.workTime = 0
                self.health = self.health-1
                if self.realTarget.workNum >= 10 then
                    self.state = PEOPLE_STATE.FREE
                    self.realTarget:setOwner(nil)
                    self.realTarget = nil
                else
                    self.realTarget:changeWorkNum(1)
                    --种地的时候 tired 直接 回去即可
                    --正在工作的时候 不要去休息
                    --[[
                    if self.health <= 0 then
                        self.state = PEOPLE_STATE.FREE 
                        self.realTarget:setOwner(nil)
                        self.realTarget = nil
                    end
                    --]]
                end
            end
        end
    elseif self.state == PEOPLE_STATE.IN_HOME then
        if self.realTarget.deleted then
            self.state = PEOPLE_STATE.FREE
            self.myHouse = nil
        end
        self.restTime = self.restTime+diff
        if self.restTime > 1 then
            self.restTime = 0
            --用小数表示health 但是 休息结束的时候 需要做成 整数
            self.health = self.health +1*(self.myHouse.rate+1)
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
        elseif cx > MapWidth and nv[1] > x then
        elseif cy < 0 and nv[2] < y then
        elseif cy > MapHeight and nv[2] > y then
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
        --进入工厂中工作
        elseif self.predictTarget.id == 5 then
            print("go into factory !!!!!!!!!!")
            table.insert(self.path, path[1])
        elseif self.predictTarget.id == 2 then
            --进入农田中心去工作
            table.insert(self.path, path[1])
        --商人走到路中心位置
        elseif self.predictTarget.picName == 'backPoint' then
            table.insert(self.path, path[1])
        --进入商店
        elseif self.predictTarget.id == 6 then
            table.insert(self.path, path[1])
        --进入采矿场 进入矿坑
        else
            table.insert(self.path, path[1])
        end
        --设置全局Cell 中此处的权重+10
        if #self.path > 0 then
            self.endPoint = self.path[#self.path]
            --self.map:setCell(self.endPoint)
        end
    end
end

function MiaoPeople:doPaused(diff)
    if self.state == PEOPLE_STATE.PAUSED then
        self.pausedTime = self.pausedTime+diff
        if self.pausedTime > 5 then
            self.pausedTime = 0
            self.state = PEOPLE_STATE.FREE
        end
    end
end

require "Miao.MiaoPeopStatic"
