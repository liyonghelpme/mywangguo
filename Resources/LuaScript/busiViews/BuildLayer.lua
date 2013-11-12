require "model.MapGridController"
require "views.Building"
require "views.Soldier"
require "views.Monster"

ClearNode = class

BuildLayer = class(MoveMap)
function BuildLayer:ctor(scene)
    self.scene = scene
    self.moveZone = TrainZone
    self.buildZone = BUILD_ZONE
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
    
    self.showBuildLayer = nil
    self.showGrids = {}

    --用于士兵到达目的地之后防止冲突
    self.cells = {}
    --当前允许寻路的士兵
    self.curSol = nil
    self.birdTime = 30
    self.birds = {}

    registerEnterOrExit(self)
    registerUpdate(self)
    self.passTime = 30
    self.treeTime = 0
    self.monsters = {}
    self:initGrassSprite()
    self:initMagic()
end
--所有魔法特效图片
function BuildLayer:initMagic()
    local tex = CCTextureCache:sharedTextureCache():addImage("fig7.png")
    local ca = CCSpriteFrameCache:sharedSpriteFrameCache()
    for i=0, 1 do
        for j=0, 3 do
            local r = CCRectMake(120*j, 120*i, 120, 120)
            local sp = CCSpriteFrame:createWithTexture(tex, r)
            ca:addSpriteFrame(sp, "ball"..i*10+j)
        end
    end

    local r = CCRectMake(0, 240, 240, 60)
    local sp = CCSpriteFrame:createWithTexture(tex, r)
    ca:addSpriteFrame(sp, "arrow0")

    local r = CCRectMake(0, 300, 240, 60)
    local sp = CCSpriteFrame:createWithTexture(tex, r)
    ca:addSpriteFrame(sp, "arrow1")

    local r = CCRectMake(0, 360, 240, 60)
    local sp = CCSpriteFrame:createWithTexture(tex, r)
    ca:addSpriteFrame(sp, "arrow2")
end
function BuildLayer:initGrassSprite()
    --[[
    local tex = CCTextureCache:sharedTextureCache():addImage("tileset.png")
    local ca = CCSpriteFrameCache:sharedSpriteFrameCache()
    for i=0, 7, 1 do
        local r = CCRectMake(4, i*53+9, 56, 43)
        local sp = CCSpriteFrame:createWithTexture(tex, r)
        ca:addSpriteFrame(sp, "grass"..i)
    end

    local tex = CCTextureCache:sharedTextureCache():addImage("realGrass.png")
    local r = CCRectMake(0, 22, 64, 38)
    local sp = CCSpriteFrame:createWithTexture(tex, r)
    ca:addSpriteFrame(sp, "realGrass")
    --]]
end
function BuildLayer:showMapGrid()
    if self.showYet ~= true then
        self.showYet = true
        --第一次显示 初始化一个
        if self.showBuildLayer == nil then
            --removeSelf(self.showBuildLayer)
            self.showBuildLayer = CCSpriteBatchNode:create("white2.png")
            self.bg:addChild(self.showBuildLayer)
            for k, v in pairs(self.mapGridController.effectDict) do
                local x = math.floor(k/10000)
                local y = k%10000
                local p = setBuildMap({1, 1, x, y})
                local sp = setColor(setAnchor(setPos(setSize(addSprite(self.showBuildLayer, "white2.png"), {SIZEX, SIZEY}), p), {0.5, 0}), {102, 0, 0})
                sp:runAction(sequence({fadein(0.5), delaytime(3), fadeout(0.5)}))
                table.insert(self.showGrids, sp)
            end

            for k, v in pairs(self.staticObstacle) do
                local x = math.floor(k/10000)
                local y = k%10000
                local p = setBuildMap({1, 1, x, y})
                local sp = setColor(setAnchor(setPos(setSize(addSprite(self.showBuildLayer, "white2.png"), {SIZEX, SIZEY}), p), {0.5, 0}), {102, 0, 0})
                sp:runAction(sequence({fadein(0.5), delaytime(3), fadeout(0.5)}))
                table.insert(self.showGrids, sp)
            end
        else
            for k, v in ipairs(self.showGrids) do
                v:runAction(sequence({fadein(0.5), delaytime(3), fadeout(0.5)}))
            end
        end
        local function clearShowYet()
            self.showYet = false
        end
        self.showBuildLayer:runAction(sequence({delaytime(4), callfunc(nil, clearShowYet)}))
    end
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
    print("removeKilled Soldiers")
    for k, v in pairs(BattleLogic.killedSoldier) do
        local allSol = self.mapGridController.allSoldiers 
        for i=1, v, 1 do
            for sk, sv in pairs(allSol) do
                if sk.kind == k then
                    print("kind ", k)
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

function BuildLayer:initWall()
    local allB = self.mapGridController.allBuildings
    for k, v in pairs(allB) do
        if k.funcs == WALL then
            k.funcBuild:calValue()
        end
    end
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
        print("getBuildingData", bid, bdata.kind)
        local data = getData(GOODS_KIND.BUILD, bdata["kind"]) 
        local build = Building.new(self, data, bdata)
        build:setBid(bid)

        self.bg:addChild(build.bg, MAX_BUILD_ZORD)
        build:setPos(normalizePos({bdata["px"], bdata["py"]}, data["sx"], data["sy"]))
        self.mapGridController:addBuilding(build)
        build:setZord()
    end
    self:initWall()
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
function BuildLayer:beginSell()
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
function BuildLayer:update(diff)
    self:genMonster(diff)
    self:genBird(diff)
    self:genTree(diff)
end
--当前怪兽堆数小于一定的值的时候 产生怪兽 怪兽移动的范围不超过边界 
--怪兽和士兵之间有战斗
--最多同时4个怪兽
--杀死怪兽的时候 清理怪兽
function BuildLayer:genMonster(diff)
    if BattleLogic.inBattle then
        return
    end
    self.passTime = self.passTime+diff
    if self.passTime > 30 then
        self.passTime = 0
        if #self.monsters < 4 then
            local m = Monster.new(self)
            self.bg:addChild(m.bg, MAX_BUILD_ZORD)
            self.mapGridController:addSoldier(m)
            table.insert(self.monsters, m)
            if CCUserDefault:sharedUserDefault():getBoolForKey("firstGame") then
                local rd = math.random(2)
                if rd == 1 then
                    addCmd({cmd="monGen"}) 
                end
            end
        end
    end
end

function BuildLayer:genBird(diff)
    self.birdTime = self.birdTime+diff
    if self.birdTime > 15 and #self.birds < 6 then
        self.birdTime = 0

        CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("bird.plist")
        createAnimation("bird", "bird%d.png", 0, 9, 1, 1, true)
        local animation = CCAnimationCache:sharedAnimationCache():animationByName("bird")

        local n = math.random(3)+1
        local dy = math.random(200)
        for k=1, n, 1 do
            local bird = CCNode:create()
            local temp = CCSprite:createWithSpriteFrameName("bird0.png")
            setScale(temp, 0.5)
            local shadow = setPos(addSprite(bird, "roleShadow.png"), {0, -100})
            local sz = temp:getContentSize()
            setAnchor(temp, {60/sz.width, (sz.height-83)/sz.height})
            bird:addChild(temp)
            self.bg:addChild(bird, MAX_BUILD_ZORD+1)
            setPos(bird, {-50+k*30, 150+dy-k*30})
            temp:runAction(repeatForever(CCAnimate:create(animation)))
            local dy = math.random(300)
            bird:runAction(moveto(40, MapWidth, 100+dy))
            local function removeBird()
                for k, v in ipairs(self.birds) do
                    if v == bird then
                        table.remove(self.birds, k)
                        break
                    end
                end
                removeSelf(bird)
            end
            bird:runAction(sequence({delaytime(40), callfunc(nil, removeBird)}))
            table.insert(self.birds, bird)
        end
    end
end
--士兵来砍伐树木获得银币 
function BuildLayer:genTree(diff)
    self.treeTime = self.treeTime+diff
    if self.treeTime >= 10 then
    end
end
