MoveMap = class()
function MoveMap:ctor(sc)
    self.scene = sc
end
function MoveMap:enterScene()
end
function MoveMap:exitScene()
end
--显示建筑物网格
function MoveMap:updateMapGrid()
    if DEBUG then
        removeSelf(self.gridLayer)
        self.gridLayer = CCSpriteBatchNode:create("white2.png")
        self.bg:addChild(self.gridLayer)
        for k, v in pairs(self.mapGridController.mapDict) do
            local x = math.floor(k/10000)
            local y = k%10000
            local p = setBuildMap({1, 1, x, y})
            local sp = setColor(setAnchor(setPos(setSize(addSprite(self.gridLayer, "white2.png"), {SIZEX*2, SIZEY*2}), p), {0.5, 0}), {255, 0, 0})
            --print("show MapDict", x, y)

            --local lab = ui.newTTFLabel({text=""..p[1].." "..p[2], size=100})
            --sp:addChild(lab)
        end
    end
end
--寻路算法的 node
function MoveMap:updateCells(cells, bcells)
    if DEBUG then
        removeSelf(self.cellLayer)
        self.cellLayer = CCSpriteBatchNode:create("white2.png")
        self.bg:addChild(self.cellLayer)
        --gScore hScore fScore
        --openList
        --closedList
        --key:      normal coordinate
        --value:    parent gScore hScore fScore
        --正在搜索的路径块
        for k, v in pairs(cells) do
            local x, y = getXY(k)
            --local cx, cy = normalToCartesian(x, y)
            local cxy = setBuildMap({1, 1, x, y})
            local sp = setColor(setAnchor(setPos(setSize(addSprite(self.cellLayer, "white2.png"), {SIZEX, SIZEY}), cxy), {0.5, 0}), {0, 128, 0})
        end
        --路径网格
        --大地图上面的路径块
        for k, v in pairs(bcells) do
            local x, y = getXY(k)
            --local cx, cy = normalToCartesian(x, y)
            local cxy = setBuildMap({1, 1, x, y})
            local sp = setColor(setAnchor(setPos(setSize(addSprite(self.cellLayer, "white2.png"), {SIZEX, SIZEY}), cxy), {0.5, 0}), {128, 0, 0})
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
--先拆除道路 再铺设道路
--返回冲突的建筑物
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
                if v[#v][1] ~= build then
                    return v[#v][1]
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
function MoveMap:adjustLayer(chd)
    chd.bg:retain()
    removeSelf(chd.bg)
    if chd.picName == 'build' or chd.picName == 'fence' then
        if chd.id == 2 then
            self.farmLayer:addChild(chd.bg)
        --斜坡
        elseif chd.data.kind == 1 then
            self.roadLayer:addChild(chd.bg)
        else
            self.buildingLayer:addChild(chd.bg)
        end
    elseif chd.picName == 'remove' then
        self.removeLayer:addChild(chd.bg)
    elseif chd.picName == 'move' then
        self.removeLayer:addChild(chd.bg)
    elseif chd.picName == 't' then
        self.roadLayer:addChild(chd.bg)
    else
        self.terrian:addChild(chd.bg)
    end
    chd.bg:release()
end
function MoveMap:fastAddBuilding(chd, z)
    self.buildingLayer:addChild(chd.bg, z)
    self.mapGridController:addBuilding(chd)
end
function MoveMap:addBuilding(chd, z)
    print('MoveMap addBuilding', chd, z)
    if chd.picName == 'build' or chd.picName == 'fence' then
        if chd.id == 2 then
            self.farmLayer:addChild(chd.bg, z)
        --斜坡
        elseif chd.data.kind == 1 then
            self.roadLayer:addChild(chd.bg, z)
        else
            self.buildingLayer:addChild(chd.bg, z)
        end
    elseif chd.picName == 'remove' then
        self.removeLayer:addChild(chd.bg, z)
    elseif chd.picName == 'move' then
        self.removeLayer:addChild(chd.bg, z)
    elseif chd.picName == 't' then
        self.roadLayer:addChild(chd.bg, z)
    else
        self.terrian:addChild(chd.bg, z)
    end
    self.mapGridController:addBuilding(chd)
end
function MoveMap:removeBuilding(chd)
    --self.bg:removeChild(chd.bg, true)
    --先清除 map 数据 再移除 建筑物view 因为需要view 来获取位置
    self.mapGridController:removeBuilding(chd)
    removeSelf(chd.bg)
end

