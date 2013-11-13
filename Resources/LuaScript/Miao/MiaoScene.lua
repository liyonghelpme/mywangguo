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

