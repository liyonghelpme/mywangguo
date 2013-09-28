require "views.FuncBuild"
require "views.Farm"
require "views.BuildAnimate"

Building = class()
function Building:ctor(m, d, privateData)
    self.data = d
    self.bid = -1
    self.map = m
    self.id = self.data["id"]
    self.sx = self.data["sx"]
    self.sy = self.data["sy"]
    self.kind = d["kind"]
    self.funcs = d["funcs"]

    self.bg = CCLayer:create()
    
    if privateData == nil then
        privateData = {}
        self.buildColor = global.user:getLastColor()
    else
        self.buildColor = privateData['color']
    end
    self.objectList = privateData['objectList']
    self.buildLevel = privateData['level']

    if self.funcs == FARM_BUILD then
        self.funcBuild = Farm.new(self)
    end
    --papaya不同之处
    --anchorPoint 就是 坐标 0 0 时候的点 因此 changeDirNode 坐标就是0 0 
    self.changeDirNode = setAnchor(addSprite(self.bg, "images/build"..self.id..".png"), {0.5, 0})
    if self.data['hasFeature'] and self.buildColor ~= 0 then
        
    end
    local offY = 0
    if self.data['isoView'] then
        offY = (self.sx+self.sy)*SIZEY/2
    end


    local sz = self.changeDirNode:getContentSize()

    setPos(setAnchor(setContentSize(self.bg, {sz.width, sz.height}), {0.5, 0}), {ZoneCenter[self.kind+1][1], fixY(MapHeight, ZoneCenter[self.kind+1][2])})

    setPos(self.changeDirNode, {0, 0})
    self.dir = getDefault(privateData, 'dir', 0)
    self:setState(getDefault(privateData, 'state', getParam('buildMove')))
    self:setDir(self.dir)


    local pos = getPos(self.bg)
    local nPos = normalizePos(pos, self.sx, self.sy)
    self:setPos(nPos)
    self:setColPos()

    self.funcBuild:initWorking(privateData)
    if self.data['hasAni'] ~= 0 then
        self.aniNode = BuildAnimate.new(self)
        self.changeDirNode:addChild(self.aniNode.bg)
    end


    registerEnterOrExit(self)
    registerMultiTouch(self)
end
function Building:setMap(m)
    self.map = m
end
function Building:setColPos()
    self.colNow = 0;
    local other = self.map:checkCollision(self)
    if other ~= nil then
        self.colNow = 1
        self:setColor(0)
    else
        self:setColor(1);
    end
end
function Building:setColor(inZ)
    if self.bottom == nil then
        return
    end
    print('bottom setColor', inZ)
    if inZ == 0 then
        setTexture(self.bottom, "images/red2.png")
    else
        setTexture(self.bottom, "images/green2.png")
    end
end

function Building:setDir(d)
    self.dir = d
    if dir == 0 then
        self.changeDirNode:setFlipX(true)
    else
        self.changeDirNode:setFlipX(false)
    end
end
function Building:receiveMsg(name, msg)
end
function Building:enterScene()
    if self.funcs == CAMP and self.state == getParam("buildFree") then
        Event:unregisterEvent(EVENT_TYPE.CALL_SOL, self)
        Event:registerEvent(EVENT_TYPE.CALL_SOL, self)

        Event:unregisterEvent(EVENT_TYPE.MOVE_TO_CAMP, self)
        Event:registerEvent(EVENT_TYPE.MOVE_TO_CAMP, self)
    end

    if self.funcs == FARM_BUILD and self.state == getParam("buildFree") then
        Event:unregisterEvent(EVENT_TYPE.MOVE_TO_FARM, self)
        Event:registerEvent(EVENT_TYPE.MOVE_TO_FARM, self)
    end
end
function Building:exitScene()
    Event:unregisterEvent(EVENT_TYPE.CALL_SOL, self)
    Event:unregisterEvent(EVENT_TYPE.MOVE_TO_CAMP, self)
    Event:unregisterEvent(EVENT_TYPE.MOVE_TO_FARM, self)
end
function Building:onSwitch()
    if self.data['changeDir'] == 0 then
        return
    end
    self.dirty = 1
    self.dir = 1-self.dir
    self:setDir(self.dir)

    global.user:updateBuilding(self)
end

--建筑物一旦触摸成功则swallow 掉场景的touch
--某个手指在建筑物内
--只有一个手指 则移动建筑 并且拒绝移动地图
--touch的Point 从0开始计数
function Building:touchesBegan(touches)
    self.lastPos = convertMultiToArr(touches)
    self.doMove = false
    self.accMove = 0
    if self.lastPos.count == 1 then
        local px, py = self.bg:getPosition()
        local tp = self.bg:getParent():convertToNodeSpace(ccp(self.lastPos[0][1], self.lastPos[0][2]))
        if checkPointIn(tp.x, tp.y,  px, py, self.sx, self.sy) then
            if self.Planing == 1 then
                local setSuc = global.director.curScene:setBuilding(self)
                if setSuc then
                    if self.bottom == nil then
                        self:setState(self.bottom)
                    end
                end
            end
            if self.state == getParam('buildMove') or self.Planing == 1 then
                self.dirty = 1
                self.map.mapGridController:clearMap(self)

                self.doMove = true
                Event:sendMsg(EVENT_TYPE.DO_MOVE, self)        
            end

        end
    end
end
function Building:setState(s)
    print('Building setState', s, getParam('buildMove'))
    self.state = s;
    if self.funcs == CAMP then
        Event:unregisterEvent(EVENT_TYPE.CALL_SOL, self)
        if self.state == getParam("buildFree") then
            Event:registerEvent(EVENT_TYPE.CALL_SOL, self)
        end
    end
    if self.state == getParam("buildMove") or self.Planing == 1 then
        local bSize = self.bg:getContentSize()
        if self.bottom == nil then
            self.bottom = setSize(setAnchor(setPos(CCSprite:create("images/green2.png"), {0, (self.sx+self.sy)/2*SIZEY}), {0.5, 0.5}), {(self.sx+self.sy)*SIZEX+20, (self.sx+self.sy)*SIZEY+10})
            self.bg:addChild(self.bottom, -1)
        end
    end
end

function Building:touchesMoved(touches)
    if self.doMove then
        local oldPos = self.lastPos
        self.lastPos = convertMultiToArr(touches)
        local difx = self.lastPos[0][1]-oldPos[0][1]
        local dify = self.lastPos[0][2]-oldPos[0][2]
        
        local offY = (self.sx+self.sy)*SIZEY/2
        local parPos = self.bg:getParent():convertToNodeSpace(ccp(self.lastPos[0][1], self.lastPos[0][2]-offY))
        local newPos = normalizePos({parPos.x, parPos.y}, self.sx, self.sy)
        self:setPos(newPos)
    end
end

function Building:touchesEnded(touches)
    if self.doMove then
        self.map.mapGridController:updateMap(self)
        Event:sendMsg(EVENT_TYPE.FINISH_MOVE, self)
    end
end

--调整zord
function Building:setPos(p)
    print("buildingPos", p[1], p[2])

    local curPos = p
    local zord = MAX_BUILD_ZORD-curPos[2]
    self.bg:setPosition(ccp(curPos[1], curPos[2]))
    local parent = self.bg:getParent()
    if parent == nil then
        return
    end
    self.bg:retain()
    self.bg:removeFromParentAndCleanup(true)
    parent:addChild(self.bg, zord)


    --[[
    if self.tempNode ~= nil then
        self.tempNode:removeFromParentAndCleanup(true)
    end
    self.tempNode = ui.newTTFLabel({text=""..curPos[1].." "..curPos[2]})
    self.bg:addChild()
    --]]
end
function Building:keepPos()
    self.oldPos = getPos(self.bg)
    self.dirty = 0
    self.Planing = 1
end
function Building:restorePos()
    self.map.mapGridController:clearMap(self)
    self:setPos(self.oldPos)
    self.map.mapGridController:updateMap(self)
    self:finishPlan()
end
function Building:finishPlan()
    self.dirty = 0
    self.Planing = 0
    if bottom ~= nil then
        self:finishBottom()
        --self:setZord()
    end
end

function Building:setBid(b)
    self.bid = b
end

function Building:finishBuild()
    self:setState(getParam("buildFree"))
    self:finishBottom()
    self:setZord()
    global.user:updateBuilding(self)
end
function Building:setZord()
    local zOrd = MAX_BUILD_ZORD-getPos(self.bg)[2]
    local par = self.bg:getParent()
    if par ~= nil then
        self.bg:retain()
        removeSelf(self.bg)
        par:addChild(self.bg, zOrd)
        self.bg:release()
    end
end
function Building:finishBottom()
    self.bottom:removeFromParentAndCleanup(true)
    self.bottom = nil
end
function Building:cancelBuild()
end

function Building:getPos()
    return getPos(self.bg)
end

function Building:getObjectId()
    return self.funcBuild:getObjectId()
end

function Building:getStartTime()
    return self.funcBuild:getStartTime()
end
