require "Miao.MiaoBuild"
require "Miao.MiaoBuildLayer"
require "Miao.RegionDialog"
MiaoPage = class()
function MiaoPage:ctor(s)
    self.scene = s
    self.bg = CCLayer:create()
    setContentSize(self.bg, {MapWidth, MapHeight})

    self.oldBuildPos = {}

    self.backpg = CCSpriteBatchNode:create("sea.png")
    self.bg:addChild(self.backpg)
    local col = math.ceil(MapWidth/64)
    local row = math.ceil(MapHeight/32)+1
    for i=0, row-1, 1 do
        local initx = 0
        if i%2 == 1 then
            initx = 64 
        end
        for j=0, col-1, 1 do
            local s = CCSprite:create("sea.png")
            self.backpg:addChild(s)
            setPos(s, {j*64+initx, i*32})
        end
    end

    --[[
    self.tileMap = CCTMXTiledMap:create("nolayer.tmx")
    self.bg:addChild(self.tileMap)
    self:initTiles()
    setPos(self.tileMap, {200, -100+FIX_HEIGHT})
    --]]
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("myTile2.plist")
    self.tileMap = CCSpriteBatchNode:create("myTile2.png")
    self.bg:addChild(self.tileMap)

    local mj = simple.decode(getFileData("newMap.json"))
    self.mapInfo = mj
    local width = mj.width
    local height = mj.height
    self.width = width
    self.height = height
    local tilesets = mj.tilesets
    local tileName = {}
    for k, v in ipairs(tilesets) do
        tileName[v.firstgid] = v.image 
    end
    self.tileName = tileName

    local layers = mj.layers
    local layerName = {}
    for k, v in ipairs(layers) do
        layerName[v.name] = v
    end
    self.layerName = layerName

    for dk, dv in ipairs(layerName['slop1'].data) do
        if dv ~= 0 then
            local pname = tileName[dv]
            local w = (dk-1)%width
            local h = math.floor((dk-1)/width)

            --得到affine坐标到笛卡尔坐标的变换
            local cx, cy = newAffineToCartesian(w, h, width, height, 0, 0)
            local pic = CCSprite:createWithSpriteFrameName(pname)
            self.tileMap:addChild(pic)
            setAnchor(setPos(pic, {cx, cy}), {0.5, 0})
        end
    end
    setPos(self.tileMap, {MapWidth/2, FIX_HEIGHT})

    for dk, dv in ipairs(layerName['slop2'].data) do
        if dv ~= 0 then
            local pname = tileName[dv]
            local w = (dk-1)%width
            local h = math.floor((dk-1)/width)

            --得到affine坐标到笛卡尔坐标的变换
            local cx, cy = newAffineToCartesian(w, h, width, height, 0, 0)
            local pic = CCSprite:createWithSpriteFrameName(pname)
            self.tileMap:addChild(pic)
            setAnchor(setPos(pic, {cx, cy}), {0.5, 0})
        end
    end

    for dk, dv in ipairs(layerName['ladder'].data) do
        if dv ~= 0 then
            local pname = tileName[dv]
            local w = (dk-1)%width
            local h = math.floor((dk-1)/width)

            --得到affine坐标到笛卡尔坐标的变换
            local cx, cy = newAffineToCartesian(w, h, width, height, 0, 0)
            local pic = CCSprite:createWithSpriteFrameName(pname)
            self.tileMap:addChild(pic)
            local sz = pic:getContentSize()
            setAnchor(setPos(pic, {cx, cy}), {(64-20)/sz.width, 20/sz.height})
        end
    end

    for dk, dv in ipairs(layerName['sea'].data) do
        if dv ~= 0 then
            local pname = tileName[dv]
            local w = (dk-1)%width
            local h = math.floor((dk-1)/width)

            --得到affine坐标到笛卡尔坐标的变换
            local cx, cy = newAffineToCartesian(w, h, width, height, 0, 0)
            local pic = CCSprite:createWithSpriteFrameName(pname)
            self.tileMap:addChild(pic)
            local sz = pic:getContentSize()
            setAnchor(setPos(pic, {cx, cy}), {0.5, 0})
        end
    end

    for dk, dv in ipairs(layerName['fence'].data) do
        if dv ~= 0 then
            local pname = tileName[dv]
            local w = (dk-1)%width
            local h = math.floor((dk-1)/width)

            --得到affine坐标到笛卡尔坐标的变换
            local cx, cy = newAffineToCartesian(w, h, width, height, 0, 0)
            local pic = CCSprite:createWithSpriteFrameName(pname)
            self.tileMap:addChild(pic)
            local sz = pic:getContentSize()
            setAnchor(setPos(pic, {cx, cy}), {0.5, 0})
        end
    end


    self.touchDelegate = StandardTouchHandler.new()
    self.touchDelegate.bg = self.bg
    self.blockMove = false
    
    self.buildLayer = MiaoBuildLayer.new(self)
    self.bg:addChild(self.buildLayer.bg)

    registerEnterOrExit(self)
    registerMultiTouch(self)
    self.touchDelegate:scaleToMax(1)
end
function MiaoPage:setPoint(x, y)
    local wp = self.bg:convertToWorldSpace(ccp(x, y))
    local sz = getVS()
    local dx = sz[1]/2-wp.x
    local dy = sz[2]/2-wp.y
    local curPos = getPos(self.bg)
    setPos(self.bg, {curPos[1]+dx, curPos[2]+dy})
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

--移动move 
--点击某个建筑物 进入移动状态 
--原地还有这个建筑物 不过 新的 替换成了这个建筑物 的 图像 可以移动 桥梁 普通建筑物   道路不能移动
function MiaoPage:touchesBegan(touches)
    self.touchBuild = nil
    self.lastPos = convertMultiToArr(touches)
    if self.lastPos.count == 1 then
        local tp = self.buildLayer.bg:convertToNodeSpace(ccp(self.lastPos[0][1], self.lastPos[0][2]))
        tp.y = tp.y-SIZEY
        local allCell = self.buildLayer.mapGridController.mapDict
        local map = getPosMap(1, 1, tp.x, tp.y)
        local key = getMapKey(map[3], map[4])
        --点击到某个建筑物
        if allCell[key] ~= nil then
            --如果在移动状态 点击某个建筑物 那么 选中的是 Move 的建筑物
            --移动地图 和 单纯的点击 地图
            --if self.curBuild ~= nil and self.curBuild.picName == 'move' then
            --    self.touchBuild = self.curBuild
            --    self.touchBuild:touchesBegan(touches)
            --else
            self.touchBuild = allCell[key][#allCell[key]][1]
            self.touchBuild:touchesBegan(touches)
            --end
        end
    end

    if not self.blockMove then
        self.touchDelegate:tBegan(touches)
    end
end
function MiaoPage:touchesMoved(touches)
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
    if not self.blockMove then
        --快速点击 curBuild 移动到 这个点击位置  屏幕移动到中心位置 
        if self.touchDelegate.accMove == nil then

        elseif self.touchDelegate.accMove < 20 then
            --点击移动建筑物 
            if self.curBuild ~= nil and self.curBuild.picName == 'move' then
                self.lastPos = convertMultiToArr(touches)
                --场景没有被缩放的情况下 使用 SIZEY 偏移世界坐标
                --场景缩放了之后 不能使用SIZEY 偏移世界坐标
                local tp = self.buildLayer.bg:convertToNodeSpace(ccp(self.lastPos[0][1], self.lastPos[0][2]))
                tp.y = tp.y-SIZEY
                local np = normalizePos({tp.x, tp.y}, 1, 1)
                self.curBuild:runMoveAction(np[1], np[2])
                self:moveToPoint(np[1], np[2]+SIZEY)
            end
        else
            if self.curBuild ~= nil and self.curBuild.picName == 'move' then
                local vs = getVS()
                local p = self.bg:convertToNodeSpace(ccp(vs.width/2, vs.height/2))
                p = normalizePos({p.x, p.y-SIZEY}, 1, 1)
                self.curBuild:runMoveAction(p[1], p[2])
            end
        end

        self.touchDelegate:tEnded(touches)
    end
    --处理完 blockMove 之后 再清理 blockMove
    if self.touchBuild then
        self.touchBuild:touchesEnded(touches)
    end
end
function MiaoPage:beginBuild(kind, id, px, py)
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
        
        p = normalizePos({p.x, p.y}, 1, 1)
        self.curBuild:setPos(p)
        self.curBuild:setColPos()
        self.curBuild:setState(BUILD_STATE.MOVE)
        self.buildLayer:addBuilding(self.curBuild, MAX_BUILD_ZORD)
        --调整bottom 冲突状态
        self.curBuild:setColPos()
        self.curBuild.changeDirNode:runAction(repeatForever(sequence({fadeout(0.5), fadein(0.5)})))
        
        Logic.paused = true
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
        Logic.paused = false
        global.director.curScene.menu:finishBuild()
    end
end
function MiaoPage:finishBuild()
    if self.curBuild ~= nil then
        if self.curBuild.picName == 't' then
            table.insert(self.oldBuildPos, getPos(self.curBuild.bg))
            if #self.oldBuildPos >= 3 then
                table.remove(self.oldBuildPos, 1)
            end
        end
        local oldBuild = self.curBuild
        print("finishBuild", self.curBuild.picName, self.curBuild.id)
        if self.curBuild.picName == 'move' then
            if self.curBuild.moveTarget == nil then
                self.curBuild:removeSelf()
                self.curBuild = nil
            --取消移动
            else
                self.curBuild:removeSelf()
                self.curBuild = nil
            end
        --道路和 斜坡冲突 斜坡不能移动
        elseif self.curBuild.picName == 't' then
            if self.curBuild.colNow == 0 then
                self.curBuild:finishBuild()
                self.curBuild = nil
            else
                if type(self.curBuild.otherBuild) == 'table' then
                    local ob = self.curBuild.otherBuild
                    --斜坡
                    if ob.picName == 'build' and ob.data.kind == 1 then
                        self.curBuild:finishBuild()
                        self.curBuild = nil
                    else
                        addBanner("道路不能修建在这里！")
                    end
                end
            end
        --矿坑
        elseif self.curBuild.picName == 'build' and self.curBuild.id == 11 then
            if self.curBuild.colNow == 0 then
                addBanner("必须建造到斜坡上面！")
            else
                local ret = false
                if type(self.curBuild.otherBuild) == 'table' then
                    local ob = self.curBuild.otherBuild
                    if ob.picName == 'build' and ob.data.kind == 1 then
                        ret = true
                        self.curBuild:finishBuild()
                        self.curBuild = nil
                    end
                end
                if not ret then
                    addBanner("必须建造到斜坡上面！")
                end
            end
        elseif self.curBuild.picName == 'build' and self.curBuild.id == 3 then
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
        elseif self.curBuild.picName == 'remove' then
            self.curBuild:removeSelf()
            self.curBuild = nil
        elseif self.curBuild.colNow == 0  then
            self.curBuild:finishBuild()
            self.curBuild = nil
        else
            addBanner("和其它建筑物冲突啦！")
        end
        --根据当前的位置 调整一个新位置
        if oldBuild.picName == 't' then
            if #self.oldBuildPos == 1 then
                self:beginBuild('build', 15, self.oldBuildPos[1][1]+SIZEX, self.oldBuildPos[1][2]+SIZEY)
            else
                local dx = self.oldBuildPos[2][1]-self.oldBuildPos[1][1]
                local dy = self.oldBuildPos[2][2]-self.oldBuildPos[1][2]
                local sx = Sign(dx)*SIZEX
                local sy = Sign(dy)*SIZEY
                self:beginBuild('build', 15, self.oldBuildPos[2][1]+sx, self.oldBuildPos[2][2]+sy)
            end
        else
            Logic.paused = false
            global.director.curScene.menu:finishBuild()
        end
        Logic.gotoHouse = true
    end
end

function MiaoPage:onRemove()
    if self.curBuild == nil then
        local vs = getVS()
        --先确定位置 再加入到 buildLayer里面
        self.curBuild = MiaoBuild.new(self.buildLayer, {picName='remove'}) 
        local p = self.bg:convertToNodeSpace(ccp(vs.width/2, vs.height/2))
        p = normalizePos({p.x, p.y}, 1, 1)
        self.curBuild:setPos(p)
        self.curBuild:setState(BUILD_STATE.MOVE)
        self.buildLayer:addBuilding(self.curBuild, MAX_BUILD_ZORD)
        Logic.paused = true
    end
end
--拖动某个建筑物 还是  
--选择某个建筑物 拖动 确定  取消 移动 setCurBuild = '??' 作为最上层一旦和这个建筑物 合体 就一起了 
--点击某个位置 这个建筑物 就被选中了 
function MiaoPage:onMove()
    if self.curBuild == nil then
        local vs = getVS()
        self.curBuild = MiaoBuild.new(self.buildLayer, {picName='move'})
        local p = self.bg:convertToNodeSpace(ccp(vs.width/2, vs.height/2))
        p = normalizePos({p.x, p.y}, 1, 1)
        self.curBuild:setPos(p)
        self.curBuild:setState(BUILD_STATE.MOVE)
        self.buildLayer:addBuilding(self.curBuild, MAX_BUILD_ZORD)
        Logic.paused = true
    end
end

function MiaoPage:setBuilding(b)
    print("setBuilding", self.curBuild, b)
    if b == self.curBuild then
        return 1
    end
    return 0
end
