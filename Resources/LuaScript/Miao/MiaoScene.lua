require "Miao.MiaoPage"
require "Miao.MiaoMenu"
MiaoScene = class()
function MiaoScene:ctor()
    self.bg = CCScene:create()
    self.page = MiaoPage.new(self)
    self.bg:addChild(self.page.bg)
    self.menu = MiaoMenu.new(self)
    self.bg:addChild(self.menu.bg)
end
function MiaoScene:beginBuild()
    self.curBuild = self.page:beginBuild()
end
function MiaoScene:setBuilding(b)
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
