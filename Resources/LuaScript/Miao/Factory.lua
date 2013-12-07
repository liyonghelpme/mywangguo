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
    bi = FactoryInfo.new(self.baseBuild)
    global.director:pushView(bi, 1, 0)
    global.director.curScene.menu:setMenu(bi)
end
function Factory:startWork()
    if self.banner == nil then
        local banner = setSize(CCSprite:create("probg.png"), {100, 27})
        local pro = display.newScale9Sprite("pro1.png")
        banner:addChild(pro)
        setAnchor(setPos(pro, {27, fixY(76, 40)}), {0, 0.5})
        setPos(banner, {271, fixY(280, 91)})
        self.banner = banner
        setPos(self.banner, {0, 90})
        self.baseBuild.bg:addChild(banner, 1)
        self.bg = banner
        self.passTime = 0
        self.pro = pro
        registerEnterOrExit(self)
        print("registerEnterOrExit factory")
        registerUpdate(self)
    end
end
function Factory:enterScene()
    print("factory enterScene")
end
function Factory:update(diff)
    --print("Factory", self.passTime)
    setProNum(self.pro, self.passTime, 1)
    self.passTime = self.passTime+diff
    if self.passTime > 1 then
        self.passTime = 0
    end
end
function Factory:stopWork()
    removeSelf(self.banner)
    self.bg = nil
    self.banner = nil
end


