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
    
    self.buildLayer = MiaoBuildLayer.new(self)
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
    self.touchBuild = nil
    self.lastPos = convertMultiToArr(touches)
    if self.lastPos.count == 1 then
        local tp = self.buildLayer.bg:convertToNodeSpace(ccp(self.lastPos[0][1], self.lastPos[0][2]-SIZEY))
        local allCell = self.buildLayer.mapGridController.mapDict
        local map = getPosMap(1, 1, tp.x, tp.y)
        local key = getMapKey(map[3], map[4])
        --点击到某个建筑物
        if allCell[key] ~= nil then
            self.touchBuild = allCell[key][#allCell[key]][1]
            self.touchBuild:touchesBegan(touches)
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
function MiaoPage:touchesEnded(touches)
    if self.touchBuild then
        self.touchBuild:touchesEnded(touches)
    end
    if not self.blockMove then
        self.touchDelegate:tEnded(touches)
    end
end
function MiaoPage:beginBuild(kind, id)
    if self.curBuild == nil then
        local vs = getVS()
        --先确定位置 再加入到 buildLayer里面
        self.curBuild = MiaoBuild.new(self.buildLayer, {picName=kind, id=id}) 
        local p = self.bg:convertToNodeSpace(ccp(vs.width/2, vs.height/2))
        p = normalizePos({p.x, p.y}, 1, 1)
        self.curBuild:setPos(p)
        self.curBuild:setColPos()
        self.curBuild:setState(BUILD_STATE.MOVE)
        self.buildLayer:addBuilding(self.curBuild, MAX_BUILD_ZORD)
        --调整bottom 冲突状态
        self.curBuild:setColPos()
    end
    return self.curBuild
end
function MiaoPage:addPeople(param)
    self.buildLayer:addPeople(param)
end

function MiaoPage:finishBuild()
    print("finishBuild", self.curBuild.picName, self.curBuild.id)
    if self.curBuild ~= nil then
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
        elseif self.curBuild.picName == 'remove' then
            self.curBuild:removeSelf()
            self.curBuild = nil
        elseif self.curBuild.colNow == 0  then
            self.curBuild:finishBuild()
            self.curBuild = nil
        else
            addBanner("和其它建筑物冲突啦！")
        end
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
    end
end
