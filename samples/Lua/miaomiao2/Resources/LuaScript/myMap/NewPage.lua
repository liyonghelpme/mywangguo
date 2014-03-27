require "myMap.NewUtil"
NewPage = class()
function NewPage:ctor()
    self.bg = CCLayer:create()
    setContentSize(self.bg, {MapWidth, MapHeight})

    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("myTile3.plist")
    self.backpg = CCSpriteBatchNode:create("sea.png")
    self.bg:addChild(self.backpg)

    self.tileMap = CCSpriteBatchNode:create("myTile3.png")
    self.bg:addChild(self.tileMap)
    
    local mj = simple.decode(getFileData("newTile.json"))
    local width = mj.width
    local height = mj.height
    local tilesets = mj.tilesets
    local tileName = {}
    for k, v in ipairs(tilesets) do
        tileName[v.firstgid] = v.image 
    end
    
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

    local layers = mj.layers
    local layerName = {}
    for k, v in ipairs(layers) do
        layerName[v.name] = v
    end
    for dk, dv in ipairs(layerName.grass.data) do
        if dv ~= 0 then
            local pname = tileName[dv]
            local w = (dk-1)%width
            local h = math.floor((dk-1)/width)

            --得到affine坐标到笛卡尔坐标的变换
            local cx, cy = newAffineToCartesian(w, h, width, height, 0, 0)
            local pic = CCSprite:createWithSpriteFrameName(pname)
            self.tileMap:addChild(pic)
            setAnchor(setPos(pic, {cx, cy}), {0.5, 0})
            pic:setScale(1.05)
            if w%2 ~= h%2 then
                pic:setFlipX(true)
                pic:setFlipY(true)
            end
        end
    end

    for dk, dv in ipairs(layerName.slop1.data) do
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

    for dk, dv in ipairs(layerName.slop2.data) do
        if dv ~= 0 then
            local pname = tileName[dv]
            local w = (dk-1)%width
            local h = math.floor((dk-1)/width)

            --得到affine坐标到笛卡尔坐标的变换
            local cx, cy = newAffineToCartesian(w, h, width, height, 0, 0)
            local pic = CCSprite:createWithSpriteFrameName(pname)
            self.tileMap:addChild(pic)
            local sz = pic:getContentSize()
            setAnchor(setPos(pic, {cx, cy}), {170/sz.width, (170)/sz.height})
        end
    end

    for dk, dv in ipairs(layerName.ladder.data) do
        if dv ~= 0 then
            local pname = tileName[dv]
            local w = (dk-1)%width
            local h = math.floor((dk-1)/width)

            --得到affine坐标到笛卡尔坐标的变换
            local cx, cy = newAffineToCartesian(w, h, width, height, 0, 0)
            local pic = CCSprite:createWithSpriteFrameName(pname)
            self.tileMap:addChild(pic)
            local sz = pic:getContentSize()
            setAnchor(setPos(pic, {cx, cy}), {170/sz.width, (170)/sz.height})
        end
    end
    local mask2 = {}
    for dk, dv in ipairs(layerName.mask2.data) do
        if dv ~= 0 then
            mask2[dk] = true
        end
    end

    for dk, dv in ipairs(layerName.road.data) do
        if dv ~= 0 then
            local pname = tileName[dv]
            local w = (dk-1)%width
            local h = math.floor((dk-1)/width)

            --得到affine坐标到笛卡尔坐标的变换
            local cx, cy = newAffineToCartesian(w, h, width, height, 0, 0)
            local pic = CCSprite:createWithSpriteFrameName(pname)
            self.tileMap:addChild(pic)
            local sz = pic:getContentSize()
            print("init road !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!", dk)
            if mask2[dk] then
                print("maks2", dk)
                --cx = cx+162
                --cy = cy+15
                cx = cx+84
                cy = cy+90
            end
            setAnchor(setPos(pic, {cx, cy}), {170/sz.width, (sz.height-170)/sz.height})
        end
    end

    --[[
    for dk, dv in ipairs(layers[1].data) do
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
    --]]
    setPos(self.tileMap, {MapWidth/2, FIX_HEIGHT})

    self.touchDelegate = StandardTouchHandler.new()
    self.touchDelegate.bg = self.bg

    registerEnterOrExit(self)
    registerMultiTouch(self)
end
function NewPage:touchesBegan(touches)
    self.touchDelegate:tBegan(touches)
end

function NewPage:touchesMoved(touches)
    self.touchDelegate:tMoved(touches)
end

function NewPage:touchesEnded(touches)
    self.touchDelegate:tEnded(touches)
end
