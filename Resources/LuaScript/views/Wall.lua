Wall = class(FuncBuild) 
function Wall:ctor(b)
    self.baseBuild = b
    self.value = 0
end
--所有城墙都初始化结束之后 再给城墙设定value
function Wall:initWorking(data)
end

--初始化所有建筑物之后 计算城墙的值
function Wall:calValue()
    local bm = getBuildMap(self.baseBuild)
    local nei = {
        [1] = {bm[3]-1, bm[4]+1},
        --{bm[3], bm[4]+2},
        [3] = {bm[3]+1, bm[4]+1},
        --{bm[3]+2, bm[4]},
        [5] = {bm[3]+1, bm[4]-1},
        --{bm[3], bm[4]-2},
        [7] = {bm[3]-1, bm[4]-1},
        --{bm[3]-2, bm[4]},
    }
    local neiState = {
    }
    local neiborNode = {
    }
    --检测4个邻居的值
    local allCell = self.baseBuild.map.mapGridController.mapDict
    for k, v in pairs(nei) do
        local key = getMapKey(v[1], v[2])
        --print("check Key", key, allCell[key])
        if allCell[key] ~= nil and allCell[key][#allCell[key]][1].funcs == WALL then
            neiState[k] = true
            neiborNode[k] = allCell[key][#allCell[key]][1]
        end
    end
    
    local num = {1, 3, 5, 7}
    local val = 0
    local wei = 1
    for i=1, #num, 1 do
        if neiState[num[i]] then
            val = val+wei
        end
        wei = wei*2
    end
    self.value = val
    self:adjustValue()
    
    --[[
    local addVal = {
        [1]=4,
        [3]=8,
        [5]=1,
        [7]=2,
    }
    
    if val ~= 0 then
        for k, v in ipairs(num) do
            --邻居点存在
            if neiborNode[v] ~= nil then
                neiborNode[v].funcBuild.value = neiborNode[v].funcBuild.value+addVal[v]
                neiborNode[v].funcBuild:adjustValue()
            end
        end
    end
    --]]
end
--增加城墙调整邻居状态
--确认建造的时候
function Wall:finishBuild()
    local bm = getBuildMap(self.baseBuild)
    local nei = {
        [1] = {bm[3]-1, bm[4]+1},
        --{bm[3], bm[4]+2},
        [3] = {bm[3]+1, bm[4]+1},
        --{bm[3]+2, bm[4]},
        [5] = {bm[3]+1, bm[4]-1},
        --{bm[3], bm[4]-2},
        [7] = {bm[3]-1, bm[4]-1},
        --{bm[3]-2, bm[4]},
    }
    local neiState = {
    }
    local neiborNode = {
    }
    --检测4个邻居的值
    local allCell = self.baseBuild.map.mapGridController.mapDict
    for k, v in pairs(nei) do
        local key = getMapKey(v[1], v[2])
        --print("check Key", key, allCell[key])
        if allCell[key] ~= nil and allCell[key][#allCell[key]][1].funcs == WALL then
            neiState[k] = true
            neiborNode[k] = allCell[key][#allCell[key]][1]
        end
    end

    local num = {1, 3, 5, 7}
    local val = 0
    local wei = 1
    for i=1, #num, 1 do
        if neiState[num[i] ] then
            val = val+wei
        end
        wei = wei*2
    end
    self.value = val
    self:adjustValue()

    local addVal = {
        [1]=4,
        [3]=8,
        [5]=1,
        [7]=2,
    }
    if val ~= 0 then
        for k, v in ipairs(num) do
            --邻居点存在
            if neiborNode[v] ~= nil then
                neiborNode[v].funcBuild.value = neiborNode[v].funcBuild.value+addVal[v]
                neiborNode[v].funcBuild:adjustValue()
            end
        end
    end
end
--移除城墙改变邻居状态
function Wall:removeBuild()
    local bm = getBuildMap(self.baseBuild)
    local nei = {
        [1] = {bm[3]-1, bm[4]+1},
        --{bm[3], bm[4]+2},
        [3] = {bm[3]+1, bm[4]+1},
        --{bm[3]+2, bm[4]},
        [5] = {bm[3]+1, bm[4]-1},
        --{bm[3], bm[4]-2},
        [7] = {bm[3]-1, bm[4]-1},
        --{bm[3]-2, bm[4]},
    }
    local neiState = {
    }
    local neiborNode = {
    }
    --检测4个邻居的值
    local allCell = self.baseBuild.map.mapGridController.mapDict
    for k, v in pairs(nei) do
        local key = getMapKey(v[1], v[2])
        --print("check Key", key, allCell[key])
        if allCell[key] ~= nil and allCell[key][#allCell[key]][1].funcs == WALL then
            neiState[k] = true
            neiborNode[k] = allCell[key][#allCell[key]][1]
        end
    end

    local num = {1, 3, 5, 7}
    --[[
    local val = 0
    local wei = 1
    for i=1, #num, 1 do
        if neiState[num[i] ] then
            val = val+wei
        end
        wei = wei*2
    end
    --]]
    --self.value = val
    --self:adjustValue()
    
    local addVal = {
        [1]=4,
        [3]=8,
        [5]=1,
        [7]=2,
    }
    
    if val ~= 0 then
        for k, v in ipairs(num) do
            --邻居点存在
            if neiborNode[v] ~= nil then
                neiborNode[v].funcBuild.value = neiborNode[v].funcBuild.value-addVal[v]
                neiborNode[v].funcBuild:adjustValue()
            end
        end
    end

end

function Wall:adjustValue()
    local tex
    local picName
    local mask1 = self.value%2
    local mask2 = math.floor(self.value/2)%2
    if mask1 == 0 and mask2 == 0 then
        picName = "wall0.png"
    elseif mask1 == 1 and mask2 == 0 then
        picName = "wall1.png"
    elseif mask1 == 0 and mask2 == 1 then
        picName = "wall2.png"
    else
        picName = "wall3.png"
    end
    local mv = mask1*1+mask2*2

    tex = CCTextureCache:sharedTextureCache():addImage(picName) 
    self.baseBuild.changeDirNode:setTexture(tex)
    local sz = self.baseBuild.changeDirNode:getContentSize()
    local axy = WALL_OFFXY[mv] 
    setAnchor(self.baseBuild.changeDirNode, {axy[1]/sz.width, (sz.height-axy[2])/sz.height})
    --setPos(self.baseBuild.changeDirNode, {0, })
end

