require "miao.MiaoPeople"
require "model.MapGridController"
MiaoBuildLayer = class(MoveMap)
function MiaoBuildLayer:ctor(s)
    self.scene = s
    self.moveZone = {{0, 0, 1000, 1000}}
    self.buildZone = {{0, 0, 1000, 1000}}
    self.staticObstacle = {}

    
    self.bg = CCLayer:create()
    self.mapGridController = MapGridController.new(self)
    self.roadLayer = CCLayer:create()
    self.bg:addChild(self.roadLayer)
    self.buildingLayer = CCLayer:create()
    self.bg:addChild(self.buildingLayer)

    self.gridLayer = CCLayer:create()
    self.bg:addChild(self.gridLayer)
    self.cellLayer = CCLayer:create()
    self.bg:addChild(self.cellLayer)
    self.pathLayer = CCNode:create()
    self.bg:addChild(self.pathLayer)

    --self:initData()
    --self:initTest()
    --self:initSea()
    
    --寻路功能模块
    self.curSol = nil
    self.cells = {}
end

function MiaoBuildLayer:switchPathSol()
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
end

function MiaoBuildLayer:initBuild()
    local b = MiaoBuild.new(self, {picName='build', id=1})
    local p = normalizePos({200, 200}, 1, 1)
    b:setPos(p)
    b:setColPos()
    self:addBuilding(b, MAX_BUILD_ZORD)
    b:setPos(p)
    b:finishBuild()


    local b = MiaoBuild.new(self, {picName='build', id=1})
    local p = normalizePos({500, 500}, 1, 1)
    b:setPos(p)
    b:setColPos()
    self:addBuilding(b, MAX_BUILD_ZORD)
    b:setPos(p)
    b:finishBuild()

    --每个农田只能有一个人去工作
    local b = MiaoBuild.new(self, {picName='build', id=2})
    local p = normalizePos({300, 500}, 1, 1)
    b:setPos(p)
    b:setColPos()
    self:addBuilding(b, MAX_BUILD_ZORD)
    b:setPos(p)
    b:finishBuild()
end

function MiaoBuildLayer:initSea()
    local initX = -128
    local initY = 500
    local offX = 64
    local offY = 47
    local col = 13
    for i = 0, col-1, 1 do
        local b = MiaoBuild.new(self, {picName='s'})
        local p = {initX+i*offX, initY+i*offY} 
        p = normalizePos(p, b.sx, b.sy)
        b:setPos(p)
        b:setColPos()
        self:addBuilding(b, MAX_BUILD_ZORD)
        b:setPos(p)
        b:finishBuild()

        local b = MiaoBuild.new(self, {picName='s'})
        local p = {initX+i*offX+offX, initY+i*offY-offY} 
        p = normalizePos(p, b.sx, b.sy)
        b:setPos(p)
        b:setColPos()
        self:addBuilding(b, MAX_BUILD_ZORD)
        --调整zord
        b:setPos(p)
        b:finishBuild()

        local b = MiaoBuild.new(self, {picName='s'})
        local p = {initX+i*offX-offX, initY+i*offY+offY} 
        p = normalizePos(p, b.sx, b.sy)
        b:setPos(p)
        b:setColPos()
        self:addBuilding(b, MAX_BUILD_ZORD)
        --调整zord
        b:setPos(p)
        b:finishBuild()
    end
end
function MiaoBuildLayer:initTest()
    local initX = 60
    local initY = 60
    local offX = 150
    local offY = 150
    local row = 5
    local col = 5
    for i=0, 15, 1 do
        local n = i
        local cr = math.floor(i/col)
        local cc = i%col

        local b = MiaoBuild.new(self, {picName='s'})
        local p = {initX+cc*offX, initY+cr*offY} 
        p = normalizePos(p, b.sx, b.sy)
        b:setPos(p)
        b:setColPos()
        self:addBuilding(b, MAX_BUILD_ZORD)
        --调整zord
        b:setPos(p)
        b:finishBuild()
        b.value = i
        b:adjustValue()


    end
end
function MiaoBuildLayer:initRoad()
    local initX = 60
    local initY = 60
    local offX = 64
    local offY = 47
    local row = 5
    local col = 8
    for i=0, col, 1 do
        local b = MiaoBuild.new(self, {picName='t'})
        local p = {initX+i*offX, initY+i*offY} 
        p = normalizePos(p, b.sx, b.sy)
        b:setPos(p)
        b:setColPos()
        self:addBuilding(b, MAX_BUILD_ZORD)
        b:setPos(p)
        b:finishBuild()

        local rd = math.random(2)
        if rd == 1 then
            local b = MiaoBuild.new(self, {picName='t'})
            local p = {initX+(i+1)*offX, initY+(i-1)*offY} 
            p = normalizePos(p, b.sx, b.sy)
            b:setPos(p)
            b:setColPos()
            self:addBuilding(b, MAX_BUILD_ZORD)
            b:setPos(p)
            b:finishBuild()
        end
    end

    --id = nil picName 决定地形块类型
    local b = MiaoBuild.new(self, {picName='t'})
    local p = {300+offX, 500-offY} 
    p = normalizePos(p, b.sx, b.sy)
    b:setPos(p)
    b:setColPos()
    self:addBuilding(b, MAX_BUILD_ZORD)
    b:setPos(p)
    b:finishBuild()

    local b = MiaoBuild.new(self, {picName='t'})
    local p = {300+offX+offX, 500-offY-offY} 
    p = normalizePos(p, b.sx, b.sy)
    b:setPos(p)
    b:setColPos()
    self:addBuilding(b, MAX_BUILD_ZORD)
    b:setPos(p)
    b:finishBuild()

    local b = MiaoBuild.new(self, {picName='t'})
    local p = {300+offX+offX+offX, 500-offY} 
    p = normalizePos(p, b.sx, b.sy)
    b:setPos(p)
    b:setColPos()
    self:addBuilding(b, MAX_BUILD_ZORD)
    b:setPos(p)
    b:finishBuild()
end
--道路始终 放在 建筑物 下面的
function MiaoBuildLayer:initDataOver()
    self:initSea()
    self:initRoad()
    self:initBuild()
end
function MiaoBuildLayer:initData()
    --构造16种 类型的 道路连接方式
    local initX = 60
    local initY = 60
    local offX = 300
    local offY = 300
    local row = 5
    local col = 5
    for i=0, 15, 1 do
        local n = i
        local cr = math.floor(i/col)
        local cc = i%col

        local r1 = i%2
        i = math.floor(i/2)
        local r3 = i%2
        i = math.floor(i/2)
        local r5 = i%2
        i = math.floor(i/2)
        local r7 = i%2
        
        
        local b = MiaoBuild.new(self, {picName='t'})
        local p = {initX+cc*offX, initY+cr*offY} 
        p = normalizePos(p, b.sx, b.sy)
        b:setPos(p)
        b:setColPos()
        self:addBuilding(b, MAX_BUILD_ZORD)
        --调整zord
        b:setPos(p)
        b:finishBuild()

        local map = getBuildMap(b)
        if r1 ~= 0 then
            local tp = setBuildMap({1, 1, map[3]-1, map[4]+1})
            local b = MiaoBuild.new(self, {picName='t'})
            local p = tp 
            b:setPos(p)
            b:setColPos()
            self:addBuilding(b, MAX_BUILD_ZORD)
            --调整zord
            b:setPos(p)
            b:finishBuild()
        end

        if r3 ~= 0 then
            local tp = setBuildMap({1, 1, map[3]+1, map[4]+1})
            local b = MiaoBuild.new(self, {picName='t'})
            local p = tp 
            b:setPos(p)
            b:setColPos()
            self:addBuilding(b, MAX_BUILD_ZORD)
            --调整zord
            b:setPos(p)
            b:finishBuild()
        end

        if r5 ~= 0 then
            local tp = setBuildMap({1, 1, map[3]+1, map[4]-1})
            local b = MiaoBuild.new(self, {picName='t'})
            local p = tp 
            b:setPos(p)
            b:setColPos()
            self:addBuilding(b, MAX_BUILD_ZORD)
            --调整zord
            b:setPos(p)
            b:finishBuild()
        end

        if r7 ~= 0 then
            local tp = setBuildMap({1, 1, map[3]-1, map[4]-1})
            local b = MiaoBuild.new(self, {picName='t'})
            local p = tp 
            b:setPos(p)
            b:setColPos()
            self:addBuilding(b, MAX_BUILD_ZORD)
            --调整zord
            b:setPos(p)
            b:finishBuild()
        end
    end
end
function MiaoBuildLayer:addPeople()
    local p = MiaoPeople.new(self)
    self.buildingLayer:addChild(p.bg, MAX_BUILD_ZORD)
    setPos(p.bg, {600, 400})
    p:setZord()
    self.mapGridController:addSoldier(p)
end

function MiaoBuildLayer:setCell(p)
    if p ~= nil then
        self.cells[getMapKey(p[1], p[2])] = true
    end
end
function MiaoBuildLayer:clearCell(p)
    if p ~= nil then
        self.cells[getMapKey(p[1], p[2])] = nil
    end
end
