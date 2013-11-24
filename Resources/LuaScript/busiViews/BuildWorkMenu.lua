require "views.UpgradeNow"
BuildWorkMenu = class()
--建筑物可能不需要funcMenu
function BuildWorkMenu:ctor(b, func1, func2)
    self.build = b
    self.bg = CCNode:create()
    local sca = global.director.disSize[1]/global.director.designSize[1]
    self.banner = setAnchor(setPos(addSprite(self.bg, "buildMenu1.png"), {0, 0}), {0, 0})
    setScale(self.banner, sca)
    self:updateView()
    self.passTime = 0
    registerEnterOrExit(self)
end
function BuildWorkMenu:enterScene()
    registerUpdate(self)
end
function BuildWorkMenu:updateView()
    if self.cw ~= nil then
        removeSelf(self.cw)
        self.cw = nil
    end
    local bData = self.build.data
    local state = self.build.state
    local leftTime = self.build:getLeftTime()
    local s = getWorkTime(leftTime)
    self.cw = ui.newTTFLabel({text=getStr("bInfo", {"[NAME]", self.build:getName(), "[LEVEL]", getStr(self.build.level+1)}), size=21})
    setAnchor(setPos(self.cw, {31, 32}), {0, 0.5})
    self.banner:addChild(self.cw)


    if self.build.level < 5 then
        local but0 = ui.newButton({image="upgrade.png", delegate=self, callback=self.onUpgrade})
        self.banner:addChild(but0.bg)
        but0:setAnchor(0.5, 0.5)
        setPos(but0.bg, {636, 30}) 
    end
end
function BuildWorkMenu:onUpgrade()
    global.director.curScene:closeGlobalMenu()
    local uv = UpgradeNow.new(self.build)
    global.director:pushView(uv, 1, 0)
end
function BuildWorkMenu:update(diff)
    self.passTime = self.passTime+diff
    if self.build.state == getParam("buildWork") and self.passTime > 1 then
        self.passTime = 0
        self:updateView()
    end
end
