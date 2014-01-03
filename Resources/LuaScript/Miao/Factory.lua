require "menu.FactoryInfo"
Factory = class(FuncBuild)
function Factory:setWorker(b)
    self.worker = b
end
function Factory:clearWorker(b)
    self.worker = nil
end
--[[
function Factory:showInfo()
    local bi
    bi = FactoryInfo.new(self.baseBuild)
    global.director:pushView(bi, 1, 0)
    global.director.curScene.menu:setMenu(bi)
end
--]]
function Factory:startWork()
    if self.banner == nil then
        local banner = setSize(CCSprite:create("probg.png"), {200, 38})
        local pro = display.newScale9Sprite("pro1.png")
        banner:addChild(pro)
        setAnchor(setPos(pro, {27, fixY(76, 40)}), {0, 0.5})
        setPos(banner, {271, fixY(280, 91)})
        self.banner = banner
        setPos(self.banner, {0, 240})
        self.baseBuild.heightNode:addChild(banner, 1)
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

function Factory:getIncWord()
    return "生产"
end
--[[
function Factory:showDecrease(n)
    local sp = ui.newButton({image="info.png", conSize={100, 45}, text="生产 -"..n, color={102, 10, 10}, size=25})
    self.baseBuild.map.bg:addChild(sp.bg)
    local wp = self.baseBuild.heightNode:convertToWorldSpace(ccp(0, 100))
    local np = self.baseBuild.map.bg:convertToNodeSpace(wp)
    setPos(sp.bg, {np.x, np.y})
    sp.bg:runAction(sequence({moveby(1, 0, 20), callfunc(nil, removeSelf, sp.bg)}))
    self.baseBuild.productNum = self.baseBuild.productNum-n
end
function Factory:showIncrease(n)
    local sp = ui.newButton({image="info.png", conSize={100, 45}, text="生产 +"..n, color={0, 0, 0}, size=25})
    self.baseBuild.map.bg:addChild(sp.bg)
    local wp = self.baseBuild.heightNode:convertToWorldSpace(ccp(0, 100))
    local np = self.baseBuild.map.bg:convertToNodeSpace(wp)
    setPos(sp.bg, {np.x, np.y})
    sp.bg:runAction(sequence({moveby(1, 0, 20), callfunc(nil, removeSelf, sp.bg)}))
    self.baseBuild.productNum = self.baseBuild.productNum+n
end
--]]

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


function Factory:detailDialog()
    global.director:pushView(StoreInfo2.new(self.baseBuild), 1)
end

