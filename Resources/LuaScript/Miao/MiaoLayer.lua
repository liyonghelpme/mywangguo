require "Miao.BigBuildLayer"
MiaoLayer = class()
function MiaoLayer:ctor(s)
    self.scene = s
    self.bg = CCLayer:create()
    setContentSize(self.bg, {BIG_MAPWIDTH, BIG_MAPHEIGHT})


    self.backpg = CCSpriteBatchNode:create("sea.png")
    self.bg:addChild(self.backpg)
    local col = math.ceil(BIG_MAPWIDTH/64)
    local row = math.ceil(BIG_MAPHEIGHT/32)+1
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

    self.tileMap = CCTMXTiledMap:create("bigmap.tmx")
    self.bg:addChild(self.tileMap)
    setPos(self.tileMap, {-1612, 963})


    self.touchDelegate = StandardTouchHandler.new()
    self.touchDelegate.bg = self.bg

    --setPos(self.bg, {-2800, 0})
    setPos(self.bg, {-2800, -1000})

    self.buildLayer = BigBuildLayer.new(self)
    self.bg:addChild(self.buildLayer.bg)
    
    registerEnterOrExit(self)
    registerMultiTouch(self)
    
    self.touchDelegate:scaleToMax(0.5)

    self.moveBack = false
    --[[
    local but = ui.newButton({image="blueButton.png", callback=self.onMb, delegate=self})
    self.scene.bg:addChild(but.bg, 1)
    setPos(but.bg, {100, 100})

    local sp = ui.newBMFontLabel({text="0,0", font="bound.fnt", size=15})
    self.scene.bg:addChild(sp, 2)
    setPos(sp, {700, 400})
    self.posw = sp
    --]]
end
function MiaoLayer:onMb()
    self.moveBack = not self.moveBack
end
function MiaoLayer:enterScene()
    registerUpdate(self)
end
function MiaoLayer:update(diff)
    
end
function MiaoLayer:touchesBegan(touches)
    self.touchBuild = nil
    self.lastPos = convertMultiToArr(touches)
    if self.lastPos.count == 1 then
        local tp = self.buildLayer.bg:convertToNodeSpace(ccp(self.lastPos[0][1], self.lastPos[0][2]))
        tp.y = tp.y-SIZEY
        local allCell = self.buildLayer.mapGridController.mapDict
        local map = getPosMapFloat(1, 1, tp.x, tp.y)
        local key = getMapKey(map[3], map[4])
        --点击到某个建筑物
        if allCell[key] ~= nil then
            self.touchBuild = allCell[key][#allCell[key]][1]
            self.touchBuild:touchesBegan(touches)
        end
    end

    if not self.moveBack then
        self.touchDelegate:tBegan(touches)
    else
        self.lastPos = convertMultiToArr(touches)
    end
end

function MiaoLayer:touchesMoved(touches)
    if self.touchBuild ~= nil then
        self.touchBuild:touchesMoved(touches)
    end

    if not self.moveBack then
        self.touchDelegate:tMoved(touches)
    else
        local oldPos = self.lastPos
        self.lastPos = convertMultiToArr(touches)

        local difx = self.lastPos[0][1]-oldPos[0][1]
        local dify = self.lastPos[0][2]-oldPos[0][2]
        local p = getPos(self.tileMap)
        p[1] = p[1]+difx
        p[2] = p[2]+dify
        setPos(self.tileMap, p)
        self.posw:setString(math.floor(p[1])..","..math.floor(p[2]))
    end
end

function MiaoLayer:touchesEnded(touches)
    if self.touchBuild ~= nil then
        self.touchBuild:touchesEnded(touches)
    end
    if not self.moveBack then
        self.touchDelegate:tEnded(touches)
    end
end
 

