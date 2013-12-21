FuncBuild = class()
function FuncBuild:ctor(b)
    self.baseBuild = b
end
function FuncBuild:initView()
    local bd = Logic.buildings[self.baseBuild.id]
    local sz = self.baseBuild.changeDirNode:getContentSize()
    setPos(setAnchor(self.baseBuild.changeDirNode, {313/sz.width, (sz.height-298)/sz.height}), {0, SIZEY})
    --setAnchor(self.baseBuild.changeDirNode, {170/sz.width, 0})
end
function FuncBuild:handleTouchEnded()
end
function FuncBuild:clearEffect()
end
function FuncBuild:doEffect()
end
function FuncBuild:adjustRoad()
end
function FuncBuild:finishBuild()
end
function FuncBuild:beginBuild()
end
function FuncBuild:beginMove()
end
function FuncBuild:finishMove()
end
function FuncBuild:removeSelf()
end
function FuncBuild:finishMove()
end
function FuncBuild:setBuyer(b)
end
function FuncBuild:clearBuyer(b)
end
function FuncBuild:setWorker(b)
end
function FuncBuild:clearWorker(b)
end
function FuncBuild:initWork()
end
function FuncBuild:whenColNow()
    if self.baseBuild.colNow == 1 then
        addBanner("该位置有冲突")
    end
end
function FuncBuild:setColor()
end
function FuncBuild:checkFinish()
end

function FuncBuild:canFinish()
    return true
end
function FuncBuild:checkBuildable()
    print("checkBuildable", self.baseBuild.colNow)
    return self.baseBuild.colNow == 0
end
function FuncBuild:clearMenu()
    print("try to clear Menu", self.baseBuild.colNow, self.selGrid)
    if self.selGrid ~= nil then
        removeSelf(self.selGrid)
        self.baseBuild.changeDirNode:stopAllActions()
        setColor(self.baseBuild.changeDirNode, {255, 255, 255})
        self.selGrid = nil
        
        --local curMap = getBuildMap(self.baseBuild)
        if not self:checkBuildable() then
            self.baseBuild.map.mapGridController:clearMap(self.baseBuild)
            local np = getPos(self.baseBuild.bg)
            setPos(self.baseBuild.bg, self.baseBuild.oldPos)

            self.baseBuild.map.mapGridController:updateMap(self.baseBuild)
            self:adjustHeight()
            --清理冲突 调整周围道路的value
            self.baseBuild.colNow = 0
            self:finishMove()
            setPos(self.baseBuild.bg, np)
            self.baseBuild.bg:runAction(sequence({moveto(0.2, self.baseBuild.oldPos[1], self.baseBuild.oldPos[2])}))

        end
        if #global.director.stack > 0 then
            global.director:popView()
        end
        --getPosMap(self.baseBuild.sx, self.baseBuild.sy)    

        --deleted = true
        --构建一个新的建筑物 放在相同的位置  告诉所有的猫我被移动了 大家就要把我从allBuilding 里面删除掉
        --当前所有正在向这个建筑物移动的人 来确认建筑物 moved 移动了 
        --每只猫都hold 到这个建筑物的oldPos 和 newPos 进行比对 如果不同了 表示建筑物move了 网格 这样就要调整当前的网格
        --self.baseBuild.moved = true
        Event:sendMsg(EVENT_TYPE.ROAD_CHANGED)
    end
end
function FuncBuild:showInfo()
    --先清理旧的
    Event:sendMsg(EVENT_TYPE.SELECT_ME, self.baseBuild)

    local bo = BuildOpMenu.new(self.baseBuild)
    global.director:pushView(bo)

    self.baseBuild.changeDirNode:runAction(repeatForever(sequence({itintto(0.5, 128, 128, 128), itintto(0.5, 255, 255, 255)})))
    self.baseBuild.oldPos = getPos(self.baseBuild.bg)
    self:initBottom()
end

function FuncBuild:finishBottom()
    if self.selGrid ~= nil then
        removeSelf(self.selGrid)
        self.selGrid = nil
    end
end
function FuncBuild:initBottom()
    if self.selGrid == nil then
        self.selGrid = setAnchor(setPos(CCSprite:create("newBlueGrid.png"), {0, (self.baseBuild.sx+self.baseBuild.sy)/2*SIZEY}), {0.5, 0.5})
        self.baseBuild.heightNode:addChild(self.selGrid, -1)
    end
    --[[
    self.baseBuild.bottom = setSize(setAnchor(setPos(CCSprite:create("white2.png"), {0, (self.baseBuild.sx+self.baseBuild.sy)/2*SIZEY}), {0.5, 0.5}), {(self.baseBuild.sx+self.baseBuild.sy)*SIZEX+20, (self.baseBuild.sx+self.baseBuild.sy)*SIZEY+10})
    self.baseBuild.heightNode:addChild(self.baseBuild.bottom, 1)
    --]]
end
function FuncBuild:setBottomColor(c)
    if self.selGrid ~= nil then
        if c == 0 then
            setTexture(self.selGrid, "newRedGrid.png")
        else
            setTexture(self.selGrid, "newBlueGrid.png")
        end
    end
    --[[
    if c == 0 then
        setColor(self.baseBuild.bottom, {255, 0, 0})
    else
        setColor(self.baseBuild.bottom, {0, 255, 0})
    end
    --]]
end
function FuncBuild:doSwitch()
end
function FuncBuild:takeTool()
end
function FuncBuild:putTool()
end
function FuncBuild:updateState()
end
function FuncBuild:updateGoods()
end
function FuncBuild:setPos()
    self:adjustHeight()
end

function FuncBuild:adjustHeight()
    local p = getPos(self.baseBuild.bg)
    local ax, ay = newCartesianToAffine(p[1], p[2], self.baseBuild.map.scene.width, self.baseBuild.map.scene.height, MapWidth/2, FIX_HEIGHT)
    print("adjust Road Height !!!!!!!!!!!!!!!!!!!!!!!!!", ax, ay)
    local hei = adjustNewHeight(self.baseBuild.map.scene.mask, self.baseBuild.map.scene.width, ax, ay)
    setPos(self.baseBuild.heightNode, {0, hei*103})
end

function FuncBuild:showIncrease(n)
end
--调用公有代码
function FuncBuild:doMyEffect()
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
                --樱花树建筑物
                if ob.id == 4 then
                    if dist == 2 then
                        self:showIncrease(2)
                    elseif dist == 4 then
                        self:showIncrease(1)
                    end
                end
            end

            curX = curX+1
            curY = curY+1
        end
    end
end
function FuncBuild:getProductName()
    return "--"
end
function FuncBuild:getProductPrice()
    return "--"
end
function FuncBuild:setOwner(s)
end
function FuncBuild:enterStore(s)
    self.inMerchant = s
end
function FuncBuild:exitStore()
    self.inMerchant = nil
end
