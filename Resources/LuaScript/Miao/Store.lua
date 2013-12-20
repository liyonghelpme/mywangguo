require "menu.StoreInfo"
Store = class(FuncBuild)
function Store:ctor(b)
    self.goodsNum = 0
    self.allGoods = {}
end
--[[
function Store:showInfo()
    local bi
    bi = StoreInfo.new(self.baseBuild)
    global.director:pushView(bi, 1, 0)
    global.director.curScene.menu:setMenu(bi)
end
--]]
function Store:updateGoods()
    --[[
    if self.goods ~= nil then
        removeSelf(self.goods)
    end

    self.goods = CCNode:create()
    self.baseBuild.changeDirNode:addChild(self.goods)
    --]]

    local show = math.floor(6*self.baseBuild.workNum/self.baseBuild.maxNum)
    --local sz = {width=1024, height=768}
    local showPos = {
        {408, 271},
        {386, 286},
        {363, 295},
        {427, 284},
        {405, 294},
        {383, 304},
    }
    local sz = self.baseBuild.changeDirNode:getContentSize()
    local wt = 0
    self.goodsNum = #self.allGoods
    if self.goodsNum < show then
        for k=self.goodsNum+1, show, 1 do
            local sp = CCSprite:create("goods6.png")
            setPos(addChild(self.baseBuild.changeDirNode, sp), {showPos[k][1], sz.height-showPos[k][2]})
            sp:setOpacity(0)
            sp:runAction(sequence({delaytime(wt), fadein(0.5)}))
            table.insert(self.allGoods, sp)
            wt = wt+0.2
        end
    elseif self.goodsNum > show then
        for k=self.goodsNum, show, -1 do
            local sp = table.remove(self.allGoods)
            sp:runAction(sequence({fadeout(0.5), callfunc(nil, removeSelf, sp)}))
        end
    end
end
