MapGridController = class()
function MapGridController:ctor(scene)
    self.scene = scene
    self.mapDict = {}
    self.allBuildings = {}
    self.allSoldiers = {}
end

--掉落物品占用单个网格
function MapGridController:updateRxRyMap(rx, ry, obj)
end
function MapGridController:clearRxRyMap(rx, ry, obj)
end
function MapGridController:addSoldier(sol)
end
function MapGridController:removeSoldier(sol)
end
function MapGridController:removeAllSoldiers()
end
function MapGridController:clearSolMap(sol)
end

--更新Map 更新建筑物数据
function MapGridController:updateMap(build)
    local px, py = build.bg:getPosition()
    return self:updatePosMap({build.sx, build.sy, px, py, build})
end
function MapGridController:clearMap(build)
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
            local v = getDefault(self.mapDict, key, {})
            removeMapEle(v, build)
            if #v == 0 then
                self.mapDict[key] = nil
            end
            --节约内存使用
            curX = curX-1
            curY = curY+1
        end
    end
end

function MapGridController:updatePosMap(sizePos)
    local map = getPosMap(sizePos[1], sizePos[2], sizePos[3], sizePos[4])
    local sx = map[1]
    local sy = map[2]
    local initX = map[3]
    local initY = map[4]

    for i=0, sx-1, 1 do
        local curX = initX+i
        local curY = initY+i
        for j=0, sy-1, 1 do
            local key = getMapKey(curX, curY)
            local v = getDefault(self.mapDict, key, {})
            table.insert(v, {sizePos[5], 1, 1})
            --self.mapDict[key] = v
            curX = curX-1
            curY = curY+1
        end
    end
    self.scene:updateMapGrid()
    return {initX, initY}
end


function MapGridController:addBuilding(chd)
    self.allBuildings[chd] = true
    self:updateMap(chd)
end
function MapGridController:removeBuilding(build)
    self:clearMap(build)
    self.allBuildings[build] = nil
end


