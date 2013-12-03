require "Miao.MiaoPage"
require "Miao.TMXMenu"
require "Miao.NewGame"
TMXScene = class()

function TMXScene:initDataNow()
    sendReq('login', dict(), self.initData, nil, self)
end
function TMXScene:ctor()
    self.bg = CCScene:create()
    self.page = MiaoPage.new(self)
    self.bg:addChild(self.page.bg)
    self.menu = TMXMenu.new(self)
    self.bg:addChild(self.menu.bg)
    self.dialogController = DialogController.new(self)
    self.bg:addChild(self.dialogController.bg)

    self.page:moveToPoint(1644, 384)
    delayCall(0.3, self.initDataNow, self)
end

function TMXScene:initData(rep, param)
    Logic.buildings = {}
    for k, v in ipairs(rep.build) do
        Logic.buildings[v.id] = v 
    end
    Logic.buildList = rep.build
    Logic.people = {}
    Logic.allPeople = rep.people
    print("allPeople", #Logic.allPeople)
    for k, v in ipairs(rep.people) do
        Logic.people[v.id] = v
    end

    self.menu:initDataOver()
    self.page:initDataOver()
    self.page.buildLayer:initDataOver()

    if Logic.inNew then
        global.director:pushView(NewGame.new(), 1, 0)
    end
end
function TMXScene:onBuild()
    self.page:addBuilding()
end

--普通建筑物 和 环境
function TMXScene:saveGame()
    local allBuild = {}
    for k, v in pairs(self.page.buildLayer.mapGridController.allBuildings) do
        local p = getPos(k.bg)
        if k.bid ~= nil then
            table.insert(allBuild, {picName=k.picName, id=k.id, px=p[1], py=p[2], bid=k.bid})
        end
    end
    local b = simple.encode(allBuild)
    local u = CCUserDefault:sharedUserDefault()
    u:setStringForKey("build", b)
    addBanner("保存建筑物成功 "..#allBuild)

    local allPeople = {}
    for k, v in pairs(self.page.buildLayer.mapGridController.allSoldiers) do
        --当前只保存普通民众
        if k.bg ~= nil and k.data.kind == 1 then
            local p = getPos(k.bg)
            local hid
            if k.myHouse ~= nil  then
                hid = k.myHouse.bid
            end
            table.insert(allPeople, {px=p[1], py=p[2], hid=hid, id=k.id})
        end
    end
    local p = simple.encode(allPeople)
    u:setStringForKey('people', p)
    addBanner("保存人物成功 "..#allPeople)
end
