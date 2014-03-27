ItemShop = class(FuncBuild)
function ItemShop:ctor(b)
    self.goodsNum = 0
    self.allGoods = {}
end
function ItemShop:updateGoods()
    --[[
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
    --]]
end
function ItemShop:getIncWord()
    return "贩卖"
end
function ItemShop:detailDialog()
    global.director:pushView(StoreInfo2.new(self.baseBuild), 1)
end
