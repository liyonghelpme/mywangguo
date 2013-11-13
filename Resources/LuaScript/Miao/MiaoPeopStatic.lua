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

--在回到房屋之后 处理房屋被拆迁的问题
function MiaoPeople:handleHome()
    self.state = PEOPLE_STATE.IN_HOME
    self.restTime = 0
    --self.bg:setVisible(false)

    local np = setBuildMap({1, 1, self.tempEndPoint[1], self.tempEndPoint[2]})
    setPos(self.bg, np)
end
function MiaoPeople:handleStore()
    --即便商店deleted 掉了 也不用考虑了
    self.realTarget.workNum = self.realTarget.workNum +self.product
    self.realTarget:setOwner(nil)
    self.realTarget = nil
    self.state = PEOPLE_STATE.FREE
end
function MiaoPeople:handleQuarry()
    if self.stone == 0 then
        --获取工具去采矿 需要矿石
        if self.tempFactory ~= nil then
            if self.realTarget.deleted then
                self.realTarget:setOwner(nil)
                self.realTarget = nil
                self.tempFactory:setOwner(nil)
                --不能生产物品了终止
                self.tempFactory.productKind = nil
                self.tempFactory = nil
                self.tempTower:setOwner(nil)
                self.tempTower = nil
                self.state = PEOPLE_STATE.FREE
            else
                self.stone = self.predictTarget.stone
                self.realTarget.stone = 0
                self.realTarget:setOwner(nil)
                self.realTarget = nil
                self.goFactory = true
                self.state = PEOPLE_STATE.FREE
            end
        elseif self.predictMine ~= nil then
            --矿场被拆除了
            if self.realTarget.deleted then
                self.realTarget:setOwner(nil)
                self.realTarget = nil
                self.predictMine:setOwner(nil)
                self.predictMine = nil
                self.state = PEOPLE_STATE.FREE
            else
                --owner 还是 该用户 直到回家休息才放弃owner权限
                self.predictQuarry = self.realTarget
                self.tempMine = self.predictMine
                self.goMine = true
                self.state = PEOPLE_STATE.FREE
            end
        --将矿石运往工厂 生产结束后 运往铁匠铺
        elseif self.predictSmith ~= nil then
            if self.realTarget.deleted then
                self.realTarget = nil
                self.predictSmith:setOwner(nil)
                self.predictSmith = nil
                self.predictFactory:setOwner(nil)
                self.predictFactory = nil
                self.state = PEOPLE_STATE.FREE
            else
                self.stone = self.predictTarget.stone
                self.realTarget.stone = 0
                self.realTarget:setOwner(nil)
                self.realTarget = nil
                self.goFactory = true
                self.tempFactory = self.predictFactory
                self.tempSmith = self.predictSmith
                self.state = PEOPLE_STATE.FREE
            end
        end
    --运送矿石回来
    else
        self.realTarget.stone = self.realTarget.stone+self.stone
        self.stone = 0
        --不要占用采矿场了
        self.realTarget:setOwner(nil)
        self.realTarget = nil
        self.state = PEOPLE_STATE.FREE
    end
end

function MiaoPeople:handleMine()
    self.state = PEOPLE_STATE.IN_WORK
    self.workTime = 0
end
function MiaoPeople:handleSmith()
    self.realTarget.workNum = self.realTarget.workNum +self.product
    self.realTarget:setOwner(nil)
    self.realTarget = nil
    self.product = 0
    self.state = PEOPLE_STATE.FREE
end

function MiaoPeople:handleFarm()
    --销售塔的商品 
    if self.predictTower ~= nil then
        if self.realTarget.deleted then
            self.state = PEOPLE_STATE.FREE
            self.predictFactory:setOwner(nil)
            self.predictFactory = nil
            self.predictTower:setOwner(nil)
            self.predictTower = nil
            self.predictQuarry:setOwner(nil)
            self.predictQuarry = nil
            self.realTarget:setOwner(nil)
            self.realTarget = nil
        else
            self.realTarget:setOwner(nil)
            self.food = self.realTarget.workNum
            self.realTarget.workNum = 0
            self.tempFactory = self.predictFactory
            self.goFactory = true
            self.tempTower = self.predictTower
            self.tempQuarry = self.predictQuarry
            self.state = PEOPLE_STATE.FREE
            self.realTarget = nil
        end
    --拉走去工厂生产食物
    elseif self.predictFactory ~= nil then
        if self.realTarget.deleted then
            print("Farm removed!!!")
            self.state = PEOPLE_STATE.FREE
            self.predictFactory:setOwner(nil)
            self.predictFactory = nil
            self.predictStore:setOwner(nil)
            self.predictStore = nil
            self.realTarget:setOwner(nil)
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
        if self.tempStore ~= nil then
            self.tempStore:setOwner(nil)
            self.tempStore = nil
        end
        if self.tempSmith ~= nil then
            self.tempSmith:setOwner(nil)
            self.tempSmith = nil
        end
        if self.tempQuarry ~= nil then
            self.tempQuarry:setOwner(nil)
            self.tempQuarry = nil
        end
        if self.tempTower ~= nil then
            self.tempTower:setOwner(nil)
            self.tempTower = nil
        end
        self.state = PEOPLE_STATE.FREE
        self.realTarget = nil
    else
        --在工厂工作
        --tempSmith
        --运送商品到商店
        --运送商品到铁匠铺
        --材料没有收集足够接着去收集 石头 = 0 
        if self.tempTower ~= nil and self.realTarget.stone == 0 then
            --去获取 石头
            self.goQuarry = true
            self.tempFactory = self.realTarget
            self.state = PEOPLE_STATE.FREE
            self.realTarget.productKind = 3
        else
            --生产商品
            self.state = PEOPLE_STATE.IN_WORK
            self.workTime = 0
        end
    end
end
function MiaoPeople:handleTower()
    self.realTarget.workNum = self.realTarget.workNum +self.product
    self.product = 0
    self.realTarget:setOwner(nil)
    self.realTarget = nil
    self.state = PEOPLE_STATE.FREE
end

function MiaoPeople:handleWork(diff)
end
