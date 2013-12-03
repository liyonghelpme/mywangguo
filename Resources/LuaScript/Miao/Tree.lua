Tree = class(FuncBuild)

function Tree:initView()
    local bd = Logic.buildings[self.baseBuild.id]
    local sz = self.baseBuild.changeDirNode:getContentSize()
    setAnchor(self.baseBuild.changeDirNode, {bd.ax/sz.width, (sz.height-bd.ay)/sz.height})
    
    local temp = CCSpriteBatchNode:create("white2.png")
    self.baseBuild.bg:addChild(temp)
    self.baseBuild.gridNode = temp
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
end
function Tree:doEffect()
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
function Tree:clearEffect()
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
                if ob.id == 1 or ob.id == 2 then
                    if dist == 2 then
                        ob:showDecrease(10)
                    elseif dist == 4 then
                        ob:showDecrease(5)
                    end
                end
            end

            curX = curX+1
            curY = curY+1
        end
    end
end
function Tree:finishBuild()
    removeSelf(self.baseBuild.gridNode)
    self.baseBuild.gridNode = nil
    --建造开始就已经确定效果了
    self.baseBuild:doEffect()
end
function Tree:removeSelf()
    self.baseBuild:clearEffect()
end
