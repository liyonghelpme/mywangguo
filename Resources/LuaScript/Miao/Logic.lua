Logic = {}
Logic.name = "liyong"
Logic.uid = nil
Logic.resource = {silver=1000, food=0, wood=0, stone=0}
Logic.battleTime = nil
Logic.battleSoldier = nil
Logic.buildings = {}
Logic.buildList = {}
Logic.people = {}
Logic.allPeople = {}

Logic.waitPeople = {}


function doGain(r)
    for k, v in pairs(r) do
        Logic.resource[k] = Logic.resource[k]+v
    end
end
Logic.paused = false
function setLogicPause(p)
    Logic.paused = p
    if Logic.paused then
        Event:sendMsg(EVENT_TYPE.PAUSE_GAME)
    else
        Event:sendMsg(EVENT_TYPE.CONTINUE_GAME)
    end
end

Logic.maxBid = 0
function getBid()
    Logic.maxBid = Logic.maxBid+1
    return Logic.maxBid
end

--60s 1 week
--4 week 1 month
--12 month 1 year
Logic.date = 720
Logic.story = 1
Logic.inNew = false
Logic.buyHouseYet = false
Logic.gotoHouse = false
Logic.checkFarm = false
Logic.newBuildYet = false
Logic.buyIt = false
Logic.getNewRegion = false
--s 秒
--每周 1 分钟
--每个月 4周
--每年 12个月
function getDate()
    local t = Logic.date
    local w = math.floor(t/10)
    local m = math.floor(w/4)
    w = w%4
    local y = math.floor(m/12)
    m = m%12
    return y+1, m+1, w+1
end
local function yearUpdate(diff)
    if not Logic.paused then
        Logic.date = Logic.date+diff
    end
end
Logic.yearHandler = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(yearUpdate, 1, false)

function checkCost(c)
end
function doCost(c)
    Logic.resource.silver = Logic.resource.silver-c
    Event:sendMsg(EVENT_TYPE.UPDATE_RESOURCE) 
end
function doGain(g)
    Logic.resource.silver = Logic.resource.silver+g
    Event:sendMsg(EVENT_TYPE.UPDATE_RESOURCE) 
end

--增加多彩文字支持
StoryWord = {
"服部家 参谋\n小明拜见!!",
"此地<0000ff雪隐之村>被数个的郡县分裂，互相争夺土地",
"服部家虽然刚刚成立，领地微小，但让我们以统一村落为目标努力吧！",
"有什么不明白的请随时从菜单中的<0000ff系统>里面选择<0000ff游戏方法>查看说明哦。",
"让我们先为追随你而来的村民建造住所吧。\n请选择菜单中的<0000ff建筑>!!",
}

GoodsName = {
    [1]={name="浊酒", food=1, wood=0, stone=0, price=6},
    [2]={name="白酒", food=2, wood=0, stone=0, price=13},
    [3]={name="素酒", food=2, wood=0, stone=1, price=37},
}

laborEffect = {
    [10]={time=-1},
    [20]={time=-1},
    [30]={product=1},
    [40]={time=-1},
    [50]={time=-1},
    [60]={product=1},
    [70]={time=-1},
    [80]={product=1},
    [90]={move=2},
    [100]={health=-1},
    [110]={time=-1},
    [120]={time=-1},
    [130]={health=-1},
    [140]={product=1},
--每增加10点 health都减少1
}
newEffect = {
}
function calEffect()
    newEffect[10] = laborEffect[10]
    for k = 20, 140, 10 do
        local la = newEffect[k-10]
        local cur = laborEffect[k]
        newEffect[k] = {time=(la.time or 0)+(cur.time or 0), product=(la.product or 0)+(cur.product or 0), move=(la.move or 0)+(cur.move or 0), health=(la.health or 0) +(cur.health or 0)}
    end
    --[[
    for k, v in pairs(newEffect) do
        print("newEffect", k, v)
        for nk, nv in pairs(v) do
            print(nk, nv)
        end
    end
    --]]
end
calEffect()
function getLaborEffect(l)
    --print("labor", l)
    --print("newEffect ", simple:encode(newEffect))
    if l < 10 then
        return {}
    elseif l < 150  then
        local d = math.floor(l/10)
        return newEffect[d*10]
    else
        local ll = math.floor((l-140)/10)
        local p = copyTable(newEffect[140])
        --最少1点
        p.health = -ll
        return p
    end

end

