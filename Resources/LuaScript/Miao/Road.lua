--道路或者河流
Road = class(FuncBuild)

function Road:adjustValue()
    if not self.baseBuild.onSlope then
        print("adjust Value", self.baseBuild.value)
        setDisplayFrame(self.baseBuild.changeDirNode, "t"..self.baseBuild.value..".png")
    else
        self:whenColNow()
    end
end

function Road:adjustRoad()
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
    --print("neiState", simple.encode(neiState))
    local num = {1, 3, 5, 7}
    local val = 0
    local wei = 1
    for i=1, #num, 1 do
        if neiState[(num[i]+1)/2] then
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
        [3]=8,
        [5]=1,
        [7]=2,
    }
    if val ~= 0 then
        for k, v in ipairs(num) do
            --邻居点存在
            local nv = (v+1)/2
            if neiborNode[nv] ~= false then
                neiborNode[nv].value = neiborNode[nv].value+addVal[v]
                neiborNode[nv].funcBuild:adjustValue()
            end
        end
    end
    self:adjustValue()
end
function Road:removeSelf()
    --[[
    if true then
        Event:sendMsg(EVENT_TYPE.ROAD_CHANGED)
        return
    end
    --]]
    if self.baseBuild.state == BUILD_STATE.MOVE then
        return
    end
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
            local nv = (v+1)/2
            if neiborNode[nv] ~= false then
                neiborNode[nv].value = neiborNode[nv].value-addVal[v]
                neiborNode[nv].funcBuild:adjustValue()
            end
        end
    end
    Event:sendMsg(EVENT_TYPE.ROAD_CHANGED)
end
--当和斜坡冲突的时候变换路块类型
function Road:whenColNow()
    local setYet = false
    if self.baseBuild.colNow == 1 then
        if self.baseBuild.otherBuild ~= nil then
            if self.baseBuild.otherBuild.picName == 'slope' then
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
            end
        end
    end
    --没有斜坡
    if not setYet then
        setDisplayFrame(self.baseBuild.changeDirNode, "t0.png")
        self.baseBuild.onSlope = false
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
                setColor(self.baseBuild.bottom, {0, 255, 0})
            end
        end
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

