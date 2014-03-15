require "Miao.MiaoBuild"
require "Miao.MiaoBuildLayer"
require "Miao.RegionDialog"
require "myMap.NewUtil"
MiaoPage = class()
function MiaoPage:initView()

    --setPos(self.bg, {-MapWidth/2})

    self.oldBuildPos = {}

    local col = math.ceil(MapWidth/64)
    local row = math.ceil(MapHeight/32)+1

    --water 没有alpha通道图片
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGB5A1)
    local tex = CCTextureCache:sharedTextureCache():addImage("water.png")
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    
    local param = ccTexParams()
    param.minFilter = GL_LINEAR
    param.magFilter = GL_LINEAR
    param.wrapS = GL_REPEAT
    param.wrapT = GL_REPEAT
    tex:setTexParameters(param)

    local sea2 = CCSprite:createWithTexture(tex, CCRectMake(0, 0, MapWidth+2, MapHeight))
    local sea = CCSprite:createWithTexture(tex, CCRectMake(0, 0, MapWidth+2, MapHeight))
    setGLProgram(sea, "sea", "Vert.h", "SeaFrag.h")
    self.bg:addChild(sea)
    setAnchor(setPos(sea, {0, 0}), {0, 0})
    self.bg:addChild(sea2)
    setAnchor(setPos(sea2, {MapWidth, 0}), {0, 0})
    self.seas = {sea, sea2}



    local sf = CCSpriteFrameCache:sharedSpriteFrameCache()
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    sf:addSpriteFramesWithFile("grassOne.plist")
    sf:addSpriteFramesWithFile("fenceOne.plist")
    sf:addSpriteFramesWithFile("t512.plist")
    sf:addSpriteFramesWithFile("daoyin.plist")
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)


    self.grassMap = CCSpriteBatchNode:create("grassOne.png")
    self.bg:addChild(self.grassMap)
    setPos(self.grassMap, {MapWidth/2, FIX_HEIGHT})
    
    self.seaMap = CCSpriteBatchNode:create("daoyin.png")
    self.bg:addChild(self.seaMap)
    setPos(self.seaMap, {MapWidth/2, FIX_HEIGHT})

    self.tileMap = CCSpriteBatchNode:create("t512.png")
    self.bg:addChild(self.tileMap)
    setPos(self.tileMap, {MapWidth/2, FIX_HEIGHT})

    self.waterMap = CCSpriteBatchNode:create("t512.png")
    self.bg:addChild(self.waterMap)
    setPos(self.waterMap, {MapWidth/2, FIX_HEIGHT})


    self.fenceMap = CCSpriteBatchNode:create("fenceOne.png")
    self.bg:addChild(self.fenceMap)
    setPos(self.fenceMap, {MapWidth/2, FIX_HEIGHT})

    self.buildLayer = MiaoBuildLayer.new(self)
    self.bg:addChild(self.buildLayer.bg)



    local mj = simple.decode(getFileData("big512.json"))
    self.mapInfo = mj
    local width = mj.width
    local height = mj.height
    self.width = width
    MapAX = width
    self.height = height
    MapAY = height

    local tilesets = mj.tilesets
    self.tilesets = tilesets
    -- >= 1 < 65
    self.normal = {}
    self.water = {}
    self.gidToTileName = {}
    self.gidToImage = {}
    for k, v in ipairs(self.tilesets) do
        self.gidToImage[v.firstgid] = string.gsub(v.name, 'build', '')
        if string.find(v.name, 'water') ~= nil then
            table.insert(self.water, v.firstgid)
        elseif string.find(v.name, 'tt512') ~= nil then
            table.insert(self.normal, v.firstgid)
        else
            self.gidToTileName[v.firstgid] = v.name
        end
    end
    print("normal water", simple.encode(self.normal))
    print(simple.encode(self.water))

    --1-64   --> tile0 tile63
    --65-128 ---> tile0 tile63
    --tid tileNames 

    local layers = mj.layers
    local layerName = {}
    for k, v in ipairs(layers) do
        layerName[v.name] = v
    end
    self.layerName = layerName

    self.mask = {}
    --所有mask layer 2 ---> 1
    for k, v in pairs(layerName) do
        if string.find(k, 'mask') ~= nil then
            local mv = tonumber(string.sub(k, 5))
            print("mask Layer mv", mv)
            for i=1, #v.data, 1 do
                if v.data[i] ~= 0 then
                    self.mask[i] = mv-1
                end
            end
        end
    end


    self.block = {}
    for k, v in pairs(layerName) do
        if string.find(k, 'block') ~= nil then
            local bId = tonumber(string.sub(k, 6))
            self.block[bId] = v.data
        end
    end
    self.publicPath = layerName.publicPath
    self.publicSlope = layerName.publicSlope

    sf:addSpriteFramesWithFile("whiteGeo.plist")
    local debug = CCSpriteBatchNode:create("whiteGeo.png")
    self.bg:addChild(debug, 10)
    self.debug = debug

    --屏幕点 范围 到 axy的一个映射范围
    --调整高度值
    --检查一个小范围的 ax ay 即可 确定属于哪个ax ay
    self.cxyToAxyMap = {}
    for dk=1, self.width*self.height, 1 do
        --if dk <= 10 and dk >= 1 and dk%2 == 1 then
            local w = (dk-1)%width
            local h = math.floor((dk-1)/width)
            --affine to normal
            local cx, cy = newAffineToCartesian(w, h, width, height, MapWidth/2, FIX_HEIGHT)
            --屏幕坐标 计算 mapDict 里面使用的坐标系统
            --使用菱形的 中下点 对齐的
            local left = cx-SIZEX
            local right = cx+SIZEX
            local bottom = cy+(self.mask[dk] or 0)*103
            local top = cy+SIZEY*2+(self.mask[dk] or 0)*103
            
            left = math.floor(left/SIZEX)
            right = math.ceil(right/SIZEX)
            bottom = math.floor(bottom/SIZEY)
            top = math.ceil(top/SIZEY)

            --将该区域 插入到 对应的 cxy区域中
            for i = left, right-1, 1 do
                for j=bottom, top-1, 1 do
                    --print("i j is", i, j, w, h)
                    local v = getDefault(self.cxyToAxyMap, getMapKey(i, j), {})
                    table.insert(v, {w, h})
                end
            end
       -- end
    end

    self.allSlopeAndWater = {}
    for dk, dv in ipairs(layerName.grass.data) do
        if dv ~= 0 then
            --local pname = tidToTile(dv, self.normal, self.water)
            --print("pname is what?", pname)
            local w = (dk-1)%width
            local h = math.floor((dk-1)/width)

            --得到affine坐标到笛卡尔坐标的变换
            local cx, cy = newAffineToCartesian(w, h, width, height, 0, 0)
            local hei = adjustNewHeight(self.mask, self.width, w, h)

            local wid = w%2
            local hid = h%2
            local tid = hid*2+wid
            local pic = CCSprite:createWithSpriteFrameName('grass'..tid..'.png')
            self.grassMap:addChild(pic)
            local sz = pic:getContentSize()
            setAnchor(setPos(pic, {cx, cy+hei*103}), {170/512, 0})
            pic:setScale(1.02)
            table.insert(self.allSlopeAndWater, {pic, w, h})
        end
    end

    for dk, dv in ipairs(layerName.slop1.data) do
        if dv ~= 0 then
            local pname = tidToTile(dv, self.normal, self.water, self.gidToTileName)
            local w = (dk-1)%width
            local h = math.floor((dk-1)/width)

            --得到affine坐标到笛卡尔坐标的变换
            local cx, cy = newAffineToCartesian(w, h, width, height, 0, 0)
            local pic = CCSprite:createWithSpriteFrameName(pname)
            self.tileMap:addChild(pic)
            setScale(setAnchor(setPos(pic, {cx, cy}), {170/512, 0}), 1.05)

            table.insert(self.allSlopeAndWater, {pic, w, h})

            local p2Name = string.gsub(pname, 'tile', 'dao')
            local pic2 = CCSprite:createWithSpriteFrameName(p2Name)
            self.seaMap:addChild(pic2)
            if pname == 'tile11.png' then
                setAnchor(setPos(pic2, {cx, cy-103}), {170/512, 0})
            elseif pname == 'tile9.png' then
                setScaleX(setAnchor(setPos(setRotation(setScaleY(pic2, -1.05), 53), {cx, cy+67}), {170/512, 0}), 1.05)
            else
                setScaleX(setAnchor(setPos(setRotation(setScaleY(pic2, -1), -53), {cx, cy+67}), {170/512, 0}), 1.05)
            end
        end
    end
    setGLProgram(self.seaMap, "blurReflect", "Vert.h", "BlurFrag.h")

    for dk, dv in ipairs(layerName.sea.data) do
        if dv ~= 0 then
            local pname = tidToTile(dv, self.normal, self.water)
            local w = (dk-1)%width
            local h = math.floor((dk-1)/width)

            --得到affine坐标到笛卡尔坐标的变换
            --local cx, cy = newAffineToCartesian(w, h, width, height, 0, 0)
            local pic = CCSprite:createWithSpriteFrameName(pname)
            self.fenceMap:addChild(pic)
            --local sz = pic:getContentSize()
            local cx, cy = axyToCxyWithDepth(w, h, width, height, 0, 0, self.mask)
            --print("cx cy", cx, cy)
            setScale(setAnchor(setPos(pic, {cx, cy}), {170/512, 0}), 1.1)
        end
    end

    self.newFence = {}
    --self.blockFence = {}
    for dk, dv in ipairs(layerName.newFence.data) do
        if dv ~= 0 then
            local pname = tidToTile(dv, self.normal, self.water, self.gidToTileName)
            local w = (dk-1)%width
            local h = math.floor((dk-1)/width)

            local pic = createSprite(pname)
            self.fenceMap:addChild(pic)
            local cx, cy = axyToCxyWithDepth(w, h, width, height, 0, 0, self.mask)
            --print("cx cy", cx, cy)
            setScale(setAnchor(setPos(pic, {cx, cy}), {170/512, 0}), 1.1)
            table.insert(self.newFence, {pic, w, h})
            
            --[[
            for bk, bv in pairs(self.block) do
                self.blockFence[bk] = {}
                if bv[dk] ~= 0 then
                    local df = table.insert(self.blockFence[bk], pic)
                end
            end
            --]]
        end
    end


    self.slopeData = {}
    for dk, dv in ipairs(layerName.slop2.data) do
        if dv ~= 0 then
            local pname = tidToTile(dv, self.normal, self.water, self.gidToTileName)
            local w = (dk-1)%width
            local h = math.floor((dk-1)/width)

            local dir = 0
            if pname == 'tile18.png' then
                dir = 0
            elseif pname == 'tile16.png' then
                dir = 1
            else
                dir = 2
            end
            --斜坡方向
            local hei = adjustNewHeight(self.mask, self.width, w, h)
            --nil 没有斜坡

            local pic = CCSprite:createWithSpriteFrameName(pname)
            self.slopeData[dk] = {dir, hei*OFF_HEIGHT+OFF_HEIGHT/2, pic=pic}

            self.tileMap:addChild(pic)
            local cx, cy = axyToCxyWithDepth(w, h, width, height, 0, 0, self.mask)
            --print("cx cy", cx, cy)
            setAnchor(setPos(pic, {cx, cy}), {170/512, 0})

            table.insert(self.allSlopeAndWater, {pic, w, h})
        end
    end

    for dk, dv in ipairs(layerName.slope3.data) do
        if dv ~= 0 then
            local pname = self.gidToTileName[dv]..'.png'
            local w = (dk-1)%width
            local h = math.floor((dk-1)/width)
            local pic = CCSprite:createWithSpriteFrameName(pname)
            self.tileMap:addChild(pic)
            local cx, cy, oldy = axyToCxyWithDepth(w, h, width, height, 0, 0, self.mask)
            setAnchor(setPos(pic, {cx, cy}), {170/512, 0})

            table.insert(self.allSlopeAndWater, {pic, w, h})
        end
    end

    --河流图片
    --调整河流的zord 来进行遮挡
    --播放河流的动画
    self.waterData = {}
    for dk, dv in ipairs(layerName.water.data) do
        if dv ~= 0 then
            print("water pid", dv)
            --local pname = tidToTile(dv, self.normal, self.water)
            local pname = self.gidToTileName[dv]..'.png'
            local w = (dk-1)%width
            local h = math.floor((dk-1)/width)
            print("water pname", pname)
            local pic = CCSprite:createWithSpriteFrameName(pname)
            self.waterMap:addChild(pic)
            local hei = adjustNewHeight(self.mask, self.width, w, h)
            local cx, cy, oldy = axyToCxyWithDepth(w, h, width, height, 0, 0, self.mask)
            setAnchor(setPos(pic, {cx, cy}), {170/512, 0})
            table.insert(self.allSlopeAndWater, {pic, w, h})
            self.waterData[dk] = {0, hei*OFF_HEIGHT, pic=pic, pname=pname}
        end
    end

    setGLProgram(self.waterMap, "wave", "waveVert.h", "waveFrag.h")

end

function MiaoPage:ctor(s)
    self.scene = s
    self.bg = CCLayer:create()

    local mj = simple.decode(getFileData("big512.json"))
    self.mapInfo = mj
    local width = mj.width
    local height = mj.height
    self.width = width
    self.height = height
    local maxWH = math.max(self.width, self.height)
    --矩形地图MapPos 对照
    MapWidth = SIZEX*(maxWH*2)
    --3*103
    MapHeight = SIZEY*(self.width+self.height)+FIX_HEIGHT+OFF_HEIGHT*4+50
    --+180 
    --
    self:initView()

    setContentSize(self.bg, {MapWidth, MapHeight})
    setAnchor(self.bg, {0, 0})

    self.touchDelegate = StandardTouchHandler.new()
    self.touchDelegate:setBg(self.bg)
    self.blockMove = false
    

    self.initYet = true
    registerEnterOrExit(self)
    registerMultiTouch(self)
    --缩放背景图到 0.5
    self.touchDelegate:scaleToMax(0.5)
    self:moveToPoint(MapWidth/2, FIX_HEIGHT+200)
end

--斜坡 河流 初始化不可见部分
function MiaoPage:initInvisibleSlope()
    self.invisibleSlope = {}
    local sr = Logic.stageRange[Logic.gameStage]
    print("visible Slope", sr[1], sr[2])
    for k, v in ipairs(self.allSlopeAndWater) do
        local pic, w, h = v[1], v[2], v[3]
        if w < sr[1] or h < sr[2] then
            setVisible(pic, false)
            table.insert(self.invisibleSlope, {pic, w, h})
        end
    end
    self.allSlopeAndWater = nil
end


--开启一片新的 4个新手 村落
--新手村落加入到openMap里面
--移除特定的建筑物
function MiaoPage:restoreBuildAndMap()
    local lastV = Logic.curVillage-1
    --8 10 9
    Logic.openMap[Logic.villageBlock[lastV]] = true
    Logic.openMapDirty = true
    local landId = Logic.villageBlock[lastV]

    local nm = {}
    for k, v in ipairs(self.allMask) do
        if v[2] == landId then
            removeSelf(v[1])
        else
            table.insert(nm, v)
        end
    end
    self.allMask = nm

    local mg = self.buildLayer.mapGridController
    local allB = {mg.allBuildings, mg.allRoad, mg.allEnvTile}
    --print("len allB", #allB[])
    --村落的 blockId
    for bk, bv in ipairs(allB) do
        for k, v in pairs(bv) do
            if k.blockId == landId then
                k:setOperatable(true)
            end
        end
    end

    local ns = {}
    for k, v in ipairs(self.darkSlope) do
        if v[2] == landId then
            setColor(v[1], {255, 255, 255})
        else
            table.insert(ns, v)
        end
    end
    self.darkSlope = ns

    self:removeFence(landId)

    Event:sendMsg(EVENT_TYPE.ROAD_CHANGED)
end

--移除该土地块的篱笆建筑物
function MiaoPage:removeFence(landId)
    local bdata = self.block[landId]
    local nf = {}
    for k, v in ipairs(self.newFence) do
        if bdata[axayToTid(v[2], v[3], self.width)] ~= 0 then
            removeSelf(v[1])
        else
            table.insert(nf, v)
        end
    end
    self.newFence = nf
end


--调整 touch
--调整建筑物 显示
--调整地面显示
--2 3 5 6
--调整道路和建筑物的显示

--初始化扩展土地的信息
function MiaoPage:initGameStage()
    print("initGameStage", Logic.gameStage)
    self.allMask = {}
    local hideBlock = Logic.stage2Block
    for hk, hv in ipairs(hideBlock) do
        if Logic.openMap[hv] then
        else
            for k, v in ipairs(self.block[hv]) do
                if v ~= 0 then
                    local ax, ay = (k-1)%self.width, math.floor((k-1)/self.width)
                    local cx, cy, oldy = axyToCxyWithDepth(ax, ay, self.width, self.height, MapWidth/2, FIX_HEIGHT, self.mask)
                    local m = createSprite("blackArrow.png")
                    addChild(self.buildLayer.buildingLayer, m)
                    --m:setZOrder(MAX_BUILD_ZORD-oldy)
                    setBlackZord(m, oldy)
                    setColor(setSize(setAnchor(setPos(m, {cx, cy}), {0.5, 0}), {SIZEX*2, SIZEY*2}), {0, 0, 0})
                    table.insert(self.allMask, {m, hv})
                end
            end
        end
    end
    

    local mg = self.buildLayer.mapGridController
    local allB = {mg.allBuildings, mg.allRoad, mg.allEnvTile}
    --print("len allB", #allB[])
    for bk, bv in ipairs(allB) do
        for k, v in pairs(bv) do
            local ax, ay = k:getAxAyHeight()
            local tid = axayToTid(ax, ay, self.width) 
            --print("mask Map", ax, ay, tid, self.block[8][tid])
            for hk, hv in ipairs(hideBlock) do
                if Logic.openMap[hv] then
                else
                    if self.block[hv][tid] ~= 0 then
                        k:setOperatable(false, hv)
                    end
                end
            end
        end
    end

    local sr = Logic.stageRange[2]
    for bk, bv in ipairs(allB) do
        for k, v in pairs(bv) do
            local ax, ay = k:getAxAyHeight()
            print("out of stageRange", ax, ay)
            if ax < sr[1] or ay < sr[2] then
                --setVisible(k, false)
                k:setOutOfStage(Logic.gameStage)
                k:setOperatable(false)
            end
        end
    end

    --第二阶段初始化 将所有block 超出第二阶段的 篱笆消除
    for k, v in ipairs(self.newFence) do
        if v[2] < sr[1] or v[3] < sr[2] then
            setVisible(v[1], false)
        end
    end

    self.darkSlope = {}
    for k, v in pairs(self.slopeData) do
        local tid = k
        for hk, hv in ipairs(hideBlock) do
            if Logic.openMap[hv] then
            else
                if self.block[hv][tid] ~= 0 then
                    setColor(v.pic, {128, 128, 128})
                    table.insert(self.darkSlope, {v.pic, hv})
                end
            end
        end
    end

    local wid = self.width-Logic.stageRange[2][1]
    local hei = self.height-Logic.stageRange[2][2]
    --local maxWH = math.max(wid, hei)
    local boundWid = SIZEX*(wid+hei)
    --local boundWid = MapWidth
    local boundLeft = MapWidth/2-wid*SIZEX 
    local boundBottom = 0
    --矩形地图MapPos 对照
    local boundHeight = SIZEY*(wid+hei)+FIX_HEIGHT+OFF_HEIGHT*2+50
    local br = {left=boundLeft, bottom = 0,width=boundWid, height=boundHeight}

    print("bound range", simple.encode(br))
    self.touchDelegate.boundRange = br

    self.allFly = {}
    for k, v in ipairs(Logic.stage2Center) do
        if not Logic.openMap[hideBlock[k]] then
            local cx, cy = axyToCxyWithDepth(v[1], v[2], self.width, self.height, MapWidth/2, FIX_HEIGHT, self.mask)
            --local sp = ui.newButton({image="fly.png", conSize={74, 97}, delegate=self, callback=self.onLand, param=hideBlock[k]})
            --setPos(addChild(self.bg, sp.bg), {cx, cy})
            local sp = self:makeFly(self.onLand, hideBlock[k])
            addChild(self.bg, setPos(sp.bg, {cx, cy}))

            self.allFly[hideBlock[k]] = sp

        end
    end
    --点击使用 土地使用证来交换

    self:initExtendLand()
end


--土地产权证 交换 第二阶段的土地
--参考 restoreBuildAndMap
function MiaoPage:onLand(p)
    local landId = p
    if Logic.landBook <= 0 then
        addBanner("土地产权证书不足")
    else
        if landId == 6 then
            if not Logic.openMap[5] and not Logic.openMap[2] then
                addBanner("请先开发临近的块")
                return
            end
        end

        addBanner("开放土地块"..landId)

        Logic.landBook = Logic.landBook-1
        Logic.openMap[landId] = true
        Logic.openMapDirty = true
        --去掉地面的 遮罩
        local nm = {}
        for k, v in ipairs(self.allMask) do
            if v[2] == landId then
                removeSelf(v[1])
            else
                table.insert(nm, v)
            end
        end
        self.allMask = nm
        
        --建筑物不用 显示在阶段2
        local mg = self.buildLayer.mapGridController
        --local allB = {mg.allBuildings, mg.allRoad, mg.allEnvTile}
        --for k, v in pairs(mg.allBuildings) do
        --end
        
        
        --显示黑色的斜坡 和地面
        local nds = {}
        for k, v in ipairs(self.darkSlope) do
            if v[2] == landId then
                setColor(v[1], {255, 255, 255})
            else
                table.insert(nds, v)
            end
        end
        self.darkSlope = nds
        removeSelf(self.allFly[landId].bg)
        self.allFly[landId]= nil

        self:openNearLand(landId)
        
        --包含有采矿场
        --local landId = Logic.stage2Block[p]
        self:initWoodAndMine(landId, mg)
        self:removeOpenMapFence()

        Event:sendMsg(EVENT_TYPE.ROAD_CHANGED)
        self:showAllFly()
    end
end
function MiaoPage:initWoodAndMine(landId)
    print("initWoodAndMine", landId)
    local mg = self.buildLayer.mapGridController
    --加入到holdNum里面去
    --获得 land上面的建筑物
    local landHasWood = false
    local landHasMine = false
    for k, v in pairs(mg.allBuildings) do
        if k.blockId == landId then
            if k.id == 29 then
                changeBuildNum(k.id, 1)
                landHasWood = true
            elseif k.id == 28 then
                changeBuildNum(k.id, 1)
                landHasMine = true
            end
            k:setOperatable(true)
        end
    end
    print("land has", landHasWood, landHasMine)
    
    --self:showFence(landId)
    
    local hasWood = false
    for bk, bv in ipairs(Logic.ownBuild) do
        if bv == 19 then
            hasWood = true
            break
        end
    end
    if landHasWood and not hasWood then
        --增加若干个木材建筑物
        --addBanner("发现了木材")
        --addBanner("新增加伐木场建筑物")
        addNewBuild(29)
        addNewBuild(19)
    end

    local hasMine = false
    for bk, bv in ipairs(Logic.ownBuild) do
        if bv == 12 then
            hasMine = true
            break
        end
    end
    if landHasMine and not hasMine then
        --addBanner("发现了坑道")
        --addBanner("新增加采矿场建筑物")
        addNewBuild(28)
        addNewBuild(12)
    end
end


--类似于调用onLand 之后显示showLand 的信息
--也会调整道路信息
--
--如果建筑物 本身是dark的 inRange 本身inRange
function MiaoPage:initExtendLand()
    local hideBlock
    local newCenter
    local sr

    if Logic.showLand[13] and not Logic.showLand[11] then
        hideBlock = Logic.extendBlock2
        newCenter = Logic.extendCenter2
        sr = Logic.stageRange[5]
        self.init13Yet = true
    elseif Logic.showLand[11] and not Logic.showLand[13] then
        hideBlock = Logic.extendBlock
        newCenter = Logic.extendCenter
        sr = Logic.stageRange[3]
        self.init11Yet = true
    elseif Logic.showLand[11] and Logic.showLand[13] then
        if self.init13Yet then
            hideBlock = concateTable(Logic.lastBlock, Logic.extendBlock)
            newCenter = concateTable(Logic.lastCenter, Logic.extendCenter)
        elseif self.init11Yet then
            hideBlock = concateTable(Logic.lastBlock, Logic.extendBlock2)
            newCenter = concateTable(Logic.lastCenter, Logic.extendCenter2)
        else
            hideBlock = concateTable(concateTable(Logic.lastBlock, Logic.extendBlock2), Logic.extendBlock)
            newCenter = concateTable(concateTable(Logic.lastCenter, Logic.extendCenter2), Logic.extendCenter)
        end
        sr = Logic.stageRange[4]
    else
        --没有扩充任何 土地 则返回
        hideBlock = {}
        newCenter = {}
        sr = nil
        self:removeOpenMapFence()
        return 
    end
        
        for hk, hv in ipairs(hideBlock) do
            if Logic.openMap[hv] then
            else
                for k, v in ipairs(self.block[hv]) do
                    if v ~= 0 then
                        local ax, ay = (k-1)%self.width, math.floor((k-1)/self.width)
                        local cx, cy, oldy = axyToCxyWithDepth(ax, ay, self.width, self.height, MapWidth/2, FIX_HEIGHT, self.mask)
                        local m = createSprite("blackArrow.png")
                        addChild(self.buildLayer.buildingLayer, m)
                        --m:setZOrder(MAX_BUILD_ZORD-oldy)
                        setBlackZord(m, oldy)
                        setColor(setSize(setAnchor(setPos(m, {cx, cy}), {0.5, 0}), {SIZEX*2, SIZEY*2}), {0, 0, 0})
                        table.insert(self.allMask, {m, hv})
                    end
                end
            end
        end
        --stageRange 建筑物范围

        --在范围内  但是不一定 可以 被操作

        --建筑物 显示在range 中 包括树木 矿洞 和 樱花树
        local mg = self.buildLayer.mapGridController
        local allB = {mg.allBuildings, mg.allRoad, mg.allEnvTile}
        --在范围内
        for bk, bv in ipairs(allB) do
            for k, v in pairs(bv) do
                local ax, ay = k:getAxAyHeight()
                print("out of stageRange", ax, ay)
                if ax < sr[1] or ay < sr[2] then
                    k:setOutOfStage(Logic.gameStage)
                    k:setOperatable(false)
                else
                    k:setInStage()
                end
            end
        end

        self:showFence(sr)
        --[[
        --扩展地图块 将扩展地图块的篱笆显示出来
        for k, v in ipairs(self.newFence) do
            if v[2] < sr[1] or v[3] < sr[2] then
                setVisible(v[1], false)
            else
                setVisible(v[1], true)
            end
        end
        --]]
        
        for bk, bv in ipairs(allB) do
            for k, v in pairs(bv) do
                local ax, ay = k:getAxAyHeight()
                local tid = axayToTid(ax, ay, self.width) 
                --print("mask Map", ax, ay, tid, self.block[8][tid])
                for hk, hv in ipairs(hideBlock) do
                    if Logic.openMap[hv] then
                    else
                        if self.block[hv][tid] ~= 0 then
                            k:setOperatable(false, hv)
                        end
                    end
                end
            end
        end

        for k, v in ipairs(self.newFence) do
            local tid = axayToTid(v[2], v[3], self.width)
            for hk, hv in ipairs(hideBlock) do
                if Logic.openMap[hv] then
                else
                    if self.block[hv][tid] ~= 0 then
                        setVisible(v[1], true)
                    end
                end
            end
        end

        --显示gameStage 相关的visible 信息 stage == 3
        --stage 可能会 分叉根据 开启的 地图不同决定的
        local invS = {}
        --local sr = Logic.stageRange[4]
        for k, v in ipairs(self.invisibleSlope) do
            local pic, w, h = v[1], v[2], v[3]
            if w < sr[1] or h < sr[2] then
                table.insert(invS, v)
            else
                setVisible(pic, true)
            end
        end
        self.invisibleSlope = invS
        
        local wid = self.width-sr[1]
        local hei = self.height-sr[2]
        --local maxWH = math.max(wid, hei)
        local boundWid = SIZEX*(wid+hei)
        --local boundWid = MapWidth
        local boundLeft = MapWidth/2-wid*SIZEX 
        local boundBottom = 0
        --矩形地图MapPos 对照
        local boundHeight = SIZEY*(wid+hei)+FIX_HEIGHT+OFF_HEIGHT*4+50
        local br = {left=boundLeft, bottom = 0,width=boundWid, height=boundHeight}

        print("bound range", simple.encode(br))
        self.touchDelegate.boundRange = br

        --初始化 v 土地块的编号
        for k, v in ipairs(newCenter) do
            if not Logic.openMap[hideBlock[k]] then
                local cx, cy = axyToCxyWithDepth(v[1], v[2], self.width, self.height, MapWidth/2, FIX_HEIGHT, self.mask)
                --local sp = ui.newButton({image="fly.png", conSize={74, 97}, delegate=self, callback=self.onExtendLand2, param=hideBlock[k]})
                local sp = self:makeFly(self.onExtendLand2, hideBlock[k])
                setPos(addChild(self.bg, sp.bg), {cx, cy})
                --对应地图块编号的 fly
                self.allFly[hideBlock[k]] = sp
            end
        end

        --添加新的darkSlope
        --self.darkSlope = {}
        for k, v in pairs(self.slopeData) do
            local tid = k
            for hk, hv in ipairs(hideBlock) do
                if Logic.openMap[hv] then
                else
                    if self.block[hv][tid] ~= 0 then
                        setColor(v.pic, {128, 128, 128})
                        table.insert(self.darkSlope, {v.pic, hv})
                    end
                end
            end
        end
        
        local bp = self.buildLayer.backPoint
        bp:clearState()
        local bax, bay
        bax = self.width-3
        bay = sr[2]
        local cx, cy = newAffineToCartesian(bax, bay, self.width, self.height, MapWidth/2, FIX_HEIGHT)
        bp:setPos({cx, cy})
        bp:resetState()

        --移除第二阶段不用的fence
        self:removeOpenMapFence()
end

function MiaoPage:showFence(sr)
    for k, v in ipairs(self.newFence) do
        if v[2] < sr[1] or v[3] < sr[2] then
            setVisible(v[1], false)
        else
            setVisible(v[1], true)
        end
    end
end
--初始化游戏的将相邻的块也要显示出来
--开启地图块3 5 之后连接的 块也显示

--类似第一阶段 进入 第二阶段 调整地图大小 和 黑色
--gameStage 进入第三阶段
--darkSlope 
function MiaoPage:openNearLand(p)
    print("openNearLand", p)
    local lr = p
    if lr == 2 or lr == 6 then
        if not Logic.showLand[13] then
            Logic.showLand[13] = true
            self:initExtendLand()
        end

    elseif lr == 3 or lr == 5 then
        if not Logic.showLand[11] then
            Logic.showLand[11] = true
            self:initExtendLand()
        end
    end    
end

function MiaoPage:showAllFly()
    for k, v in pairs(self.allFly) do
        if checkShowFly(k) then
            setVisible(v.bg, true)
        end
    end
end

function MiaoPage:onExtendLand2(p)
    local landId = p
    if Logic.landBook <= 0 then
        addBanner("土地产权证书不足")
    else
        if landId == 13 then
            if not Logic.openMap[14] and not Logic.openMap[12] then
                addBanner("请先开发临近的块")
                return
            end
        end
        local sf = checkShowFly(landId)
        if not sf then
            addBanner("请先开发临近的块")
            return
        end
        

        addBanner("开放土地块"..landId)

        Logic.landBook = Logic.landBook-1
        Logic.openMap[landId] = true
        Logic.openMapDirty = true
        --去掉地面的 遮罩
        local nm = {}
        for k, v in ipairs(self.allMask) do
            if v[2] == landId then
                removeSelf(v[1])
            else
                table.insert(nm, v)
            end
        end
        self.allMask = nm

        --建筑物不用 显示在阶段2
        
        --显示黑色的斜坡 和地面
        local nds = {}
        for k, v in ipairs(self.darkSlope) do
            if v[2] == p then
                setColor(v[1], {255, 255, 255})
            else
                table.insert(nds, v)
            end
        end
        self.darkSlope = nds

        --移除地面的通知
        removeSelf(self.allFly[landId].bg)
        self.allFly[landId]= nil
        
        --self:addBuildNum(landId)
        --是否显示邻近陆地呢？
        --self:openNearLand(p)

        self:initWoodAndMine(landId)
        self:removeOpenMapFence()

        Event:sendMsg(EVENT_TYPE.ROAD_CHANGED)
        self:showAllFly()
    end
end

--新开启的地块 增加建筑物数量
function MiaoPage:addBuildNum(landId)
    local mg = self.buildLayer.mapGridController
    for k, v in pairs(mg.allBuildings) do
        if k.blockId == landId then
            if k.id == 29 then
                changeBuildNum(k.id, 1)
            elseif k.id == 28 then
                changeBuildNum(k.id, 1)
            end
        end
    end
end




--从第一阶段 进入 第二阶段
--显示更多的 建筑物 和 地面
function MiaoPage:stageOneToTwo()
    self.allMask = {}
    local hideBlock = Logic.stage2Block
    --显示出来 加上黑色的框
    for hk, hv in ipairs(hideBlock) do
        if Logic.openMap[hv] then
        else
            for k, v in ipairs(self.block[hv]) do
                if v ~= 0 then
                    local ax, ay = (k-1)%self.width, math.floor((k-1)/self.width)
                    local cx, cy, oldy = axyToCxyWithDepth(ax, ay, self.width, self.height, MapWidth/2, FIX_HEIGHT, self.mask)
                    local m = createSprite("blackArrow.png")
                    addChild(self.buildLayer.buildingLayer, m)
                    --m:setZOrder(MAX_BUILD_ZORD-oldy)
                    setBlackZord(m, oldy)
                    setColor(setSize(setAnchor(setPos(m, {cx, cy}), {0.5, 0}), {SIZEX*2, SIZEY*2}), {0, 0, 0})
                    table.insert(self.allMask, {m, hv})
                end
            end
        end
    end

    local mg = self.buildLayer.mapGridController
    local allB = {mg.allBuildings, mg.allRoad, mg.allEnvTile}
    
    local sr = Logic.stageRange[2]
    --在范围内
    for bk, bv in ipairs(allB) do
        for k, v in pairs(bv) do
            local ax, ay = k:getAxAyHeight()
            print("out of stageRange", ax, ay)
            if ax < sr[1] or ay < sr[2] then
                --setVisible(k, false)
                k:setOutOfStage(Logic.gameStage)
                k:setOperatable(false)
            else
                k:setInStage()
                --k:setOperatable(true)
            end
        end
    end

    --第一阶段 进入 第二阶段 将 部分篱笆显示出来
    self:showFence(sr)

    
    --是否可以操作
    --print("len allB", #allB[])
    for bk, bv in ipairs(allB) do
        for k, v in pairs(bv) do
            local ax, ay = k:getAxAyHeight()
            local tid = axayToTid(ax, ay, self.width) 
            --print("mask Map", ax, ay, tid, self.block[8][tid])
            for hk, hv in ipairs(hideBlock) do
                if Logic.openMap[hv] then
                else
                    if self.block[hv][tid] ~= 0 then
                        k:setOperatable(false, hv)
                    end
                end
            end
        end
    end

    local invS = {}
    local sr = Logic.stageRange[Logic.gameStage]
    for k, v in ipairs(self.invisibleSlope) do
        local pic, w, h = v[1], v[2], v[3]
        if w < sr[1] or h < sr[2] then
            table.insert(invS, v)
        else
            setVisible(pic, true)
            --table.insert(self.invisibleSlope, {pic, w, h})
        end
    end
    self.invisibleSlope = invS

    local wid = self.width-Logic.stageRange[2][1]
    local hei = self.height-Logic.stageRange[2][2]
    --local maxWH = math.max(wid, hei)
    local boundWid = SIZEX*(wid+hei)
    --local boundWid = MapWidth
    local boundLeft = MapWidth/2-wid*SIZEX 
    local boundBottom = 0
    --矩形地图MapPos 对照
    local boundHeight = SIZEY*(wid+hei)+FIX_HEIGHT+OFF_HEIGHT*2+50
    local br = {left=boundLeft, bottom = 0,width=boundWid, height=boundHeight}

    print("bound range", simple.encode(br))
    self.touchDelegate.boundRange = br


    --重置 backpoint位置
    local bp = self.buildLayer.backPoint
    bp:clearState()
    local bax, bay
    bax = self.width-3
    bay = Logic.stageRange[Logic.gameStage][2]
    local cx, cy = newAffineToCartesian(bax, bay, self.width, self.height, MapWidth/2, FIX_HEIGHT)
    bp:setPos({cx, cy})
    bp:resetState()

    --显示每块土地的 交换图标
    self.allFly = {}
    for k, v in ipairs(Logic.stage2Center) do
        if not Logic.openMap[hideBlock[k]] then
            local cx, cy = axyToCxyWithDepth(v[1], v[2], self.width, self.height, MapWidth/2, FIX_HEIGHT, self.mask)
            --local sp = ui.newButton({image="fly.png", conSize={74, 97}, delegate=self, callback=self.onLand, param=hideBlock[k]})
            local sp = self:makeFly(self.onLand, hideBlock[k])
            setPos(addChild(self.bg, sp.bg), {cx, cy})
            self.allFly[hideBlock[k]] = sp
        end
    end
end

function setBlackZord(b, z)
    b:setZOrder(MAX_BUILD_ZORD-z)
end

--根据游戏 阶段 和 该阶段开启的地图数量 显示游戏地图大小
function MiaoPage:maskMap()
    --self.maskNode = CCSpriteBatchNode:create("blackArrow.png")
    --addChild(self.bg, self.maskNode)
    if Logic.gameStage == 1 then
        self.allMask = {}
        local hideBlock = Logic.villageBlock
        for hk, hv in ipairs(hideBlock) do
            if hk >= Logic.curVillage then
                for k, v in ipairs(self.block[hv])  do
                    if v ~= 0 then
                        local ax, ay = (k-1)%self.width, math.floor((k-1)/self.width)
                        local cx, cy, oldy = axyToCxyWithDepth(ax, ay, self.width, self.height, MapWidth/2, FIX_HEIGHT, self.mask)
                        local m = createSprite("blackArrow.png")
                        addChild(self.buildLayer.buildingLayer, m)
                        --显示在所有建筑物上面
                        --m:setZOrder(MAX_BUILD_ZORD-oldy)
                        setBlackZord(m, oldy)
                        setColor(setSize(setAnchor(setPos(m, {cx, cy}), {0.5, 0}), {SIZEX*2, SIZEY*2}), {0, 0, 0})
                        table.insert(self.allMask, {m, hv})
                    end
                end
            end
        end

        --一个块的 建筑 建筑物初始化的 时候 可以确定 所在的 块位置
        local mg = self.buildLayer.mapGridController
        local allB = {mg.allBuildings, mg.allRoad, mg.allEnvTile}
        --print("len allB", #allB[])
        for bk, bv in ipairs(allB) do
            for k, v in pairs(bv) do
                local ax, ay = k:getAxAyHeight()
                local tid = axayToTid(ax, ay, self.width) 
                --print("mask Map", ax, ay, tid, self.block[8][tid])
                for hk, hv in ipairs(hideBlock) do
                    if hk >= Logic.curVillage then
                        if self.block[hv][tid] ~= 0 then
                            k:setOperatable(false, hv)
                        end
                    end
                end
            end
        end

        local sr = Logic.stageRange[1]
        for bk, bv in ipairs(allB) do
            for k, v in pairs(bv) do
                local ax, ay = k:getAxAyHeight()
                if ax < sr[1] or ay < sr[2] then
                    --setVisible(k, false)
                    k:setOutOfStage(Logic.gameStage)
                    k:setOperatable(false)
                end
            end
        end

        --第一阶段 将超出范围的篱笆隐藏起来
        print("set newFence out of stage")
        self:showFence(sr)

        self.darkSlope = {}
        for k, v in pairs(self.slopeData) do
            local tid = k
            for hk, hv in ipairs(hideBlock) do
                if hk >= Logic.curVillage then
                    if self.block[hv][tid] ~= 0 then
                        setColor(v.pic, {128, 128, 128})
                        table.insert(self.darkSlope, {v.pic, hv})
                    end
                end
            end
        end
        
        local wid = self.width-Logic.stageRange[1][1]
        local hei = self.height-Logic.stageRange[1][2]
        --local maxWH = math.max(wid, hei)
        local boundWid = SIZEX*(wid+hei)
        --local boundWid = MapWidth
        local boundLeft = MapWidth/2-wid*SIZEX 
        local boundBottom = 0
        --矩形地图MapPos 对照
        local boundHeight = SIZEY*(wid+hei)+FIX_HEIGHT+OFF_HEIGHT*2+50
        local br = {left=boundLeft, bottom = 0,width=boundWid, height=boundHeight}

        print("bound range", simple.encode(br))
        self.touchDelegate.boundRange = br

        --新手阶段 完成直接显示 旗帜
        if Logic.newStage >= 18 then
            if Logic.curVillage < 4 then
                local cc = Logic.villageCenter[Logic.curVillage]
                local cx, cy = axyToCxyWithDepth(cc[1], cc[2], self.width, self.height, MapWidth/2, FIX_HEIGHT, self.mask)
                local sp = ui.newButton({image="fly.png", conSize={74, 97}, delegate=self, callback=self.onBut, param=1})
                setPos(addChild(self.bg, sp.bg), {cx, cy})
                local ani = createAnimation("flyNew", "fnew%d.png", 0, 3, 1, 1, true)
                self.fly = sp
                self.fly.sp:runAction(repeatForever(CCAnimate:create(ani)))

                local homeLabel = ui.newButton({image="info.png", conSize={130, 50}, text="可以攻略", color={0, 0, 0}, size=25, callback=self.onBut, param=1})
                self.fly.bg:addChild(homeLabel.bg)
                setPos(homeLabel.bg, {0, -60})
                homeLabel.bg:runAction(repeatForever(jumpBy(1, 0, 0, 10, 1)))

            end
        end

        --删除对应的新手村的 fence 对象
        self:removeOpenMapFence()

    elseif Logic.gameStage == 2 then
        --block 2 3 5 6
        self:initGameStage()
        --self:removeOpenMapFence()
    end
end
function MiaoPage:makeFly(f, p)
    --local temp = CCNode:create()

    local sp = ui.newButton({image="fnew0.png", conSize={128, 128}, delegate=self, callback=f, param=p})
    --setPos(addChild(temp, sp.bg), {cx, cy})
    --addChild(temp, sp.bg)

    local ani = createAnimation("flyNew", "fnew%d.png", 0, 3, 1, 0.3, true)
    sp.sp:runAction(repeatForever(CCAnimate:create(ani)))
    --sp.sp:runAction(sequence({fadeout(0), delaytime(0.8), fadein(0.25), jumpBy(0.5, 0, 0, 20, 1)}))
    --self:moveToPoint(cx, cy)

    local homeLabel = ui.newButton({image="info.png", conSize={130, 50}, text="可以开发", color={0, 0, 0}, size=25, delegate=self, callback=f, param=p})
    sp.bg:addChild(homeLabel.bg)
    setPos(homeLabel.bg, {0, -60})
    homeLabel.bg:runAction(repeatForever(jumpBy(1, 0, 0, 10, 1)))
    --homeLabel.bg:runAction(sequence({disappear(homeLabel.bg), delaytime(0.8), appear(homeLabel.bg), jumpBy(0.5, 0, 20, 25, 1)}))
    --return temp

    --对于
    local sf = checkShowFly(p)
    if not sf then
        setVisible(sp.bg, false)
    end
    return sp
end


function MiaoPage:showFly()
    if self.fly == nil then
        if Logic.curVillage < 4 then
            print("showFly")
            local cc = Logic.villageCenter[Logic.curVillage]
            local cx, cy = axyToCxyWithDepth(cc[1], cc[2], self.width, self.height, MapWidth/2, FIX_HEIGHT, self.mask)

            local sp = ui.newButton({image="fnew0.png", conSize={128, 128}, delegate=self, callback=self.onBut, param=1})
            setPos(addChild(self.bg, sp.bg), {cx, cy})
            self.fly = sp
            local ani = createAnimation("flyNew", "fnew%d.png", 0, 3, 1, 0.3, true)
            self.fly.sp:runAction(repeatForever(CCAnimate:create(ani)))

            self.fly.sp:runAction(sequence({fadeout(0), delaytime(0.8), fadein(0.25), jumpBy(0.5, 0, 0, 20, 1)}))
            self:moveToPoint(cx, cy)


            local homeLabel = ui.newButton({image="info.png", conSize={130, 50}, text="可以攻略", color={0, 0, 0}, size=25, callback=self.onBut, param=1})
            self.fly.bg:addChild(homeLabel.bg)
            setPos(homeLabel.bg, {0, -60})
            homeLabel.bg:runAction(repeatForever(jumpBy(1, 0, 0, 10, 1)))
            homeLabel.bg:runAction(sequence({disappear(homeLabel.bg), delaytime(0.8), appear(homeLabel.bg), jumpBy(0.5, 0, 20, 25, 1)}))
        end
    end
end


function MiaoPage:removeOpenMapFence()
    --删除第二阶段里面 和 第一阶段里面的所有篱笆
    for hk, hv in pairs(self.block) do
        if Logic.openMap[hk] then
            print("remove OpenMap fence", hk)
            self:removeFence(hk)
        end
    end
end


function MiaoPage:adjustFly()
    local c = Logic.villageCenter[Logic.curVillage]
    local cx, cy = axyToCxyWithDepth(c[1], c[2], self.width, self.height, MapWidth/2, FIX_HEIGHT, self.mask)
    setPos(self.fly.bg, {cx, cy})
end

function MiaoPage:onBut(p)
    local function attackNow()
    end
    global.director:pushView(ConfigMenu.new(nil), 1, 0)
    --global.director:pushView(SessionMenu.new("是否攻入该地区？",  attackNow, nil, true), 1, 0)
end

function MiaoPage:touchesCanceled(touches)
    self.touchDelegate:tCanceled(touches)
end

function MiaoPage:setPoint(x, y)
    local wp = self.bg:convertToWorldSpace(ccp(x, y))
    local sz = getVS()
    local dx = sz[1]/2-wp.x
    local dy = sz[2]/2-wp.y
    local curPos = getPos(self.bg)
    setPos(self.bg, {curPos[1]+dx, curPos[2]+dy})
end
function MiaoPage:touchesCanceled(touches)
    self.touchDelegate:tCanceled(touches)
end

function MiaoPage:enterScene()
    Event:registerEvent(EVENT_TYPE.DO_MOVE, self)
    Event:registerEvent(EVENT_TYPE.FINISH_MOVE, self)
    registerUpdate(self)
end
function MiaoPage:update(diff)

    self.touchDelegate:update(diff)
    self:updateSea(diff)
end
function MiaoPage:updateSea(diff)
    if true then
        return
    end
    local s = diff*50
    local p1 = getPos(self.seas[1])
    local p2 = getPos(self.seas[2])
    if p1[1]+s >= MapWidth then
        p1[1] = -MapWidth
    end
    
    --print("MapWidth", MapWidth, p2[1])
    if p2[1]+s >= MapWidth then
        p2[1] = -MapWidth
    end

    setPos(self.seas[1], {p1[1]+s, p1[2]})
    setPos(self.seas[2], {p2[1]+s, p2[2]})
end
function MiaoPage:exitScene()
    Event:unregisterEvent(EVENT_TYPE.DO_MOVE, self)
    Event:unregisterEvent(EVENT_TYPE.FINISH_MOVE, self)
end

function MiaoPage:initDataOver()
end
function MiaoPage:receiveMsg(name, msg)
    if name == EVENT_TYPE.DO_MOVE then
        self.blockMove = true
    elseif name == EVENT_TYPE.FINISH_MOVE then
        self.blockMove = false
    end
end

function MiaoPage:showGrid(nx, ny, allV)
    local box = createSprite("whitebox.png")
    self.debug:addChild(box)
    setSize(setAnchor(setPos(box, {nx*SIZEX, ny*SIZEY}), {0, 0}), {SIZEX, SIZEY})
    
    for k, v in ipairs(allV) do
        local cx, cy = axyToCxyWithDepth(v[1], v[2], self.width, self.height, MapWidth/2, FIX_HEIGHT, self.mask)
        local arr = createSprite("whiteArrow.png")
        self.debug:addChild(arr)
        setColor(setSize(setAnchor(setPos(arr, {cx, cy}), {0.5, 0}), {SIZEX*2, SIZEY*2}), {10, 20, 128})
    end
end

--移动move 
--点击某个建筑物 进入移动状态 
--原地还有这个建筑物 不过 新的 替换成了这个建筑物 的 图像 可以移动 桥梁 普通建筑物   道路不能移动
function MiaoPage:touchesBegan(touches)
    if self.inMove then
        return
    end
    --self.touchBuild = nil
    --self.lastPos = convertMultiToArr(touches)
    self.touchDelegate:tBegan(touches)
    --只有一个手指的时候建筑物会可能响应touch事件 多个手指之后 取消建筑物响应
    if self.touchDelegate.touchValue.count == 1 and self.touchDelegate.touchValue[0] ~= nil then
        local tp = self.buildLayer.bg:convertToNodeSpace(ccp(self.touchDelegate.touchValue[0][1], self.touchDelegate.touchValue[0][2]))
        --tp.y = tp.y-SIZEY
        local ax, ay, height = cxyToAxyWithDepth(tp.x, tp.y, self.width, self.height, MapWidth/2, FIX_HEIGHT, self.mask, self.cxyToAxyMap)
        print("touchesBegan", ax, ay, height)
        --没在裂缝里面
        if ax ~= nil and ay ~= nil then
            --实际对应的建筑物块 向下偏移103个像素
            --偏移计算建筑物的位置
            --tp.y = tp.y-103*height-SIZEY
            --转化成菱形标准基点的 笛卡尔坐标
            local cx, cy = newAffineToCartesian(ax, ay, self.width, self.height, MapWidth/2, FIX_HEIGHT)

            --将 ax ay 坐标转化成 可以用到地图上的 MapGridController的坐标 直接根据touch 坐标转化map坐标?
            local allCell = self.buildLayer.mapGridController.mapDict
            local map = getPosMap(1, 1, cx, cy)
            local key = getMapKey(map[3], map[4])
            local scon
            if DEBUG then
                print("allCell state", map[3], map[4], allCell[key])
                scon = map[3].." "..map[4]..' '..str(allCell[key])
                global.director.curScene.menu.stateLabel:setString(scon)
            end
            --点击到某个建筑物
            if allCell[key] ~= nil then
                --如果在移动状态 点击某个建筑物 那么 选中的是 Move 的建筑物
                --移动地图 和 单纯的点击 地图
                local cb = allCell[key][#allCell[key]][1]
                --建筑为没有被禁止
                if DEBUG then
                    scon = scon..str(cb.static)
                    global.director.curScene.menu.stateLabel:setString(scon)
                end

                if (cb.picName == 'build' or cb.picName == 't') and not cb.static and cb.operate then
                    self.touchBuild = allCell[key][#allCell[key]][1]
                    self.touchBuild:touchesBegan(touches)
                end
                --end
            end
        end
    else
        if self.touchBuild ~= nil then
            self.touchBuild:touchesEnded(touches)
            self.touchBuild = nil
        end
    end

    --if not self.blockMove then
    --end
end
function MiaoPage:touchesMoved(touches)
    if self.inMove then
        return
    end

    print("MiaoPage toucesMoved", self.touchBuild)
    if self.touchBuild then
        self.touchBuild:touchesMoved(touches)
    end
    if not self.blockMove then
        self.touchDelegate:tMoved(touches)
    end
end
function MiaoPage:moveToPoint(x, y)
    self.inMove = true   

    local wp = self.bg:convertToWorldSpace(ccp(x, y))
    local vs = getVS()
    local dx, dy = vs.width/2-wp.x, vs.height/2-wp.y
    local cp = getPos(self.bg)
    cp[1] = cp[1]+dx
    cp[2] = cp[2]+dy

    local sz = self.bg:getContentSize()
    local mx = math.min(0, cp[1])
    local my = math.min(0, cp[2])
    local sca = self.bg:getScale()
    mx = math.max(mx, vs.width-sz.width*sca)
    my = math.max(my, vs.height-sz.height*sca)
    local function finishMov()
        self.moveAct = nil
        self.inMove = false
    end
    if self.moveAct ~= nil then
        self.bg:stopAction(self.moveAct)
        self.moveAct = nil
    end

    self.touchDelegate.targetMove = {mx, my}
    self.bg:runAction(sequence({delaytime(0.2), callfunc(nil, finishMov)}))
    
    --[[
    self.moveAct = sequence({moveto(0.2, mx, my), callfunc(nil, finishMov)})
    self.bg:runAction(self.moveAct)
    --]]
end
function MiaoPage:touchesEnded(touches)
    --不处理 但是有可能存在bug
    if self.inMove then
        return
    end

    self.touchDelegate:tEnded(touches)

    --处理完 blockMove 之后 再清理 blockMove
    if self.touchBuild then
        self.touchBuild:touchesEnded(touches)
        self.touchBuild = nil
    else
        print("touchDelegate accMove", self.touchDelegate.accMove)
        if self.touchDelegate.accMove < 20 then
            --关闭移动菜单
            if #global.director.stack > 0 then
                global.director:popView()
            end
        end
    end
end

--开始建造建筑物
function MiaoPage:beginBuild(kind, id, px, py)
    print("MiaoPage beginBuild!!!!", kind, id, px, py)
    if self.curBuild == nil then
        local vs = getVS()
        --先确定位置 再加入到 buildLayer里面
        self.curBuild = MiaoBuild.new(self.buildLayer, {picName=kind, id=id, bid=getBid()}) 
        local p
        if px == nil or py == nil then
            p = self.bg:convertToNodeSpace(ccp(vs.width/2, vs.height/2))
        else
            p = {x=px, y=py}
        end
        --p = normalizePos({p.x, p.y}, 1, 1)

        --取消左下右下的边
        local ax, ay = newCartesianToAffine(p.x, p.y, self.width, self.height, MapWidth/2, FIX_HEIGHT)
        ax = math.max(math.min(ax, self.width-1-1), 0)
        ay = math.max(math.min(ay, self.height-1-1), 0)
        local cx, cy = newAffineToCartesian(ax, ay, self.width, self.height, MapWidth/2, FIX_HEIGHT)
        p = {cx, cy}

        self.curBuild:setPos(p)
        self.curBuild:setColPos()
        self.curBuild:setState(BUILD_STATE.MOVE)
        self.buildLayer:fastAddBuilding(self.curBuild, MAX_BUILD_ZORD)
        --调整自动道路图片
        self.curBuild.funcBuild:whenColNow()
        
        --调整建筑物高度
        self.curBuild:setPos(p)
        --调整bottom 冲突状态

        --初始化道路状态 因为如果建筑物已经加入到building 里面了那么就不能再检测到冲突了
        self.curBuild:beginBuild()
        self.curBuild.funcBuild:runBeginBuild()
        
        --Logic.paused = true
        setLogicPause(true)
        global.director.curScene.menu:beginBuild()
    end
    return self.curBuild
end
function MiaoPage:addPeople(param)
    self.buildLayer:addPeople(param)
end
function MiaoPage:showNewPeople()
end

function MiaoPage:onLight()
    global.director:pushView(RegionDialog.new(), 1, 0)
end
function MiaoPage:enableRegion()
    self:moveToPoint(1216, 448)
    
    local w = Welcome2.new(self.showNewPeople, self)
    w:updateWord("领地<0000ff一滤波地区>可以进行攻略了!")
    global.director:pushView(w, 1, 0)

    local sp = ui.newButton({image="lightTower.png", callback=self.onLight, delegate=self})
    sp:setAnchor(0.5, 0)
    setPos(sp.bg, {1216, 448})
    self.bg:addChild(sp.bg)
    self.attackTarget = sp
end
function MiaoPage:regionOpen()
    self:moveToPoint(1216, 448)
     
    removeSelf(self.smallMask[1])
    removeSelf(self.attackTarget.bg)
    self.smallMask[1] = nil
    self.attackTarget = nil
end
function MiaoPage:cancelBuild()
    if self.curBuild ~= nil then
        self.curBuild:removeSelf()
        self.curBuild = nil
        --Logic.paused = false
        setLogicPause(false)
        global.director.curScene.menu:finishBuild()
    end
end

--完成建筑物建造
function MiaoPage:finishBuild()
    if self.curBuild ~= nil then
        self.buildLayer:adjustLayer(self.curBuild)
        local c = Logic.buildings[self.curBuild.id].silver
        local needCount = self.curBuild.data.countNum
        local oid = self.curBuild.id
        doCost(c)
        local bdata = self.curBuild.data
        --if self.curBuild.picName == 't' then
        table.insert(self.oldBuildPos, getPos(self.curBuild.bg))
        if #self.oldBuildPos >= 3 then
            table.remove(self.oldBuildPos, 1)
        end
        --end
        local oldBuild = self.curBuild
        print("finishBuild", self.curBuild.picName, self.curBuild.id)
        --桥梁建河流上
        self.curBuild:finishBuild()
        self.curBuild:showFinishLabel()
        --table.insert(Logic.newBuild, self.curBuild)
        self.curBuild = nil
        --end

        --根据当前的位置 调整一个新位置
        --oldBuild.picName == 't' and
        local nextOk = true
        if needCount == 1 and getAvaBuildNum(oid) <= 0 then
            nextOk = false
        end
        print("needCount", needCount, getAvaBuildNum(oid))

        if Logic.resource.silver >= c and nextOk then
            if #self.oldBuildPos == 1 then
                self:beginBuild('build', bdata.id, self.oldBuildPos[1][1]+SIZEX, self.oldBuildPos[1][2]+SIZEY)
            else
                local dx = self.oldBuildPos[2][1]-self.oldBuildPos[1][1]
                local dy = self.oldBuildPos[2][2]-self.oldBuildPos[1][2]
                local sx = Sign(dx)*SIZEX
                local sy = Sign(dy)*SIZEY
                self:beginBuild('build', bdata.id, self.oldBuildPos[2][1]+sx, self.oldBuildPos[2][2]+sy)
            end
        else
            --Logic.paused = false
            setLogicPause(false)
            global.director.curScene.menu:finishBuild()
        end
        Logic.gotoHouse = true
    end
end

function MiaoPage:setBuilding(b)
    print("setBuilding", self.curBuild, b)
    if b == self.curBuild then
        return 1
    end
    return 0
end
