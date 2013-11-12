require "miao.MiaoPeople"
require "model.MapGridController"
require "Miao.TestCat"
MiaoBuildLayer = class(MoveMap)
function MiaoBuildLayer:ctor(s)
    self.scene = s
    self.moveZone = {{0, 0, MapWidth, MapHeight}}
    self.buildZone = {{0, 0, MapWidth, MapHeight}}
    self.staticObstacle = {}

    
    self.bg = CCLayer:create()
    self.mapGridController = MapGridController.new(self)
    self.roadLayer = CCLayer:create()
    self.bg:addChild(self.roadLayer)
    self.farmLayer = CCLayer:create()
    self.bg:addChild(self.farmLayer)
    self.buildingLayer = CCLayer:create()
    self.bg:addChild(self.buildingLayer)

    self.gridLayer = CCLayer:create()
    self.bg:addChild(self.gridLayer)
    self.cellLayer = CCLayer:create()
    self.bg:addChild(self.cellLayer)
    self.pathLayer = CCNode:create()
    self.bg:addChild(self.pathLayer)

    self.removeLayer = CCNode:create()
    self.bg:addChild(self.removeLayer)

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

function MiaoBuildLayer:initSlope()
    local initX = 11
    local initY = 19
    for i=0, 14, 1 do
        local curX = initX+i
        local curY = initY-i

        local b = MiaoBuild.new(self, {picName='build', id=8})
        local p = normalizePos({curX*SIZEX, curY*SIZEY-SIZEY}, 1, 1)
        b:setPos(p)
        b:setColPos()
        self:addBuilding(b, MAX_BUILD_ZORD)
        b:setPos(p)
        b:finishBuild()

    end

    local b = MiaoBuild.new(self, {picName='build', id=7})
    local p = normalizePos({10*SIZEX, 20*SIZEY-SIZEY}, 1, 1)
    b:setPos(p)
    b:setColPos()
    self:addBuilding(b, MAX_BUILD_ZORD)
    b:setPos(p)
    b:finishBuild()

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


    local b = MiaoBuild.new(self, {picName='backPoint'})
    local p = normalizePos({900, 400}, 1, 1)
    b:setPos(p)
    b:setColPos()
    self:addBuilding(b, MAX_BUILD_ZORD)
    b:setPos(p)
    b:finishBuild()
    self.backPoint = b

    --矿坑
    local b = MiaoBuild.new(self, {picName='build', id=11})
    local p = normalizePos({17*SIZEX, 13*SIZEY-SIZEY}, 1, 1)
    b:setPos(p)
    b:setColPos()
    self:addBuilding(b, MAX_BUILD_ZORD)
    b:setPos(p)
    b:finishBuild()
    --采矿营地
    local b = MiaoBuild.new(self, {picName='build', id=12})
    local p = normalizePos({13*SIZEX, 13*SIZEY-SIZEY}, 1, 1)
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
--初始化商人的路径
function MiaoBuildLayer:initMerchantRoad()
    local initX = 200
    local initY = 0
    local offX = 64
    local offY = 47
    local row = 5
    local col = 10

    for i=0, col, 1 do
        local b = MiaoBuild.new(self, {picName='t'})
        local p = {initX+i*offX, initY+i*offY} 
        p = normalizePos(p, b.sx, b.sy)
        b:setPos(p)
        b:setColPos()
        self:addBuilding(b, MAX_BUILD_ZORD)
        b:setPos(p)
        b:finishBuild()
        if i == 10 or i == 9 then
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


    local b = MiaoBuild.new(self, {picName='t'})
    local p = normalizePos({300-offX, 500+offY}, 1, 1)
    b:setPos(p)
    b:setColPos()
    self:addBuilding(b, MAX_BUILD_ZORD)
    b:setPos(p)
    b:finishBuild()

    --连接到河流
    local b = MiaoBuild.new(self, {picName='t'})
    local p = normalizePos({300-offX, 500+offY}, 1, 1)
    b:setPos(p)
    b:setColPos()
    self:addBuilding(b, MAX_BUILD_ZORD)
    b:setPos(p)
    b:finishBuild()

    --绕开那个 breakpoint
    for i=0, 5, 1 do
        local b = MiaoBuild.new(self, {picName='t'})
        local p = normalizePos({(14+i)*SIZEX, (12+i)*SIZEY-SIZEY}, 1, 1)
        b:setPos(p)
        b:setColPos()
        self:addBuilding(b, MAX_BUILD_ZORD)
        b:setPos(p)
        b:finishBuild()
    end
end
--道路始终 放在 建筑物 下面的 所以先初始化road 再初始化建筑物 如果建筑物 和 road 重叠了 则需要直接取消掉road
function MiaoBuildLayer:initDataOver()
    self:initSea()
    self:initSlope()
    self:initRoad()
    self:initMerchantRoad()
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
function MiaoBuildLayer:addCat()
    local p = MiaoPeople.new(self, {id=3})
    self.buildingLayer:addChild(p.bg, MAX_BUILD_ZORD)
    local pos = normalizePos({600, 400}, 1, 1)
    setPos(p.bg, pos)
    p:setZord()

end
function MiaoBuildLayer:addPeople(param)
    local p = MiaoPeople.new(self, {id=param})
    self.buildingLayer:addChild(p.bg, MAX_BUILD_ZORD)
    local pos
    if param == 1 then
        pos = normalizePos({600, 400}, 1, 1)
    --商人
    else
        pos = normalizePos({200, 20}, 1, 1)
    end
    setPos(p.bg, pos)
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

--加入一个特殊的remove建筑物
