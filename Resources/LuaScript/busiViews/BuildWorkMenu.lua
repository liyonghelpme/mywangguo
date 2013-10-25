BuildWorkMenu = class()
--建筑物可能不需要funcMenu
function BuildWorkMenu:ctor(b, func1, func2)
    self.build = b
    self.bg = CCNode:create()
    self.banner = setAnchor(setPos(addSprite(self.bg, "buildMenu1.png"), {0, 0}), {0, 0})
    self:updateView()
    self.passTime = 0
    registerUpdate(self)
    registerEnterOrExit(self)
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
    if bData["funcs"] == DECOR_BUILD then
        local ct = bData["cityDefense"] or 0
        local exp = bData["exp"] or 0
        if ct ~= 0 then
            self.cw = colorWordsNode(getStr("decorInfo0", {"[NAME]", self.build:getName(), "[NUM]", str(ct)}), 21, {255, 255, 255}, fixColor({89, 72, 18}))
        else
            self.cw = colorWordsNode(getStr("decorInfo1", {"[NAME]", self.build:getName(), "[NUM]", str(exp)}), 21, {255, 255, 255}, fixColor({89, 72, 18}))
        end
    elseif bData["funcs"] == FARM_BUILD then
        self.cw = ui.newTTFLabel({text = "下次收获时间 "..s, size=21, color=toCol({52, 101, 36})})
    elseif bData["funcs"] == MINE_KIND then
        self.cw = ui.newTTFLabel({text = "下次收获时间 "..s, size=21, color=toCol({52, 101, 36})})
    elseif bData["funcs"] == CASTLE_BUILD then
        self.cw = colorWordsNode(getStr("castleInfo", {"[LEV]", str(global.user:getValue("level")+1), "[NUM]", str(global.user:getValue("cityDefense"))}), 21, fixColor({100, 100, 100}), fixColor({89, 72, 18}))
    elseif bData["funcs"] == CAMP then
        self.cw = ui.newTTFLabel({text=self.build:getName(), size=21})
    end
    setAnchor(setPos(self.cw, {31, 32}), {0, 0.5})
    self.banner:addChild(self.cw)
end
function BuildWorkMenu:update(diff)
    self.passTime = self.passTime+diff
    if self.build.state == getParam("buildWork") and self.passTime > 1 then
        self.passTime = 0
        self:updateView()
    end
end
