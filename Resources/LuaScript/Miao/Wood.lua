Wood = class(FuncBuild)
function Wood:ctor(b)
    self.baseBuild.maxNum = 20
    self.showState = -1
end

function Wood:initView()
    print("Wood Tree")
    local sz = self.baseBuild.changeDirNode:getContentSize()
    setPos(setAnchor(self.baseBuild.changeDirNode, {306/1024, (768-288)/768}), {0, SIZEY})
    local fence = setPos(createSprite("treeFence.png"), {512, 384})
    self.baseBuild.changeDirNode:addChild(fence, -1) 
end
--砍伐结束 阶段 = 0
function Wood:updateStage(diff)
    if self.baseBuild.state == BUILD_STATE.FREE then
        self.baseBuild.lifeStage = self.baseBuild.lifeStage+diff
        --4 个阶段 每8s 一个阶段
        local s = math.floor(self.baseBuild.lifeStage/8)
        s = math.min(s, 3)
        if s ~= self.showState then
            self.showState = s
            setDisplayFrame(self.baseBuild.changeDirNode, "tree"..(self.showState+1)..'.png')
        end
    end
end
function Wood:updateGoods()
    self.baseBuild.changeDirNode:runAction(repeatN(sequence({moveby(0.1, -5, 0), moveby(0.1, 5, 0)}), 4))
    if self.baseBuild.workNum == 0 then
        self.showState = -1
        self.baseBuild.lifeStage = 0
    end

    local show = math.floor(3*self.baseBuild.workNum/self.baseBuild.maxNum)
    print("update WoodStore Goods", self.baseBuild.workNum, self.baseBuild.maxNum, self.goodsNum, show)
    if self.baseBuild.workNum > 0 then
        show = math.max(1, show)
    end
    if show == self.goodsNum then
        return
    end
    self.goodsNum = show
    if self.goodsObj ~= nil then
        removeSelf(self.goodsObj)
    end
    self.goodsObj = nil
    if show == 0 then
        return
    elseif show == 1 then
        self.goodsObj = createSprite("fall1.png")
    elseif show == 2 then
        self.goodsObj = createSprite("fall2.png")
    elseif show == 3 then
        self.goodsObj = createSprite("fall3.png")
    else
        self.goodsObj = createSprite("fall1.png")
    end

    self.baseBuild.changeDirNode:addChild(self.goodsObj)
    self.goodsObj:runAction(jumpBy(0.5, 0, 0, 10, 1))
    --local sz = self.baseBuild.changeDirNode:getContentSize()
    setPos(self.goodsObj, {512, 384})
    print("setPos", 512)

end
