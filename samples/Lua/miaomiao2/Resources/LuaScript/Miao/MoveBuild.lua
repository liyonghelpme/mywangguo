MoveBuild = class(FuncBuild)
function MoveBuild:handleTouchEnded()
    if self.baseBuild.moveTarget == nil then
        --print("move collide ", self.baseBuild.otherBuild.picName, self.baseBuild.lastColBuild.picName, self.baseBuild.moveTarget)
        print("move Collide")
        --确认移动建筑物了
        if self.baseBuild.otherBuild ~= nil and self.baseBuild.lastColBuild == self.baseBuild.otherBuild and self.baseBuild.otherBuild.picName == 'build' then
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

                self:clearMoveState()
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
            local nb = MiaoBuild.new(self.baseBuild.map, {picName='build', id=self.baseBuild.moveTarget.id, bid=getBid()})
            local p = normalizePos(np, 1, 1)
            nb:setPos(p)
            nb:setColPos()
            self.baseBuild.map:addBuilding(nb, MAX_BUILD_ZORD)
            nb:setPos(p)
            nb:finishBuild()

            self:clearMoveState()
        end
    end
end
function MoveBuild:canFinish()
    return false
end

function MoveBuild:clearMoveState()
    print("clearMoveState")
    self.baseBuild.lastColBuild = nil
    self.baseBuild.otherBuild = nil
    self.baseBuild.moveTarget = nil
    local tex = CCTextureCache:sharedTextureCache():addImage("build21.png")
    self.baseBuild.changeDirNode:setTexture(tex)
end
