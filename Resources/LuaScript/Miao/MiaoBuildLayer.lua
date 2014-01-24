require "Miao.MiaoPeople"
require "model.MapGridController"
require "Miao.TestCat"
MiaoBuildLayer = class(MoveMap)
function MiaoBuildLayer:ctor(s)
    self.scene = s
    self.offX = 1472
    self.offY = 0

    self.moveZone = {{0, 0, MapWidth, MapHeight}}
    self.buildZone = {{0, 0, MapWidth, MapHeight}}
    self.staticObstacle = {}

    
    self.bg = CCLayer:create()
    self.mapGridController = MapGridController.new(self)
    self.terrian = addCLayer(self.bg)
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

    
    --寻路功能模块
    self.curSol = nil
    self.cells = {}
    self.passTime = 10
    self.events = {EVENT_TYPE.ROAD_CHANGED}
    registerEnterOrExit(self)
    self:initCar()
end
function MiaoBuildLayer:receiveMsg(msg, param)
    --print("receiveMsg !!!!!!!!!!", msg, param)
    if msg == EVENT_TYPE.ROAD_CHANGED then
        print("dirty public MiaoPath !!!!!!!!!", publicMiaoPath)
        if publicMiaoPath ~= nil then
            publicMiaoPath.dirty = true
        end
    end
end
function MiaoBuildLayer:initCar()
end
function MiaoBuildLayer:enterScene()
    registerUpdate(self)
end

--商人的状态也要保存么？
function MiaoBuildLayer:update(diff)
    self.passTime = self.passTime+diff
    if self.passTime >= 10 and self.initYet and not Logic.paused  then
        self.passTime = 0
        self:addPeople(8)
    end
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

function MiaoBuildLayer:testCat()
    self:addPeople(14)
    self:addPeople(14)
    self:addPeople(14)
    self:addPeople(14)
    self:addPeople(14)
    self:addPeople(14)
    self:addPeople(14)
    self:addPeople(14)
    self:addPeople(14)
end
function MiaoBuildLayer:initCat()
    if Logic.inNew then
        self:addPeople(3)
        self:addPeople(4)
        return
    end
    local u = CCUserDefault:sharedUserDefault()
    local cat = u:getStringForKey("people")
    if cat ~= "" then
        cat = simple.decode(cat)
        for k, v in ipairs(cat) do
            --{id=v.id or 3, needAppear = false, health=v.health}
            v.needAppear = false
            local p = MiaoPeople.new(self, v)
            table.insert(Logic.farmPeople, p)
            self.buildingLayer:addChild(p.bg, MAX_BUILD_ZORD)
            local pos = normalizePos({v.px, v.py}, 1, 1)
            p:setPos(pos)
            p:setZord()
            self.mapGridController:addSoldier(p)
            if v.hid ~= nil then
                p.myHouse = self.mapGridController.bidToBuilding[v.hid]
                p.myHouse:setOwner(p)
            end
        end
    end
end
function MiaoBuildLayer:initBackPoint()
    local b = MiaoBuild.new(self, {picName='backPoint', id=23})
    local width = self.scene.width
    local height = self.scene.height
    local cx, cy = newAffineToCartesian(self.scene.width-3, 0, width, height, MapWidth/2, FIX_HEIGHT)
    --local cx, cy = affineToCartesian(21, 0)
    local p = normalizePos({cx, cy}, 1, 1)
    b:setPos(p)
    b:setColPos()
    self:addBuilding(b, MAX_BUILD_ZORD)
    b:setPos(p)
    b:finishBuild()
    self.backPoint = b
end
function MiaoBuildLayer:initBuild()
    if Logic.inNew then
        local b = MiaoBuild.new(self, {picName='build', id=1, bid=1})
        local p = normalizePos({1344, 384}, 1, 1)
        b:setPos(p)
        b:setColPos()
        self:addBuilding(b, MAX_BUILD_ZORD)
        b:setPos(p)
        b:finishBuild()

        local b = MiaoBuild.new(self, {picName='build', id=2, bid=2})
        local p = normalizePos({1472, 448}, 1, 1)
        b:setPos(p)
        b:setColPos()
        self:addBuilding(b, MAX_BUILD_ZORD)
        b:setPos(p)
        b:finishBuild()

        local mbid = 0
        mbid = math.max(2, mbid)
        mbid = mbid+1
        Logic.maxBid = mbid
        return
    end

    local u = CCUserDefault:sharedUserDefault()
    local build = u:getStringForKey("build")
    local mbid = 0
    if build ~= "" then
        build = simple.decode(build)
        for k, v in ipairs(build) do
            local dir = v.dir or 0
            v.dir = 1-dir
            local b = MiaoBuild.new(self, v)
            b:setWork(v)
            --local p = normalizePos({v.px, v.py}, 1, 1)
            local p = {v.px, v.py}
            b:setPos(p)
            b:setColPos()
            self:addBuilding(b, MAX_BUILD_ZORD)
            b:setPos(p)
            b.funcBuild:adjustRoad()
            b:finishBuild()
            --调整建筑物方向
            b:doSwitch()
            mbid = math.max(v.bid, mbid)
        end
        mbid = mbid+1
        Logic.maxBid = mbid
    end

    local road = u:getStringForKey("road")
    if road ~= "" then
        --print("road is what")
        --print(road)
        road = simple.decode(road)
        for k, v in ipairs(road) do
            local b = MiaoBuild.new(self, v)
            --b:setWork(v)
            --local p = normalizePos({v.px, v.py}, 1, 1)
            local p = {v.px, v.py}
            b:setPos(p)
            b:setColPos()
            self:addBuilding(b, MAX_BUILD_ZORD)
            b:setPos(p)
            b.funcBuild:whenColNow()
            b.funcBuild:adjustRoad()
            b:finishBuild()
            mbid = math.max(v.bid, mbid)
        end
        mbid = mbid+1
        Logic.maxBid = mbid
    end

end

function MiaoBuildLayer:initPic()
    local sf = CCSpriteFrameCache:sharedSpriteFrameCache()
    sf:addSpriteFramesWithFile("buildOne.plist")
    sf:addSpriteFramesWithFile("buildTwo.plist")
    sf:addSpriteFramesWithFile("buildThree.plist")
    sf:addSpriteFramesWithFile("buildFour.plist")
    sf:addSpriteFramesWithFile("skillOne.plist")
    sf:addSpriteFramesWithFile("catOne.plist")
    sf:addSpriteFramesWithFile("goodsOne.plist")
    sf:addSpriteFramesWithFile("catCut.plist")
    sf:addSpriteFramesWithFile("catHeadOne.plist")
end

--道路始终 放在 建筑物 下面的 所以先初始化road 再初始化建筑物 如果建筑物 和 road 重叠了 则需要直接取消掉road
function MiaoBuildLayer:initDataOver()
    self:initPic()

    --env 减少 地图
    self:initEnv()
    self:initBuild()
    self:initCat()
    self:initRoad()
    self:initBackPoint()
    --[[
    --最后保存道路
    --backPoint 在道路上面
    --]]
    self.initYet = true
end
function MiaoBuildLayer:initEnv()
    local width = self.scene.width
    local height = self.scene.height


    --篱笆 
    for dk, dv in ipairs(self.scene.layerName.fence.data) do
        if dv ~= 0 then
            local pname = tidToTile(dv, self.scene.normal, self.scene.water)
            local w = (dk-1)%width
            local h = math.floor((dk-1)/width)
            
            --得到affine坐标到笛卡尔坐标的变换
            local cx, cy = newAffineToCartesian(w, h, width, height, MapWidth/2, FIX_HEIGHT)

            local b = MiaoBuild.new(self, {picName='fence', id=22, dir=dir, tileName=pname})
            --local p = normalizePos({cx, cy}, 1, 1)
            local p = {cx, cy}
            b:setPos(p)
            b:setColPos()
            self:addBuilding(b, MAX_BUILD_ZORD)
            b:setPos(p)
            b:finishBuild()
            
        end
    end
end
--road 外部的道路 第一次进入游戏需要从这里面初始化 firstGame = true ---->initRoad
function MiaoBuildLayer:initRoad() 
    local u = CCUserDefault:sharedUserDefault()
    local initRoadYet = u:getBoolForKey("initRoadYet")
    if initRoadYet == true then
        return
    end

    local staticRow = 4

    local nlayer = self.scene.layerName['road']
    local width = self.scene.width
    local height = self.scene.height
    for dk, dv in ipairs(nlayer.data) do
        if dv ~= 0 then
            local pname = tidToTile(dv, self.scene.normal, self.scene.water)
            local w = (dk-1)%width
            local h = math.floor((dk-1)/width)

            --得到affine坐标到笛卡尔坐标的变换
            local cx, cy = newAffineToCartesian(w, h, width, height, MapWidth/2, FIX_HEIGHT)
            --不能移动的道路
            local static = false
            --斜 右下 4行 包括向上走的梯子
            if w >= width-staticRow then
                static =true
            end
            local b = MiaoBuild.new(self, {picName='build', id=15, setYet=false, pname=pname, bid = getBid(), static=static})
            --local p = normalizePos({cx, cy}, 1, 1)
            --不要经过normal pos 处理 normalpos跟当前的奇数偶数不同了
            --使用newAffineToCartesian  newCartesianToAffine  withDepth 进行转化
            local p = {cx, cy}

            b:setPos(p)
            b:setColPos()
            self:addBuilding(b, MAX_BUILD_ZORD)
            b:setPos(p)
            b.funcBuild:adjustRoad()
            b:finishBuild()
        end
    end


    --临时斜坡显示一下 和斜坡的方向 0 1 
    for dk, dv in ipairs(self.scene.layerName.ladder.data) do
        if dv ~= 0 then
            local pname = tidToTile(dv, self.scene.normal, self.scene.water)
            local w = (dk-1)%width
            local h = math.floor((dk-1)/width)

            local static = false
            if w >= width-staticRow then
                static =true
            end

            --得到affine坐标到笛卡尔坐标的变换
            local cx, cy = newAffineToCartesian(w, h, width, height, MapWidth/2, FIX_HEIGHT)
            local b = MiaoBuild.new(self, {picName='build', id=15, setYet=false, ladder=true, dir = 0, static = static, bid=getBid()})
            --local p = normalizePos({cx, cy}, 1, 1)
            p = {cx, cy}
            b:setPos(p)
            b:setColPos()
            self:addBuilding(b, MAX_BUILD_ZORD)
            b:setPos(p)
            b.funcBuild:adjustRoad()
            b:finishBuild()
        end
    end


    --初始化建筑物数据 建筑物id
    for dk, dv in ipairs(self.scene.layerName.build2.data) do
        if dv ~= 0 then
            local pname = self.scene.gidToImage[dv]
            local w = (dk-1)%width
            local h = math.floor((dk-1)/width)

            local static = false
            if w >= width-staticRow then
                static =true
            end
            print("dv is what", dv, pname)

            --得到affine坐标到笛卡尔坐标的变换
            local cx, cy = newAffineToCartesian(w, h, width, height, MapWidth/2, FIX_HEIGHT)
            local b = MiaoBuild.new(self, {picName='build', id=tonumber(pname), static = static, bid=getBid()})
            --local p = normalizePos({cx, cy}, 1, 1)
            local p = {cx, cy}
            b:setPos(p)
            b:setColPos()
            self:addBuilding(b, MAX_BUILD_ZORD)
            b:setPos(p)
            b.funcBuild:adjustRoad()
            b:finishBuild()
        end
    end
    self:addPeople(14)
    self:addPeople(18)
    self:addPeople(20)
    self:addPeople(23)
    
    global.director.curScene:saveGame(true)
    u:setBoolForKey("initRoadYet", true)
end
function MiaoBuildLayer:addPeople(param)
    local p = MiaoPeople.new(self, {id=param})
    self.buildingLayer:addChild(p.bg, MAX_BUILD_ZORD)
    
    local data = Logic.people[param]
    local pos
    if data.kind == 1 then
        table.insert(Logic.farmPeople, p)
        local vs = getVS()
        pos = self.bg:convertToNodeSpace(ccp(vs.width/2, vs.height/2))
        --计算屏幕中心位置对应的网格坐标
        --将猫咪限制到地图边界里面才行
        --超出地图边界的 cxy 如何转化呢？
        --附近最近的一个有效的网格
        --local ax, ay = cxyToAxyWithDepth(pos.x, pos.y, self.scene.width, self.scene.height, MapWidth/2, FIX_HEIGHT, self.scene.mask, self.scene.cxyToAxyMap)
        --出现位置基本在地图中
        pos = normalizePos({pos.x, pos.y}, 1, 1)
        local p = pos

        local ax, ay = newCartesianToAffine(p[1], p[2], self.scene.width, self.scene.height, MapWidth/2, FIX_HEIGHT)
        ax = math.max(math.min(ax, self.scene.width-1-1-1-1), 1)
        ay = math.max(math.min(ay, self.scene.height-1-1-1-1), 1)
        local cx, cy = newAffineToCartesian(ax, ay, self.scene.width, self.scene.height, MapWidth/2, FIX_HEIGHT)
        pos = {cx, cy}
        
        local nv = getPosMap(1, 1, pos[1], pos[2])
        nv = {nv[3], nv[4]}

        local neiNode = {
            {nv[1], nv[2]},
            {nv[1], nv[2]+2},
            {nv[1]+1, nv[2]+1},
            {nv[1]+2, nv[2]},
            {nv[1]+1, nv[2]-1},
            {nv[1], nv[2]-2},
            {nv[1]-1, nv[2]-1},
            {nv[1]-2, nv[2]},
            {nv[1]-1, nv[2]+1},
        }
        local buildCell = self.mapGridController.mapDict
        local findPos = nil
        for k, v in ipairs(neiNode) do
            local key = getMapKey(v[1], v[2])
            print("state", v[1], v[2], buildCell[key])
            if buildCell[key] ~= nil then
                local bb = buildCell[key][#buildCell[key]][1]
                if bb.picName == 't' then
                    findPos = v
                    break
                end
            else
                findPos = v
                break
            end
        end
        print("findPos", simple.encode(findPos))
        print(simple.encode(neiNode))
        if findPos ~= nil then
            pos = setBuildMap({1, 1, findPos[1], findPos[2]})
        end
        --只保存普通村民
    --商人
    elseif data.kind == 2 then
        local width = self.scene.width
        local height = self.scene.height
        local cx, cy = newAffineToCartesian(self.scene.width-3, self.scene.height-2, width, height, MapWidth/2, FIX_HEIGHT)
        --local cx, cy = affineToCartesian(21, 24)
        pos = normalizePos({cx, cy}, 1, 1)
        --如何解决 猫咪坐标需要 normalizePos的问题
        --pos = {cx, cy}
    end
    --setPos(p.bg, pos)
    p:setPos(pos)
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
