require "menu.StoreInfo"
Store = class(FuncBuild)
function Store:showInfo()
    local bi
    bi = StoreInfo.new(self.baseBuild)
    global.director:pushView(bi, 1, 0)
    global.director.curScene.menu:setMenu(bi)
end
