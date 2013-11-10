MapGridController = class()
function MapGridController:ctor(scene)
    self.scene = scene
    self.mapDict = {}
    self.allBuildings = {}
    self.allSoldiers = {}
    self.solList = {}
    self.effectDict = {}
end

--掉落物品占用单个网格
function MapGridController:updateRxRyMap(rx, ry, obj)
end
function MapGridController:clearRxRyMap(rx, ry, obj)
end
function MapGridController:addSoldier(sol)
    self.allSoldiers[sol] = true
    --士兵当前不占用地面体积 建筑物可以摆放在士兵身上
    table.insert(self.solList, sol)
end
function MapGridController:removeSoldier(sol)
    self.allSoldiers[sol] = nil
    for k, v in ipairs(self.solList) do
        if v == sol then
            table.remove(self.solList, k)
            break
        end
    end
    print("remove sol", sol, sol.kind)
    removeSelf(sol.bg)
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
    if BattleLogic.inBattle then
        initX = map[3]
        initY = map[4]-2
        sx = map[1]+2
        sy = map[2]+2
    end

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
--战斗中绘制影响范围grid
--战斗中建筑物的影响范围大上一圈 但是 不能影响建筑物的布局
--effect range 和 建筑range
function MapGridController:updatePosMap(sizePos)
    local map = getPosMap(sizePos[1], sizePos[2], sizePos[3], sizePos[4])
    local sx = map[1]
    local sy = map[2]
    local initX = map[3]
    local initY = map[4]

    --不能行走的位置
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

    --不能放置的位置 影响范围
    if BattleLogic.inBattle then
        initX = map[3]
        initY = map[4]-2
        sx = map[1]+2
        sy = map[2]+2

        --同一个位置被多个交叉影响了那么就是影响力最大的放在最后
        for i=0, sx-1, 1 do
            local curX = initX+i
            local curY = initY+i
            for j=0, sy-1, 1 do
                local key = getMapKey(curX, curY)
                if BattleLogic.inBattle then
                    local vef = getDefault(self.effectDict, key, {})
                    --effectDict 只保存 影响范围
                    --mapDict 只保存 建筑物范围
                    table.insert(vef, {sizePos[5], 0, 0})
                end
                --self.mapDict[key] = v
                curX = curX-1
                curY = curY+1
            end
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

