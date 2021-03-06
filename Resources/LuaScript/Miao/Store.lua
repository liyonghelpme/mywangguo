require "menu.StoreInfo2"
Store = class(FuncBuild)
function Store:ctor(b)
    self.goodsNum = 0
    self.allGoods = {}
end
function Store:updateGoods()
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
            setPos(addChild(self.baseBuild.changeDirNode, sp), {showPos[k][1]*0.8, (sz.height-showPos[k][2]*0.8)})
            sp:setOpacity(0)
            sp:runAction(sequence({delaytime(wt), fadein(0.5)}))
            table.insert(self.allGoods, sp)
            wt = wt+0.2
        end
    elseif self.goodsNum > show then
        for k=self.goodsNum, show+1, -1 do
            local sp = table.remove(self.allGoods)
            sp:runAction(sequence({fadeout(0.5), callfunc(nil, removeSelf, sp)}))
        end
    end
end
function Store:getIncWord()
    return "贩卖"
end
--[[
function Store:showDecrease(n)
    local sp = ui.newButton({image="info.png", conSize={100, 45}, text="贩卖 -"..n, color={102, 10, 10}, size=25})
    self.baseBuild.map.bg:addChild(sp.bg)
    local wp = self.baseBuild.heightNode:convertToWorldSpace(ccp(0, 100))
    local np = self.baseBuild.map.bg:convertToNodeSpace(wp)
    setPos(sp.bg, {np.x, np.y})
    sp.bg:runAction(sequence({moveby(1, 0, 20), callfunc(nil, removeSelf, sp.bg)}))
    self.baseBuild.productNum = self.baseBuild.productNum-n
end
function Store:showIncrease(n)
    local sp = ui.newButton({image="info.png", conSize={100, 45}, text="贩卖 +"..n, color={0, 0, 0}, size=25})
    self.baseBuild.map.bg:addChild(sp.bg)
    local wp = self.baseBuild.heightNode:convertToWorldSpace(ccp(0, 100))
    local np = self.baseBuild.map.bg:convertToNodeSpace(wp)
    setPos(sp.bg, {np.x, np.y})
    sp.bg:runAction(sequence({moveby(1, 0, 20), callfunc(nil, removeSelf, sp.bg)}))
    self.baseBuild.productNum = self.baseBuild.productNum+n
end
--]]
function Store:detailDialog()
    global.director:pushView(StoreInfo2.new(self.baseBuild), 1)
end
