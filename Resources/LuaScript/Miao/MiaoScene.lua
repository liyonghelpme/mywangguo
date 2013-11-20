require "Miao.MiaoPage"
require "Miao.MiaoMenu"
MiaoScene = class()
function MiaoScene:ctor()
    self.bg = CCScene:create()
    self.page = MiaoPage.new(self)
    self.bg:addChild(self.page.bg)
    self.menu = MiaoMenu.new(self)
    self.bg:addChild(self.menu.bg)
    self.dialogController = DialogController.new(self)
    self.bg:addChild(self.dialogController.bg)
    sendReq('login', dict(), self.initData, nil, self)
end
function MiaoScene:initData(rep, param)
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
    self.page.buildLayer:initDataOver()
end

function MiaoScene:setBuilding(b)
    print("setBuilding", self.curBuild, b)
    if b == self.page.curBuild then
        return 1
    end
    return 0
end

--普通建筑物 和 环境
function MiaoScene:saveGame()
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
        local p = getPos(k.bg)
        local hid
        if k.myHouse ~= nil  then
            hid = k.myHouse.bid
        end
        table.insert(allPeople, {px=p[1], py=p[2], hid=hid})
    end
    local p = simple.encode(allPeople)
    u:setStringForKey('people', p)
    addBanner("保存人物成功 "..#allPeople)
end
