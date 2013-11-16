Logic = {}
Logic.name = "liyong"
Logic.uid = nil
Logic.resource = {silver=0, food=0, wood=0, stone=0}
function doGain(r)
    for k, v in pairs(r) do
        Logic.resource[k] = Logic.resource[k]+v
    end
end
Logic.paused = false
Logic.maxBid = 0
function getBid()
    Logic.maxBid = Logic.maxBid+1
    return Logic.maxBid
end

Logic.date = 0
--s 秒
--每周 1 分钟
--每个月 4周
--每年 12个月
function getDate(t)
    local w = math.floor(t/60)
    local m = math.floor(w/4)
    w = w%4
    local y = math.floor(m/12)
    m = m%12
    return y, m, w
end
function checkCost(c)
end
function doCost(c)
end
function doGain(g)
end


