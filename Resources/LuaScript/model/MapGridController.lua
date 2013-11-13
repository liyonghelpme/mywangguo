MapGridController = class()
function MapGridController:ctor(scene)
    self.scene = scene
    self.mapDict = {}
    self.allBuildings = {}
    self.allSoldiers = {}
    self.allEnvTile = {}
    self.solList = {}
end

--掉落物品占用单个网格
function MapGridController:updateRxRyMap(rx, ry, obj)
end
function MapGridController:clearRxRyMap(rx, ry, obj)
end
function MapGridController:addSoldier(sol)
    --暂时不用管理所有soldier信息
    self.allSoldiers[sol] = true
    --士兵当前不占用地面体积 建筑物可以摆放在士兵身上
    table.insert(self.solList, sol)
end
function MapGridController:removeSoldier(sol)
    self.allSoldiers[sol] = false
    for k, v in ipairs(self.solList) do
        if v == sol then
            table.remove(self.solList, k)
            break
        end
    end
    --不用删除node soldier自己删除自己的node
    --removeSelf(sol.bg)
end
--TODO
function MapGridController:removeTheseSol(t)
    local temp = {}
    for k, v in ipairs(self.allSoldiers) do
        if t[k.kind] > 0 then
            t[k.kind] = t[k.kind]-1
        end
    end
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
    self.scene:updateMapGrid()
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
    if chd.picName == 'build' then
        self.allBuildings[chd] = true
    else
        self.allEnvTile[chd] = true
    end
    self:updateMap(chd)
end
function MapGridController:removeBuilding(build)
    self:clearMap(build)
    self.allBuildings[build] = nil
    self.allEnvTile[build] = nil
end

