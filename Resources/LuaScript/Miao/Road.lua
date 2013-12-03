--道路或者河流
Road = class(FuncBuild)
function Road:adjustRoad()
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
