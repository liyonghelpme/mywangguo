require "model.MapGridController"
require "views.Building"
require "views.Soldier"

ClearNode = class

BuildLayer = class(MoveMap)
function BuildLayer:ctor(scene)
    self.scene = scene
    self.moveZone = TrainZone
    self.buildZone = FullZone
    --显示所有的obstacle块的位置
    self.staticObstacle = obstacleBlock
    self.bg = CCLayer:create()
    self.mapGridController = MapGridController.new(self)
    self.gridLayer = CCLayer:create()
    self.bg:addChild(self.gridLayer)
    self.cellLayer = CCLayer:create()
    self.bg:addChild(self.cellLayer)
    self.pathLayer = CCNode:create()
    self.bg:addChild(self.pathLayer)

    --用于士兵到达目的地之后防止冲突
    self.cells = {}
    --当前允许寻路的士兵
    self.curSol = nil

    registerEnterOrExit(self)
end
function BuildLayer:setCell(p)
    if p ~= nil then
        self.cells[getMapKey(p[1], p[2])] = true
    end
end
function BuildLayer:clearCell(p)
    if p ~= nil then
        self.cells[getMapKey(p[1], p[2])] = nil
    end
end
--跳到下一个寻路的士兵那里
--如果下一个还是 自己 那么就设置为nil
function BuildLayer:switchPathSol()
    local net = nil
    local find = false
    for k, v in ipairs(self.mapGridController.solList) do
        if v == self.curSol then
            find = true
        elseif find then
            net = v
            break
        end
    end
    if net == nil then
        net = self.mapGridController.solList[1]
    end
    if net == self.curSol then
        self.curSol = nil
    else
        self.curSol = net
    end
    --print("switchPathSol", self.curSol.kind)
end

function BuildLayer:enterScene()
    Event:registerEvent(EVENT_TYPE.HARVEST_SOLDIER, self)
    for k, v in pairs(BattleLogic.killedSoldier) do
        local allSol = self.mapGridController.allSoldiers 
        for i=1, v, 1 do
            for sk, sv in pairs(allSol) do
                if sk.kind == k then
                    self.mapGridController:removeSoldier(sk)
                    break
                end
            end
        end
    end
    --self.mapGridController:removeTheseSol(BattleLogic.killedSoldier)
    BattleLogic.killedSoldier = {}
end
function BuildLayer:exitScene()
    Event:unregisterEvent(EVENT_TYPE.HARVEST_SOLDIER, self)
end
function BuildLayer:receiveMsg(name, msg)
    if name == EVENT_TYPE.HARVEST_SOLDIER then
        local solId = msg[2]
        local data = getData(GOODS_KIND.SOLDIER, solId)
        local s = Soldier.new(self, data, nil)
        self.bg:addChild(s.bg, MAX_BUILD_ZORD)
        self.mapGridController:addSoldier(s)
    end
end

function BuildLayer:addSoldier(kind, x, y)
    local data = getData(GOODS_KIND.SOLDIER, kind)
    local s = Soldier.new(self, data, nil)
    self.bg:addChild(s.bg, MAX_BUILD_ZORD)
    setPos(s.bg, {x, y})
    self.mapGridController:addSoldier(s)
end

function BuildLayer:initBuilding()
    print("initBuilding now!!!!!!!!!!!!!!!!!!!!!")
    local item
    if BattleLogic.inBattle then
        item = BattleLogic.buildings 
    else
        item = global.user.buildings
    end
    for k, v in pairs(item) do
        local bid = k
        local bdata = v
        local data = getData(GOODS_KIND.BUILD, bdata["kind"]) 
        local build = Building.new(self, data, bdata)
        build:setBid(bid)

        self.bg:addChild(build.bg, MAX_BUILD_ZORD)
        build:setPos(normalizePos({bdata["px"], bdata["py"]}, data["sx"], data["sy"]))
        self.mapGridController:addBuilding(build)
        build:setPos(normalizePos({bdata["px"], bdata["py"]}, data["sx"], data["sy"]))
        build:setState(getParam("free"))
    end
    --[[
    local temp = CCSprite:create("images/loadingCircle.png")
    temp:setPosition(ccp(992, 320))
    self.bg:addChild(temp)
    temp:setScale(0.2)
    --]]
end
function BuildLayer:initSoldier()
    local item
    if BattleLogic.inBattle then
        item = BattleLogic.soldiers
        --不要初始化对方的士兵
        return
    else
        item = global.user.soldiers
    end
    for k, v in pairs(item) do
        local data = getData(GOODS_KIND.SOLDIER, k)
        for i=1, v, 1 do
            local s = Soldier.new(self, data, nil)
            self.bg:addChild(s.bg, MAX_BUILD_ZORD)
            self.mapGridController:addSoldier(s)
        end
    end
end
function BuildLayer:initDataOver()
    print("initDataOver !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
    self:initBuilding()
    self:initSoldier()
    BattleLogic.finishInitBuild = true
end

function BuildLayer:keepPos()
    self.Planing = 1
    self:buildKeepPos()
    self:soldierKeepPos()
end
function BuildLayer:restorePos()
    self:restoreBuildPos()
    self:restoreSoldierPos()
    self:clearPlanState()
end
function BuildLayer:restoreBuildPos()
    for k, v in pairs(self.mapGridController.allBuildings) do
        k:restorePos()
    end
end
function BuildLayer:restoreSoldierPos()
end
function BuildLayer:clearPlanState()
    self.Planing = 0
end

function BuildLayer:buildKeepPos()
    for k, v in pairs(self.mapGridController.allBuildings) do
        k:keepPos()
    end
end
function BuildLayer:soldierKeepPos()
end
function BuildLayer:finishPlan()
    local changedBuilding = {}
    for k, v in pairs(self.mapGridController.allBuildings) do
        if k.dirty == 1 then
            global.user:updateBuilding(k)
            local p = getPos(k.bg)
            table.insert(changedBuilding, {k.bid, p[1], p[2], k.dir})
        end
        k:finishPlan()
    end
    if #changedBuilding > 0 then
        global.httpController:addRequest("finishPlan", dict({{"uid", global.user.uid}, {"builds", simple.encode(changedBuilding)}}), nil, nil)
    end
    self:clearPlanState()
end

