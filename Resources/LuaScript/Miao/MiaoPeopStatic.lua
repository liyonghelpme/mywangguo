function MiaoPeople:setZord()
    local p = getPos(self.bg)
    local zOrd = MAX_BUILD_ZORD-p[2]
    self.bg:setZOrder(zOrd)
end

function MiaoPeople:setDir(x, y)
    local p = getPos(self.bg)
    local dx = x-p[1]
    local dy = y-p[2]
    if dx > 0 then
        if dy > 0 then
            self.changeDirNode:stopAllActions()
            local ani = CCAnimationCache:sharedAnimationCache():animationByName("people"..self.id.."_rt")
            self.changeDirNode:runAction(repeatForever(CCAnimate:create(ani)))
        elseif dy < 0 then
            self.changeDirNode:stopAllActions()
            local ani = CCAnimationCache:sharedAnimationCache():animationByName("people"..self.id.."_rb")
            self.changeDirNode:runAction(repeatForever(CCAnimate:create(ani)))
        end
    elseif dx < 0 then
        if dy > 0 then
            self.changeDirNode:stopAllActions()
            local ani = CCAnimationCache:sharedAnimationCache():animationByName("people"..self.id.."_lt")
            self.changeDirNode:runAction(repeatForever(CCAnimate:create(ani)))
        elseif dy < 0 then
            self.changeDirNode:stopAllActions()
            local ani = CCAnimationCache:sharedAnimationCache():animationByName("people"..self.id.."_lb")
            self.changeDirNode:runAction(repeatForever(CCAnimate:create(ani)))
        end
    end
end

--从房子里面跳出来了
function MiaoPeople:clearHouse()
    print("clearHouse", self.myHouse)
    self.myHouse = nil
end

--农田被拆除或者移动了
function MiaoPeople:clearWork()
    if self.state == PEOPLE_STATE.IN_WORK then
        self.state = PEOPLE_STATE.FREE
    end
end

function MiaoPeople:handleFarm()
    --拉走去工厂生产食物
    if self.predictFactory ~= nil then
        if self.realTarget.deleted then
            print("Farm removed!!!")
            self.state = PEOPLE_STATE.FREE
            self.predictFactory:setOwner(nil)
            self.predictFactory = nil
            self.predictStore:setOwner(nil)
            self.predictStore = nil
            self.realTarget = nil
        else
            self.realTarget:setOwner(nil)
            self.food = self.realTarget.workNum
            self.realTarget.workNum = 0
            self.tempFactory = self.predictFactory
            self.goFactory = true
            self.tempStore = self.predictStore
            self.state = PEOPLE_STATE.FREE
            self.realTarget = nil
        end
    --去农田劳作生产粮食
    else
        if self.realTarget.deleted then
            self.state = PEOPLE_STATE.FREE
            self.realTarget = nil
        else
            self.state = PEOPLE_STATE.IN_WORK
            self.workTime = 0
        end
    end
end

function MiaoPeople:handleFactory()
    --运送粮食
    if self.food ~= nil then
        self.realTarget.food = self.realTarget.food + self.food
        self.food = 0
    end
    --运送石头
    if self.stone > 0 then
        self.realTarget.stone = self.realTarget.stone + self.stone
        self.stone = 0
    end
    --在工厂生产产品运到目的地 结果工厂被拆除了
    if self.realTarget.deleted then
        if self.predictStore ~= nil then
            self.predictStore:setOwner(nil)
            self.predictStore = nil
        end
        if self.predictSmith ~= nil then
            self.predictSmith:setOwner(nil)
            self.predictSmith = nil
        end
        self.state = PEOPLE_STATE.FREE
        self.realTarget = nil
    else
        --在工厂工作
        --tempSmith
        --运送商品到商店
        --运送商品到铁匠铺
        if self.predictStore ~= nil then
        elseif self.predictSmith ~= nil then
        else
            --生产商品
            self.state = PEOPLE_STATE.IN_WORK
            self.workTime = 0
        end
    end
end
