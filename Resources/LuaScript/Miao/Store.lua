require "menu.StoreInfo"
Store = class(FuncBuild)
--[[
function Store:showInfo()
    local bi
    bi = StoreInfo.new(self.baseBuild)
    global.director:pushView(bi, 1, 0)
    global.director.curScene.menu:setMenu(bi)
end
--]]
function Store:updateGoods()
    if self.goods ~= nil then
        removeSelf(self.goods)
    end
    self.goods = CCNode:create()
    self.baseBuild.changeDirNode:addChild(self.goods)
    local show = math.floor(6*self.baseBuild.workNum/self.baseBuild.maxNum)
    local showPos = {
        {263, 212},
        {245, 220},
        {228, 231},
        {263, 185},
        {245, 198},
        {228, 209},
    }
    local sz = self.baseBuild.changeDirNode:getContentSize()
    local wt = 0
    for k=1, show, 1 do
        local sp = CCSprite:create("goods6.png")
        setPos(addChild(self.goods, sp), {showPos[k][1], sz.height-showPos[k][2]})
        sp:runAction(sequence({fadeout(0), delaytime(wt), fadein(0.5)}))
        wt = wt+0.2
    end
end
