require "menu.FactoryInfo"
Factory = class(FuncBuild)
function Factory:setWorker(b)
    self.worker = b
end
function Factory:clearWorker(b)
    self.worker = nil
end
function Factory:showInfo()
    local bi
    bi = FactoryInfo.new(self)
    global.director:pushView(bi, 1, 0)
    global.director.curScene.menu:setMenu(bi)
end


Store = class(FuncBuild)
