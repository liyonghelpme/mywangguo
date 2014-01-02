Logic = {}
Logic.name = "liyong"
Logic.uid = nil
Logic.resource = {silver=10000, food=0, wood=0, stone=0, gold=10000}
Logic.battleTime = nil
Logic.battleSoldier = nil
Logic.buildings = {}
Logic.buildList = {}
Logic.people = {}
Logic.allPeople = {}

Logic.waitPeople = {}

--所有村民
Logic.farmPeople = {}

--all equip
Logic.equip = {}
Logic.allEquip = {}
Logic.allWeapon = {}
Logic.allHead = {}
Logic.allBody = {}
Logic.allSpe = {}

Logic.skill = {}
Logic.allSkill = {}

--持有武器的数量
Logic.holdNum = {}

--待研究的物品 类型 id
Logic.researchGoods = {{0, 2}, {0, 3}, {0, 4}}
--正在研究的物品
Logic.inResearch = nil

--已经研究的物品 商店可以购买
--默认割草镰刀
Logic.ownGoods = {{0, 1}, {0, 2}, {0, 28}, {0, 29}, {0, 47}, {0, 48}, {0, 67}, {0, 68}}



--初始化已经研究的物品
--研究结束更新
Logic.researchEquip = {}
function initResearchEquip()
    Logic.researchEquip = {}
    for k, v in ipairs(Logic.ownGoods) do
        if v[1] == 0 then
            Logic.researchEquip[v[2]] = true
        end
    end
end


--获得什么条件可以新增加的研究物品

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
    if type(c) == "table" then
        for k, v in pairs(c) do
            if Logic.resource[k] < v then
                return false
            end
        end
    else
        if Logic.resource.silver < c then
            return false
        end
    end
    return true
end
function doCost(c)
    if type(c) == 'table' then
        for k, v in pairs(c) do
            Logic.resource[k] = Logic.resource[k]-v
        end
    else
        Logic.resource.silver = Logic.resource.silver-c
    end
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

--不用了
GoodsName = {
    [1]={name="浊酒", food=1, wood=0, stone=0, price=6},
    [2]={name="白酒", food=2, wood=0, stone=0, price=13},
    [3]={name="素酒", food=2, wood=0, stone=1, price=37},

    [4]={name="饮料", food=1, wood=0, stone=0, price=20},
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

function changeEquip(id, num)
    Logic.holdNum[id] = (Logic.holdNum[id] or 0)+num
end

--实现升级属性提升机制
Logic.LevelCost = {
    0,
    200,
    270,
    380,
    470, 
    570,
    680,
    800,
    930,
    1070,
    1220, 
    1380,
    1550,
    1730,
    1920,
    2120,
    2330,
    2550,
    2780,
    3020,
    3270,
    3630,
    3900,
    4180,
    4470,
    4770,
    5080,
    5400,
    5730,
    6070,
}

--士兵初始数量 升级数量 价格
Logic.IncCost = {
    {50, 20, 200},
    {30, 20, 300},
    {20, 20, 400},
    {10, 20, 500},
}
--等级 数量
Logic.soldiers = {
    [1] = {1, 50},
    [2] = {0, 0},
    [3] = {0, 0},
    [4] = {0, 0},
}

--每种商品卖出的数量
--如果条件满足了 就显示可以卖出的物品了
--判断这个商品的 下一个商品是否已经满足条件可以卖出了
--判断这个商品所在商店类型 得到列表 检查是否 拥有
--保存和加载
Logic.goodsSellNum = {}
function updateSellNum(k, n)
    local v = getDefault(Logic.goodsSellNum, k, 0)
    Logic.goodsSellNum[k] = v+n
    local me = GoodsName[k]
    local ng = GoodsName[k+1]
    if me.store == ng.store then
        local find = false
        for tk, v in ipairs(Logic.ownGoods) do
            if v[1] == 1 and v[2] == (k+1) then
                find = true
                break
            end
        end
        if not find then
            for tk, v in ipairs(Logic.researchGoods) do
                --print(v[1], v[2], 1, k+1)
                if v[1] == 1 and v[2] == (k+1) then
                    find = true
                    break
                end
            end
        end
        print("researchGoods", k+1)
        print(simple.encode(Logic.researchGoods))
        print(simple.encode(Logic.ownGoods))
        --研究对话框 里面显示这个物品
        if not find then
            table.insert(Logic.researchGoods, {1, k+1})
            addBanner(ng.name.."可以研究了")
        end
    end
    
end
function checkResearchYet(k, v)
    for tk, tv in ipairs(Logic.ownGoods) do
        if tv[1] == k and tv[2] == v then
            return true
        end
    end
    return false
end

--当前可以研究这个物品 和 当前的研究列表 inResearch 和 researchGoods
--当前拥有的商品  保存和加载
--Logic.curOwnGoods = {}

--Logic.goods = {}

--农田类建筑物 IsStore == 2
function getAllMatNum()
    local allBuild = global.director.curScene.page.buildLayer.mapGridController.allBuildings
    local temp = {food=0, wood=0, stone=0}
    for k, v in pairs(allBuild) do
        if k.id == 2 then
            temp.food = temp.food + k.workNum
        end
    end
    return temp
end

Logic.inSell = {
    food=true,
    wood=true,
    stone=true,
}
