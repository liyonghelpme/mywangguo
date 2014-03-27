Worker = class(FuncPeople)
function Worker:checkWork(k)
    local ret = false
    --两种情况 给 其它工厂运输农作物 丰收状态 
    --生产农作物
    --先不允许并行处理
    if k.picName == 'build' and k.owner == nil then
        print("checkWork", k.id)
        if k.id == 2 then
            ret = (k.state == BUILD_STATE.FREE and k.workNum < 10)
            --[[
            if not ret then
            --可以运送到工厂了 寻找最近的工厂 拉着拉着 没有工厂了怎么办？ 到目标地发现建筑物不在了则停止
                ret = (k.state == BUILD_STATE.FREE and k.workNum >= 10)
            end
            --]]
            --一条链路
        --商店需要放置物品 food farm
        elseif k.id == 6 then
            print('try goto store')
            ret = k.state == BUILD_STATE.FREE and k.workNum == 0
        --去工厂生产产品 运送粮食到工厂 或者 到工厂生产产品
        --运送物资到工厂 如果工厂 的 stone > 0 就可以开始生产了  
        --或者将生产好的产品运送到 商店
        --没有直接去工厂的说法
        --采矿场
        elseif k.id == 12 then
            print("mine stone", k.stone)
            ret = k.stone < 10 
            --运送矿石到 商店 不同类型商店经营物品不同
            if not ret then
                ret = k.stone >= 10
            end
        elseif k.id == 11 then
            --ret = k.stone ~= nil and k.stone > 0 
        --灯塔可以生产
        elseif k.id == 14 then
            ret = k.workNum < 10
        end
        --工厂 空闲状态 没有粮食储备 且没有其它用户 
    end
    return ret
end

