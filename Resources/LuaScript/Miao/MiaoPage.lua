require "Miao.MiaoBuild"
require "Miao.MiaoBuildLayer"
require "Miao.RegionDialog"
require "myMap.NewUtil"
MiaoPage = class()
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
    MapHeight = SIZEY*(self.width+self.height)+FIX_HEIGHT+OFF_HEIGHT*2+20 

    setContentSize(self.bg, {MapWidth, MapHeight})
    setAnchor(self.bg, {0, 0})

    self.oldBuildPos = {}

    local col = math.ceil(MapWidth/64)
    local row = math.ceil(MapHeight/32)+1
    local tex = CCTextureCache:sharedTextureCache():addImage("water.jpg")
    
    local param = ccTexParams()
    param.minFilter = GL_LINEAR
    param.magFilter = GL_LINEAR
    param.wrapS = GL_REPEAT
    param.wrapT = GL_REPEAT
    tex:setTexParameters(param)

    local sea2 = CCSprite:createWithTexture(tex, CCRectMake(0, 0, MapWidth+2, MapHeight))
    local sea = CCSprite:createWithTexture(tex, CCRectMake(0, 0, MapWidth+2, MapHeight))
    self.bg:addChild(sea)
    setAnchor(setPos(sea, {0, 0}), {0, 0})
    self.bg:addChild(sea2)
    setAnchor(setPos(sea2, {MapWidth, 0}), {0, 0})
    self.seas = {sea, sea2}


    local sf = CCSpriteFrameCache:sharedSpriteFrameCache()
    sf:addSpriteFramesWithFile("grassOne.plist")
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("t512.plist")
    self.tileMap = CCSpriteBatchNode:create("t512.png")
    self.bg:addChild(self.tileMap)
    setPos(self.tileMap, {MapWidth/2, FIX_HEIGHT})

    self.grassMap = CCSpriteBatchNode:create("grassOne.png")
    self.bg:addChild(self.grassMap)
    setPos(self.grassMap, {MapWidth/2, FIX_HEIGHT})

    local mj = simple.decode(getFileData("big512.json"))
    self.mapInfo = mj
    local width = mj.width
    local height = mj.height
    self.width = width
    self.height = height

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

    --[[
    --affine 坐标计算mask2
    local mask2 = layerName.mask2.data
    local mask3 = layerName.mask3.data
    for i=1, #mask2, 1 do
        if mask2[i] ~= 0 then
            self.mask[i] = 1
        elseif mask3[i] ~= 0 then
            self.mask[i] = 2
        else
            self.mask[i] = 0
        end
    end
    --]]

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
            --[[
            print("left right", cx, cy, left, right, bottom, top)
            local c = {255, 0, 0}
            local wid = (right-left)*SIZEX
            local hei = (top-bottom)*SIZEY
            for i=left,right-1,1 do
                for j=bottom,top-1,1 do
                    local sp = setSize(setColor(CCSprite:createWithSpriteFrameName("whitebox.png"), c), {SIZEX, SIZEY})
                    debug:addChild(sp)
                    setAnchor(setPos(sp, {i*SIZEX, j*SIZEY}), {0, 0})
                end
            end

            local sp = setSize(setColor(CCSprite:createWithSpriteFrameName("whiteArrow.png"), c), {SIZEX*2, SIZEY*2})
            debug:addChild(sp)
            local cx, cy = newAffineToCartesian(w, h, self.width, self.height, MapWidth/2, FIX_HEIGHT)
            setAnchor(setPos(sp, {cx, cy}), {0.5, 0})
            --]]

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
        end
    end

    for dk, dv in ipairs(layerName.slop1.data) do
        if dv ~= 0 then
            local pname = tidToTile(dv, self.normal, self.water)
            local w = (dk-1)%width
            local h = math.floor((dk-1)/width)

            --得到affine坐标到笛卡尔坐标的变换
            local cx, cy = newAffineToCartesian(w, h, width, height, 0, 0)
            local pic = CCSprite:createWithSpriteFrameName(pname)
            self.tileMap:addChild(pic)
            setScale(setAnchor(setPos(pic, {cx, cy}), {170/512, 0}), 1.05)
        end
    end
    for dk, dv in ipairs(layerName.sea.data) do
        if dv ~= 0 then
            local pname = tidToTile(dv, self.normal, self.water)
            local w = (dk-1)%width
            local h = math.floor((dk-1)/width)

            --得到affine坐标到笛卡尔坐标的变换
            --local cx, cy = newAffineToCartesian(w, h, width, height, 0, 0)
            local pic = CCSprite:createWithSpriteFrameName(pname)
            self.tileMap:addChild(pic)
            --local sz = pic:getContentSize()
            local cx, cy = axyToCxyWithDepth(w, h, width, height, 0, 0, self.mask)
            --print("cx cy", cx, cy)
            setScale(setAnchor(setPos(pic, {cx, cy}), {170/512, 0}), 1.1)
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
            self.slopeData[dk] = {dir, hei*OFF_HEIGHT+OFF_HEIGHT/2}
            --nil 没有斜坡

            local pic = CCSprite:createWithSpriteFrameName(pname)
            self.tileMap:addChild(pic)
            local cx, cy = axyToCxyWithDepth(w, h, width, height, 0, 0, self.mask)
            --print("cx cy", cx, cy)
            setAnchor(setPos(pic, {cx, cy}), {170/512, 0})
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
        end
    end

    --河流图片
    --调整河流的zord 来进行遮挡
    for dk, dv in ipairs(layerName.water.data) do
        if dv ~= 0 then
            print("water pid", dv)
            --local pname = tidToTile(dv, self.normal, self.water)
            local pname = self.gidToTileName[dv]..'.png'
            local w = (dk-1)%width
            local h = math.floor((dk-1)/width)
            print("water pname", pname)
            local pic = CCSprite:createWithSpriteFrameName(pname)
            self.tileMap:addChild(pic)
            local cx, cy, oldy = axyToCxyWithDepth(w, h, width, height, 0, 0, self.mask)
            setAnchor(setPos(pic, {cx, cy}), {170/512, 0})
        end
    end


    self.touchDelegate = StandardTouchHandler.new()
    self.touchDelegate:setBg(self.bg)
    self.blockMove = false
    
    self.buildLayer = MiaoBuildLayer.new(self)
    self.bg:addChild(self.buildLayer.bg)

    registerEnterOrExit(self)
    registerMultiTouch(self)
    self.touchDelegate:scaleToMax(0.5)
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
--初始化地图遮罩部分 不用了 新的直接CCBatchNodeSprite 来绘制遮罩
function MiaoPage:initTiles()
    self.allIsland = {}
    self.allMask = {}
    for k=1, 8, 1 do
        local nlayer = self.tileMap:layerNamed("dirt"..k)
        nlayer:setupTiles()
        self.allIsland[k] = nlayer
        if k > 1 then
            local mask = self.tileMap:layerNamed("mask"..k)
            --setBatchColor(nlayer, {128, 128, 128})
            mask:setupTiles()
            self.allMask[k] = mask
        end
    end
    self.smallMask = {}
    for k=1, 3, 1 do
        local sm = self.tileMap:layerNamed("mask1_"..k)
        sm:setupTiles()
        self.smallMask[k] = sm
    end
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
            print("allCell state", map[3], map[4], allCell[key])
            --点击到某个建筑物
            if allCell[key] ~= nil then
                --如果在移动状态 点击某个建筑物 那么 选中的是 Move 的建筑物
                --移动地图 和 单纯的点击 地图
                local cb = allCell[key][#allCell[key]][1]
                if (cb.picName == 'build' or cb.picName == 't') and not cb.static then
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
    print("MiaoPage toucesMoved", self.touchBuild)
    if self.touchBuild then
        self.touchBuild:touchesMoved(touches)
    end
    if not self.blockMove then
        self.touchDelegate:tMoved(touches)
    end
end
function MiaoPage:moveToPoint(x, y)
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
    end
    if self.moveAct ~= nil then
        self.bg:stopAction(self.moveAct)
        self.moveAct = nil
    end
    self.moveAct = sequence({moveto(0.2, mx, my), callfunc(nil, finishMov)})
    self.bg:runAction(self.moveAct)
end
function MiaoPage:touchesEnded(touches)
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
        self.curBuild.changeDirNode:runAction(repeatForever(sequence({fadeout(0.5), fadein(0.5)})))
        
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
        if self.curBuild.picName == 'build' and self.curBuild.id == 3 then
            --桥梁没有冲突
            if self.curBuild.colNow == 0 then
                self.curBuild:finishBuild()
                self.curBuild = nil
            else
                if type(self.curBuild.otherBuild) == 'table' then
                    --地形河流
                    if self.curBuild.otherBuild.picName == 's' then
                        self.curBuild:finishBuild()
                        self.curBuild = nil
                    else
                        addBanner("和其它建筑物冲突啦！")
                    end
                end
            end
        else
            self.curBuild:finishBuild()
            self.curBuild = nil
        end

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
