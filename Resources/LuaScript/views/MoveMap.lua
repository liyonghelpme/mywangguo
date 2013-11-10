MoveMap = class()
function MoveMap:ctor(sc)
    self.scene = sc
end
function MoveMap:enterScene()
end
function MoveMap:exitScene()
end
function MoveMap:updateMapGrid()
    if DEBUG then
        removeSelf(self.gridLayer)
        self.gridLayer = CCSpriteBatchNode:create("white2.png")
        self.bg:addChild(self.gridLayer)
        local allCell
        if BattleLogic.inBattle then
            allCell = self.mapGridController.effectDict
        else
            allCell = self.mapGridController.mapDict
        end
        for k, v in pairs(allCell) do
            local x = math.floor(k/10000)
            local y = k%10000
            local p = setBuildMap({1, 1, x, y})
            local sp = setColor(setAnchor(setPos(setSize(addSprite(self.gridLayer, "white2.png"), {SIZEX*2, SIZEY*2}), p), {0.5, 0}), {255, 0, 0})
            --[[
            local lab = ui.newTTFLabel({text=""..p[1].." "..p[2], size=100})
            sp:addChild(lab)
            --]]
        end
        --[[
        for k, v in pairs(self.staticObstacle) do
            local x = math.floor(k/10000)
            local y = k%10000
            local p = setBuildMap({1, 1, x, y})
            local sp = setAnchor(setPos(setSize(addSprite(self.gridLayer, "white2.png"), {SIZEX, SIZEY}), p), {0.5, 0})
            local lab = ui.newTTFLabel({text=""..p[1].." "..p[2], size=100})
            sp:addChild(lab)
        end
        --]]
    end
end
--寻路算法的 node
function MoveMap:updateCells(cells, bcells, predict)
    if DEBUG then
        removeSelf(self.cellLayer)
        self.cellLayer = CCSpriteBatchNode:create("white2.png")
        self.bg:addChild(self.cellLayer)
        --gScore hScore fScore
        --openList
        --closedList
        --key:      normal coordinate
        --value:    parent gScore hScore fScore
        for k, v in pairs(cells) do
            local x, y = getXY(k)
            --local cx, cy = normalToCartesian(x, y)
            local cxy = setBuildMap({1, 1, x, y})
            local sp = setColor(setAnchor(setPos(setSize(addSprite(self.cellLayer, "white2.png"), {SIZEX, SIZEY}), cxy), {0.5, 0}), {0, 255, 0})
        end

        for k, v in pairs(bcells) do
            local x, y = getXY(k)
            --local cx, cy = normalToCartesian(x, y)
            local cxy = setBuildMap({1, 1, x, y})
            local sp = setColor(setAnchor(setPos(setSize(addSprite(self.cellLayer, "white2.png"), {SIZEX, SIZEY}), cxy), {0.5, 0}), {255, 0, 0})
        end
        if predict ~= nil then
            local cxy = setBuildMap({1, 1, predict[1], predict[2]})
            local sp = setColor(setAnchor(setPos(setSize(addSprite(self.cellLayer, "white2.png"), {SIZEX, SIZEY}), cxy), {0.5, 0}), {255, 255, 0})
        end
    end
end
--normal 坐标
function MoveMap:updatePath(path)
    if DEBUG then
        removeSelf(self.pathLayer)
        self.pathLayer = CCSpriteBatchNode:create("white2.png")
        self.bg:addChild(self.pathLayer)
        for k, v in ipairs(path) do
            local cxy = setBuildMap({1, 1, v[1], v[2]})
            local sp = setColor(setAnchor(setPos(setSize(addSprite(self.pathLayer, "white2.png"), {SIZEX, SIZEY}), cxy), {0.5, 0}), {0, 0, 255})
        end
    end
end

function MoveMap:checkPosCollision(mx, my, ps)
    local key = getMapKey(mx, my)
    local v = self.mapGridController.mapDict[key]
    if v ~= nil then
        if #v > 0 then
            if v[1][3] == 1 then
                return v[1]
            end
        end
    end
    return nil
end
function MoveMap:checkFallGoodsCol(rx, ry)
    local key = getMapKey(mx, my)
    local v = self.mapGridController.mapDict[key]
    if v ~= nil then
        return true
    end
    return false
end
function MoveMap:checkInFlow(zone, p)
    for i = 1, #zone, 1 do
        local difx = p[1] - zone[i][1]
        local dify = p[2] - zone[i][2]
        if difx > 0 and difx < zone[i][3] and dify > 0 and dify < zone[i][4] then
            return 1
        end
    end
    return 0
end
function MoveMap:checkCollision(build)
    --print("checkCollision", build)
    local inZ = self:checkInFlow(self.buildZone, getPos(build.bg))
    if inZ == 0 then
        return 1
    end

    local map = getBuildMap(build)
    local sx = map[1]
    local sy = map[2]
    local initX = map[3]
    local initY = map[4]
    print("map is", sx, sy, initX, initY)
    for i=0, sx-1, 1 do
        local curX = initX+i
        local curY = initY+i
        for j=0, sy-1, 1 do
            local key = getMapKey(curX, curY)
            local v = self.mapGridController.mapDict[key]
            if v ~= nil then
                for m, n in ipairs(v) do
                    if n[1] ~= build then
                        return n
                    end
                end
            end
            if self.staticObstacle[key] ~= nil then
                print("col key", key)
                return 1
            end
            curX = curX-1
            curY = curY+1
        end
    end
    return nil
end
function MoveMap:addBuilding(chd, z)
    print('MoveMap addBuilding', chd, z)
    self.bg:addChild(chd.bg, z)
    self.mapGridController:addBuilding(chd)
end
--先清理map 再remove
function MoveMap:removeBuilding(chd)
    self.mapGridController:removeBuilding(chd)
    self.bg:removeChild(chd.bg, true)
end

