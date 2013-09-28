BuildWorkMenu = class()
function BuildWorkMenu:ctor(b, func1, func2)
    self.build = b
    self.bg = CCNode:create()
    self.banner = adjustWidth(setPos(addSprite(self.bg, "buildMenu1.png"), {0, 0}))
    self:updateView()
    self.left = ChildMenuLayer.new(0, func1, build, func2)
    self.right = ChildMenuLayer.new(1, func2, build, func1)
    self.bg:addChild(self.left.bg)
    self.bg:addChild(self.right.bg)
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

    if bData['funcs'] == DECOR_BUILD then
    elseif bData['funcs'] == FARM_BUILD then
        local rate = bData['rate']
        if rate > getParam("farmRateNormal") then
            self.cw = colorWordsNode(getStr("magicFarm", {"[NAME]", self.build:getName(), "[TIME]", s}), 21, {100, 100, 100}, {89, 72, 18})
        else
            self.cw = colorWordsNode(getStr("normalFarm", {"[NAME]", self.build:getname(), "[TIME]", s}), 21, {100, 100, 100}, {89, 72, 18})
        end
    end
    setAnchor(setPos(self.cw, {31, fixY(getRealHeight(self.banner), 32)}), {0, 0.5})
    self.banner:addChild(self.cw)
end
function BuildWorkMenu:update(diff)
    if self.build.state == getParam("buildWork") then
        self:updateView()
    end
end

function BuildWorkMenu:removeSelf()
    self.left:removeSelf()
    self.right:removeSelf()
    self.bg:runAction(sequence({expin(moveby(getParam("hideTime")/1000, 0, -40)), itintto(0, 0, 0, 0), callfunc(self, self.clearChildMenu)}))
end
function BuildWorkMenu:clearChildMenu()
    removeSelf(self.bg)
end
