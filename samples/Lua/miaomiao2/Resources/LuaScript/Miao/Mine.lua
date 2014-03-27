Mine = class(FuncBuild)
function Mine:ctor(b)
    self.baseBuild.maxNum = 20
end
function Mine:initView()
    local sz = self.baseBuild.changeDirNode:getContentSize()
    setPos(setAnchor(self.baseBuild.changeDirNode, {306/1024, (768-288)/768}), {0, SIZEY})
end
--在touch的时候setColor
function Mine:setColor()
    local s = self:checkSlope()
    print("Mine setColor")
    if self.selGrid ~= nil then
        if s == false then
            setTexture(self.selGrid, "newRedGrid.png")
        else
            setTexture(self.selGrid, "newBlueGrid.png")
        end
    end
end
function Mine:checkSlope()
    print("checkSlope", self.baseBuild.colNow, self.baseBuild.otherBuild)
    if self.baseBuild.colNow == 1 then
        if self.baseBuild.otherBuild ~= nil then
            local dir = self.baseBuild.otherBuild.dir
            print("checkMineSlope", self.baseBuild.colNow, self.baseBuild.otherBuild, dir)
            if self.baseBuild.otherBuild.picName == 'slope' and (dir ==0 or dir == 1) then
                return true
            end
        end
    end
    return false
end
function Mine:checkFinish()
    local s = self:checkSlope()
    if s then
        self.baseBuild.map.scene:finishBuild() 
    else
        addBanner("必须建造到斜坡上")
    end
end
function Mine:checkBuildable()
    --return false
    if self.baseBuild.colNow == 1 then
        if self.baseBuild.otherBuild ~= nil then
            local dir = self.baseBuild.otherBuild.dir
            if self.baseBuild.otherBuild.picName == 'slope' and (dir ==0 or dir == 1) then
                return true
            end
        end
        return false
    else
        --必须放斜坡上面
        return false
    end
end

--如果和斜坡碰撞了 调整图片方向
--restore位置的时候 只是上一个有效位置 
function Mine:whenColNow()
    local scaY = getScaleY(self.baseBuild.changeDirNode)
    if self:checkSlope() then
        print("whenColNow Mine", self.baseBuild.colNow, self.baseBuild.otherBuild)
        local dir = self.baseBuild.otherBuild.dir
        --矿洞方向
        self.dir = dir
        if dir == 0 then
            setScaleX(self.baseBuild.changeDirNode, -scaY)
        else
            setScaleX(self.baseBuild.changeDirNode, scaY)
        end
    else
        setScaleX(self.baseBuild.changeDirNode, scaY)
    end
end
function Mine:adjustRoad()
    print("adjust Mine dir")
    self:whenColNow()
end

--放置多个动作 同时出现产生的 位移的问题
function Mine:updateGoods()
    self.baseBuild.changeDirNode:runAction(jumpBy(0.5, 0, 0, 8, 1))
    local scaX = getScaleX(self.baseBuild.changeDirNode)
    --self.baseBuild.changeDirNode:runAction(sequence({scaleto(0.25, 1.05*scaX, 0.95), scaleto(0.25, 1*scaX, 1)}))

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
        self.goodsObj = createSprite("buildStone1.png")
    elseif show == 2 then
        self.goodsObj = createSprite("buildStone2.png")
    elseif show == 3 then
        self.goodsObj = createSprite("buildStone3.png")
    else
        self.goodsObj = createSprite("buildStone1.png")
    end
    self.baseBuild.changeDirNode:addChild(self.goodsObj)
    self.goodsObj:runAction(jumpBy(0.5, 0, 0, 10, 1))
    --local sz = self.baseBuild.changeDirNode:getContentSize()
    setPos(self.goodsObj, {512, 384})
    print("setPos", 512)
end

