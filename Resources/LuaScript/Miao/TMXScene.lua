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
    self.initDataing = true
    Logic.lastCloseTime = 0
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


    self.events = {"EVENT_COCOS_PAUSE"}
    registerEnterOrExit(self)
    self.passTime = 0
    self.checkTime = 0

    self.debugTime = 0

    initCityData()
end
function TMXScene:receiveMsg(name, msg)
    if name == 'EVENT_COCOS_PAUSE' then
        self:saveGame(true)
    end
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
    print("afterInitBuild")
    --初始化斜坡
    self.page:initInvisibleSlope()
    --遮挡斜坡
    self.page:maskMap()

    if Logic.inNew then
        global.director:pushView(NewGame.new(), 1, 0)
    end

    --弹出加载页面
    global.director:popView()

    --释放动画
    --移除掉loadingAni中的SpriteFrame 而不是全部的SpriteFrame
    removeAnimation("loadingAni")
    --CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFrameByName("")
    self.initDataing = false
    Event:sendMsg(EVENT_TYPE.INIT_OVER)
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
        Logic.catDirty = true

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

function TMXScene:onNew(p) 
    Logic.newStage = Logic.newStage+1
    Logic.lastCloseTime = Logic.date
end

local newWord = {
    "此地是 喵喵忍者村 被数个郡县分裂，互相争夺领土",
    "我们虽然刚刚成立，领地微小，但是让我们以统一村落为目标努力吧！！",
    "让我们先为追随你而来的村民建造住所吧。\n请选择菜单中的 建筑！",
}

local merWord = {
    "如果这里有食材的话，\n希望能够让我收购一些...",
    "真是求之不得的建议啊。\n那么就让商人收购一些田地里生产的 食材 吧。",
}
local news = {
    "喵喵村日报最新刊\n已经送到了",
    "那么进入正题，在无数小领主相互较劲的喵喵村上，新的喵喵部落终于独立出来了。\n他们将以统一全村落为目标，和所有势力进行角逐，到底那个实例才能达成统一，还真是叫人期待呢。",
    "没想到！！喵喵村的情报竟然逐一被泄露出来了。",
    "今后也许还能够得到有用的情报，让我们多加留心吧。",
}

local battle = {
    "喵喵大人...\n我曾暗中派遣某人前往临近地区进行谍报活动...",
    "此人刚刚完成任务，\n顺利归来了。\n让我们听听他是怎么说的吧。",
    "初次见面，我叫娜米！！\n我收集到攻下临近村庄的必要的情报。\n请灵活运用。",
}

local bat2 = {
    "临近领地可以进行攻略啦！！",
    "选择领地就可以对其发起战争。",
    "那么今后我打算在大人下面任事，还请您多多关照！！",
}
function TMXScene:checkNewUser()
    if not self.initDataing and Logic.newStage < 1000 then
        if Logic.date-Logic.lastCloseTime > 3 then 
            if Logic.newStage < #newWord then
                global.director:pushView(SessionMenu.new(newWord[Logic.newStage+1], self.onNew, self, {butOk=true}), 1, 0)
            elseif Logic.newStage == 5 then
                global.director:pushView(SessionMenu.new("等我休息好了，就在附近的田地里进行耕作好了。", onNew, nil, {butOk=true}), 1, 0)
            elseif Logic.newStage >= 7 and Logic.newStage <= 6+#merWord then
                global.director:pushView(SessionMenu.new(merWord[Logic.newStage-6], onNew, nil, {butOk=true}), 1, 0)
            --9 商人收购食材
            elseif Logic.newStage == 10 then
                global.director:pushView(SessionMenu.new("今后我打算定期前来采购，希望你能够增加田地。", onNew, nil, {butOk=true}), 1, 0)
            end
        end

        --日报系统
        if Logic.newStage >= 11 and Logic.newStage < #news+11 then
            global.director:pushView(SessionMenu.new(news[Logic.newStage-10], onNew, nil, {butOk=true}), 1, 0)
        end

        --1 4 3
        if Logic.newStage >= 15 and Logic.newStage < 15+#battle and Logic.date >= 780 then
            global.director:pushView(SessionMenu.new(battle[Logic.newStage-14], self.onNew, self, {butOk=true}), 1, 0)
        end

        --移动插旗
        --村落中心
        if Logic.newStage == 18 then
            self.page:showFly()
            onNew()
        end

        --显示对话
        if Logic.newStage == 19 and Logic.date-Logic.lastCloseTime > 3  then
            global.director:pushView(SessionMenu.new(bat2[Logic.newStage-18], onNew, nil, {butOk=true}), 1, 0)
        elseif Logic.newStage > 19 and Logic.newStage<19+#bat2 then
            global.director:pushView(SessionMenu.new(bat2[Logic.newStage-18], onNew, nil, {butOk=true}), 1, 0)
        end

        --放出新的人物
        if Logic.newStage == 22 then
            self.page:addPeople(14)
            Logic.newStage = Logic.newStage+1
        end


    end
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
    self:checkNewUser()
    
    if not self.showLoad then
        print("show Loading View")
        self.showLoad = true
        global.director:pushView(LoadingView.new(), 1, 0, 1)
    end


    if self.initPageYet then
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
            Logic.researchGoodsDirty = true
            table.insert(Logic.ownGoods, resG)
            Logic.ownGoodsDirty = true
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
    --更新保存时间
    self.passTime = 0
    local allBuild = {}
    --bug： allRoad 似乎没有生效
    for k, v in pairs(self.page.buildLayer.mapGridController.allBuildings) do
        local p = getPos(k.bg)
        if k.bid ~= nil then
            print("save Building static !!!!", k.static, k.dirty)
            if DEBUG_BUILD then
                table.insert(allBuild, {picName=k.picName, id=k.id, px=p[1], py=p[2], bid=k.bid, goodsKind=k.goodsKind, workNum=k.workNum, static=k.static, lifeStage=k.lifeStage, dir=k.dir})
            else
                --保存建筑物信息
                if k.builddirty then
                    table.insert(allBuild, {k.bid, math.floor(p[1]), math.floor(p[2]), k.goodsKind or 0, k.workNum, math.floor(k.lifeStage), k.dir, k.id})
                    k.builddirty = false
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
                table.insert(allPeople, {k.pid, k.id, math.floor(p[1]), math.floor(p[2]), hid, math.floor(k.health), k.level, (k.weapon or 0), (k.head or 0), (k.body or 0), (k.spe or 0)})
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
    u:setStringForKey('newStage', Logic.newStage)
    --数字作为key的 dict 不能转化成json格式 所以先转化成一个 table
    --压缩了的数据直接采用二进制存储
    local rd = {inResearch=(Logic.inResearch or simple.null)}
    if Logic.researchGoodsDirty then
        Logic.researchGoodsDirty = false
        rd['researchGoods'] = Logic.researchGoods
    end
    if Logic.ownGoodsDirty then
        Logic.ownGoodsDirty = false
        rd['ownGoods'] = Logic.ownGoods
    end
    u:setStringForKey("researchData", rd)
    --只有训练了士兵才同步士兵
    if Logic.soldierDirty then
        u:setStringForKey("soldiers", Logic.soldiers)
        Logic.soldierDirty = false
    end

    if Logic.sellDirty then
        u:setStringForKey("inSell", Logic.inSell)
        Logic.sellDirty = false
    end

    local cd
    if Logic.catData ~= nil then
        cd = copyTable(Logic.catData)
        cd.moveTime = math.floor(cd.moveTime)
    else
        cd = simple.null
    end

    if Logic.catDirty then
        Logic.catDirty = false
        u:setStringForKey("catData", cd) 
    end

    u:setStringForKey("date", math.floor(Logic.date)) 
    if Logic.curVillageDirty then
        Logic.curVillageDirty = false
        u:setStringForKey("curVillage", Logic.curVillage) 
    end

    u:setStringForKey("gameStage", Logic.gameStage) 
    if Logic.ownPeopleDirty then
        Logic.ownPeopleDirty = false
        u:setStringForKey("ownPeople", Logic.ownPeople) 
    end
    if Logic.ownBuildDirty then
        Logic.ownBuildDirty = false
        u:setStringForKey("ownBuild", Logic.ownBuild) 
    end

    --转化成research 的操作而不是单纯的同步数据
    u:setStringForKey("fightNum", Logic.fightNum) 
    u:setStringForKey("arenaLevel", Logic.arenaLevel) 
    if Logic.ownTechDirty then
        u:setStringForKey("ownTech", Logic.ownTech) 
    end
    u:setStringForKey("lastArenaTime", Logic.lastArenaTime) 
    u:setStringForKey("landBook", Logic.landBook) 
    u:setStringForKey("showMapYet", Logic.showMapYet) 
    --[[
    local at = {}
    for k, v in ipairs(Logic.attendHero) do
        table.insert(at, {v['id'], v['pos']})
    end
    --]]
    if Logic.attendHeroDirty then
        Logic.attendHeroDirty = false
        u:setStringForKey("attendHero", Logic.attendHero)
    end


    local u2 = {}
    local dt = {}
    function u2:setStringForKey(k, v)
        dt[k] = v
    end
    local hold = {}
    for k, v in pairs(Logic.changedHold) do
        table.insert(hold, {k, Logic.holdNum[k]})
    end
    --u2:setStringForKey("holdNum", dictToTable(Logic.holdNum))

    if Logic.buildNumDirty then
        Logic.buildNumDirty = false
        u2:setStringForKey("buildNum", dictToTable(Logic.buildNum))
    end
    if Logic.ownCityDirty then
        Logic.ownCityDirty = false
        u2:setStringForKey("ownCity", dictArray(Logic.ownCity)) 
    end

    if Logic.openMapDirty then
        u2:setStringForKey("openMap", dictArray(Logic.openMap))
        Logic.openMapDirty = false
    end
    u2:setStringForKey("showLand", dictToTable(Logic.showLand))
    if Logic.ownVillageDirty then
        Logic.ownVillageDirty = false
        u2:setStringForKey("ownVillage", dictArray(Logic.ownVillage)) 
    end

    print("inResearchData", simple.encode(os))
    sendReq("saveGame", {uid=Logic.uid, allBuild=simple.encode(allBuild), allRoad=simple.encode(allRoad), allSellBuild=simple.encode(allSellBuild), allPeople=simple.encode(allPeople), dirParams=simple.encode(os), indirParams=simple.encode(dt), holdNum=simple.encode(hold)})

end


function TMXScene:newVillageWin(w)
    print("newVillageWin call function")
    if w then
        addBanner("村落攻略胜利啦")
        
        --新手村 获得人口
        local cp = Logic.newPeople[Logic.curVillage+1]
        if cp ~= nil then
            print("newPeople is who", simple.encode(Logic.newPeople), cp)
            addNewPeople(cp)
            --showPeopleInfo(cp)
            for k, v in ipairs(cp) do
                local pd = Logic.people[v]
                addBanner("可以启用"..pd.name)
            end
        end


        Logic.curVillage = Logic.curVillage+1
        Logic.curVillageDirty = true
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
            addNewBuild(5)
            addNewBuild(11)
            removeSelf(self.page.fly.bg)
        end
        self.page:restoreBuildAndMap()
    else
        addBanner("村落攻略失败啦")
    end
end
