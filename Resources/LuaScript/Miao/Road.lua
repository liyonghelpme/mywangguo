--道路或者河流
Road = class(FuncBuild)

function Road:adjustValue()
    if not self.baseBuild.onSlope then
        print("adjust Value", self.baseBuild.value)
        if self.baseBuild.value >= 16 then
            setDisplayFrame(self.baseBuild.changeDirNode, "t0.png")
        else
            setDisplayFrame(self.baseBuild.changeDirNode, "t"..self.baseBuild.value..".png")
        end
    else
        --self:whenColNow()
        self:adjustOnSlope()
    end
end

function Road:adjustRoad()
    local bm = getBuildMap(self.baseBuild) 
    print("self.baseBuild map", bm[1], bm[2], bm[3], bm[4])
    --判定周围八个map状态
    local nei = {
        {bm[3]-1, bm[4]+1},
        {bm[3]+1, bm[4]+1},
        {bm[3]+1, bm[4]-1},
        {bm[3]-1, bm[4]-1},
    }
    local neiState = {
    }
    local neiborNode = {
    }
    local allCell = self.baseBuild.map.mapGridController.mapDict
    for k, v in ipairs(nei) do
        local key = getMapKey(v[1], v[2])
        print("check Key", key, allCell[key])
        if allCell[key] ~= nil and allCell[key][#allCell[key]][1].picName == self.baseBuild.picName then
            table.insert(neiState, true)
            table.insert(neiborNode, allCell[key][#allCell[key]][1])
        else
            table.insert(neiState, false)
            table.insert(neiborNode, false)
        end
    end
    --print("neiState", simple.encode(neiState))
    local val = 0
    local wei = 1
    for i=1, 4, 1 do
        if neiState[i] then
            val = val+wei
        end
        wei = wei*2
    end
    print("check Value", val, wei)
    --adjust neibor state
    --end
    --调整邻居的状态
    self.baseBuild.value = val
    local addVal = {
        [1]=4,
        [2]=8,
        [3]=1,
        [4]=2,
    }
    print("finish adjust Road ", val)
    self:adjustValue()
    if val ~= 0 then
        for v=1, 4, 1 do
            --邻居点存在
            local nv = v
            if neiborNode[nv] ~= false then
                neiborNode[nv].value = neiborNode[nv].value+addVal[v]
                neiborNode[nv].funcBuild:adjustValue()
            end
        end
    end
end
function Road:beginMove()
    if self.baseBuild.colNow == 0 or self:checkBuildable() then
        self:removeSelf()
    end
end
function Road:finishMove()
    if self.baseBuild.colNow == 0 or self:checkBuildable() then
        self:adjustRoad()
    end
end
function Road:removeSelf()
    local bm = getBuildMap(self.baseBuild) 
    print("self.baseBuild map", bm[1], bm[2], bm[3], bm[4])
    --判定周围八个map状态
    local nei = {
        {bm[3]-1, bm[4]+1},
        --{bm[3], bm[4]+2},
        {bm[3]+1, bm[4]+1},
        --{bm[3]+2, bm[4]},
        {bm[3]+1, bm[4]-1},
        --{bm[3], bm[4]-2},
        {bm[3]-1, bm[4]-1},
        --{bm[3]-2, bm[4]},
    }
    local neiState = {
    }
    local neiborNode = {
    }
    local allCell = self.baseBuild.map.mapGridController.mapDict
    for k, v in ipairs(nei) do
        local key = getMapKey(v[1], v[2])
        print("check Key", key, allCell[key])
        if allCell[key] ~= nil and allCell[key][#allCell[key]][1].picName == self.baseBuild.picName then
            table.insert(neiState, true)
            table.insert(neiborNode, allCell[key][#allCell[key]][1])
        else
            table.insert(neiState, false)
            table.insert(neiborNode, false)
        end
    end
    print("neiState", simple.encode(neiState))
    --调整邻居的状态
    local addVal = {
        [1]=4,
        [2]=8,
        [3]=1,
        [4]=2,
    }
    if val ~= 0 then
        for v=1, 4, 1 do
            --邻居点存在
            local nv = v
            if neiborNode[nv] ~= false then
                neiborNode[nv].value = neiborNode[nv].value-addVal[v]
                neiborNode[nv].funcBuild:adjustValue()
            end
        end
    end
    Event:sendMsg(EVENT_TYPE.ROAD_CHANGED)
end
function Road:adjustOnSlope()
    local set = false
    if self.baseBuild.otherBuild.dir == 0 then
        local tex = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("tile36.png")
        self.baseBuild.changeDirNode:setDisplayFrame(tex)
        setYet = true
        self.baseBuild.onSlope = true
    elseif self.baseBuild.otherBuild.dir == 1 then
        local tex = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("tile37.png")
        self.baseBuild.changeDirNode:setDisplayFrame(tex)
        setYet = true
        self.baseBuild.onSlope = true
    end
    return setYet
end
--当和斜坡冲突的时候变换路块类型
function Road:whenColNow()
    local setYet = false
    print("when col now", self.baseBuild.colNow)
    if self.baseBuild.colNow == 1 then
        if self.baseBuild.otherBuild ~= nil then
            if self.baseBuild.otherBuild.picName == 'slope' then
                setYet = self:adjustOnSlope()
            end
        end
    end
    if self.baseBuild.colNow == 1 and not setYet then
        addBanner("该位置有冲突")
    end
    --没有斜坡
    if not setYet then
        print("not set set as t0 touch adjustValue")
        self.baseBuild.onSlope = false
        --self:adjustValue()
    end
end

--斜坡上面 可以建造道路
function Road:setColor()
    if self.baseBuild.colNow == 1 then
        if self.baseBuild.otherBuild ~= nil then
            local dir = self.baseBuild.otherBuild.dir
            print("road setColor", self.baseBuild.colNow, self.baseBuild.otherBuild.picName, dir)
            if self.baseBuild.otherBuild.picName == 'slope' and (dir ==0 or dir == 1) then
                print("setColor")
                --setColor(self.baseBuild.bottom, {0, 255, 0})
                self:setBottomColor(1)
            end
        end
    end
end
function Road:checkBuildable()
    if self.baseBuild.colNow == 1 then
        if self.baseBuild.otherBuild ~= nil then
            local dir = self.baseBuild.otherBuild.dir
            if self.baseBuild.otherBuild.picName == 'slope' and (dir ==0 or dir == 1) then
                return true
            end
        end
        return false
    else
        return true
    end
end

--斜坡上面完成建造
function Road:checkFinish()
    if self.baseBuild.colNow == 1 then
        if self.baseBuild.otherBuild ~= nil then
            local dir = self.baseBuild.otherBuild.dir
            if self.baseBuild.otherBuild.picName == 'slope' and (dir ==0 or dir == 1) then
                self.baseBuild.map.scene:finishBuild() 
            end
        end
    end
end
function Road:initView()
    local sf = CCSpriteFrameCache:sharedSpriteFrameCache()
    sf:addSpriteFramesWithFile("road.plist")
    if self.baseBuild.privData.ladder == true then
        self.baseBuild.changeDirNode = setAnchor(CCSprite:createWithSpriteFrameName("tile36.png"), {170/512, 0})
        self.baseBuild.onSlope = true
    else
        self.baseBuild.changeDirNode = setAnchor(CCSprite:createWithSpriteFrameName("t0.png"), {170/512, 0})
    end
end

function Road:beginBuild()
    print("beginBuild!!!!!!!!!!!!!", self.baseBuild.colNow)
    if self.baseBuild.colNow == 0 or self:checkBuildable() then
        self:adjustRoad()
    end
end
function Road:finishBuild()
    print("finish Building!!!!!", self.baseBuild.value)
end
