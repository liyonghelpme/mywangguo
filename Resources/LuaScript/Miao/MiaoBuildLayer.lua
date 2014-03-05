require "Miao.MiaoPeople"
require "model.MapGridController"
--require "Miao.TestCat"
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

    self.menuLayer = CCNode:create()
    self.bg:addChild(self.menuLayer)
    
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
    if not self.initEnvYet and self.scene.initYet  then
        self.initEnvYet = true
        self:initEnv()
    end

    if self.needInit and self.initEnvYet then
        if coroutine.status(self.coroutine) ~= 'dead' then
            print("init build")
            coroutine.resume(self.coroutine, self)
        --dead then init other
        else
            print("init others")
            self:initCat()
            self:initRoad()
            self:initBackPoint()
            self.initYet = true
            --self.scene.initDataing = false
            self.needInit = false
            global.director.curScene:afterInitBuild()
        end
    end

    self.passTime = self.passTime+diff
    if self.passTime >= 10 and self.initYet and not Logic.paused  then
        self.passTime = 0
        --正在搜索路径则 不要添加新的商人
        if publicMiaoPath ~= nil and publicMiaoPath.inSearch then
        else
            self:addPeople(8)
        end
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
    self:addPeople(15)
    self:addPeople(16)
    self:addPeople(17)
    self:addPeople(18)
    self:addPeople(19)
    self:addPeople(20)
    self:addPeople(21)
    self:addPeople(22)
end

function MiaoBuildLayer:initCat()
    if DEBUG_BUILD then
        return
    end

    for k, v in ipairs(Logic.pdata) do
        v.needAppear = false
        v.id = v.kind
        local p = MiaoPeople.new(self, v)
        Logic.farmPeople[v.pid] = p
        --table.insert(Logic.farmPeople, p)

        self.buildingLayer:addChild(p.bg, MAX_BUILD_ZORD)
        local pos = normalizePos({v.px, v.py}, 1, 1)
        p:setPos(pos)
        p:setZord()
        self.mapGridController:addSoldier(p)
        if v.hid ~= 0 then
            p.myHouse = self.mapGridController.bidToBuilding[v.hid]
            if p.myHouse ~= nil then
                p.myHouse:setOwner(p)
            end
        end
    end
end


function MiaoBuildLayer:initBackPoint()
    local b = MiaoBuild.new(self, {picName='backPoint', id=23})
    local width = self.scene.width
    local height = self.scene.height
    local bax, bay
    bax = self.scene.width-3
    bay = Logic.stageRange[Logic.gameStage][2]
    --[[
    if Logic.gameStage == 1 then
    elseif Logic.gameStage == 2 then
    else
    end
    --]]

    local cx, cy = newAffineToCartesian(bax, bay, width, height, MapWidth/2, FIX_HEIGHT)
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
    if DEBUG_BUILD then
        self:initBuildOld()
        return
    end
    local mbid = 0
    print("bdata is what", #Logic.bdata)
    for k, v in ipairs(Logic.bdata) do
        --if v.kind == 2 then
        local dir = v.dir or 0
        v.dir = 1-dir
        v.id = v.kind
        v.kind = nil
        v.px = v.ax
        v.py = v.ay
        v.ax = nil
        v.ay = nil

        --work data
        local b = MiaoBuild.new(self, v)
        b:setWork(v)

        local p = {v.px, v.py}
        b:setPos(p)
        b:setColPos()
        self:addBuilding(b, MAX_BUILD_ZORD)
        b:setPos(p)
        --道路需要调用这个调整斜坡
        b.funcBuild:whenColNow()
        b.funcBuild:adjustRoad()
        b:finishBuild()
        --调整建筑物方向
        b:doSwitch()
        mbid = math.max(v.bid, mbid)
        --end
        coroutine.yield()
    end
    mbid = mbid+1
    Logic.maxBid = mbid
end


function MiaoBuildLayer:initBuildOld()
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

    --初始化建筑物信息
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
    --[[
    local sf = CCSpriteFrameCache:sharedSpriteFrameCache()
    sf:addSpriteFramesWithFile("buildOne.plist")
    sf:addSpriteFramesWithFile("buildTwo.plist")
    sf:addSpriteFramesWithFile("buildThree.plist")
    sf:addSpriteFramesWithFile("buildFour.plist")
    sf:addSpriteFramesWithFile("skillOne.plist")
    --sf:addSpriteFramesWithFile("catOne.plist")
    sf:addSpriteFramesWithFile("goodsOne.plist")
    sf:addSpriteFramesWithFile("catCut.plist")
    sf:addSpriteFramesWithFile("catHeadOne.plist")
    --]]
    initPlist()
end

--道路始终 放在 建筑物 下面的 所以先初始化road 再初始化建筑物 如果建筑物 和 road 重叠了 则需要直接取消掉road
function MiaoBuildLayer:initDataOver()
    self:initPic()
    print("init building info")
    --env 减少 地图
    self.needInit = true
    self.initEnvYet = false
    self.coroutine = coroutine.create(self.initBuild)

    --[[
    self:initBuild()
    self:initCat()
    self:initRoad()
    self:initBackPoint()
    self.initYet = true
    --]]

    --[[
    --最后保存道路
    --backPoint 在道路上面
    --]]
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
    --新手建筑物 从服务器获得
    if not DEBUG_BUILD then
        return
    end

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

--检测生成的新猫咪的位置所在 的 block 是否ok
function MiaoBuildLayer:checkBlockOk(ax, ay)
    local allBlock = self.scene.block
    local mwid = self.scene.width

    local hideBlock1 = Logic.villageBlock
    local hideBlock2 = concateTable(concateTable(Logic.stage2Block, Logic.extendBlock), Logic.extendBlock2)

    local v = {ax, ay}
    if Logic.gameStage == 1 then
        local sr = Logic.stageRange[Logic.gameStage]
        if v[1] < sr[1] or v[2] < sr[2] then
            addBanner("猫咪超出边界")
            return false
        end
        local gk = v[2]*mwid+v[1]+1
        for hk, hv in ipairs(hideBlock1) do
            print("allBlock hv gk ", Logic.curVillage, hv, gk)
            if hk >= Logic.curVillage then
                print("value", allBlock[hv][gk])
                if allBlock[hv][gk] ~= 0 then
                    addBanner("不能在黑色区域建造"..hv)
                    return false
                end
            end
        end
    else
        local sr
        if Logic.showLand[13] and Logic.showLand[11] then
            sr = Logic.stageRange[4]
        elseif Logic.showLand[11] and not Logic.showLand[13] then
            sr = Logic.stageRange[3]
        elseif Logic.showLand[13] and not Logic.showLand[11] then
            sr = Logic.stageRange[5]
        else
            sr = Logic.stageRange[2]
        end
        if v[1] < sr[1] or v[2] < sr[2] then
            addBanner("超出边界stage 2")
            return false
        end
        local gk = v[2]*mwid+v[1]+1
        for hk, hv in ipairs(hideBlock2) do
            if not Logic.openMap[hv] then
                if allBlock[hv][gk] ~= 0 then
                    addBanner("不能在stage2黑色区域"..hv)
                    return false
                end
            end
        end
    end
    return true
end

function MiaoBuildLayer:addPeople(param)
    local p = MiaoPeople.new(self, {id=param, pid=#Logic.farmPeople+1})
    self.buildingLayer:addChild(p.bg, MAX_BUILD_ZORD)
    
    local data = Logic.people[param]
    local pos
    --村民需要设定pid值
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
        --pos = normalizePos({pos.x, pos.y}, 1, 1)
        --local p = pos
        --[[
        local ax, ay = newCartesianToAffine(p[1], p[2], self.scene.width, self.scene.height, MapWidth/2, FIX_HEIGHT)
        ax = math.max(math.min(ax, self.scene.width-1-1-1-1), 1)
        ay = math.max(math.min(ay, self.scene.height-1-1-1-1), 1)
        --]]
        --检测ax ay 所在位置是否正确 
        --在第一个gameStage 出现在第一块中心
        --第二个gameStage 出现在第二块中心
        --根据地图 块所在的中心位置决定
        local ax, ay
        if Logic.gameStage == 1 then
            --local sr = Logic.stageRange[Logic.gameStage]
            if Logic.curVillage == 1 then
                ax, ay = 17, 24
            elseif Logic.curVillage == 2 then
                ax, ay = Logic.villageCenter[1][1], Logic.villageCenter[1][2]
            elseif Logic.curVillage == 3 then
                ax, ay = Logic.villageCenter[2][1], Logic.villageCenter[2][2]
            else
                ax, ay = Logic.villageCenter[3][1], Logic.villageCenter[3][2]
            end
        else
            --新的块是否ok 如果ok 则 出现在这个ax ay 上面
            --或者快速得到建筑物的 ax ay 属性
            ax, ay = 15+math.random(3), 21+math.random(3)
        end

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
