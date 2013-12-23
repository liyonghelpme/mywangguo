Drink = class(FuncBuild)
function Drink:ctor(b)
    self.baseBuild.goodsKind = 4

    self.goodsNum = 0
    self.allGoods = {}
end
function Drink:updateGoods()
    local show = math.floor(6*self.baseBuild.workNum/self.baseBuild.maxNum)
    local showPos = {
        {397, 264},
        {377, 273},
        {360, 282},
        {416, 270},
        {401, 282},
        {378, 297},
    }
    local sz = self.baseBuild.changeDirNode:getContentSize()
    local wt = 0
    self.goodsNum = #self.allGoods
    print("Drink goodsNum", self.goodsNum, show)
    if self.goodsNum < show then
        for k=self.goodsNum+1, show, 1 do
            local sp = CCSprite:create("goods7.png")
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

