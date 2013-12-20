Tree = class(FuncBuild)

function Tree:initView()
    --local sf = CCSpriteFrameCache:sharedSpriteFrameCache()
    --sf:addSpriteFramesWithFile("build4.plist")


    local bd = Logic.buildings[self.baseBuild.id]
    self.baseBuild.changeDirNode = createSprite("build4.png")

    local sz = self.baseBuild.changeDirNode:getContentSize()
    setPos(setAnchor(self.baseBuild.changeDirNode, {313/sz.width, (sz.height-298)/sz.height}), {0, SIZEY})


    self.shadow = createSprite("build4_shadow_0.png")
    setPos(setAnchor(self.shadow, {313/sz.width, (sz.height-298)/sz.height}), {0, SIZEY})
    self.baseBuild.heightNode:addChild(self.shadow)
    
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
function Tree:doEffect()
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
                if ob.id == 1 or ob.id == 2 or ob.id == 5 then
                    if dist == 2 then
                        ob:showIncrease(2)
                    elseif dist == 4 then
                        ob:showIncrease(1)
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
                        ob:showDecrease(4)
                    elseif dist == 4 then
                        ob:showDecrease(1)
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
    --self.baseBuild:doEffect()
    self:doEffect()
end
function Tree:removeSelf()
    self.baseBuild:clearEffect()
end
