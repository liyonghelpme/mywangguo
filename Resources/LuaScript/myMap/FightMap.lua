require "myMap.FightPage"
FightMap = class()
function FightMap:ctor()
    self.bg = CCScene:create()
    self.page = FightPage.new()
    self.bg:addChild(self.page.bg)
end
