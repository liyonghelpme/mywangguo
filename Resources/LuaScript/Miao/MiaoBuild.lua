MiaoBuild = class()
function MiaoBuild:ctor(m)
    self.map = m
    self.sx = 1
    self.sy = 1
    self.colNow = 0
    --道路的状态
    self.value = 0

    self.bg = CCLayer:create()
    self.changeDirNode = setAnchor(CCSprite:create("t0.png"), {0.5, 0})
    self.bg:addChild(self.changeDirNode)
    setContentSize(setAnchor(self.bg, {0.5, 0}), {self.sx*SIZEX*2, self.sy*SIZEY*2})

    --看一下 CCNode 0 0 位置 和 一半位置
    --
    local temp = setSize(addSprite(self.bg, "green2.png"), {10, 10})

    self.state = getParam("buildMove")
    self:setState()
    registerEnterOrExit(self)
    registerMultiTouch(self)
end
function MiaoBuild:touchesBegan(touches)
    self.lastPos = convertMultiToArr(touches)
    self.doMove = false
    self.inSelf = false

    print("build touch began")
    if self.lastPos.count == 1 then
        --建筑物 getBuildMap 0.5 0 位置
        --手指是 0.5 0 位置 转化成0.5 0.5 位置
        local px, py = self.bg:getPosition()
        --手指坐标 向下移动SIZEY 用于在getBuildMap 里面计算手指所在的网格坐标
        local tp = self.bg:getParent():convertToNodeSpace(ccp(self.lastPos[0][1], self.lastPos[0][2]-SIZEY))
        local ret = checkPointIn(tp.x, tp.y,  px, py, self.sx, self.sy)
        print("checkPointIn", ret)
        if ret then
            self.inSelf = true
            local setSuc = 0
            if self.state == getParam("buildMove") or self.Planing == 1 then
                setSuc = global.director.curScene:setBuilding(self)
                --经营场景不允许该建筑物
                --[[
                if setSuc == 1 then
                    if self.bottom == nil then
                        self:setState(self.state)
                    end
                end
                --]]
            end
            print("touchesBegan", setSuc, self.state, self.Planing)
            if setSuc == 1 then
                self.dirty = 1
                self.map.mapGridController:clearMap(self)

                self.doMove = true
                --self:setState()
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
    else
        self.accMove = math.abs(difx)+math.abs(dify)
    end
end

function MiaoBuild:setColor()
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
end
function MiaoBuild:touchesEnded(touches)
    if self.doMove then
        self:setColPos()
        local p = getPos(self.bg)
        self:setPos(p)
        self.map.mapGridController:updateMap(self)
        Event:sendMsg(EVENT_TYPE.FINISH_MOVE, self)
    end
end

function MiaoBuild:enterScene()
end
function MiaoBuild:exitScene()
end
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
--根据当前cell类型决定 图片类型
--只有拆除路径 铺设路径 
function MiaoBuild:finishBuild()
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
        if allCell[key] ~= nil then
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
    local tex = CCTextureCache:sharedTextureCache():addImage("t"..val..".png") 
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

    self:finishBottom()
end
function MiaoBuild:adjustValue()
    local tex = CCTextureCache:sharedTextureCache():addImage("t"..self.value..".png") 
    self.changeDirNode:setTexture(tex)
end
function MiaoBuild:setState()
    self.bottom = setSize(setAnchor(setPos(CCSprite:create("green2.png"), {0, (self.sx+self.sy)/2*SIZEY}), {0.5, 0.5}), {(self.sx+self.sy)*SIZEX+20, (self.sx+self.sy)*SIZEY+10})
    self.bg:addChild(self.bottom, 1)
end
function MiaoBuild:finishBottom()
    self.bottom:removeFromParentAndCleanup(true)
    self.bottom = nil
end
