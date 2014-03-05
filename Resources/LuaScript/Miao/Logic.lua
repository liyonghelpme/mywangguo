Logic = {}
Logic.name = "liyong"
Logic.uid = nil
Logic.resource = {silver=10000000, food=0, wood=0, stone=0, gold=10000000}
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
--购买的装备数量 = 装备的 和 持有的
Logic.buyNum = {}

--rpc callback

--待研究的物品 类型 id
--0 装备 物品id
Logic.researchGoods = {
    --{0, 2}, {0, 3}, {0, 11},
}

--当前卖出的建筑物
Logic.sellBuild = {}

--正在研究的物品
--researchGoodsNum time
Logic.inResearch = nil

--已经研究的物品 商店可以购买
--默认割草镰刀
--0 装备 
--1 商店卖出物品
--[[
--]]
--商店可以直接购买的物品
--包括装备 和 其它
--各种装备
Logic.ownGoods = {
    --{0, 1}, 
    {0, 2}, {0, 3}, {0, 11},
    {0, 28}, {0, 30}, {0, 31},
    {0, 47}, 
    --{0, 48}, 
    {0, 59},
    {0, 67}, 
    --{0, 68},
}
--[[
Logic.allOwnBuild = {

{2, 1}, {2, 2}, {2, 4}, {2, 5}, {2, 11}, {2, 15},
{2, 19}, {2, 12},
{2, 28}, {2, 29},

    {2, 6}, {2, 9}, {2, 7}, {2, 10}, {2, 13}, {2, 16}, {2, 17}, {2, 18},
    {2, 8}, {2, 14}, 
    {2, 24}, {2, 25}, {2, 26}, {2, 27}, {2, 30}, {2, 31},

}
--]]

--初始化装饰物 到 商店中
function getBuyableBuild()
    local temp = {}
    for k, v in ipairs(Logic.ownBuild) do
        if Logic.buildings[v].buyable == 1 then
            table.insert(temp, v)
        end
    end
    return temp
end


--建筑物的数量
--在商店里面购买这种建筑物
--保存游戏
--树木的 数量 和 坑道的数量
--树木根据 land数量来增加
Logic.buildNum = {
    [24]=0,
    [28]=0,
    [29]=0,
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
--树木属于 operate 
function getAvaBuildNum(id)
    local total = Logic.buildNum[id] or 0
    local allB = global.director.curScene.page.buildLayer.mapGridController.allBuildings
    print("getAvaBuildNum", id, allB)
    print("total is", total)
    for k, v in pairs(allB) do
        --print("k.id", k.id)
        if k.id == id and k.operate then
            print("such build", k.bid, k.id)
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
--商店显示 hold的装备 不仅仅是 research的装备 只hold的装备不能购买
Logic.researchEquip = {}
function initResearchEquip()
    Logic.researchEquip = {}
    for k, v in ipairs(Logic.ownGoods) do
        if v[1] == 0 then
            Logic.researchEquip[v[2]] = true
        end
    end
end

function storeAddNewEquip(id)
    table.insert(Logic.ownGoods, {0, id})
    initResearchEquip()
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

function changeBuyNum(id, num)
    Logic.buyNum[id] = (Logic.buyNum[id] or 0)+num
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

--[[
SoldierAbility = {
    {attack=40, defense=30, health=30},
    {attack=35, defense=10, health=15},
    {attack=50, defense=10, health=10},
    {attack=40, defense=30, health=30},
}
--]]

--health/(defense*3+health)

--基本上是 生命值数量 起作用
SoldierAbility = {
    {attack=3, defense=4, health=12},
    {attack=2, defense=2, health=6},
    {attack=4, defense=2, health=6},
    {attack=3, defense=4, health=12},
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
    --防御力不会乘 防御力乘 起来 因为 防御力和 生命值是加法关系
    temp.defense = temp.defense*num
    temp.health = temp.health*num
    return temp
end
--根据moveTime 计算位置 
--根据 path 和 curPoint 计算方向
--test CatData
--Logic.catData = {pos={1186, 1227}, path={1, 2, 9}, curPoint=1, moveTime=2, cid=9}
--
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
--挑战竞技场胜利
Logic.winArena = false

--占领的村落
Logic.ownVillage = {}

--退出Fight 场景之后 Map 上面提示奖励
function winCity()
    print("winCity of scene", Logic.challengeCity)
    if Logic.challengeCity ~= nil then
        --竞技场
        --挑战 竞技场 kind = 0
        if type(Logic.challengeCity) == 'table' and Logic.challengeCity.kind == 0 then
            Logic.winArena = true
        else
            Logic.ownCity[Logic.challengeCity] = true
        end
    end
    --table.insert(Logic.ownCity, Logic.challengeCity)
end
function clearFight()
    Logic.catData = nil
end

function initCityData()
    if not MapDataInitYet then
        --整个地图大小
        local sz = {3072, 2304}
        --getContentSize(tex)
        MapDataInitYet = true
        MapNode = tableToDict(MapNode)
        --匹配MapCoord 城堡坐标 和 MapNode 的坐标进行重合处理
        --MapCoord 最靠近 MapNode 坐标之后 将MapCoord 坐标设置成 MapNode 的坐标
        for k, v in pairs(MapNode) do
            print("MapNode is", k, v)
            v[2] = sz[2]-v[2] 
            --x y  city or path  kind(mainCity village fightPoint)
            if v[4] ~= nil and v[4] ~= 4 then
                local md = 9999
                local minNode
                for ck, cv in ipairs(MapCoord) do
                    local dis = math.abs(v[1]-cv[1])+math.abs(v[2]-cv[2])
                    if dis < md then
                        md = dis
                        minNode = cv
                    end
                end
                --x坐标 y 坐标 路径还是城堡节点 kind城堡类型 realId 实际对应的城堡的Id
                v[1] = minNode[1]
                v[2] = minNode[2]
                --realId cityData 中使用的Id
                v[5] = minNode[3] 
            --村落坐标对应
            elseif v[4] == 4 then
                local md = 9999
                local minNode
                for ck, cv in ipairs(VillageCoord) do
                    local dis = math.abs(v[1]-cv[1])+math.abs(v[2]-cv[2])
                    if dis < md then
                        md = dis
                        minNode = cv
                    end
                end
                --x坐标 y 坐标 路径还是城堡节点 kind城堡类型 realId 实际对应的城堡的Id
                v[1] = minNode[1]
                v[2] = minNode[2]
                --realId cityData 中使用的Id
                v[5] = minNode[3] 
            end
        end
        print("allNode")
        print(simple.encode(MapNode))
        MapEdge = tableToDict(MapEdge)
        
        --村落坐标
        local vc = {}
        for k, v in ipairs(VillageCoord) do
            vc[v[3]] = v
        end
        VillageCoord = vc
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
--Logic.ownPeople = {11, 20, 21, 22, 23}
--Logic.ownPeople = {14, 18, 20, 23}
Logic.ownPeople = {}

Logic.ownTech = {
sword=0,
spear=0,
magic=0,
bow=0,
armour=0,
ninja=0,
}
Logic.techId = {
sword=40,
spear=41,
magic=42,
bow=43,
armour=44,
ninja=45,
}

--每个城市奖励的物品
Logic.cityGoods = {}
--技术等级对应的物品
--sword1 ----> goodsList 
--sword2 ----> goodsList
Logic.techGoods = {
}

function checkTechNewEquip(techName, techLevel)
    local temp = {}
    for k, v in pairs(Logic.equip) do
        local gm = v.getMethod
        local findMatch = false
        local otherOk = nil
        --需要这个新的 技术 满足了
        --并且其它条件已经满足了

        for gk, gv in ipairs(gm) do
            if techName == gv[1] and techLevel == gv[2] then
                findMatch = true
            elseif Logic.ownTech[gv[1]] == gv[2] then
            else
                otherOk = false
            end
        end
        --匹配了技术 并且 其它技术满足条件
        --新增的 装备
        if findMatch and otherOk ~= false then
            table.insert(temp, v.id)
        end
    end
    print("new Equip is", simple.encode(temp))
    return temp
end



--竞技场兵力
Logic.arena = {
    {48, 31, 0, 0},
    {65, 43, 0, 0},
    {72, 60, 5, 1},
    {85, 68, 4, 11},
    {105, 76, 4, 13},
}

--根据当前占领的城堡数量 以及当前 占领的村落数量
--ownVillage 和 ownCity分离开来
Logic.arenaLevel = 1
--挑战获得的物品包括
--奖励silver 500 + 50
--kind: equip goods gold
--id
--number
require "arenaData.lua"
Logic.arenaReward = {}
for k, v in ipairs(ArenaReward) do
    Logic.arenaReward[v[1]] = v[2]
end

function getArenaReward()
end

--参加合战士兵数量
Logic.fightNum = 4

--不同条件
Logic.ownBuild = {
    1, 2, 15, 
    4, 
}

Logic.lastArenaTime = 0

Logic.landBook = 0
--参展英雄id 列表
--{id=xx, pos=xx}
Logic.attendHero = {
}

Logic.curVillage = 1
--开放的地图
Logic.openMap = {}
Logic.gameStage = 1
Logic.showMapYet = false

--gameStage
--新手村
--开始stage2 获得一块土地证书
--开启左边
--开启全部
--开启右边
Logic.stageRange = {
    {11, 17}, 
    {5, 11},
    {0, 11},
    {0, 0},
    {5, 0},
}

--村落能量
--[[
Logic.villagePower = {
    {{2, 0, 0, 0}, },
    {10, 0, 0, 0},
    {7, 4, 0, 0},
}
--]]
Logic.villagePower = {
    {{{attack=50, health=80, defense=0}, {attack=3, health=22, defense=0}}, {}, {}, {}},
    {{{attack=5, health=30, defense=0},{attack=5, health=30, defense=0},{attack=5, health=30, defense=0},{attack=5, health=30, defense=0},{attack=5, health=30, defense=0},{attack=5, health=30, defense=0},{attack=5, health=30, defense=0},{attack=5, health=30, defense=0},{attack=5, health=30, defense=0},{attack=50, health=50, defense=0}}, {}, {}, {}},
    {{{attack=10, health=40, defense=0}, {attack=10, health=40, defense=0},  {attack=10, health=40, defense=0},{attack=10, health=40, defense=0},{attack=10, health=40, defense=0},{attack=10, health=40, defense=0},{attack=50, health=50, defense=0}}, 
    {{attack=5, health=46, defense=0}, {attack=5, health=46, defense=0}, {attack=5, health=46, defense=0},{attack=5, health=46, defense=0}}, {}, {}},
}

Logic.newVillage = false

--几个村落中心
Logic.villageCenter = {
    {13, 24},
    {12, 19},
    {17, 19},
}

Logic.stage2Center = {
    {15, 13},
    {7, 22},
    {7, 17},
    {8, 13},
}

Logic.stage2Block = {2, 3, 5, 6}
Logic.extendBlock = {11, 12}
Logic.extendBlock2 = {14, 15}
Logic.lastBlock = {13}
Logic.extendCenter = {
    {2, 22},
    {1, 13},
}
Logic.extendCenter2 = {
    {8, 6},
    {15, 5},
}
Logic.lastCenter = {
    {2, 5},
}


Logic.villageBlock = {8, 10, 9}


--当前显示的邻接land 而不是统一land
--扩展陆地显示的情况
Logic.showLand = {
}


Logic.initYet = false
local function initData(rep, param)
    initCityData()
    print("initData", rep, param)

    local u = CCUserDefault:sharedUserDefault()
    local r = u:getStringForKey("resource")
    if r ~= "" then
        Logic.resource = simple.decode(r)
    end
    local r = u:getStringForKey("holdNum")
    if r ~= "" then
        Logic.holdNum = tableToDict(simple.decode(r))
        print("decode holdNum", simple.encode(Logic.holdNum))
    end
    local r = u:getStringForKey("researchData")
    if r ~= "" then
        local rd = simple.decode(r)
        Logic.researchGoods = rd.researchGoods
        Logic.inResearch = rd.inResearch
        Logic.ownGoods = rd.ownGoods
    end
    initResearchEquip() 

    local r = u:getStringForKey("inSell")
    if r ~= "" then
        local rd = simple.decode(r)
        Logic.inSell = rd
    end

    local r = u:getStringForKey("buildNum")
    if r ~= "" then
        local rd = tableToDict(simple.decode(r))
        Logic.buildNum = rd
    end
    local r = u:getStringForKey("ownCity")
    if r ~= "" then
        print("ownCity", r)
        local rd = dictKeyToNum(simple.decode(r))
        Logic.ownCity = rd
    end
    local r = u:getStringForKey("catData")
    if r ~= "" and r ~= "null" then
        print("catData", r)
        local rd = simple.decode(r)
        Logic.catData = rd
        print("encode catData", simple.encode(Logic.catData))
    else
        Logic.catData = nil
    end

    local r = u:getStringForKey("ownPeople")
    if r ~= "" and r ~= "null" then
        local rd = simple.decode(r)
        Logic.ownPeople = rd
    end

    local r = u:getStringForKey('ownBuild')
    if r ~= "" and r ~= "null" then
        local rd = simple.decode(r)
        Logic.ownBuild = rd
    end

    local r = u:getStringForKey('fightNum')
    if r ~= "" and r ~= "null" then
        local rd = simple.decode(r)
        Logic.fightNum = rd
    end

    local r = u:getStringForKey('arenaLevel')
    if r ~= "" and r ~= "null" then
        local rd = simple.decode(r)
        Logic.arenaLevel = rd
    end

    local r = u:getStringForKey('ownTech')
    if r ~= "" and r ~= "null" then
        local rd = simple.decode(r)
        Logic.ownTech = rd
    end

    local r = u:getStringForKey('lastArenaTime')
    if r ~= "" and r ~= "null" then
        local rd = simple.decode(r)
        Logic.lastArenaTime = rd
    end

    local r = u:getStringForKey('date')
    if r ~= "" and r ~= "null" then
        local rd = simple.decode(r)
        Logic.date = rd
    end

    local r = u:getStringForKey('landBook')
    if r ~= "" and r ~= "null" then
        local rd = simple.decode(r)
        Logic.landBook = rd
    end

    local r = u:getStringForKey("soldiers")
    if r ~= "" then
        local rd = simple.decode(r)
        Logic.soldiers = rd
    end

    Logic.cityGoods = {}
    CityData = {}
    for k, v in ipairs(rep.cityData) do
        v.goods = simple.decode(v.goods)
        Logic.cityGoods[v.id] = v
        table.insert(CityData, {v.foot, v.arrow, v.magic, v.cav})
    end
    print("cityGoods", #Logic.cityGoods)


    GoodsName = {}
    for k, v in ipairs(rep.goods) do
        GoodsName[v.id] = v
    end

    Logic.buildings = {}
    for k, v in ipairs(rep.build) do
        v.goodsList = simple.decode(v.goodsList)
        Logic.buildings[v.id] = v 
    end

    Logic.buildList = {}
    for k, v in ipairs(rep.build) do
        if v.deleted == 0 then
            table.insert(Logic.buildList, v)
        end
    end
    --城堡
    Logic.castlePeople = {}
    --村庄
    Logic.villagePeople = {}
    --新手村
    Logic.newPeople = {}

    Logic.people = {}
    Logic.allPeople = rep.people
    print("allPeople", #Logic.allPeople)
    for k, v in ipairs(rep.people) do
        Logic.people[v.id] = v
        if v.cityKind == 0 then
            local df = getDefault(Logic.castlePeople, v.appear, {} )
            table.insert(df, v.id)
        elseif v.cityKind == 1 then
            local df = getDefault(Logic.villagePeople, v.appear, {} )
            table.insert(df, v.id)
        else
            local df = getDefault(Logic.newPeople, v.appear, {} )
            table.insert(df, v.id)
        end
    end
    
    Logic.allEquip = rep.equip
    for k, v in ipairs(rep.equip) do
        Logic.equip[v.id] = v
        if v.kind == 0 then
            table.insert(Logic.allWeapon, v)
        elseif v.kind == 1 then
            table.insert(Logic.allHead, v)
        elseif v.kind == 2 then
            table.insert(Logic.allBody, v)
        elseif v.kind == 3 then
            table.insert(Logic.allSpe, v)
        end
        v.getMethod = simple.decode(v.getMethod)
    end

    Logic.allSkill = rep.skill
    for k, v in ipairs(rep.skill) do
        Logic.skill[v.id] = v
    end

    Logic.initYet = true
end
function initDataFromServer()
    sendReq('login', dict(), initData, nil, nil)
end


--大地图 村落的 兵力
Logic.MapVillagePower = {
    {1, 1, 0, 0},
    {31, 13, 0, 0},
    {31, 13, 0, 0},
    {31, 13, 0, 0},
    {31, 13, 0, 0},
}

Logic.blockNeibor = {
[14] = {6, 15, 13},
[12] = {11, 6, 13},
[13] = {12, 14},
[15] = {14, 2},
[11] = {3, 12},
}
