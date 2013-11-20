require "heapq"
require "Miao.FuncPeople"
require "Miao.Worker"
require "Miao.MiaoPath"
require "Miao.TestCat"

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
    APPEAR = 10,
    --只搜索房屋一次
    FIND_NEAR_BUILDING=11,
}
function MiaoPeople:ctor(m, data)
    self.map = m
    self.state = PEOPLE_STATE.APPEAR
    self.passTime = 0
    self.health = 0
    self.maxHealth = 20
    self.tired = false
    self.goBack = nil
    self.myHouse = nil
    self.lastState = nil
    self.id = data.id
    self.name = str(math.random(99999))
    self.food = 0
    self.stone = 0
    self.product = 0
    self.data = Logic.people[self.id]
    self.miaoPath = MiaoPath.new(self)
    self.stateStack = {}


    print("init MiaoPeople", self.id)
    if self.id == 1 then
        self.funcPeople = Worker.new(self)
    elseif self.id == 2 then
        self.funcPeople = Merchant.new(self) 
    elseif self.id == 3 or self.id == 4 then
        self.funcPeople = Cat.new(self)
    end
    self.funcPeople:initView()

    registerEnterOrExit(self)
end
function MiaoPeople:enterScene()
    registerUpdate(self)
    Event:registerEvent(EVENT_TYPE.ROAD_CHANGED, self)
end
function MiaoPeople:receiveMsg(name, msg)
    if name == EVENT_TYPE.ROAD_CHANGED then
        --清理寻路的road信息
        self.dirty = true
        --self.miaoPath.allBuilding = nil
    end
end
function MiaoPeople:exitScene()
    Event:unregisterEvent(EVENT_TYPE.ROAD_CHANGED, self)
end

function MiaoPeople:doAppear(diff)
    if self.state == PEOPLE_STATE.APPEAR then
        self.passTime = self.passTime+diff
        if self.passTime >= 2 then
            self.passTime = 0
            self.state = PEOPLE_STATE.FREE
        end
    end
end
function MiaoPeople:checkHealth()
    --普通农民才会tired
    if self.health <= 0 and self.data.kind == 1 then
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
--state Stack 需要压入新的 状态来执行
function MiaoPeople:findHouse()
    --房间被拆除了也不行
    if self.myHouse == nil or self.myHouse.deleted then
        self.myHouse = nil
        --找房子 不用miaoPath
        --回到房子之后 才能搜索 miaoPath
        --暂时测试用
        --[[
        if self.miaoPath.allBuilding == nil then
            local p = getPos(self.bg)
            local mxy = getPosMapFloat(1, 1, p[1], p[2])
            local mx, my = mxy[3], mxy[4]
            self.miaoPath:init(mx, my)
            table.insert(self.stateStack, self.state)
            self.state = PEOPLE_STATE.FIND_NEAR_BUILDING 
            --self.miaoPath:update()
        else
        --]]
            --local allBuild = self.miaoPath.allBuilding
            local minHouse = nil
            local minDist = 999999
            local allBuild = self.map.mapGridController.allBuildings
            for k, v in pairs(allBuild) do
                --找house
                if k.owner == nil and k.state == BUILD_STATE.FREE and k.id == 1 and k.deleted == false then
                    minHouse = k
                    break
                    --[[
                    if v < minDist then
                        minHouse = k
                        minDist = v
                    end
                    --]]
                end
            end
            if minHouse ~= nil then
                self.myHouse = minHouse
                print("findHouse setOwner")
                self.myHouse:setOwner(self)
            end
        --end
    end
    self.predictTarget = self.myHouse
end
function MiaoPeople:findAllNearBuilding(diff)
    if self.state == PEOPLE_STATE.FIND_NEAR_BUILDING then
        self.miaoPath:update()
        if self.miaoPath.searchYet then
            self.state = table.remove(self.stateStack)
        end
    end
end

--只在home的时候 调用 初始化miaoPath
function MiaoPeople:findWorkBuilding()
    local allPossible = {}
    local allFreeFactory = {}
    local allFreeStore = {}
    local allFreeMine = {}
    local allFreeSmith = {}
    local allFreeQuarry = {}
    local allBuild
    --有粮食的 农田 有石材的采石场
    local allFoodFarm = {}
    local allStoneQuarry = {}
    --拆除了最近的工作建筑物之后
    --当所有的工作地点都ko的时候 就要findHouse
    --self.myHouse == nil? self.myHouse.deleted == true? 
    --农民才从房屋附近寻路
    if self.miaoPath.allBuilding == nil or self.dirty == true then
        self.dirty = false
        --从房子寻找
        if self.data.kind == 1 then
            print("miao Path init find!!!!!!!!!!!!")
            local p = getPos(self.myHouse.bg)
            local mxy = getPosMapFloat(1, 1, p[1], p[2])
            local mx, my = mxy[3], mxy[4]
            self.miaoPath:init(mx, my)
            table.insert(self.stateStack, self.state)
            self.state = PEOPLE_STATE.FIND_NEAR_BUILDING
        else
            --商人从本身位置出发寻路
            --没有深度限制
            local p = getPos(self.bg)
            local mxy = getPosMapFloat(1, 1, p[1], p[2])
            local mx, my = mxy[3], mxy[4]
            self.miaoPath:init(mx, my)
            table.insert(self.stateStack, self.state)
            self.state = PEOPLE_STATE.FIND_NEAR_BUILDING
        end
    else
        --TODO!! 猫使用的是Cat
        allBuild = self.miaoPath.allBuilding
        --v 是到这个建筑物的距离
        for k, v in pairs(allBuild) do
            --休息结束
            --找农田
            local ret = false
            --商人 不需要 占用 建筑物

            if self.data.kind == 2 and k.deleted == false then
                ret = self.funcPeople:checkWork(k)
                --农田没有购买者 走到后发现目标被移除了就取消工作 
                --移动建筑物相当于新建一个建筑物 broken = true
                --避免抢占 owner == nil
                --去农田
            --农民要占用建筑物
            elseif self.data.kind == 1 and k.deleted == false then
                print("build kind ", k.id, k.food, k.owner, k.workNum)
                ret = self.funcPeople:checkWork(k)
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

                --可以收集的 农田和矿市场 
                if k.id == 2 and k.workNum > 0 then
                    table.insert(allFoodFarm, k)
                end
                if k.id == 12 and k.stone > 0 then
                    table.insert(allStoneQuarry, k)
                end
                if k.id == 12 and k.owner == nil then
                    table.insert(allFreeQuarry, k)
                end
            end

            --print("building state", ret)
            if ret then
                table.insert(allPossible, k)
            end
        end
    end
    print("people kind", self.data.kind)
    if allBuild ~= nil then
        print("allBuildNum", getLen(allBuild))
    end
    print("allPossible", #allPossible)
    print("allFreeFactory num", #allFreeFactory)
    print("allFreeStore num", #allFreeStore)
    print("allFreeSmith num", #allFreeSmith)
    print("allFreeMine num", #allFreeMine)
    print("allFoodFarm num", #allFoodFarm)
    print("allStoneQuarry num", #allStoneQuarry)
    print("allFreeQuarry num", #allFreeQuarry)
    global.director.curScene.menu.stateLabel:setString(string.format("allFoodFarm %d\nallStoneQuarry %d\n", #allFoodFarm, #allStoneQuarry))
    if #allPossible > 0 then
        local minb = nil
        local minDist = 99999
        --但是最近的possible 的 条件不成熟 不能选择啊~~
        local r = math.random(#allPossible)
        local k = allPossible[r]
        print("do what??", k.id)
        --[[
        for k, v in ipairs(allPossible) do
            print("allBuild  distance", v.id, allBuild[v], minDist)
            if allBuild[v] < minDist then
                minDist = allBuild[v]
                minb = v
            end
        end
        local k = minb
        --]]
        --基本潜质
        --工作种类
        if self.data.kind == 1 then
            --寻找空闲的工厂 运送物资过去
            --寻找最近的工厂运送过去  行为转变了
            --去食品商店 
            --Planning
            if k.id == 6 then
                if #allFoodFarm > 0 and #allFreeFactory > 0 then
                    self.stateLabel:setString("findFactory!!!")
                    self.predictFactory = allFreeFactory[1]
                    self.predictFactory:setOwner(self) 
                    self.predictStore = k 
                    self.predictStore:setOwner(self)

                    self.predictTarget = allFoodFarm[1]
                    self.predictTarget:setOwner(self)
                    print("find Factory !!!!!!!!!!!!!!!!!!!!!", self.predictFactory)
                end
            elseif k.id == 13 then
                if #allStoneQuarry > 0 and #allFreeFactory > 0 then
                    self.predictFactory = allFreeFactory[1] 
                    self.predictFactory:setOwner(self)
                    self.predictSmith = k
                    self.predictSmith:setOwner(self)

                    self.predictTarget = allStoneQuarry[1]
                    self.predictTarget:setOwner(self)
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
                print("try to collect stone")
                --还可以采集石头
                if #allFreeMine > 0 then
                    self.predictMine = allFreeMine[1]
                    self.predictMine:setOwner(self)
                    self.predictTarget = k
                    k:setOwner(self)
                end
            elseif k.id == 14 then
                --很难攒够原材料
                print("goto Tower")
                if #allFoodFarm > 0 and #allStoneQuarry > 0 and #allFreeFactory > 0 then
                    self.predictTower = k
                    k:setOwner(self)
                    self.predictFactory = allFreeFactory[1]
                    self.predictFactory:setOwner(self)
                    self.predictQuarry = allStoneQuarry[1]
                    self.predictQuarry:setOwner(self)
                    self.predictTarget = allFoodFarm[1]
                    self.predictTarget:setOwner(self)
                end
            end
        --购买粮食
        --去商店
        --去矿石头场
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
    self:doAppear(diff)
    self:findPath(diff)
    self:initFind(diff) 
    self:findAllNearBuilding(diff)
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

        self.predictTarget = nil
        self.predictFactory = nil
        self.predictStore = nil
        self.predictMine = nil
        self.predictSmith = nil
        self.predictQuarry = nil
        self.predictTower = nil

        self.predictEnd = nil
        self.realTarget = nil
        
        --寻找最近的建筑物 去工作 使用简单的洪水查找法 不要使用最近建筑物查找法 人物多思考一会即可
        --只在有路的块上面行走 picName == 't'
        --tired 不能中断操作
        if self.goSmith then
            self.predictTarget = self.tempSmith
            self.tempSmith = nil
            self.goSmith = false
        elseif self.goBack then
            self.predictTarget = self.map.backPoint
            print("goBack now")
        elseif self.goStore then
            self.predictTarget = self.tempStore
            self.tempStore = nil
            self.goStore = false
        elseif self.goMine then
            self.predictTarget = self.tempMine
            self.tempMine = nil
            self.goMine = false
        --因为角色还占用着 矿场的 工具呢 所以需要返回
        elseif self.goQuarry then
            self.predictTarget = self.tempQuarry
            self.tempQuarry = nil
            self.goQuarry = false
        elseif self.goFactory then
            print("goFactory !!!!!")
            self.predictTarget = self.tempFactory
            self.tempFactory = nil
            self.goFactory = false
        elseif self.goTower then
            self.predictTarget = self.tempTower
            self.tempTower = nil
            self.goTower = false
        --寻找住宅
        elseif self.tired then
            self:findHouse()
        else
            --寻找要去收割的建筑物
            self:findWorkBuilding()
            --没有找到工作地点 或者 购买物品的地点
            if self.predictTarget == nil then
                --普通村民 没有呆在房间内 则回到房间内
                --重新生成建筑物连通性路径
                if self.data.kind == 1 and self.lastState ~= PEOPLE_STATE.IN_HOME then
                    self:findHouse()
                --商人往回走 miaoPath 初始化结束
                elseif self.data.kind == 2 and self.state == PEOPLE_STATE.START_FIND then
                    self.goBack = true
                --农民没有地方去工作 则休息一下 miaoPath 已经初始化ok了
                elseif (self.data.kind == 1 or self.data.kind == 2) and self.state == PEOPLE_STATE.START_FIND then
                    self.state = PEOPLE_STATE.PAUSED
                    self.pausedTime = 0
                end
            end
        end

        --所有cartesianToNormal 全部转化成getBuildMap 来计算
        --开始寻找工厂的路 但是工厂已经不存在了 因此不能这么搞。。。
        --getPath----->得到农田路径
        --getPath----->得到到工厂路径
        --得到到商店路径
        if self.predictTarget ~= nil then
            self.state = PEOPLE_STATE.IN_FIND
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
            --没有找到目标有两种可能 初始化没有 MiaoPath
            if self.state == PEOPLE_STATE.START_FIND then
                if self.tired then
                    self.state = PEOPLE_STATE.PAUSED 
                    self.pausedTime = 0
                else
                    self.state = PEOPLE_STATE.START_FIND
                end
            --等待MiaoPath 初始化结束 继续START_FIND
            else

            end
            --[[
            --没找到可以工作的目标 则回去休息
            --暂停寻路 再去寻找回去的路 id == 1  
            --]]
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
                    self:handleHome()
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
                        self.changeDirNode:runAction(sequence({fadeout(1), callfunc(nil, removeSelf, self.bg)}))
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
                        self:handleStore()
                    --去采矿场工作
                    elseif self.realTarget.id == 12 then
                        self:handleQuarry()
                    --去矿坑工作
                    elseif self.realTarget.id == 11 then
                        self:handleMine()
                        --矿坑stone 保持
                        --self.realTarget.stone = 0
                    --去农田种植
                    --将货物放到 铁匠铺里面
                    elseif self.realTarget.id == 13 then
                        self:handleSmith()
                    elseif self.realTarget.id == 14 then
                        self:handleTower()
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
                --是否在运送货物
                if self.food > 0 or self.stone > 0 or self.product > 0 then
                    self.health = self.health-1
                end
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
            self:workInFactory()
        --在采石场工作
        elseif self.realTarget.id == 11 then
            self:workInMine()
        --农田工作 
        elseif self.realTarget.id == 2 then
            self:workInFarm()
        end
    elseif self.state == PEOPLE_STATE.IN_HOME then
        self:workInHome(diff)
    end
end


--保证所有计算之前先给cells 赋值
function MiaoPeople:calcG(x, y)
    local key = getMapKey(x, y)
    local data = self.cells[key]

    local parent = data.parent
    local px, py = getXY(parent)
    local difX = math.abs(px-x)
    local difY = math.abs(py-y)
    local dist = 10
    --如果不是道路 
    --建筑物权重100 
    --河流权重100

    --此块有建筑物 要绕过
    local buildCell = self.map.mapGridController.mapDict
    --是建筑物 不能穿过
    if buildCell[key] ~= nil then
        local n = buildCell[key][#buildCell[key]][1]
        --普通建筑物 斜坡 樱花树
        if n.picName == 'build' and (n.data.kind == 0 or n.data.kind == 1 or n.data.kind == 3) then
            dist = 100
        end
    else
        --没有道路 河流 或者 草地
        dist = 50
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
            --local hasBuild = false
            --到达自己的目标建筑物
            --and buildCell[key][#buildCell[key]][1]  == self.predictTarget
            --road
            --sea
            --bridge 
            --general building
            --道路可达是预先判定的 
            --如果不可达则 完成本次任务之后 就不要搜索去工作了
            --if buildCell[key] ~= nil  then
            --    hasBuild = true
            --end
            --使用最短路径 更新parent信息  
            --没有建筑物 和 道路的值 = 50
            if staticObstacle[key] == nil and self.closedList[key] == nil then
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
    end
    self.closedList[curKey] = true
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
