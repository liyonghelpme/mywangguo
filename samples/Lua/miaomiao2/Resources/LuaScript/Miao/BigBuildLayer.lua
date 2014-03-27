require "Miao.BigInfo"
require "Miao.TestPeople"
require "Miao.TestBuild"
BigBuildLayer = class(MoveMap)
function BigBuildLayer:ctor(s)
    self.scene = s
    self.offX = 3200
    self.offY = 0

    self.moveZone = {{0, 0, BIG_MAPWIDTH, BIG_MAPHEIGHT}}
    self.buildZone = {{0, 0, BIG_MAPWIDTH, BIG_MAPHEIGHT}}
    self.staticObstacle = {}

    self.bg = CCLayer:create()
    self.mapGridController = MapGridController.new(self)
    self.roadLayer = CCLayer:create()
    self.bg:addChild(self.roadLayer)

    self.buildingLayer = CCLayer:create()
    self.bg:addChild(self.buildingLayer)

    self.peopleLayer = CCLayer:create()
    self.bg:addChild(self.peopleLayer)

    self.gridLayer = CCLayer:create()
    self.bg:addChild(self.gridLayer)

    self.cells = {}
    self:initRoad()
    self:initCastle()
end
function BigBuildLayer:initRoad()
    local nlayer = self.scene.tileMap:layerNamed("road")
    print("init road now", nlayer)
    if nlayer ~= nil then
        for i = 0, BIG_MAPX-1, 1 do
            for j=0, BIG_MAPY-1, 1 do
                --28 ~ 36
                local gid = nlayer:tileGIDAt(ccp(i, j))
                if gid ~= 0 then
                    local cx, cy = bigAffineToCartesian(i, j)
                    print("road x y", cx, cy)
                    local b = MiaoBuild.new(self, {picName='build', id=15, setYet=false})
                    local p = normalizePos({cx, cy}, 1, 1)
                    b:setPos(p)
                    b:setColPos()
                    self:addBuilding(b, MAX_BUILD_ZORD)
                    b:setPos(p)
                    b:finishBuild()
                end
            end
        end
    end
end
function BigBuildLayer:initCastle()
    local nlayer = self.scene.tileMap:layerNamed("build")
    print("init castle now", nlayer)
    if nlayer ~= nil then
        for i = 0, BIG_MAPX-1, 1 do
            for j=0, BIG_MAPY-1, 1 do
                --28 ~ 36
                local gid = nlayer:tileGIDAt(ccp(i, j))
                if gid == 41 then
                    local cx, cy = bigAffineToCartesian(i, j)
                    print("road x y", cx, cy)
                    local b = TestBuild.new(self, {picName='build', id=gid, setYet=false})
                    local p = normalizePos({cx, cy}, 1, 1)
                    b:setPos(p)
                    b:setColPos()
                    b:setState(BUILD_STATE.FREE)
                    self:addBuilding(b, MAX_BUILD_ZORD)
                    --b:setPos(p)
                    --b:finishBuild()
                elseif gid == 42 then
                    local cx, cy = bigAffineToCartesian(i, j)
                    print("road x y", cx, cy)
                    local b = TestBuild.new(self, {picName='build', id=gid, setYet=false})
                    local p = normalizePos({cx, cy}, 1, 1)
                    b:setPos(p)
                    b:setColPos()
                    b:setState(BUILD_STATE.FREE)
                    self:addBuilding(b, MAX_BUILD_ZORD)
                    self.homeTile = b
                end
            end
        end
    end
end
function BigBuildLayer:startBattle(b)
    self.targetBuild = b
    local m = BigInfo.new(self)
    self.scene.scene.menu.menu = m 
    global.director:pushView(m, 1, 0)
end
function BigBuildLayer:addPeople()
    local p = TestPeople.new(self)
    p:setTarget(self.targetBuild)
    local bp = getPos(self.homeTile.bg)
    setPos(p.bg, bp)
    p:setZord()
    self.peopleLayer:addChild(p.bg)
end
