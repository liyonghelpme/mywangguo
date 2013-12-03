require "myMap.NewPage"
MapScene = class()
function MapScene:ctor()
    self.bg = CCScene:create()
    self.page = NewPage.new()
    self.bg:addChild(self.page.bg)
end
