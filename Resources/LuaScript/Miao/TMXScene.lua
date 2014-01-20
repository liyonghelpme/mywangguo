require "Miao.MiaoPage"
--require "Miao.TMXMenu"
require "Miao.TMXMenu2"
require "Miao.NewGame"
TMXScene = class()

function TMXScene:initDataNow()
    --[[
    if not DEBUG then
        local rep = getFileData("data.txt")
        rep = simple.decode(rep)
        self:initData(rep, nil)
    else
    --]]
    sendReq('login', dict(), self.initData, nil, self)
    --end

    --sendReq('login', dict(), self.initData, nil, self)
end
function TMXScene:ctor()
    self.bg = CCScene:create()
    self.page = MiaoPage.new(self)
    self.bg:addChild(self.page.bg)
    self.menu = TMXMenu2.new(self)
    self.bg:addChild(self.menu.bg)
    self.dialogController = DialogController.new(self)
    self.bg:addChild(self.dialogController.bg)

    self.page:moveToPoint(1644, 384)
    delayCall(0.3, self.initDataNow, self)
    registerEnterOrExit(self)
    self.passTime = 0
    self.checkTime = 0

    local sf = CCSpriteFrameCache:sharedSpriteFrameCache()
    sf:addSpriteFramesWithFile("equipOne.plist")
end

function TMXScene:initData(rep, param)
    initCityData()

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

    local r = u:getStringForKey("soldiers")
    if r ~= "" then
        local rd = simple.decode(r)
        Logic.soldiers = rd
    end

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
    end

    Logic.allSkill = rep.skill
    for k, v in ipairs(rep.skill) do
        Logic.skill[v.id] = v
    end

    self.menu:initDataOver()
    self.page:initDataOver()
    self.page.buildLayer:initDataOver()

    if Logic.inNew then
        global.director:pushView(NewGame.new(), 1, 0)
    end
end

function TMXScene:checkBattleTime(diff)
    if Logic.catData ~= nil then
        self.checkTime = self.checkTime+diff
        if self.checkTime < 1 then
            return
        end
        local lc = Logic.catData
        --print("checkBattleTime", simple.encode(lc), lc)
        local path = lc.path
        local curPoint = lc.curPoint
        lc.moveTime = lc.moveTime - self.checkTime
        self.checkTime = 0

        --cid inkScape 边关系中的id信息
        --realId gimp 中的id信息
        Logic.challengeCity = path[#path]
        Logic.challengeNum = CityData[MapNode[Logic.challengeCity][5]]
        if lc.moveTime <= 0 then
            local nextPoint = curPoint+1
            if nextPoint > #lc.path then
                addBanner("部队到达了！")
                global.director:pushScene(FightScene.new())
                clearFight()
            else
                local lastPos = path[curPoint]
                lastPos = {MapNode[lastPos][1], MapNode[lastPos][2]}
                local xy =  path[nextPoint]
                xy = {MapNode[xy][1], MapNode[xy][2]}
                local dis = distance(lastPos, xy)/CAT_SPEED
                lc.moveTime = dis
                lc.curPoint = nextPoint
            end
        end
    end
end

function TMXScene:enterScene()
    registerUpdate(self)
    --[[
    if Logic.catData ~= nil then
        local lc = Logic.catData
        local cid = lc.path[#lc.path]
        
        --全局战斗计算时间的对象 一直存活的node对象
        if self.fakeCat == nil then
            self.fakeCat = MapCat.new(nil, nil, cid, true)
            self.bg:addChild(self.fakeCat)
        --updateFake Cat data
        else
        end
    else
    end
    --]]
end


function TMXScene:update(diff)
    if Logic.paused then
        return
    end
    self:checkBattleTime(diff)
    self.passTime = self.passTime+diff
    --暂停状态不要 保存游戏即可
    if self.passTime > 20 then
        self.passTime = 0
        self:saveGame(true)
    end

    if Logic.inResearch ~= nil then
        Logic.inResearch[2] = Logic.inResearch[2]+diff
        if Logic.inResearch[2] > 10 then
            local resG = Logic.researchGoods[Logic.inResearch[1]]
            local edata 
            if resG[1] == 0 then
                edata = Logic.equip[resG[2]]
            elseif resG[1] == 1 then
                edata = GoodsName[resG[2]]
            end
            addBanner("研究"..edata.name.."成功")
            table.remove(Logic.researchGoods, Logic.inResearch[1])
            table.insert(Logic.ownGoods, resG)
            Logic.inResearch = nil
            initResearchEquip()
        end
    end
end

function TMXScene:onBuild()
    self.page:addBuilding()
end

--普通建筑物 和 环境
--保存道路
function TMXScene:saveGame(hint)
    local allBuild = {}
    --bug： allRoad 似乎没有生效
    for k, v in pairs(self.page.buildLayer.mapGridController.allBuildings) do
        local p = getPos(k.bg)
        if k.bid ~= nil then
            print("save Building static !!!!", k.static)
            table.insert(allBuild, {picName=k.picName, id=k.id, px=p[1], py=p[2], bid=k.bid, goodsKind=k.goodsKind, workNum=k.workNum, static=k.static, goodsKind=k.goodsKind, lifeStage=k.lifeStage, dir=k.dir})
        end
    end
    
    local allRoad = {}
    for k, v in pairs(self.page.buildLayer.mapGridController.allRoad) do
        local p = getPos(k.bg)
        if k.bid ~= nil then
            print("save Road static !!!!", k.static)
            table.insert(allRoad, {picName=k.picName, id=k.id, px=p[1], py=p[2], bid=k.bid, static=k.static})
        end
    end


    local b = simple.encode(allBuild)
    local u = CCUserDefault:sharedUserDefault()
    u:setStringForKey("build", b)
    if not hint then
        addBanner("保存建筑物成功 "..#allBuild)
    end

    local r = simple.encode(allRoad)
    u:setStringForKey("road", r)
    if not hint then
        addBanner("保存道路成功"..#allRoad)
    end

    local allPeople = {}
    --只保存农民
    for _, k in pairs(Logic.farmPeople) do
    --for k, v in pairs(self.page.buildLayer.mapGridController.allSoldiers) do
        --当前只保存普通民众
        if k.bg ~= nil and k.data.kind == 1 then
            local p = getPos(k.bg)
            local hid
            if k.myHouse ~= nil  then
                hid = k.myHouse.bid
            end
            table.insert(allPeople, {px=p[1], py=p[2], hid=hid, id=k.id, health=k.health, level=k.level, weapon=k.weapon, head=k.head, body=k.body, spe=k.spe})
        end
    end

    local p = simple.encode(allPeople)
    u:setStringForKey('people', p)
    if not hint then
        addBanner("保存人物成功 "..#allPeople)
    end

    u:setStringForKey("resource", simple.encode(Logic.resource))

    --数字作为key的 dict 不能转化成json格式 所以先转化成一个 table
    u:setStringForKey("holdNum", simple.encode(dictToTable(Logic.holdNum)))
    u:setStringForKey("researchData", simple.encode({researchGoods=Logic.researchGoods, inResearch=Logic.inResearch, ownGoods=Logic.ownGoods}))
    u:setStringForKey("soldiers", simple.encode(Logic.soldiers))
    u:setStringForKey("inSell", simple.encode(Logic.inSell))
    u:setStringForKey("buildNum", simple.encode(dictToTable(Logic.buildNum)))
    u:setStringForKey("ownCity", simple.encode(Logic.ownCity)) 
    u:setStringForKey("catData", simple.encode(Logic.catData)) 
    u:setStringForKey("ownPeople", simple.encode(Logic.ownPeople)) 
end
