Hub = class(FuncBuild)
function Hub:ctor(b)
    --self.inEffect = false
end

function Hub:initView()
    setPos(setAnchor(self.baseBuild.changeDirNode, {444/1024, (768-559)/768}), {0, SIZEY})
    
    local temp = CCSpriteBatchNode:create("white2.png")
    self.baseBuild.heightNode:addChild(temp)
    self.baseBuild.gridNode = temp
    local initX = 0
    local initY = -SIZEY*2*2
    local offX = SIZEX
    local offY = SIZEY
    local ax, ay = 0, 0

    for i =0, 4, 1 do
        local curX = initX-SIZEX*i
        local curY = initY+SIZEY*i
        ax = -i 
        ay = -4+i
        for j = 0, 4, 1 do
            local no = CCSprite:create("white2.png")
            temp:addChild(no)
            setAnchor(setSize(setPos(no, {curX, curY}), {SIZEX*2, SIZEY*2}), {0.5, 0})
            if math.abs(ax)+math.abs(ay) == 2 then
                setColor(no, {255, 255, 0})
            else
                setColor(no, {0, 0, 255})
            end

            curX = curX+SIZEX
            curY = curY+SIZEY
            ax = ax+1
            ay = ay+1
        end
    end
end
function Hub:doEffect()
    print("do Effect of building")
    local map = getBuildMap(self.baseBuild) 
    local initX = 0
    local initY = -4
    local offX = 1
    local offY = 1
    local mapDict = self.baseBuild.map.mapGridController.mapDict
    for i =0, 4, 1 do
        local curX = initX-i
        local curY = initY+i
        for j = 0, 4, 1 do
            local key = getMapKey(curX+map[3], curY+map[4])
            if mapDict[key] ~= nil then
                local ob = mapDict[key][#mapDict[key]][1]
                local dist = math.abs(curX)+math.abs(curY)
                --周围要是匹配的建筑物才行 农田等
                --点数 都是增加4点 1点 不论目标对象
                --2 == 0.1  
                --0.3 6
                if ob.data ~= nil and ob.data.IsStore == 2 then
                    if dist == 2 then
                        ob:showIncrease(self.baseBuild.data.effect)
                    elseif dist == 4 then
                        ob:showIncrease(math.floor(self.baseBuild.data.effect/2))
                    end
                end
            end

            curX = curX+1
            curY = curY+1
        end
    end
end
function Hub:clearEffect()
    local map = getBuildMap(self.baseBuild) 
    local initX = 0
    local initY = -4
    local offX = 1
    local offY = 1
    local mapDict = self.baseBuild.map.mapGridController.mapDict
    for i =0, 4, 1 do
        local curX = initX-i
        local curY = initY+i
        for j = 0, 4, 1 do
            local key = getMapKey(curX+map[3], curY+map[4])
            if mapDict[key] ~= nil then
                local ob = mapDict[key][#mapDict[key]][1]
                local dist = math.abs(curX)+math.abs(curY)
                --周围要是匹配的建筑物才行 农田等
                if ob.data ~= nil and ob.data.IsStore == 2 then
                    print("effect is", self.baseBuild.data.effect)
                    if dist == 2 then
                        ob:showDecrease(self.baseBuild.data.effect)
                    elseif dist == 4 then
                        ob:showDecrease(math.floor(self.baseBuild.data.effect/2))
                    end
                end
            end

            curX = curX+1
            curY = curY+1
        end
    end
end
function Hub:finishBuild()
    removeSelf(self.baseBuild.gridNode)
    self.baseBuild.gridNode = nil
    --建造开始就已经确定效果了
    self:doEffect()
end
function Hub:removeSelf()
    --点中选择的时候 效果就已经被去除掉了 所以不用考虑
    --但是点击sell 按钮会关闭 移动对话框 效果又会加回去 所以还是需要 再去除效果的
    if self.baseBuild.state == BUILD_STATE.FREE then
        self.baseBuild:clearEffect()
    end
end
--当前位置无冲突 清理附近状态
function Hub:beginMove()
    --[[
    if self:checkBuildable() then
        --self:clearEffect() 
    end
    --]]
end
--clearMenu 的时候是会恢复状态的
function Hub:finishMove()
    --[[
    if self:checkBuildable() then
        --self:doEffect()
    end
    --]]
end
