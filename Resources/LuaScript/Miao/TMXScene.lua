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
    end
    --]]

        sendReq('login', dict(), self.initData, nil, self)
    --[[
    --]]
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

    local sf = CCSpriteFrameCache:sharedSpriteFrameCache()
    sf:addSpriteFramesWithFile("equipOne.plist")
end

function TMXScene:initData(rep, param)
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

    local r = u:getStringForKey("soldiers")
    if r ~= "" then
        local rd = simple.decode(r)
        Logic.soldiers = rd
    end

    Logic.buildings = {}
    for k, v in ipairs(rep.build) do
        Logic.buildings[v.id] = v 
    end
    Logic.buildList = {}
    for k, v in ipairs(rep.build) do
        if v.deleted == 0 then
            table.insert(Logic.buildList, v)
        end
    end

    Logic.people = {}
    Logic.allPeople = rep.people
    print("allPeople", #Logic.allPeople)
    for k, v in ipairs(rep.people) do
        Logic.people[v.id] = v
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
function TMXScene:enterScene()
    registerUpdate(self)
end

function TMXScene:update(diff)
    if Logic.paused then
        return
    end
    self.passTime = self.passTime+diff
    if self.passTime > 20 then
        self.passTime = 0
        self:saveGame(true)
    end

    if Logic.inResearch ~= nil then
        Logic.inResearch[2] = Logic.inResearch[2]+diff
        if Logic.inResearch[2] > 10 then
            local resG = Logic.researchGoods[Logic.inResearch[1]]
            local edata = Logic.equip[resG[2]]
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
            table.insert(allBuild, {picName=k.picName, id=k.id, px=p[1], py=p[2], bid=k.bid, goodsKind=k.goodsKind, workNum=k.workNum, static=k.static})
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
end
