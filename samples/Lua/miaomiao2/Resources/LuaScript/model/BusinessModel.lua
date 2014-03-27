function getProduction(level)
    local mData = getGain(GOODS_KIND.MINE_PRODUCTION, level)
    return mData
end
function getCurLevelBuildNum(id, level)
    local bData = getData(GOODS_KIND.BUILD, id)
    local count = 0
    for k, v in pairs(global.user.buildings) do
        if v.kind == id then
            count = count+1
        end
    end
    return count
end

function getBuildEnableNum(id)
    local bData = getData(GOODS_KIND.BUILD, id)
    local level = global.user:getValue("level")
    if bData.hasNum == 0 then
        return {999999, 0, 0}
    end

    local num = bData.initNum+math.floor(level/bData.numLevel)
    local upBound = 0
    if num >= #bData.numCost[1] then
        upBound = 1
    end
    --建筑只有一个档次 
    --这个档次拥有不同数量建筑时， 新的建筑购买价格不同
    return {math.min(num, #bData.numCost[1]), upBound, 1}
    --最大限制 当前拥有的建筑数量已经达到总数上限 总量是否存在限制 
end
function getCurBuildNum(id)
    local bData = getData(GOODS_KIND.BUILD, id)
    local count = 0
    for k, v in pairs(global.user.buildings) do
        if v.kind == id then
            count = count+1
        end
    end
    return count
end
--限制建筑数量明确的目标是 为了玩家合理的利用有限的建筑达到最大的收益
function checkBuildNum(id)
    local curNum = getCurBuildNum(id)
    local enableNum = getBuildEnableNum(id)
    --当前允许的建筑数量是否超过拥有的数量
    --是否已经达到可以购买数量的上限
    --是否存在上限限制
    return {enableNum[1]>curNum, enableNum[2], enableNum[3]}
end
function getNextBuildNum(id)
    local bData = getData(GOODS_KIND.BUILD, id)
    local bLevel = bData.numLevel
    local level = global.user:getValue("level")
    local need = math.floor((level+bLevel)/bLevel)
    return need+bLevel
end
