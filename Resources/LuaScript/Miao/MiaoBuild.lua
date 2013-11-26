require "Miao.FuncBuild"
require "Miao.Tree"
require "Miao.Bridge"
require "Miao.House"
require "Miao.Farm"
require "Miao.Road"
require "Miao.Factory"
require "Miao.Slope"

MiaoBuild = class()
BUILD_STATE = {
    FREE = 0,
    MOVE = 1,
}
function MiaoBuild:ctor(m, data)
    self.map = m
    self.sx = 1
    self.sy = 1
    self.bid = data.bid
    self.colNow = 0
    --道路的状态
    self.value = 0
    self.setYet = data.setYet
    if data.picName == 'build' and data.id == 15 then
        data.picName = 't'
        --data.id = nil
    end
    self.picName = data.picName
    self.id = data.id
    self.owner = nil
    self.workNum = 0
    self.lastColBuild = nil
    self.dir = 0
    self.deleted = false
    self.moveTarget = nil
    self.rate = 0
    self.data = Logic.buildings[self.id]
    self.belong = {}


    self.food = 0
    self.wood = 0
    self.stone = 0
    --id --> num
    self.product = {}


    self.bg = CCLayer:create()
    if self.picName == 'build' then
        --建造桥梁 4个方向旋转 还是两个方向旋转
        if self.id == 3 then
            self.changeDirNode = setAnchor(CCSprite:create(self.picName..self.id..".png"), {0.5, 0.5})
            self.funcBuild = Bridge.new(self)
            self.funcBuild:initView()
        --樱花树
        elseif self.id == 4 then
            self.funcBuild = Tree.new(self)
            self.changeDirNode = setAnchor(CCSprite:create(self.picName..self.id..".png"), {0.5, 0})
            self.funcBuild:initView()
        --民居 农田
        elseif self.id == 1 then
            self.changeDirNode = setAnchor(CCSprite:create(self.picName..self.id..".png"), {0.5, 0})
            self.funcBuild = House.new(self) 
            self.funcBuild:initView()
        elseif self.id == 2 then
            self.changeDirNode = setAnchor(CCSprite:create(self.picName..self.id..".png"), {0.5, 0})
            self.funcBuild = Farm.new(self) 
            self.funcBuild:initView()
        elseif self.id == 5 then
            self.changeDirNode = setAnchor(CCSprite:create(self.picName..self.id..".png"), {0.5, 0})
            self.funcBuild = Factory.new(self)
            self.funcBuild:initView()
        elseif self.id == 6 then
            self.changeDirNode = setAnchor(CCSprite:create(self.picName..self.id..".png"), {0.5, 0})
            self.funcBuild = Store.new(self)
            self.funcBuild:initView()
        elseif self.id == 7 or self.id == 8 or self.id == 9 or self.id == 10 then
            self.changeDirNode = setAnchor(CCSprite:create("slope"..(self.id-6)..".png"), {0.5, 0})
            self.funcBuild = Slope.new(self)
            self.funcBuild:initView()
        elseif self.id == 5 then
            self.changeDirNode = setAnchor(CCSprite:create(self.picName..self.id..".png"), {0.5, 0})
            self.funcBuild = Factory.new(self)
            self.funcBuild:initView()
        else
            self.changeDirNode = setAnchor(CCSprite:create(self.picName..self.id..".png"), {0.5, 0})
            self.funcBuild = FuncBuild.new(self)
            self.funcBuild:initView()
        end
    elseif self.picName == 'move' then
        self.changeDirNode = setPos(setRotation(CCSprite:create("move.png"), 45), {0, SIZEY})
        self.funcBuild = MoveBuild.new(self) 
    elseif self.picName == 'backPoint' then
        self.changeDirNode = setColor(setSize(setAnchor(CCSprite:create("white2.png"), {0.5, 0}), {SIZEX*2, SIZEY*2}), {255, 255, 0})
        self.funcBuild = FuncBuild.new(self) 
    elseif self.picName == 'remove' then
        self.changeDirNode = setPos(setRotation(CCSprite:create("hammer.png"), 45), {0, SIZEY})
        self.funcBuild = RemoveBuild.new(self) 
    --道路 或者 河流
    elseif self.picName == 't' then
        self.changeDirNode = setAnchor(CCSprite:create(self.picName.."0.png"), {0.5, 0})
        self.funcBuild = Road.new(self)
    end

    self.bg:addChild(self.changeDirNode)
    setContentSize(setAnchor(self.bg, {0.5, 0}), {self.sx*SIZEX*2, self.sy*SIZEY*2})

    self.nameLabel = ui.newBMFontLabel({text="", size=21})
    setPos(self.nameLabel, {0, 100})
    self.bg:addChild(self.nameLabel)

    self.posLabel = ui.newBMFontLabel({text="", size=15})
    setPos(self.posLabel, {0, 50})
    self.bg:addChild(self.posLabel)

    self.stateLabel = ui.newBMFontLabel({text="", size=15})
    setPos(self.stateLabel, {0, 70})
    self.bg:addChild(self.stateLabel)

    self.inRangeLabel = ui.newBMFontLabel({text="", size=15, color={102, 0, 0}})
    setPos(self.inRangeLabel, {0, 120})
    self.bg:addChild(self.inRangeLabel)
    
    self.possibleLabel = ui.newBMFontLabel({text="", size=15, color={0, 102, 0}})
    setPos(self.possibleLabel, {0, 130})
    self.bg:addChild(self.possibleLabel)

    self.funcBuild:initWork()
    --看一下 CCNode 0 0 位置 和 一半位置
    --
    --local temp = setSize(addSprite(self.bg, "green2.png"), {10, 10})
    self:setState(BUILD_STATE.FREE)

    registerEnterOrExit(self)
    --page 首先处理 建筑物的touch 再处理自身的touch事件
end
function MiaoBuild:touchesBegan(touches)
    self.lastPos = convertMultiToArr(touches)
    self.doMove = false
    self.inSelf = false

    print("build touch began")
    if self.lastPos.count == 1 then
        --建筑物 getBuildMap 0.5 0 位置
        --手指是 0.5 0 位置 转化成0.5 0.5 位置
        --local px, py = self.bg:getPosition()
        --手指坐标 向下移动SIZEY 用于在getBuildMap 里面计算手指所在的网格坐标
        --local tp = self.bg:getParent():convertToNodeSpace(ccp(self.lastPos[0][1], self.lastPos[0][2]-SIZEY))
        --local ret = checkPointIn(tp.x, tp.y,  px, py, self.sx, self.sy)
        local ret = true
        --print("checkPointIn", ret)
        if ret then
            self.inSelf = true
            local setSuc = 0
            if self.state == BUILD_STATE.MOVE or self.Planing == 1 then
                setSuc = self.map.scene:setBuilding(self)
            end
            --print("touchesBegan", setSuc, self.state, self.Planing)
            if setSuc == 1 then
                self.dirty = 1
                self.map.mapGridController:clearMap(self)
                --正在建造当中 touch 过程不调整 属性只在确认之后调整属性
                --移动过程中 一开始就要调整属性 除非建造的时候 一开始就对周围产生影响力
                --移动建筑物 只在setMoveTarget 的时候 和 放下moveTarget的时候 生效
                self:showBottom()
                self.doMove = true
                Event:sendMsg(EVENT_TYPE.DO_MOVE, self)        
            end

        end
    end

    self.accMove = 0
    self.moveStart = self.lastPos[0]
end
function MiaoBuild:touchesMoved(touches)
    local oldPos = self.lastPos
    self.lastPos = convertMultiToArr(touches)
    if oldPos == nil then
        return
    end
    
    local difx = self.lastPos[0][1]-oldPos[0][1]
    local dify = self.lastPos[0][2]-oldPos[0][2]
    if self.doMove then
        local offY = (self.sx+self.sy)*SIZEY/2
        local parPos = self.bg:getParent():convertToNodeSpace(ccp(self.lastPos[0][1], self.lastPos[0][2]-offY))
        local newPos = normalizePos({parPos.x, parPos.y}, self.sx, self.sy)
        --先判定是否冲突 再 设置位置
        local curPos = self.lastPos[0]
        local dx, dy = math.abs(curPos[1]-self.moveStart[1]), math.abs(curPos[2]-self.moveStart[2])
        if dx+dy > 20 then
            self.moveStart = self.lastPos[0]
            self:setColPos()
        end
        self:setPos(newPos)
        self:setMenuWord()
    end
    self.accMove = self.accMove+math.abs(difx)+math.abs(dify)
end

function MiaoBuild:setColor(c)
    if self.bottom ~= nil then
        if c == 0 then
            setColor(self.bottom, {255, 0, 0})
        else
            setColor(self.bottom, {0, 255, 0})
        end
    end
end

function MiaoBuild:calNormal()
    local p = getPos(self.bg)
    local px, py = fixToAffXY(p[1]-self.map.offX, p[2])
    local nx, ny = cartesianToNormal(px, py)
    return nx, ny
end
--修正一下坐标
function MiaoBuild:calAff()
    local nx, ny = self:calNormal()
    local ax, ay = normalToAffine(nx, ny)
    local ax, ay = MapGX-1-ax, MapGY-1-ay
    return ax, ay
end
function MiaoBuild:setColPos()

    self.colNow = 1
    self.otherBuild = nil
    self:setColor(0)

    local ax, ay = self:calAff()
    
    local layer = self.map.scene.tileMap:layerNamed("dirt1");
    if ax < 0 or ay < 0 or ax >= MapGX or ay >= MapGY or ax >= 21 then
        self.colNow = 1
        self:setColor(0)
        return
    end

    --可以建造的位置 并且没有其它建筑物
    local gid = layer:tileGIDAt(ccp(ax, ay))
    local pro = self.map.scene.tileMap:propertiesForGID(gid)
    if pro ~= nil then
        local v = pro:valueForKey("b"):intValue()
        print("tile gid", gid, v)
        if v == 1 then

            local other = self.map:checkCollision(self)
            print("checkCollision result", other)
            if other ~= nil then
                self.colNow = 1
                self.otherBuild = other
                self:setColor(0)
            else
                self.colNow = 0
                self:setColor(1)
            end
        end
    end
end
function MiaoBuild:touchesEnded(touches)
    if self.doMove then
        self:setColPos()
        local p = getPos(self.bg)
        self:setPos(p)
        self.map.mapGridController:updateMap(self)
        
        --建造建筑物在finish的时候 生效
        --self:doMyEffect()
        --self:doEffect()
        Event:sendMsg(EVENT_TYPE.FINISH_MOVE, self)
        if self.colNow == 1 then
            if self.picName == 'move' then
                self.funcBuild:handleTouchEnded()
            --和一个建筑物 冲突 
            elseif self.picName == 'remove' then
                self.funcBuild:handleTouchEnded()
            --建造桥梁
            elseif self.picName == 'build' and self.id == 3 then
                if type(self.otherBuild) == 'table' then

                end
            end
        else
            if self.accMove < 20 and self.state == BUILD_STATE.MOVE then
                self.map.scene:finishBuild() 
            end
            --没有冲突 顺利移动建筑物
            if self.picName == 'move' then
                self.funcBuild:handleFinMove()
            end
        end
    end
end
function MiaoBuild:update(diff)
    local map = getBuildMap(self)
    local p = getPos(self.bg)
    self.posLabel:setString("     "..map[3].." "..map[4].." "..p[1].." "..p[2])
    self.stateLabel:setString(" "..simple.encode(self.product).." "..self.workNum.." "..str(self.food).." "..self.stone)
    local s = ''
    for k, v in ipairs(self.belong) do
        s = s..v.." "
    end
    self.inRangeLabel:setString(s)
end
function MiaoBuild:enterScene()
    registerUpdate(self)
end
function MiaoBuild:exitScene()
end
--道路显示的图层Layer 在 建筑物 和 人物的下面
function MiaoBuild:setPos(p)
    local curPos = p
    local zord = MAX_BUILD_ZORD-curPos[2]

    self.bg:setPosition(ccp(curPos[1], curPos[2]))
    local parent = self.bg:getParent()
    if parent == nil then
        return
    end
    self.bg:setZOrder(zord)
end
function MiaoBuild:adjustRoad()
    self.funcBuild:adjustRoad()
end
--建造花坛 拆除花坛影响周围建筑属性 
function MiaoBuild:showIncrease(n)
    local sp = ui.newBMFontLabel({text=str(n)..'%', font="bound.fnt", size=30})
    self.bg:addChild(sp)
    setPos(sp, {0, 40})
    sp:runAction(sequence({fadein(1), fadeout(1), callfunc(nil, removeSelf, sp)}))
    self.rate = self.rate+n/100
end
function MiaoBuild:showDecrease(n)
    local sp = ui.newBMFontLabel({text='-'..str(n)..'%', font="bound.fnt", size=30, color={102, 0, 0}})
    self.bg:addChild(sp)
    setPos(sp, {0, 40})
    sp:runAction(sequence({fadein(1), fadeout(1), callfunc(nil, removeSelf, sp)}))
    self.rate = self.rate-n/100
end

--普通建筑物的移动 和放下
function MiaoBuild:clearMyEffect()
    --不是农田 和 民居
    if self.id ~= 1 and self.id ~= 2 then
        return
    end

    local map = getBuildMap(self) 
    local initX = 0
    local initY = -4
    local offX = 1
    local offY = 1
    local mapDict = self.map.mapGridController.mapDict
    for i =0, 4, 1 do
        local curX = initX-i
        local curY = initY+i
        for j = 0, 4, 1 do
            local key = getMapKey(curX+map[3], curY+map[4])
            if mapDict[key] ~= nil then
                local ob = mapDict[key][#mapDict[key]][1]
                local dist = math.abs(curX)+math.abs(curY)
                --周围要是匹配的建筑物才行 农田等
                if ob.id == 4 then
                    if dist == 2 then
                        self:showDecrease(10)
                    elseif dist == 4 then
                        self:showDecrease(5)
                    end
                end
            end

            curX = curX+1
            curY = curY+1
        end
    end
end
function MiaoBuild:doMyEffect()
    if self.id ~= 1 and self.id ~= 2 then
        return
    end

    local map = getBuildMap(self) 
    local initX = 0
    local initY = -4
    local offX = 1
    local offY = 1
    local mapDict = self.map.mapGridController.mapDict
    for i =0, 4, 1 do
        local curX = initX-i
        local curY = initY+i
        for j = 0, 4, 1 do
            local key = getMapKey(curX+map[3], curY+map[4])
            if mapDict[key] ~= nil then
                local ob = mapDict[key][#mapDict[key]][1]
                local dist = math.abs(curX)+math.abs(curY)
                --周围要是匹配的建筑物才行 农田等
                if ob.id == 4 then
                    if dist == 2 then
                        self:showIncrease(10)
                    elseif dist == 4 then
                        self:showIncrease(5)
                    end
                end
            end

            curX = curX+1
            curY = curY+1
        end
    end
end

--樱花树的移动和放下
function MiaoBuild:clearEffect()
    --不是樱花树
    self.funcBuild:clearEffect()
end
function MiaoBuild:doEffect()
    --不是樱花树 不对周围产生效果
    self.funcBuild:doEffect()
end
--根据当前cell类型决定 图片类型
--只有拆除路径 铺设路径 
function MiaoBuild:finishBuild()
    --白名单 方法
    if not self.setYet then
        self:adjustRoad()
    end
    self.changeDirNode:stopAllActions()
    self.changeDirNode:runAction(fadein(0))
    self.funcBuild:finishBuild()
    self:setState(BUILD_STATE.FREE)
    self:finishBottom()
    Event:sendMsg(EVENT_TYPE.ROAD_CHANGED)
end

function MiaoBuild:adjustValue()
    local tex = CCTextureCache:sharedTextureCache():addImage(self.picName..self.value..".png") 
    self.changeDirNode:setTexture(tex)
end
function MiaoBuild:setState(s)
    self.state = s
    print("MiaoBuild setState", s, self.state)
    if self.state == BUILD_STATE.MOVE and self.bottom == nil then
        self.bottom = setSize(setAnchor(setPos(CCSprite:create("green2.png"), {0, (self.sx+self.sy)/2*SIZEY}), {0.5, 0.5}), {(self.sx+self.sy)*SIZEX+20, (self.sx+self.sy)*SIZEY+10})
        self.bg:addChild(self.bottom, 1)
    end
end

function MiaoBuild:showBottom()
    if self.bottom == nil then
        self.bottom = setColor(setSize(setAnchor(setPos(CCSprite:create("white2.png"), {0, (self.sx+self.sy)/2*SIZEY}), {0.5, 0.5}), {(self.sx+self.sy)*SIZEX+20, (self.sx+self.sy)*SIZEY+10}),  {0, 255, 0})
        self.bg:addChild(self.bottom, -1)
    end
end
function MiaoBuild:finishBottom()
    if self.bottom ~= nil then
        self.bottom:removeFromParentAndCleanup(true)
        self.bottom = nil
    end
end

function MiaoBuild:setOwner(s)
    self.owner = s
    if s == nil then
        self.nameLabel:setString("")
    else
        self.nameLabel:setString(s.name)    
    end
end

function MiaoBuild:changeWorkNum(n)
    self.workNum = self.workNum+n
end
function MiaoBuild:removeSelf()
    print("removeSelf Building", self.picName, self.id)
    self.funcBuild:removeSelf()
    self.deleted = true
    self.map:removeBuilding(self)
    Event:sendMsg(EVENT_TYPE.ROAD_CHANGED)
end
--用于Move 建筑
--再次点击 确认
function MiaoBuild:runMoveAction(px, py)
    local np = normalizePos({px, py}, 1, 1)
    local function finishMove()
        self.moveAct = nil
        self:setColPos()
        self.lastColBuild = self.otherBuild
        self.map.mapGridController:updateMap(self)
    end
    if self.moveAct ~= nil then
        self.bg:stopAction(self.moveAct)
        self.moveAct = nil
    end
    self.map.mapGridController:clearMap(self)
    self.moveAct = sequence({moveto(0.3, np[1], np[2]), callfunc(nil, finishMove)})
    self.bg:runAction(self.moveAct)
end
function MiaoBuild:clearMoveState()
    print("clearMoveState")
    self.lastColBuild = nil
    self.otherBuild = nil
    self.moveTarget = nil
    local tex = CCTextureCache:sharedTextureCache():addImage("move.png")
    self.changeDirNode:setTexture(tex)
end
function MiaoBuild:moveToPos(p)
    print("moveToPos", simple.encode(p))
    self.map.mapGridController:clearMap(self)
    setPos(self.bg, p)
    self.map.mapGridController:updateMap(self)
    self.funcBuild:finishMove()
end

function MiaoBuild:setMenuWord()
    if self.state == BUILD_STATE.MOVE then
        local ax, ay = self:calAff()
        self.map.scene.scene.menu.infoWord:setString(Logic.buildings[self.id].name..'('..ax..","..ay..")")
    end
end
