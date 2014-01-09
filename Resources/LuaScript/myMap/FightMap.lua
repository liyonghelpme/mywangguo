require "myMap.FightPage"
require "myMap.FightMenu"
FightMap = class()
function FightMap:ctor()
    self.bg = CCScene:create()
    self.page = FightPage.new()
    self.bg:addChild(self.page.bg)
    self.menu = FightMenu.new()
    self.bg:addChild(self.menu.bg)
end
