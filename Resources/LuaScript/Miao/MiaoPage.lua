require "Miao.MiaoBuild"
require "Miao.MiaoBuildLayer"
MiaoPage = class()
function MiaoPage:ctor(s)
    self.scene = s
    self.bg = CCLayer:create()
    setContentSize(self.bg, {1000, 1000})
    local col = math.ceil(1000/256)
    local row = math.ceil(1000/192)
    local offX = 256
    local offY = 192
    local bat = CCSpriteBatchNode:create("grasstile.png")
    self.bat = bat
    self.bg:addChild(bat)
    for i = 0, row-1, 1 do
        for j =0, col-1, 1 do
            local temp = CCSprite:create("grasstile.png")
            self.bat:addChild(temp)
            setAnchor(setPos(temp, {j*offX, i*offY}), {0, 0})
        end
    end

    self.touchDelegate = StandardTouchHandler.new()
    self.touchDelegate.bg = self.bg
    self.blockMove = false
    
    self.buildLayer = MiaoBuildLayer.new()
    self.bg:addChild(self.buildLayer.bg)

    registerEnterOrExit(self)
    registerMultiTouch(self)
end

function MiaoPage:enterScene()
    Event:registerEvent(EVENT_TYPE.DO_MOVE, self)
    Event:registerEvent(EVENT_TYPE.FINISH_MOVE, self)
end
function MiaoPage:exitScene()
    Event:unregisterEvent(EVENT_TYPE.DO_MOVE, self)
    Event:unregisterEvent(EVENT_TYPE.FINISH_MOVE, self)
end

function MiaoPage:receiveMsg(name, msg)
    if name == EVENT_TYPE.DO_MOVE then
        self.blockMove = true
    elseif name == EVENT_TYPE.FINISH_MOVE then
        self.blockMove = false
    end
end

function MiaoPage:touchesBegan(touches)
    if not self.blockMove then
        self.touchDelegate:tBegan(touches)
    end
end
function MiaoPage:touchesMoved(touches)
    if not self.blockMove then
        self.touchDelegate:tMoved(touches)
    end
end
function MiaoPage:touchesEnded(touches)
    if not self.blockMove then
        self.touchDelegate:tEnded(touches)
    end
end
function MiaoPage:beginBuild()
    if self.curBuild == nil then
        local vs = getVS()
        --先确定位置 再加入到 buildLayer里面
        self.curBuild = MiaoBuild.new(self.buildLayer) 
        local p = self.bg:convertToNodeSpace(ccp(vs.width/2, vs.height/2))
        self.curBuild:setPos({p.x, p.y})
        self.curBuild:setColPos()

        self.buildLayer:addBuilding(self.curBuild, MAX_BUILD_ZORD)
    end
    return self.curBuild
end
function MiaoPage:finishBuild()
    print("finishBuild")
    self.curBuild:finishBuild()
    self.curBuild = nil 
end
