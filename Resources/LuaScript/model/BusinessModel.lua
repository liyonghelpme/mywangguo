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

