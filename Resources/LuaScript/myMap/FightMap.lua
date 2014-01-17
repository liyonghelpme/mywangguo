require "myMap.FightPage"
require "myMap.FightMenu"
FightMap = class()
function FightMap:ctor()
    self.bg = CCScene:create()
    self.page = FightPage.new()
    self.bg:addChild(self.page.bg)
    self.menu = FightMenu.new(self)
    self.bg:addChild(self.menu.bg)

    self.dialogController = DialogController.new(self)
    self.bg:addChild(self.dialogController.bg)
end
function FightMap:checkWin()
    print("FightMenu checkWin", Logic.challengeCity)
    addBanner("FightMap checkWin")
    if Logic.ownCity[Logic.challengeCity] ~= nil then
        addBanner("获取 胜利奖励！")
        local city = self.page.cidToCity[Logic.challengeCity]
        city:setColor(0)
    end
end

