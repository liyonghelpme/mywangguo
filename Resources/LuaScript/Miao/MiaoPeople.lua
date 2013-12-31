require "heapq"
require "Miao.FuncPeople"
require "Miao.Worker"
require "Miao.MiaoPath"
require "Miao.TestCat"
require "Miao.TestCat2"
require "Miao.Merchant"

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

    GO_STORE=12,
    PRODUCT = 13,
    GO_FACTORY = 14,
    GO_FARM = 15,
    GO_QUARRY = 16,

    GO_TARGET = 17,
}
function MiaoPeople:ctor(m, data)
    self.map = m
    self.privData = data
    self.state = PEOPLE_STATE.APPEAR
    self.id = data.id
    self.data = Logic.people[self.id]
    self.passTime = 0
    self.level = data.level or 0

    self.health = data.health or 0
    self.maxHealth = Logic.people[self.id].health+self.data.healthAdd*self.level
    self.labor = self.data.labor+self.data.laborAdd*self.level
    self.tired = false
    self.goBack = nil
    self.myHouse = nil
    self.lastState = nil
    self.name = str(math.random(99999))
    self.food = 0
    self.stone = 0
    self.workNum = 0
    self.lastVisible = true
    self.weapon = data.weapon
    self.head = data.head
    self.body = data.body
    self.spe = data.spe

    --修习之后就升级
    self.ignoreTerrian = false
    --普通猫咪 才会有私有的miaoPath
    if self.data.kind == 1 then
        self.miaoPath = MiaoPath.new(self)
    end
    self.stateStack = {}
    self.waitTime = 1
    --操作上下文
    self.actionContext = nil
    self.stateContext = nil


    self.bg = CCNode:create()
    self.heightNode = addNode(self.bg)
    print("init MiaoPeople", self.id)
    if self.id == 1 then
        self.funcPeople = Worker.new(self)
    elseif self.data.kind == 2 then
        self.funcPeople = Merchant.new(self) 
    --elseif self.id == 3 then
    --    self.funcPeople = Cat.new(self)
    elseif self.data.kind == 1 then
        self.funcPeople = Cat2.new(self)
    end
    self.funcPeople:initView()
    self.heightNode:addChild(self.changeDirNode)
    self.statePic = CCSprite:create()
    addChild(self.bg, self.statePic)

    self.events = {EVENT_TYPE.PAUSE_GAME, EVENT_TYPE.CONTINUE_GAME}
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
    elseif name == EVENT_TYPE.PAUSE_GAME then
        --self.changeDirNode:pauseSchedulerAndActions()
        pauseNode(self.changeDirNode)
        pauseNode(self.bg)
        pauseNode(self.heightNode)
    elseif name == EVENT_TYPE.CONTINUE_GAME then
        --self.changeDirNode:resumeSchedulerAndActions()
        resumeNode(self.changeDirNode)
        resumeNode(self.bg)
        resumeNode(self.heightNode)
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
function MiaoPeople:showNoHome()
    if self.homeLabel == nil then
        self.homeLabel = ui.newButton({image="info.png", conSize={130, 50}, text="无家可归", color={0, 0, 0}, size=25})
        self.heightNode:addChild(self.homeLabel.bg)
        setPos(self.homeLabel.bg, {0, 200})
    end
end
function MiaoPeople:clearNoHome()
    if self.homeLabel ~= nil then
        removeSelf(self.homeLabel.bg)
        self.homeLabel = nil
    end
end

function MiaoPeople:onOver()
end
function MiaoPeople:onSucFind()
    local w = Welcome2.new(self.onOver, self)
    w:updateWord("等我休息好了，我就在附近的田地里耕作好了。")
    global.director:pushView(w, 1, 0)
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
            --local allBuild = self.miaoPath.allBuilding
            local minHouse = nil
            local minDist = 999999
            local allBuild = self.map.mapGridController.allBuildings
            local p = getPos(self.bg)
            for k, v in pairs(allBuild) do
                --找house kind == 5
                if k.owner == nil and k.state == BUILD_STATE.FREE and k.data.kind == 5 and k.deleted == false then
                    local hp = getPos(k.bg)
                    local dist = math.abs(hp[1]-p[1])+math.abs(hp[2]-p[2]) 
                    if dist < minDist then
                        minHouse = k
                        minDist = dist
                    end
                end
            end
            if minHouse ~= nil then
                self.myHouse = minHouse
                print("findHouse setOwner")
                self.myHouse:setOwner(self)
            end
        --end
    end
    if self.myHouse == nil then
        self:showNoHome()
    else
        self:clearNoHome()
        if Logic.inNew and Logic.gotoHouse then
            Logic.gotoHouse = false
            local w = Welcome2.new(self.onSucFind, self)
            w:updateWord("太好啦！！新房子啊。\n一直在这里傻站着站的我脚都肿了...")
            global.director:pushView(w, 1, 0)
        end
    end
    self.predictTarget = self.myHouse
    self.actionContext = CAT_ACTION.GO_HOME
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
    self.funcPeople:findTarget()
end

function MiaoPeople:onMerch()
    if self.merch == 0 then
        local w = Welcome2.new(self.onMerch, self)
        w:updateWord("如果这里有食材的话，希望能够让我收购一些...")
        global.director:pushView(w, 1, 0)
        self.merch = 1
    elseif self.merch == 1 then
        self.merch = 2
        local w = Welcome2.new(self.onMerch, self)
        w:updateWord("真是求之不得的提议案。那么就让商人收购一些田地里生产的<0000ff食材吧>.")
        global.director:pushView(w, 1, 0)
    end
end

function MiaoPeople:update(diff)
    if Logic.paused then
        return
    end
    self:showState()
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
    self:setZord()
    local s = ''
    for k, v in ipairs(self.stateStack) do
        if type(v) == 'table' then
            s = s..v[1]..'\n'
        else
            s = s..v..'\n'
        end
    end
    self.stateLabel:setString(s)
    self.funcPeople:updateState(diff)
    self.actionLabel:setString(str(self.actionContext)..'\n'..str(self.ignoreTerrian))
    --[[
    if self.predictTarget ~= nil then
        self.stateLabel:setString(str(self.state).."target  "..str(self.predictTarget.id).." hea "..self.health.." sc "..str(self.stateContext).." ac "..str(self.actionContext))
    else
        self.stateLabel:setString(str(self.state).." hea "..self.health)
    end
    --]]
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
        --新系统 stateContext actionContext
        if self.stateContext ~= nil then
            self.predictTarget = self.stateContext[2]
            self.actionContext = self.stateContext[3] 
            self.needClearOwner = self.stateContext.needClearOwner or true
            self.stateContext = nil
            if self.predictTarget.deleted then
                self.predictTarget = nil
                self:clearStateStack()
            end
        elseif self.goSmith then
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
            --村民应该 
            if self.predictTarget == nil then
                --self:showSelf()
                --村民没有找到工作点开始寻找附近的可以工作的地点
                if self.state == PEOPLE_STATE.FIND_NEAR_BUILDING then
                --普通村民 没有呆在房间内 则回到房间内
                --重新生成建筑物连通性路径
                --已经在house里面 就不要再去找house了
                --self.lastState ~= PEOPLE_STATE.IN_HOME
                elseif self.data.kind == 1 and self.state == PEOPLE_STATE.START_FIND then
                    --显示出来自己
                    --如果和别的建筑物冲突了也要移动到旁边显示自己
                    if not self:checkMeInHouse() then
                        self:findHouse()
                        self:showSelf()
                    else
                        self.state = PEOPLE_STATE.PAUSED
                        self.pausedTime = 0
                    end

                --商人往回走 miaoPath 初始化结束 
                elseif self.data.kind == 2 and self.state == PEOPLE_STATE.START_FIND then
                    --self.funcPeople:findPathError()
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
        while n < 5 do
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
                --从当前位置附近的道路开始寻路 calcG gScore ~= 100 不是100的值
                --local findTarget = false
                if buildCell[key] ~= nil and buildCell[key][#buildCell[key]][1] == self.predictTarget then
                    --到此建筑物距离100 则是相邻的格子不可以直接行走上去 必须经过道路才行
                    --findTarget = true
                    --if self.actionContext ~= CAT_ACTION.GO_HOME and self.cells[point].gScore == 100 then
                    --else
                    self.endPoint = {x, y} 
                    self.realTarget = buildCell[key][#buildCell[key]][1]
                    print("findTarget", self.predictTarget.picName, self.realTarget.picName)
                    break
                    --end
                end
                --避免将目标点 加入到closedList 里面去
                if self.endPoint == nil and not findTarget then
                    self:checkNeibor(x, y)
                end
            end
            n = n+1
        end
        self.map:updateCells(self.cells, self.map.cells)
        --找到路径 显示自己开始移动
        if self.endPoint ~= nil then
            print("Find Path Over")
            self.state = PEOPLE_STATE.FIND
            self:getPath()

            self.oldPredictTarget = self.predictTarget
            self.openList = nil
            self.closedList = nil
            self.pqDict = nil
            self.cells = nil
            self:showSelf()
            self.ignoreTerrian = false
        elseif #self.openList == 0 then
        --回家无路可走了 休息 
            if self.tired then
                self.state = PEOPLE_STATE.PAUSED 
                self.pausedTime = 0
            --商人寻路失败了
            else
                --到商店寻路失败
                --回家寻路失败
                --self.state = PEOPLE_STATE.FREE
            end

            self.funcPeople:findPathError()

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
        --[[
        if self.lastState == PEOPLE_STATE.IN_HOME then
            print("init Home Pos", #self.path, simple.encode(self.path[2]), simple.encode(self.lastEndPoint))
            local mx = (self.path[2][1]+self.lastEndPoint[1])/2
            local my = (self.path[2][2]+self.lastEndPoint[2])/2
            local np = setBuildMap({1, 1, mx, my})
            setPos(self.bg, np)
            self:setZord()
            --self.bg:setVisible(true)
            self.lastState = nil
        end
        --]]


        self.state = PEOPLE_STATE.IN_MOVE
        self.curPoint = 1
        self.passTime = 1

        self.map:updatePath(self.path)
        self.map:switchPathSol()

    end
end
function MiaoPeople:onBuy()
    local w = Welcome2.new(self.onOver, self)
    w:updateWord("今后我打算定期前来采购，希望你能够增加田地")
    global.director:pushView(w, 1, 0)
end
function MiaoPeople:doMove(diff)
    if self.state == PEOPLE_STATE.IN_MOVE then
        self.passTime = self.passTime+diff
        if self.passTime >= self.waitTime then
            self.passTime = 0
            local nextPoint = self.curPoint+1

            if nextPoint > #self.path then
                --去休息
                --if self.realTarget ~= nil and self.realTarget.picName == 'build' and self.realTarget.id == 1 then
                --    self:handleHome()
                --商人 工作移动到了目的点 开始 往回走了

                --首先检测目标是否移动 
                local moved = self:checkMoved()
                if moved or self.realTarget.deleted then
                    --self:clearStateStack()
                    --self:resetState()
                    self.funcPeople:buildMove()
                elseif self.data.kind == 2 then
                    if self.actionContext ~= nil then
                        self.funcPeople:handleAction()
                    --收获农作物 商店资源
                    elseif self.goBack == nil then
                        self.state = PEOPLE_STATE.FREE
                        self.goBack = true
                        self.realTarget:setOwner(nil)
                        --开始交易 回家啦
                        --去采矿场
                        local getNum = 0
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
                            getNum = self.predictTarget.workNum
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
                        if Logic.inNew and not Logic.buyIt then
                            Logic.buyIt = true
                            local w = Welcome2.new(self.onBuy, self)
                            w:updateWord("好了，那么我就收购食材<0000ff"..getNum..">个，并付给你<0000ff"..getNum.."贯>")
                            global.director:pushView(w, 1, 0)
                        end
                    else
                        print("GO AWAY Now!")
                        self.state = PEOPLE_STATE.GO_AWAY
                        self.changeDirNode:runAction(sequence({fadeout(1), callfunc(nil, removeSelf, self.bg)}))
                        self.map.mapGridController:removeSoldier(self)
                    end
                else
                    self:beforeHandle()
                    if self.realTarget.data.kind == 5 then
                        self:handleHome()
                    --运送物资到工厂 带走农田产量
                    --之前的是农田 并且 农田已经 种植好了 则 走向 工厂
                    elseif self.realTarget.id == 2 then
                        self:handleFarm()
                    --向工厂前进
                    elseif self.realTarget.id == 5 then
                        self:handleFactory()
                    --商店产品
                    elseif self.realTarget.data.IsStore == 1 then
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
                    self:finishHandle()
                end
                self:setZord()
            else
                --商人会在商店门口等待一下 
                local moved = false
                local wait = false
                local deleted = false
                if nextPoint == #self.path then
                    moved = self:checkMoved()
                    if moved or self.realTarget.deleted then
                        deleted = true
                        --self:clearStateStack()
                        --self:resetState()
                        self.funcPeople:buildMove()
                    --商店 如果已经有人进去了 在门口排队等待 enterQueue 进入队列
                    --不是商人的返回点
                    elseif self.realTarget.data ~= nil and self.realTarget.data.IsStore == 1 and self.realTarget.funcBuild.inMerchant ~= nil then
                         wait = true
                    end
                end
                if not moved and not wait and not deleted then
                    --当前点是 斜坡 或者 目标点是斜坡 都会降低移动速度
                    local np = self.path[nextPoint]
                    local buildCell = self.map.mapGridController.mapDict
                    local key = getMapKey(np[1], np[2])
                    local bv = buildCell[key]


                    local cp = self.path[self.curPoint]
                    local key = getMapKey(cp[1], cp[2])
                    local cv = buildCell[key]

                    --行走在有可能是斜坡的道路上面
                    --setBuildMap --->根据normal 坐标 得到 cxy 坐标 
                    --根据normal 得到上坡 还是下坡'
                    --下个点在石头路上
                    --下一个点是斜坡 下下一个点的高度值 和当前点高度值 平均值 
                    local goYet = false

                    local accMove = false
                    if self.data.skill == 42 then
                        accMove = true
                    end
                    --道路是onSlope 
                    --道路下面的斜坡才是真正的地形高度
                    --dir 不是 0 或者 1的斜坡不能行走的 
                    if bv ~= nil then
                        --计算斜坡的高度
                        local height
                        local ons = bv[#bv][1].onSlope 
                        if ons then
                            height = bv[#bv-1][1].height
                        else
                            ons = bv[#bv][1].picName == 'slope' 
                            if ons then
                                height = bv[#bv][1].height
                            end
                        end

                        if ons then
                            goYet = true
                            local cxy = setBuildMap({1, 1, np[1], np[2]})
                            self.waitTime = 3
                            if accMove then
                                self.waitTime = self.waitTime/2
                            end
                            self.bg:runAction(moveto(self.waitTime, cxy[1], cxy[2]))    
                            local dx, dy = np[1]-cp[1], np[2]-cp[2]
                            self:setDir(cxy[1], cxy[2])
                            self:setZord()
                            --local nnp = self.path[nextPoint+1]
                            --根据下一个点的高度计算偏移位置 当前点 和 下下点 高度的平均值
                            --斜坡自身的高度 斜坡在初始化的时候自动初始化了高度值
                            self:moveSlope(dx, dy, 0, height)
                            self.curPoint = self.curPoint+1
                        end
                    end
                    --当前点在 斜坡上 下一个点的高度值
                    if not goYet and cv ~= nil then
                        local height 
                        local ons = cv[#cv][1].onSlope
                        if ons then
                            height = cv[#cv-1][1].height
                        else
                            ons = cv[#cv][1].picName == 'slope'
                            if ons then
                                height = cv[#cv][1].height
                            end
                        end

                        if ons then
                            goYet = true
                            local cxy = setBuildMap({1, 1, np[1], np[2]})
                            self.waitTime = 3
                            if accMove then
                                self.waitTime = self.waitTime/2
                            end
                            self.bg:runAction(moveto(self.waitTime, cxy[1], cxy[2]))    
                            local dx, dy = np[1]-cp[1], np[2]-cp[2]
                            self:setDir(cxy[1], cxy[2])
                            self:setZord()
                            self:moveSlope(dx, dy, 1, np)
                            self.curPoint = self.curPoint+1
                        end
                    end

                    if not goYet then
                        local cxy = setBuildMap({1, 1, np[1], np[2]})
                        self.waitTime = 1.5
                        if accMove then
                            self.waitTime = self.waitTime/2
                        end
                        self.bg:runAction(moveto(self.waitTime, cxy[1], cxy[2]))    
                        self:setDir(cxy[1], cxy[2])
                        self:setZord()
                        self.curPoint = self.curPoint+1
                    end
                    --是否在运送货物
                    if self.food > 0 or self.stone > 0 or self.workNum > 0 then
                        self.health = self.health-1
                    end
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
        local moved = self:checkMoved()
        if moved then
            self:clearStateStack()
            self:resetState()
        elseif self.realTarget.deleted then
            self:clearStateStack()
            self:resetState()
        else
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
        end
    elseif self.state == PEOPLE_STATE.IN_HOME then
        local moved = self:checkMoved()
        if moved then
            self:clearStateStack()
            self:resetState()
        elseif self.realTarget.deleted then
            self:clearStateStack()
            self:resetState()
        else
            self:workInHome(diff)
        end
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
        --不是道路
        if n.picName ~= 't' then
            dist = 100
        end
        --[[
        --普通建筑物 斜坡 樱花树
        if n.picName == 'build' and (n.data.kind == 0 or n.data.kind == 1 or n.data.kind == 3) then
            dist = 100
        end
        --]]
    else
        --没有道路 河流 或者 草地 建筑物
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
    local isStart = false
    if x == self.startPoint[1] and y == self.startPoint[2] then
        isStart = true
    end
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
            local isTarget = false
            if buildCell[key] ~= nil then
                local bb = buildCell[key][#buildCell[key]][1]
                --道路或者 桥梁 建造好的建筑物
                if bb.state == BUILD_STATE.FREE and (bb.picName == 't' or (bb.picName == 'build' and bb.id == 3)) then
                    hasRoad = true
                    --print("buildCell Kind Road")
                else
                    if bb == self.predictTarget then
                        isTarget = true
                    end
                    --print("no road")
                end
            else
                --print("not Road")
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

            --target 点不能和目标点紧邻 除了回家之外
            --isTarget isStart 不能即是目标 也是 开始点 
            --是否无视地形呢
            --or self.actionContext == CAT_ACTION.GO_HOME

            if self.closedList[key] == nil and (self.ignoreTerrian or (not (isTarget and isStart) and (hasRoad or isTarget))) then
                --没有加入过openList
                if self.cells[key] == nil then
                    self.cells[key] = {}
                    self.cells[key].parent = curKey
                    self:calcG(nv[1], nv[2])
                    self:calcH(nv[1], nv[2])
                    self:calcF(nv[1], nv[2])
                    self:pushQueue(nv[1], nv[2])
                --加入过openList
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
        --包括最后一个点 只是在行走的时候 调整一下 到最后一个点的时候 要消失 或者每半个作为一个移动单位 
        for i =#path, 1, -1 do
            table.insert(self.path, {path[i][1], path[i][2]})
        end
        print("getPath", simple.encode(self.endPoint), simple.encode(path))
        --用于确认 当前工作的目标是否移动了
        self.tempEndPoint = {path[1][1], path[1][2]}
        --[[
        --走到房间边缘消失掉
        if self.predictTarget.id == 1 then
            if #self.path >= 2 then
                local mx, my = (path[1][1]+path[2][1])/2, (path[1][2]+path[2][2])/2
                table.insert(self.path, {mx, my})
            end
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
        --]]
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
function MiaoPeople:updateLevel()
    self.level = self.level+1
end

--旧装备放下
function MiaoPeople:putEquip(eid)
    local ed = Logic.equip[eid]
    local kindToPart = {
        [0]='weapon',
        [1]='head',
        [2]='body',
        [3]='spe',
    }
    print("MIao putEquip", self.name, eid, ed.kind)
    local obj = self
    obj[kindToPart[ed.kind]] = nil
end

--旧装备卸下 新装备 装上
function MiaoPeople:setEquip(eid)
    local ed = Logic.equip[eid]
    local kindToPart = {
        [0]='weapon',
        [1]='head',
        [2]='body',
        [3]='spe',
    }
    print("MIao setEquip", self.name, eid, ed.kind)
    if ed.kind == 0 then
        if self.weapon ~= nil then
            Logic.holdNum[self.weapon] = (Logic.holdNum[self.weapon] or 0) +1
        end
        self.weapon = ed.id
    elseif ed.kind == 1 then
        if self.head ~= nil then
            Logic.holdNum[self.head] = (Logic.holdNum[self.head] or 0)+1
        end
        self.head = ed.id
    elseif ed.kind == 2 then
        if self.body ~= nil then
            Logic.holdNum[self.body] = (Logic.holdNum[self.body] or 0)+1
        end
        self.body = ed.id
    elseif ed.kind == 3 then
        if self.spe ~= nil then
            Logic.holdNum[self.spe] = (Logic.holdNum[self.spe] or 0)+1
        end
        self.spe = ed.id
    end
end

require "Miao.MiaoPeopStatic"
