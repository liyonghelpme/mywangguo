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
        self.gridLayer = CCLayer:create()
        self.bg:addChild(self.gridLayer)
        for k, v in pairs(self.mapGridController.mapDict) do
            local x = math.floor(k/10000)
            local y = k%10000
            local p = setBuildMap({1, 1, x, y})
            local sp = setAnchor(setPos(setSize(addSprite(self.gridLayer, "images/red2.png"), {SIZEX, SIZEY}), p), {0.5, 0})
            local lab = ui.newTTFLabel({text=""..p[1].." "..p[2], size=100})
            sp:addChild(lab)
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
function MoveMap:checkCollision(build)
    local map = getBuildMap(build)
    local sx = map[1]
    local sy = map[2]
    local initX = map[3]
    local initY = map[4]

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
function MoveMap:removeBuilding(chd)
    self.bg:removeChild(chd.bg)
    self.mapGridController:removeBuilding(chd)
end

