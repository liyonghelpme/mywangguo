require "Miao.MiaoPage"
--require "Miao.TMXMenu"
require "Miao.TMXMenu2"
require "Miao.NewGame"
require "menu.SessionMenu"
TMXScene = class()

function TMXScene:initDataNow()
    print("initDataNow")
    --sendReq('login', dict(), self.initData, nil, self)
    
    --[[
    if not DEBUG then
        local rep = getFileData("data.txt")
        rep = simple.decode(rep)
        self:initData(rep, nil)
    else
        sendReq('login', dict(), self.initData, nil, self)
    end
    --]]
    --
    sendReq('login', dict(), self.initData, nil, self)
end
function TMXScene:ctor()
    self.name = "TMXScene"

    self.bg = CCScene:create()
    self.page = MiaoPage.new(self)
    self.bg:addChild(self.page.bg)
    self.menu = TMXMenu2.new(self)
    self.bg:addChild(self.menu.bg)
    self.dialogController = DialogController.new(self)
    self.bg:addChild(self.dialogController.bg)

    --self.page:moveToPoint(1644, 384)
    --setPos(self.bg, {})

    delayCall(0.3, self.initDataNow, self)
    registerEnterOrExit(self)
    self.passTime = 0
    self.checkTime = 0

    local sf = CCSpriteFrameCache:sharedSpriteFrameCache()
    sf:addSpriteFramesWithFile("equipOne.plist")
end

function TMXScene:initData(rep, param)
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
        local rd = tableToDict(simple.decode(r))
        Logic.ownCity = rd
    end

    local r = u:getStringForKey("ownVillage")
    if r ~= "" then
        local rd = tableToDict(simple.decode(r))
        Logic.ownVillage = rd
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

    local r = u:getStringForKey('curVillage')
    if r ~= "" and r ~= "null" then
        local rd = simple.decode(r)
        Logic.curVillage = rd
    end

    local r = u:getStringForKey('gameStage')
    if r ~= "" and r ~= "null" then
        local rd = simple.decode(r)
        Logic.gameStage = rd
    end

    local r = u:getStringForKey('showMapYet')
    if r ~= "" and r ~= "null" then
        local rd = simple.decode(r)
        Logic.showMapYet = rd
    end
    local r = u:getStringForKey('attendHero')
    if r ~= "" and r ~= "null" then
        local rd = simple.decode(r)
        Logic.attendHero = rd
    end

    local r = u:getStringForKey("openMap")
    if r ~= "" then
        Logic.openMap = tableToDict(simple.decode(r))
        --print("decode holdNum", simple.encode(Logic.holdNum))
    end

    local r = u:getStringForKey("showLand")
    if r ~= "" then
        Logic.showLand = tableToDict(simple.decode(r))
        --print("decode holdNum", simple.encode(Logic.holdNum))
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

    Logic.villageGoods = {}
    for k, v in ipairs(rep.villageReward) do
        v.goods = simple.decode(v.goods)
        Logic.villageGoods[v.id] = v
    end
    print("villageGoods", #Logic.villageGoods)


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
    
    --Logic.techGoods = {}
    
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
        --[[
        local gm = simple.decode(v.getMethod)
        for gk, gv in ipairs(gm) do
            --技术等级
            local tg = getDefault(Logic.techGoods, gv[1]..gv[2], {})
            table.insert(tg, v.id)
        end
        --]]
    end
    --print("equips", simple.encode(Logic.techGoods))
    
    --local tt = checkTechNewEquip('sword', 1)
    --print("equips", simple.encode(tt))

    Logic.allSkill = rep.skill
    for k, v in ipairs(rep.skill) do
        Logic.skill[v.id] = v
    end

    self.initDataing = true

    print("start init Menu")
    self.menu:initDataOver()
    --self.page.buildLayer:testCat()
    print("start init Page")
    self.page:initDataOver()
    print("start init buildLayer")
    self.page.buildLayer:initDataOver()
    self.page:initInvisibleSlope()
    self.page:maskMap()

    if Logic.inNew then
        global.director:pushView(NewGame.new(), 1, 0)
    end

    self.initDataing = false
end

function TMXScene:gotoFight()
    if Logic.catData ~= nil then
        self.showYet = false
        clearFight()
        global.director:pushScene(FightScene.new())
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

        --cid 信息
        --cid inkScape 边关系中的id信息
        --realId gimp 中的id信息
        Logic.challengeCity = path[#path]
        local cityInfo = MapNode[Logic.challengeCity]
        if cityInfo[4] == 1 then
            Logic.challengeNum = CityData[cityInfo[5]]
        else
            Logic.challengeNum = Logic.MapVillagePower[math.min(#Logic.MapVillagePower, cityInfo[5])]
        end

        if lc.moveTime <= 0 then
            local nextPoint = curPoint+1
            --尴尬的bug 在开战的时候 不应该弹出这个对话框的
            if nextPoint > #lc.path then
                if not self.showYet then
                    self.showYet = true
                --addBanner("部队到达了！")
                    global.director:pushView(SessionMenu.new("服部大人,\n幕府军看来已经到达了!", self.gotoFight, self), 1, 0)
                end
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
    if Logic.gameStage == 1 and Logic.landBook > 0 then
        addBanner("获得土地产权证书 进入 第二阶段")
        Logic.gameStage = 2
        --显示几个黑色的块
        self.page:stageOneToTwo()
    end
    if Logic.curVillage >= 4 and not Logic.showMapYet then
        addBanner("大地图功能开启了")
        Logic.showMapYet = true
        self.menu:adjustLeftShow()
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
    u:setStringForKey("ownCity", simple.encode(dictToTable(Logic.ownCity))) 

    u:setStringForKey("catData", simple.encode(Logic.catData)) 
    u:setStringForKey("ownPeople", simple.encode(Logic.ownPeople)) 
    u:setStringForKey("ownBuild", simple.encode(Logic.ownBuild)) 
    u:setStringForKey("fightNum", simple.encode(Logic.fightNum)) 
    u:setStringForKey("arenaLevel", simple.encode(Logic.arenaLevel)) 
    u:setStringForKey("ownTech", simple.encode(Logic.ownTech)) 
    u:setStringForKey("lastArenaTime", simple.encode(Logic.lastArenaTime)) 
    u:setStringForKey("date", simple.encode(Logic.date)) 
    u:setStringForKey("landBook", simple.encode(Logic.landBook)) 
    u:setStringForKey("curVillage", simple.encode(Logic.curVillage)) 
    u:setStringForKey("gameStage", simple.encode(Logic.gameStage)) 
    u:setStringForKey("showMapYet", simple.encode(Logic.showMapYet)) 
    u:setStringForKey("attendHero", simple.encode(Logic.attendHero)) 
    u:setStringForKey("openMap", simple.encode(dictToTable(Logic.openMap)))
    u:setStringForKey("showLand", simple.encode(dictToTable(Logic.showLand)))
     
    u:setStringForKey("ownVillage", simple.encode(dictToTable(Logic.ownVillage))) 
end


function TMXScene:newVillageWin(w)
    if w then
        addBanner("村落攻略胜利啦")
        
        --新手村 获得人口
        local cp = Logic.newPeople[Logic.curVillage+1]
        if cp ~= nil then
            print("newPeople is who", simple.encode(Logic.newPeople), cp)
            Logic.ownPeople = concateTable(Logic.ownPeople, cp)
            --showPeopleInfo(cp)
            for k, v in ipairs(cp) do
                local pd = Logic.people[v]
                addBanner("可以启用"..pd.name)
            end
        end


        Logic.curVillage = Logic.curVillage+1
        if Logic.curVillage < 4 then
            self.page:adjustFly()
        else
            removeSelf(self.page.fly.bg)
        end
        self.page:restoreBuildAndMap()
    else
        addBanner("村落攻略失败啦")
    end
end
