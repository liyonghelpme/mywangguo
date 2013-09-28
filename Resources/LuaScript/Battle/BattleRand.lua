--[[
    战斗使用自己的随机数产生器，可以保证在同样种子下的随机序列不会发生改变
    就用最简单的(a*n+b)%c生成序列即可
    因为只生成很小的数，所以c也很小；计算过程中的数不会超过int范围，因此应该也不会出现浮点误差
--]]

local a=4253
local b=7027
local c=9973
local d=0

if not BattleRand then
    BattleRand = {}
    
    function BattleRand.setSeed(s)
        d = s%c
        for i=1,10 do
            d = (a*d+b)%c
        end
    end
    
    local function randNext()
        d = (a*d+b)%c
        return d
    end
    
    --返回一个1到max的随机值；因为是lua所以不从0开始
    function BattleRand.random(max)
        return randNext()%max+1
    end
    
    --返回一个从min到max的随机值，闭区间
    function BattleRand.randomBetween(min, max)
        return min-1+BattleRand.random(max-min+1)
    end
end
