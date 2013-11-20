
Farm = class(FuncBuild)
--workNum 有个最大值
function Farm:ctor()
    self.bg = CCNode:create()
    self.baseBuild.bg:addChild(self.bg)
    registerEnterOrExit(self)
    self.state = 0
end
function Farm:enterScene()
    registerUpdate(self)
end
function Farm:update(diff)
    --print("farm update", diff, self.baseBuild.workNum)
    if self.baseBuild.workNum >0 and self.baseBuild.workNum < 4 then
        if self.state ~= 1 then
            self.state = 1
            if self.fn == nil then
                self.fn = CCSprite:create("p0.png")
                self.baseBuild.bg:addChild(self.fn)
                setPos(self.fn, {0, 40})
            else
                local tex = CCTextureCache:sharedTextureCache():addImage("p0.png")
                self.fn:setTexture(tex)
            end
        end
    elseif self.baseBuild.workNum >= 4 and self.baseBuild.workNum < 7 then
        if self.state ~= 2 then
            self.state = 2
            if self.fn == nil then
                self.fn = CCSprite:create("p1.png")
                self.baseBuild.bg:addChild(self.fn)
                setPos(self.fn, {0, 40})
            else
                local tex = CCTextureCache:sharedTextureCache():addImage("p1.png")
                self.fn:setTexture(tex)
            end
        end
    elseif self.baseBuild.workNum >= 7 then
        if self.state ~= 3 then
            self.state = 3
            if self.fn == nil then
                self.fn = CCSprite:create("p2.png")
                self.baseBuild.bg:addChild(self.fn)
                setPos(self.fn, {0, 40})
            else
                local tex = CCTextureCache:sharedTextureCache():addImage("p2.png")
                self.fn:setTexture(tex)
            end
        end
    elseif self.baseBuild.workNum == 0 then
        self.state = 0
        if self.fn ~= nil then
            removeSelf(self.fn)
            self.fn = nil
        end
    end
end

function Farm:exitScene()
end

function Farm:initState()
end
function Farm:finishBuild()
    self.baseBuild:doMyEffect()
end
function Farm:removeSelf()
    if self.baseBuild.owner ~= nil then
        self.baseBuild.owner:clearWork()
        self.baseBuild.owner = nil
    end
end
function Farm:finishMove()
    if self.owner ~= nil then
        self.owner:clearWork()
        self.owner = nil
    end
end

function Farm:setBuyer(b)
    self.buyer = b
end
function Farm:clearBuyer()
    self.buyer = nil
end
--农田没有购买者
function Farm:checkBuyer()
    return self.buyer == nil
end



MoveBuild = class(FuncBuild)
function MoveBuild:handleTouchEnded()
    if self.baseBuild.moveTarget == nil then
        --print("move collide ", self.baseBuild.otherBuild.picName, self.baseBuild.lastColBuild.picName, self.baseBuild.moveTarget)
        print("move Collide")
        --确认移动建筑物了
        if self.baseBuild.lastColBuild == self.baseBuild.otherBuild and self.baseBuild.otherBuild.picName == 'build' then
            local tex = self.baseBuild.otherBuild.changeDirNode:getTexture()
            --确认当前移动的建筑物
            self.baseBuild.changeDirNode:setTexture(tex)
            self.baseBuild.moveTarget = self.baseBuild.otherBuild

            self.baseBuild.moveTarget:clearEffect()
            self.baseBuild.moveTarget:clearMyEffect()
        else
            self.baseBuild.lastColBuild = self.baseBuild.otherBuild
        end
    --如果上次点击位置 和这次位置一样 则 确认移动  要移动的目的地和原来的目的地相同则不变
    --之后需要加上朝向direction
    else
        print("moveBuilding now finish 没有移动位置", self.baseBuild.accMove)
        if self.baseBuild.accMove < 20 then 
            if self.baseBuild.otherBuild == self.baseBuild.moveTarget then
                local p = getPos(self.baseBuild.bg)
                self.baseBuild.moveTarget:moveToPos(p)
                self.baseBuild.moveTarget:doEffect()
                self.baseBuild.moveTarget:doMyEffect()

                self.baseBuild:clearMoveState()
            else
                addBanner("不能在这里建造！")
            end
        end
    end
end
function MoveBuild:handleFinMove()
    if self.baseBuild.moveTarget ~= nil then
        print("sure to move", self.baseBuild.accMove)
        if self.baseBuild.accMove < 20 then
            local np = getPos(self.baseBuild.bg)
            --移除旧的建筑物
            print("remove oldBuilding")
            self.baseBuild.moveTarget:removeSelf()
            --新的位置新建一个新的建筑物
            
            print("add NewBuilding")
            local nb = MiaoBuild.new(self.baseBuild.map, {picName='build', id=self.baseBuild.moveTarget.id})
            local p = normalizePos(np, 1, 1)
            nb:setPos(p)
            nb:setColPos()
            self.baseBuild.map:addBuilding(nb, MAX_BUILD_ZORD)
            nb:setPos(p)
            nb:finishBuild()

            self.baseBuild:clearMoveState()
        end
    end
end


RemoveBuild = class(FuncBuild)
function RemoveBuild:handleTouchEnded()
    if type(self.baseBuild.otherBuild) == 'table' then
        print("removeBuilding", self.baseBuild.otherBuild, type(self.baseBuild.otherBuild))
        if self.baseBuild.lastColBuild == self.baseBuild.otherBuild then
            --self.baseBuild.map:removeBuilding(self.baseBuild.otherBuild)
            --只能移除 建筑物 和 道路
            if self.baseBuild.otherBuild.picName == 'build' or self.baseBuild.otherBuild.picName == 't' then
                self.baseBuild.otherBuild:removeSelf()
                self.baseBuild.lastColBuild = nil
                self.baseBuild.otherBuild = nil
            end
        else
            self.baseBuild.lastColBuild = self.baseBuild.otherBuild
        end
    end
end
