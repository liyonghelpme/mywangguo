--道路或者河流
Road = class(FuncBuild)
function Road:adjustRoad()
    if true then
        return
    end
    print("MiaoBuild")
    local bm = getBuildMap(self.baseBuild) 
    print("self.baseBuild map", bm[1], bm[2], bm[3], bm[4])
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
    local tex = CCTextureCache:sharedTextureCache():addImage(self.baseBuild.picName..val..".png") 
    --if wei == 0 then
    self.baseBuild.changeDirNode:setTexture(tex)
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
            if neiborNode[v] ~= false then
                neiborNode[v].value = neiborNode[v].value+addVal[v]
                neiborNode[v]:adjustValue()
            end
        end
    end
end
function Road:removeSelf()
    if true then
        Event:sendMsg(EVENT_TYPE.ROAD_CHANGED)
        return
    end
    if self.baseBuild.state == BUILD_STATE.MOVE then
        return
    end
    local bm = getBuildMap(self.baseBuild) 
    print("self.baseBuild map", bm[1], bm[2], bm[3], bm[4])
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
            if neiborNode[v] ~= false then
                neiborNode[v].value = neiborNode[v].value-addVal[v]
                neiborNode[v]:adjustValue()
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
                    local tex = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("tile26.png")
                    self.baseBuild.changeDirNode:setDisplayFrame(tex)
                    local sz = self.baseBuild.changeDirNode:getContentSize()
                    setAnchor(self.baseBuild.changeDirNode, {(64-20)/sz.width, 20/sz.height})
                    setYet = true
                    self.baseBuild.onSlope = true
                elseif self.baseBuild.otherBuild.dir == 1 then
                    local tex = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("tile27.png")
                    self.baseBuild.changeDirNode:setDisplayFrame(tex)
                    local sz = self.baseBuild.changeDirNode:getContentSize()
                    setAnchor(self.baseBuild.changeDirNode, {(64)/sz.width, 20/sz.height})
                    --setAnchor(self.baseBuild.changeDirNode, {})
                    setYet = true
                    self.baseBuild.onSlope = true
                end
            end
        end
    end
    --没有斜坡
    if not setYet then
        local tex = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("tile29.png")
        self.baseBuild.changeDirNode:setDisplayFrame(tex)
        setAnchor(self.baseBuild.changeDirNode, {0.5, 0})
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
    if self.baseBuild.privData.ladder == true then
        self.baseBuild.changeDirNode = CCSprite:createWithSpriteFrameName("tile26.png")
        local sz = self.baseBuild.changeDirNode:getContentSize()
        setAnchor(self.baseBuild.changeDirNode, {170/sz.width, (170)/sz.height})
        self.baseBuild.onSlope = true
    else
        self.baseBuild.changeDirNode = setAnchor(CCSprite:createWithSpriteFrameName("tile29.png"), {0.5, 0})
        local sz = self.baseBuild.changeDirNode:getContentSize()
        setAnchor(self.baseBuild.changeDirNode, {170/sz.width, (sz.height-170)/sz.height})
    end
end

function Road:setPos()
    local p = getPos(self.baseBuild.bg)
    local ax, ay = newCartesianToAffine(p[1], p[2], self.baseBuild.map.scene.width, self.baseBuild.map.scene.height, MapWidth/2, FIX_HEIGHT)
    print("adjust Road Height !!!!!!!!!!!!!!!!!!!!!!!!!", ax, ay)
    local ad = adjustNewHeight(self.baseBuild.map.scene.mask2, self.baseBuild.map.scene.width, ax, ay)
    if ad then
        setPos(self.baseBuild.changeDirNode, {0, 90})
    else
        setPos(self.baseBuild.changeDirNode, {0, 0})
    end
end
