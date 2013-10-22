require "Miao.MiaoPage"
require "Miao.MiaoMenu"
MiaoScene = class()
function MiaoScene:ctor()
    self.bg = CCScene:create()
    self.page = MiaoPage.new(self)
    self.bg:addChild(self.page.bg)
    self.menu = MiaoMenu.new(self)
    self.bg:addChild(self.menu.bg)
    sendReq('login', dict(), self.initData, nil, self)
end
function MiaoScene:initData(rep, param)
    Logic.buildings = {}
    for k, v in ipairs(rep.build) do
        Logic.buildings[v.id] = v 
    end
    Logic.buildList = rep.build

    self.menu:initDataOver()
    self.page.buildLayer:initDataOver()
end
function MiaoScene:beginBuild(kind, id)
    self.curBuild = self.page:beginBuild(kind, id)
end
function MiaoScene:setBuilding(b)
    print("setBuilding", self.curBuild, b)
    if b == self.curBuild then
        return 1
    end
    return 0
end

function MiaoScene:finishBuild()
    if self.curBuild.colNow == 0  then
        self.page:finishBuild()
        self.curBuild = nil
    end
end
