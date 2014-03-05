Wood = class(FuncBuild)
function Wood:ctor(b)
    self.baseBuild.maxNum = 20
    self.showState = -1
    self.lastTime = 0
end

function Wood:initView()
    print("Wood Tree")

    local rx = math.random(10)
    local ry = math.random(10)
    local sz = self.baseBuild.changeDirNode:getContentSize()
    setPos(setAnchor(self.baseBuild.changeDirNode, {306/1024, (768-288)/768}), {0+rx, SIZEY+ry})
    self.baseBuild.heightNode:addChild(self.baseBuild.changeDirNode)
    self.baseBuild.addYet = true

    local rd = math.random(2)
    if rd == 1 then
        self.leaf2 = createSprite("tree4_leaf.png")
        self.baseBuild.heightNode:addChild(self.leaf2)
        setPos(setAnchor(self.leaf2, {306/1024, (768-288)/768}), {0+rx, SIZEY+ry})
        setVisible(self.leaf2, false)
    end


    local fence = setPos(createSprite("treeFence.png"), {512, 384})
    self.baseBuild.changeDirNode:addChild(fence, -1) 
    self.fence = fence
end
--砍伐结束 阶段 = 0
--降低建筑物更新频率
function Wood:updateStage(diff)
    self.lastTime = self.lastTime+diff
    if self.lastTime > 1 then
        if self.baseBuild.state == BUILD_STATE.FREE then
            self.baseBuild.lifeStage = self.baseBuild.lifeStage+diff
            self.baseBuild:setDirty()
            --4 个阶段 每8s 一个阶段
            local s = math.floor(self.baseBuild.lifeStage/8)
            s = math.min(s, 3)
            if s ~= self.showState then
                self.showState = s
                setDisplayFrame(self.baseBuild.changeDirNode, "tree"..(self.showState+1)..'.png')
                if self.leaf2 ~= nil then
                    if self.showState == 3 then
                        setVisible(self.leaf2, true)
                    else
                        setVisible(self.leaf2, false)
                    end
                end
            end
        end
    end
end

function Wood:showAnimation()
    self.baseBuild.changeDirNode:runAction(repeatN(sequence({moveby(0.1, -5, 0), moveby(0.1, 5, 0)}), 1))
end

function Wood:updateGoods()
    if self.baseBuild.workNum == 0 then
        self.showState = -1
        self.baseBuild.lifeStage = 0
        self.baseBuild:setDirty()
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
function Wood:setOperatable(a)
    if self.leaf2 ~= nil then
        if not self.baseBuild.operate then
            setColor(self.leaf2, {128, 128, 128})
        else
            setColor(self.leaf2, {255, 255, 255})
        end
    end

    if a then
        setColor(self.fence, {255, 255, 255})
    else
        setColor(self.fence, {128, 128, 128})
    end
end
