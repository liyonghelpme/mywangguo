MiaoBuild = class()
BUILD_STATE = {
    FREE = 0,
    MOVE = 1,
}
function MiaoBuild:ctor(m, data)
    self.map = m
    self.sx = 1
    self.sy = 1
    self.colNow = 0
    --道路的状态
    self.value = 0
    self.picName = data.picName
    self.id = data.id
    self.owner = nil
    self.workNum = 0
    self.lastColBuild = nil
    self.dir = 0
    self.deleted = false
    self.moveTarget = nil
    self.rate = 0

    self.bg = CCLayer:create()
    if self.picName == 'build' then
        --建造桥梁 4个方向旋转 还是两个方向旋转
        if self.id == 3 then
            self.changeDirNode = setAnchor(CCSprite:create(self.picName..self.id..".png"), {0.5, 0.5})
            setPos(self.changeDirNode, {0, SIZEY})
            setRotation(self.changeDirNode, 45)
        --樱花树
        elseif self.id == 4 then
            self.changeDirNode = setAnchor(CCSprite:create(self.picName..self.id..".png"), {0.5, 0})
            local bd = Logic.buildings[self.id]
            local sz = self.changeDirNode:getContentSize()
            setAnchor(self.changeDirNode, {bd.ax/sz.width, (sz.height-bd.ay)/sz.height})
            
            local temp = CCSpriteBatchNode:create("white2.png")
            self.bg:addChild(temp)
            self.gridNode = temp
            local initX = 0
            local initY = -SIZEY*2*2
            local offX = SIZEX
            local offY = SIZEY
            for i =0, 4, 1 do
                local curX = initX-SIZEX*i
                local curY = initY+SIZEY*i
                for j = 0, 4, 1 do
                    local no = CCSprite:create("white2.png")
                    temp:addChild(no)
                    setAnchor(setSize(setPos(no, {curX, curY}), {SIZEX*2, SIZEY*2}), {0.5, 0})
                    curX = curX+SIZEX
                    curY = curY+SIZEY
                end
            end
        else
            self.changeDirNode = setAnchor(CCSprite:create(self.picName..self.id..".png"), {0.5, 0})
            local bd = Logic.buildings[self.id]
            local sz = self.changeDirNode:getContentSize()
            setAnchor(self.changeDirNode, {bd.ax/sz.width, (sz.height-bd.ay)/sz.height})

            --local temp = setPos(setSize(addSprite(self.changeDirNode, "green2.png"), {10, 10}), {Logic.buildings[self.id].doorx, (sz.height-Logic.buildings[self.id].doory)})
            --self.doorPoint = temp
        end
    elseif self.picName == 'move' then
        self.changeDirNode = setPos(setRotation(CCSprite:create("move.png"), 45), {0, SIZEY})
    elseif self.picName == 'backPoint' then
        self.changeDirNode = setColor(setSize(setAnchor(CCSprite:create("white2.png"), {0.5, 0}), {SIZEX*2, SIZEY*2}), {255, 255, 0})
    elseif self.picName == 'remove' then
        self.changeDirNode = setPos(setRotation(CCSprite:create("hammer.png"), 45), {0, SIZEY})
    else
        self.changeDirNode = setAnchor(CCSprite:create(self.picName.."0.png"), {0.5, 0})
    end
    self.bg:addChild(self.changeDirNode)
    setContentSize(setAnchor(self.bg, {0.5, 0}), {self.sx*SIZEX*2, self.sy*SIZEY*2})

    self.nameLabel = ui.newBMFontLabel({text="", size=21})
    setPos(self.nameLabel, {0, 100})
    self.bg:addChild(self.nameLabel)

    --看一下 CCNode 0 0 位置 和 一半位置
    --
    --local temp = setSize(addSprite(self.bg, "green2.png"), {10, 10})
    self:setState(BUILD_STATE.FREE)

    registerEnterOrExit(self)
    --page 首先处理 建筑物的touch 再处理自身的touch事件
    --registerMultiTouch(self)
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
                setSuc = global.director.curScene:setBuilding(self)
            end
            --print("touchesBegan", setSuc, self.state, self.Planing)
            if setSuc == 1 then
                self.dirty = 1
                self.accMove = 0
                self.map.mapGridController:clearMap(self)
                self:showBottom()

                self.doMove = true
                Event:sendMsg(EVENT_TYPE.DO_MOVE, self)        
            end

        end
    end
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
        if math.abs(difx)+math.abs(dify) > 20 then
            self:setColPos()
        end
        self:setPos(newPos)
        self.accMove = self.accMove+math.abs(difx)+math.abs(dify)
    end
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
function MiaoBuild:setColPos()
    self.colNow = 0
    local other = self.map:checkCollision(self)
    print("checkCollision result", other)
    if other ~= nil then
        self.colNow = 1
        self:setColor(0)
    else
        self:setColor(1);
    end
    self.otherBuild = other
end
function MiaoBuild:touchesEnded(touches)
    if self.doMove then
        self:setColPos()
        local p = getPos(self.bg)
        self:setPos(p)
        self.map.mapGridController:updateMap(self)
        Event:sendMsg(EVENT_TYPE.FINISH_MOVE, self)
        if self.colNow == 1 then
            if self.picName == 'move' then
                if self.moveTarget == nil then
                    --print("move collide ", self.otherBuild.picName, self.lastColBuild.picName, self.moveTarget)
                    print("move Collide")
                    --确认移动建筑物了
                    if self.lastColBuild == self.otherBuild and self.otherBuild.picName == 'build' then
                        local tex = self.otherBuild.changeDirNode:getTexture()
                        --确认当前移动的建筑物
                        self.changeDirNode:setTexture(tex)
                        self.moveTarget = self.otherBuild
                    else
                        self.lastColBuild = self.otherBuild
                    end
                --如果上次点击位置 和这次位置一样 则 确认移动  要移动的目的地和原来的目的地相同则不变
                --之后需要加上朝向direction
                else
                    print("moveBuilding now", self.accMove)
                    if self.accMove < 20 and self.otherBuild == self.moveTarget then
                        local p = getPos(self.bg)
                        self.moveTarget:moveToPos(p)
                        self:clearMoveState()
                    end
                end
            --和一个建筑物 冲突 
            elseif self.picName == 'remove' then
                if type(self.otherBuild) == 'table' then
                    print("removeBuilding", self.otherBuild, type(self.otherBuild))
                    if self.lastColBuild == self.otherBuild then
                        --self.map:removeBuilding(self.otherBuild)
                        --只能移除 建筑物 和 道路
                        if self.otherBuild.picName == 'build' or self.otherBuild.picName == 't' then
                            self.otherBuild:removeSelf()
                            self.lastColBuild = nil
                            self.otherBuild = nil
                        end
                    else
                        self.lastColBuild = self.otherBuild
                    end
                end
            --建造桥梁
            elseif self.picName == 'build' and self.id == 3 then
                if type(self.otherBuild) == 'table' then

                end
            end
        else
            --没有冲突 顺利移动建筑物
            if self.picName == 'move' then
                if self.moveTarget ~= nil then
                    print("sure to move", self.accMove)
                    if self.accMove < 20 then
                        local p = getPos(self.bg)
                        self.moveTarget:moveToPos(p)
                        self:clearMoveState()
                    end
                end
            end
        end
    end
end

function MiaoBuild:enterScene()
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
    print("MiaoBuild")
    local bm = getBuildMap(self) 
    print("self map", bm[1], bm[2], bm[3], bm[4])
    --判定周围八个map状态
    local nei = {
        {bm[3]-1, bm[4]+1},
        {bm[3], bm[4]+2},
        {bm[3]+1, bm[4]+1},
        {bm[3]+2, bm[4]},
        {bm[3]+1, bm[4]-1},
        {bm[3], bm[4]-2},
        {bm[3]-1, bm[4]-1},
        {bm[3]-2, bm[4]},
    }
    local neiState = {
    }
    local neiborNode = {
    }
    local allCell = self.map.mapGridController.mapDict
    for k, v in ipairs(nei) do
        local key = getMapKey(v[1], v[2])
        print("check Key", key, allCell[key])
        if allCell[key] ~= nil and allCell[key][1][1].picName == self.picName then
            table.insert(neiState, true)
            table.insert(neiborNode, allCell[key][1][1])
        else
            table.insert(neiState, false)
            table.insert(neiborNode, false)
        end
    end
    print("neiState", simple.encode(neiState))
    local num = {1, 3, 5, 7}
    local val = 0
    local wei = 1
    for i=1, #num, 1 do
        if neiState[num[i]] then
            val = val+wei
        end
        wei = wei*2
    end
    print("check Value", val, wei)
    --adjust neibor state
    local tex = CCTextureCache:sharedTextureCache():addImage(self.picName..val..".png") 
    --if wei == 0 then
    self.changeDirNode:setTexture(tex)
    --end
    --调整邻居的状态
    self.value = val
    local addVal = {
        [1]=4,
        [3]=8,
        [5]=1,
        [7]=2,
    }
    if val ~= 0 then
        for k, v in ipairs(num) do
            --邻居点存在
            if neiborNode[v] ~= false then
                neiborNode[v].value = neiborNode[v].value+addVal[v]
                neiborNode[v]:adjustValue()
            end
        end
    end
end
--建造花坛 拆除花坛影响周围建筑属性 
function MiaoBuild:showIncrease(n)
    local sp = ui.newBMFontLabel({text=str(n)..'%', font="bound.fnt", size=30})
    self.bg:addChild(sp)
    setPos(sp, {0, 40})
    sp:runAction(sequence({fadein(1), fadeout(1), callfunc(nil, removeSelf, sp)}))
    self.rate = self.rate+n/100
end
--根据当前cell类型决定 图片类型
--只有拆除路径 铺设路径 
function MiaoBuild:finishBuild()
    --白名单 方法
    if self.picName == 't' or self.picName == 's' then
        self:adjustRoad()
    elseif self.picName == 'build' then
        --樱花树
        if self.id == 4 then
            removeSelf(self.gridNode)
            self.gridNode = nil

            local allBuild = {}
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
                        if ob.id == 1 or ob.id == 2 then
                            if dist == 2 then
                                ob:showIncrease(10)
                            elseif dist == 4 then
                                ob:showIncrease(5)
                            end
                        end
                    end

                    curX = curX+1
                    curY = curY+1
                end
            end

        end
    end
    self:setState(BUILD_STATE.FREE)
    self:finishBottom()
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
    if self.picName == 't' then
        local bm = getBuildMap(self) 
        print("self map", bm[1], bm[2], bm[3], bm[4])
        --判定周围八个map状态
        local nei = {
            {bm[3]-1, bm[4]+1},
            {bm[3], bm[4]+2},
            {bm[3]+1, bm[4]+1},
            {bm[3]+2, bm[4]},
            {bm[3]+1, bm[4]-1},
            {bm[3], bm[4]-2},
            {bm[3]-1, bm[4]-1},
            {bm[3]-2, bm[4]},
        }
        local neiState = {
        }
        local neiborNode = {
        }
        local allCell = self.map.mapGridController.mapDict
        for k, v in ipairs(nei) do
            local key = getMapKey(v[1], v[2])
            print("check Key", key, allCell[key])
            if allCell[key] ~= nil and allCell[key][1][1].picName == self.picName then
                table.insert(neiState, true)
                table.insert(neiborNode, allCell[key][1][1])
            else
                table.insert(neiState, false)
                table.insert(neiborNode, false)
            end
        end
        print("neiState", simple.encode(neiState))
        local num = {1, 3, 5, 7}
        --调整邻居的状态
        local addVal = {
            [1]=4,
            [3]=8,
            [5]=1,
            [7]=2,
        }
        if val ~= 0 then
            for k, v in ipairs(num) do
                --邻居点存在
                if neiborNode[v] ~= false then
                    neiborNode[v].value = neiborNode[v].value-addVal[v]
                    neiborNode[v]:adjustValue()
                end
            end
        end
    elseif self.picName == 'build' then
        --拆除民居
        if self.id == 1 then
            print("remove House", self.owner)
            if self.owner ~= nil then
                self.owner:clearHouse()
                self.owner = nil
            end
        --农田
        elseif self.id == 2 then
            --商人来收获 或者 村民正在过来 工作 
            --商人自己检测如果 目标不存在了 则终止行动
            --农民自己检测 目标不存在了则终止行动
            if self.owner ~= nil then
                self.owner:clearWork()
                self.owner = nil
            end
        --桥梁
        elseif self.id == 3 then
        end
    end
    self.deleted = true
    self.map:removeBuilding(self)
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
    if self.owner ~= nil then
        if self.id == 1 then
            self.owner:clearHouse()
        elseif self.id == 2 then
            self.owner:clearWork()
        end
        self.owner = nil
    end
end
