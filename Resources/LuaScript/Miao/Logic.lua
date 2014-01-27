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
Logic.researchGoods = {
    {0, 2}, {0, 3}, {0, 4},
}
--正在研究的物品
Logic.inResearch = nil

--已经研究的物品 商店可以购买
--默认割草镰刀
--0 装备 
--1 商店卖出物品
--[[
--]]
Logic.ownGoods = {
    {0, 1}, {0, 2}, {0, 28}, {0, 29}, {0, 47}, {0, 48}, {0, 67}, {0, 68},
}
Logic.allOwnBuild = {

{2, 1}, {2, 2}, {2, 4}, {2, 5}, {2, 11}, {2, 15},
{2, 19}, {2, 12},
{2, 28}, {2, 29},

    {2, 6}, {2, 9}, {2, 7}, {2, 10}, {2, 13}, {2, 16}, {2, 17}, {2, 18},
    {2, 8}, {2, 14}, 
    {2, 24}, {2, 25}, {2, 26}, {2, 27}, {2, 30}, {2, 31},

}

--初始化装饰物 到 商店中
function getBuyableBuild()
    local temp = {}
    for k, v in ipairs(Logic.allOwnBuild) do
        if Logic.buildings[v[2]].buyable == 1 then
            table.insert(temp, v)
        end
    end
    return temp
end

--建筑物的数量
--在商店里面购买这种建筑物
--保存游戏
Logic.buildNum = {
    [24]=2,
    [28]=2,
    [29]=2,
}

function changeBuildNum(id, n)
    Logic.buildNum[id] = (Logic.buildNum[id] or 0)+n
end

function getBuyPrice(id)
    local t = getTotalBuildNum(id)
    local bdata = Logic.buildings[id]
    local add = math.floor(bdata.buyPrice*0.5)
    return bdata.buyPrice+add*t
end

function getTotalBuildNum(id)
    return Logic.buildNum[id] or 0
end
function getAvaBuildNum(id)
    local total = Logic.buildNum[id] or 0
    local allB = global.director.curScene.page.buildLayer.mapGridController.allBuildings
    print("getAvaBuildNum", id, allB)
    for k, v in pairs(allB) do
        --print("k.id", k.id)
        if k.id == id then
            total = total-1
        end
    end
    return total
end

--某些有数量限制的装饰物的购买数量 * n 
--只有研究 从商店购买 之后 才能使用
--树木 和 矿坑也有数量限制
Logic.buildBuyNum = {}


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
--
function convertTimeToWeek(t)
    local w = math.floor(t/10)
    local m = math.floor(w/4)
    w = w%4
    local y = math.floor(m/12)
    m = m%12
    return y+1, m+1, w+1
end
function getDate()
    local t = Logic.date
    return convertTimeToWeek(t)
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
--等级 数量 当前训练士兵的阶梯
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
    local selNum = Logic.goodsSellNum[k]
    local me = GoodsName[k]
    local ng = GoodsName[k+1]
    --最后一个商品
    if ng ~= nil and me.store == ng.store and selNum >= ng.condition then
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
        elseif k.id == 19 then
            temp.wood = temp.wood + k.workNum
        elseif k.id == 12 then
            temp.stone = temp.stone + k.workNum
        end
    end
    return temp
end

Logic.inSell = {
    food=true,
    wood=true,
    stone=true,
}

SoldierAbility = {
    {attack=40, defense=30, health=30},
    {attack=35, defense=10, health=15},
    {attack=50, defense=10, health=10},
    {attack=40, defense=30, health=30},
}
IncEffect = {
    {attack=2, defense=1, health=1},
    {attack=3, defense=0, health=0},
    {attack=4, defense=0, health=1},
    {attack=4, defense=1, health=1},
}

--计算单个士兵能力
--计算增益效果
--计算多个士兵在增益下的实际能力

function getSolAbility(kind, num, total)
    local addEffect = math.floor(total/50)
    local se = SoldierAbility[kind]
    local ae = IncEffect[kind]
    local temp = {}
    temp.attack = se.attack+ae.attack*addEffect
    temp.defense = se.defense+ae.defense*addEffect
    temp.health = se.health+ae.health*addEffect

    temp.attack = temp.attack*num
    temp.defense = temp.defense*num
    temp.health = temp.health*num
    return temp
end
--根据moveTime 计算位置 
--根据 path 和 curPoint 计算方向
--test CatData
--Logic.catData = {pos={1186, 1227}, path={1, 2, 9}, curPoint=1, moveTime=2, cid=9}
Logic.catData = nil

--计算合战剩余时间
function getLeftTime()
    if Logic.catData ~= nil then
        local path = Logic.catData.path
        if Logic.catData.totalTime == nil then
            local ttime = {}
            for k, v in ipairs(path) do
                if k > 1 then
                    local lastPos = path[k-1]
                    lastPos = {MapNode[lastPos][1], MapNode[lastPos][2]}
                    local xy = v
                    xy = {MapNode[xy][1], MapNode[xy][2]}
                    local dis = distance(lastPos, xy)/CAT_SPEED
                    table.insert(ttime, dis)
                end
            end
            Logic.catData.totalTime = ttime
            print("path need time", simple.encode(ttime))
        end
        --后面路段的时间
        local tt = 0
        local ttime = Logic.catData.totalTime
        for k, v in ipairs(Logic.catData.totalTime) do
            if k >= Logic.catData.curPoint then
                print("add Time", tt, k, v)
                tt = tt+v
            end
        end
        print("before time", tt, Logic.catData.curPoint)
        local cp = Logic.catData.curPoint
        local mt = Logic.catData.moveTime
        --当前路段剩余的时间
        if Logic.catData.curPoint > 1 and Logic.catData.curPoint <= #path then
            print("tt is", tt, ttime[cp-1], mt)
            tt = tt+Logic.catData.moveTime
        end
        print("after time", tt, Logic.catData.moveTime)
        print("tttime", simple.encode(ttime))
        return tt
    end
    return 0
end


--保存挑战数据
Logic.challengeNum = {
    10, 10, 0, 0
}
Logic.challengeCity = nil

--保存每个城市的士兵发展的数据
--城市士兵数据
--基础数据 和城市发展时间 以及城市是否出来过
--cid = [0, 0, 0, 0]
Logic.cityNum = {}

--占领的城市
Logic.ownCity = {}

--退出Fight 场景之后 Map 上面提示奖励
function winCity()
    print("winCity of scene", Logic.challengeCity)
    if Logic.challengeCity ~= nil then
        Logic.ownCity[Logic.challengeCity] = true
    end
    --table.insert(Logic.ownCity, Logic.challengeCity)
end
function clearFight()
    Logic.catData = nil
end

function initCityData()
    if not MapDataInitYet then
        --local tex = CCTextureCache:sharedTextureCache():addImage("bigMap.png")
        local sz = {3072, 2304}
        --getContentSize(tex)
        MapDataInitYet = true
        MapNode = tableToDict(MapNode)
        for k, v in pairs(MapNode) do
            print("MapNode is", k, v)
            v[2] = sz[2]-v[2] 
            --x y  city or path  kind(mainCity village fightPoint)
            if v[4] ~= nil then
                local md = 9999
                local minNode
                for ck, cv in ipairs(MapCoord) do
                    local dis = math.abs(v[1]-cv[1])+math.abs(v[2]-cv[2])
                    if dis < md then
                        md = dis
                        minNode = cv
                    end
                end
                v[1] = minNode[1]
                v[2] = minNode[2]
                --realId cityData 中使用的Id
                v[5] = minNode[3] 
            end
        end
        print("allNode")
        print(simple.encode(MapNode))
        MapEdge = tableToDict(MapEdge)
    end
end

function getPeopleSkill(id, level)
    local pdata = Logic.people[id]
    if pdata.levelSkill ~= '[]' then
        local ls = simple.decode(pdata.levelSkill)
        for i=#ls, 1, -1 do
            if ls[i][1] <= (level+1) then
                return ls[i][2]        
            end
        end
        --升到一定等级才能开启新的技能
        return 0
    end
    return pdata.skill
end
function getSkillIcon(sid)
    local sdata = Logic.allSkill[sid]
    if sdata.hasLevel > 0 then
        return sid-sdata.hasLevel+1
    else
        return sid
    end
end

--当前可以启用的村民
Logic.ownPeople = {11, 20, 21, 22, 23}
--
Logic.ownTech = {
sword=0,
spear=0,
magic=0,
bow=0,
armour=0,
ninja=0,
}
--每个城市奖励的物品
Logic.cityGoods = {}
