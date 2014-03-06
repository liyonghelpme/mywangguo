require "Miao.MiaoPage"
--require "Miao.TMXMenu"
require "Miao.TMXMenu2"
require "Miao.NewGame"
require "menu.SessionMenu"
require "Miao.LoadingView"
TMXScene = class()

function TMXScene:initDataNow()
    print("initDataNow")
    --sendReq('login', dict(), self.initData, nil, self)
    
    if not DEBUG then
        local rep = getFileData("data.txt")
        rep = simple.decode(rep)
        self:initData(rep, nil)
    else
        sendReq('login', dict(), self.initData, nil, self)
    end
    --sendReq('login', dict(), self.initData, nil, self)
end

function TMXScene:initPage()
    self.page = MiaoPage.new(self)
    self.bg:addChild(self.page.bg)
end

function TMXScene:ctor()
    self.name = "TMXScene"
    self.bg = CCScene:create()

    --init UI PIC
    local sf = CCSpriteFrameCache:sharedSpriteFrameCache()
    sf:addSpriteFramesWithFile("uiOne.plist")

    
    self.cameraLight = addNode(self.bg, 1)
    local vs = getVS()
    local sp1 = CCSprite:create("light.png")
    local bf = ccBlendFunc()
    bf.src = GL_ONE
    bf.dst = GL_ONE
    sp1:setBlendFunc(bf)
    addChild(self.cameraLight, sp1)
    setScale(sp1, 10)
    setAnchor(setPos(sp1, {0, 0}), {0, 0.5})
    setRotation(sp1, -33)
    setColor(sp1, {224/3, 172/3, 32/3})

    sp1:runAction(repeatForever(sequence({scaleto(0.5, 11, 11), scaleto(0.5, 10, 10)})))
    sp1:runAction(repeatForever(sequence({rotateby(3, -15), rotateby(3, 15)})))


    self.menu = TMXMenu2.new(self)
    self.bg:addChild(self.menu.bg, 2)
    self.dialogController = DialogController.new(self)
    self.bg:addChild(self.dialogController.bg)


    registerEnterOrExit(self)
    self.passTime = 0
    self.checkTime = 0

    self.debugTime = 0

    initCityData()
end

--分步初始化 每帧率初始化一个 建筑物
function TMXScene:initData(rep, param)
    print("initData", rep, param)
    local u = CCUserDefault:sharedUserDefault()
    initResearchEquip() 


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

end

--建筑物初始化结束后调用
function TMXScene:afterInitBuild()
    --初始化斜坡
    self.page:initInvisibleSlope()
    --遮挡斜坡
    self.page:maskMap()

    if Logic.inNew then
        global.director:pushView(NewGame.new(), 1, 0)
    end
    self.initDataing = false

    --弹出加载页面
    global.director:popView()

    --释放动画
    --移除掉loadingAni中的SpriteFrame 而不是全部的SpriteFrame
    removeAnimation("loadingAni")
    --CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFrameByName("")
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
    --初始化page
    if self.showLoad then
        --print("self.initPageYet", self.initPageYet)
        if not self.initPageYet then
            self.initPageYet = true
            print("delayCall")
            self:initPage()
        end

        if not self.synData then
            self.synData = true
            delayCall(0.3, self.initDataNow, self)
        end
    end

    self.debugTime = self.debugTime+diff
    if self.debugTime > 5 then
        self.debugTime = 0
        print(CCTextureCache:sharedTextureCache():dumpCachedTextureInfo())
    end
    if Logic.paused then
        return
    end

    if not self.showLoad then
        print("show Loading View")
        self.showLoad = true
        global.director:pushView(LoadingView.new(), 1, 0, 1)
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
            print("save Building static !!!!", k.static, k.dirty)
            if DEBUG_BUILD then
                table.insert(allBuild, {picName=k.picName, id=k.id, px=p[1], py=p[2], bid=k.bid, goodsKind=k.goodsKind, workNum=k.workNum, static=k.static, lifeStage=k.lifeStage, dir=k.dir})
            else
                if k.dirty then
                    table.insert(allBuild, {k.bid, math.floor(p[1]), math.floor(p[2]), k.goodsKind or 0, k.workNum, k.lifeStage, k.dir, k.id})
                    k.dirty = false
                end
            end
        end
    end

    local allSellBuild = {}
    for k, v in ipairs(Logic.sellBuild) do
        table.insert(allSellBuild, v.bid)
    end
    Logic.sellBuild = {}
    
    local allRoad = {}
    for k, v in pairs(self.page.buildLayer.mapGridController.allRoad) do
        local p = getPos(k.bg)
        if k.bid ~= nil then
            print("save Road static !!!!", k.static)
            if DEBUG_BUILD then
                table.insert(allRoad, {picName=k.picName, id=k.id, px=p[1], py=p[2], bid=k.bid, static=k.static})
            else
                if k.dirty then
                    table.insert(allRoad, {k.bid, math.floor(p[1]), math.floor(p[2])})
                    k.dirty = false
                end
            end
        end
    end

    local allPeople = {}
    --只保存农民
    for _, k in pairs(Logic.farmPeople) do
    --for k, v in pairs(self.page.buildLayer.mapGridController.allSoldiers) do
        --当前只保存普通民众
        if k.bg ~= nil and k.data.kind == 1 then
            local p = getPos(k.bg)
            local hid = 0
            if k.myHouse ~= nil  then
                hid = k.myHouse.bid
            end
            if DEBUG_BUILD then
                table.insert(allPeople, {px=p[1], py=p[2], hid=hid, id=k.id, health=k.health, level=k.level, weapon=k.weapon, head=k.head, body=k.body, spe=k.spe})
            else
                table.insert(allPeople, {k.pid, k.id, p[1], p[2], hid, k.health, k.level, (k.weapon or 0), (k.head or 0), (k.body or 0), (k.spe or 0)})
            end
        end
    end
    
    --一种是直接encode 一种是转化成table再encode
    --[[
    local otherDirParams = {"resource", "researchData", "soldiers", "inSell", "buildNum", "ownCity", "catData", "ownPeople", "ownBuild", "fightNum", 
    "arenaLevel", "ownTech", "lastArenaTime", "date", "landBook", "curVillage", "gameStage", "showMapYet", "attendHero", 
    }
    --]]
    --local otherTabParams = {}


    if not hint then
        addBanner("保存建筑物成功 "..#allBuild)
    end
    if not hint then
        addBanner("保存道路成功"..#allRoad)
    end
    if not hint then
        addBanner("保存人物成功 "..#allPeople)
    end

    if DEBUG_BUILD then
        local u = CCUserDefault:sharedUserDefault()
        local b = simple.encode(allBuild)
        u:setStringForKey("build", b)

        local r = simple.encode(allRoad)
        u:setStringForKey("road", r)

        local p = simple.encode(allPeople)
        u:setStringForKey('people', p)
    end

    local u = {}
    local os = {}
    function u:setStringForKey(k, v)
        os[k] = v
    end

    u:setStringForKey("resource", Logic.resource)
    --数字作为key的 dict 不能转化成json格式 所以先转化成一个 table
    --压缩了的数据直接采用二进制存储
    u:setStringForKey("researchData", {researchGoods=Logic.researchGoods, inResearch=(Logic.inResearch or simple.null), ownGoods=Logic.ownGoods})
    u:setStringForKey("soldiers", Logic.soldiers)
    u:setStringForKey("inSell", Logic.inSell)

    local cd
    if Logic.catData ~= nil then
        cd = copyTable(Logic.catData)
        cd.moveTime = math.floor(cd.moveTime)
    else
        cd = simple.null
    end
    u:setStringForKey("catData", cd) 
    u:setStringForKey("date", Logic.date) 
    u:setStringForKey("curVillage", Logic.curVillage) 
    u:setStringForKey("gameStage", Logic.gameStage) 
    u:setStringForKey("ownPeople", Logic.ownPeople) 
    u:setStringForKey("ownBuild", Logic.ownBuild) 
    --转化成research 的操作而不是单纯的同步数据
    u:setStringForKey("fightNum", Logic.fightNum) 
    u:setStringForKey("arenaLevel", Logic.arenaLevel) 
    u:setStringForKey("ownTech", Logic.ownTech) 
    u:setStringForKey("lastArenaTime", Logic.lastArenaTime) 
    u:setStringForKey("landBook", Logic.landBook) 
    u:setStringForKey("showMapYet", Logic.showMapYet) 
    u:setStringForKey("attendHero", Logic.attendHero) 

    local u2 = {}
    local dt = {}
    function u2:setStringForKey(k, v)
        dt[k] = v
    end
    u2:setStringForKey("holdNum", dictToTable(Logic.holdNum))
    u2:setStringForKey("buildNum", dictToTable(Logic.buildNum))
    u2:setStringForKey("ownCity", dictToTable(Logic.ownCity)) 
    u2:setStringForKey("openMap", dictToTable(Logic.openMap))
    u2:setStringForKey("showLand", dictToTable(Logic.showLand))
    u2:setStringForKey("ownVillage", dictToTable(Logic.ownVillage)) 

    print("inResearchData", simple.encode(os))
    sendReq("saveGame", {uid=Logic.uid, allBuild=simple.encode(allBuild), allRoad=simple.encode(allRoad), allSellBuild=simple.encode(allSellBuild), allPeople=simple.encode(allPeople), dirParams=simple.encode(os), indirParams=simple.encode(dt)})

end


function TMXScene:newVillageWin(w)
    print("newVillageWin call function")
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
        --最后获得 工厂和商店
            if Logic.curVillage == 2 then
                addBanner("获得小甲")
                --table.insert(Logic.ownGoods, {0, 47})
                storeAddNewEquip(47)
            end
        else
            addBanner("获得工厂 和 茶屋")
            table.insert(Logic.ownBuild, 5)
            table.insert(Logic.ownBuild, 11)
            removeSelf(self.page.fly.bg)
        end
        self.page:restoreBuildAndMap()
    else
        addBanner("村落攻略失败啦")
    end
end
