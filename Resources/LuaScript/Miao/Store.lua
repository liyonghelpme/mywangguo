require "menu.StoreInfo"
Store = class(FuncBuild)
function Store:showInfo()
    local bi
    bi = StoreInfo.new(self.baseBuild)
    global.director:pushView(bi, 1, 0)
    global.director.curScene.menu:setMenu(bi)
end
function Store:updateGoods()
    if self.goods ~= nil then
        removeSelf(self.goods)
    end
    self.goods = CCNode:create()
    self.baseBuild.bg:addChild(self.goods)
    local initX = -40
    for k=1, self.baseBuild.workNum,1 do
        local sp = CCSprite:create("drug0.png")
        setPos(addChild(self.goods, sp), {initX+(k-1)*30, 30})
    end
end
