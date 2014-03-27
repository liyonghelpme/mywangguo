function MiaoPeople:getFastZord()
    local p = getPos(self.bg)
    local zOrd = MAX_BUILD_ZORD-p[2]
    return zOrd
end

function MiaoPeople:setZord()
    local p = getPos(self.bg)
    local zOrd = MAX_BUILD_ZORD-p[2]-1
    self.bg:setZOrder(zOrd)

    if DEBUG then
        self.zordLabel:setString(zOrd)
        print("setNormalZord", self.name, zOrd)
    end
end
function MiaoPeople:setHighZord()
    local p = getPos(self.bg)
    local zOrd = MAX_BUILD_ZORD-p[2]+2
    self.bg:setZOrder(zOrd)

    if DEBUG then
        self.zordLabel:setString(zOrd)
        print("setHighZord", simple.encode(getPos(self.realTarget.bg)), simple.encode(getPos(self.bg)))
        print("setHighZord", self.name, zOrd)
    end
end

function MiaoPeople:setSuperHighZord()
    local p = getPos(self.bg)
    local zOrd = MAX_BUILD_ZORD-p[2]+100
    self.bg:setZOrder(zOrd)
    print("setSuperHighZord", zOrd)
end


function MiaoPeople:stopMoveAction()
    if self.moveAction ~= nil then
        self.changeDirNode:stopAction(self.moveAction)
        self.moveAction = nil
    end
end
function MiaoPeople:setMoveAction(aniName)
    if self.curAni ~= aniName then
        self:stopMoveAction()
        self.curAni = aniName

        if aniName ~= nil then
            local ani = CCAnimationCache:sharedAnimationCache():animationByName(aniName)
            self.moveAction = repeatForever(CCAnimate:create(ani))
            self.changeDirNode:runAction(self.moveAction)
        end
    end
end
function MiaoPeople:setDir(x, y)
    local p = getPos(self.bg)
    local dx = x-p[1]
    local dy = y-p[2]
    if self.send then
        print("setDir of car !!!")
        if dx > 0 then
            if dy > 0 then
                --self.changeDirNode:stopAllActions()
                self:setMoveAction("car_rt")
                if self.carGoods ~= nil then
                    setDisplayFrame(self.carGoods, self.carName[1])
                end
                setDisplayFrame(self.shadow, "shadow0.png")
            elseif dy < 0 then
                --self.changeDirNode:stopAllActions()
                self:setMoveAction("car_rb")
                if self.carGoods ~= nil then
                    setDisplayFrame(self.carGoods, self.carName[2])
                end
                setDisplayFrame(self.shadow, "shadow1.png")
            end
            local sca = getScaleY(self.changeDirNode)
            setScaleX(self.changeDirNode, sca)
            setScaleX(self.shadow, sca)
        elseif dx < 0 then
            if dy > 0 then
                self:setMoveAction("car_rt")
                if self.carGoods ~= nil then
                    setDisplayFrame(self.carGoods, self.carName[1])
                end
                setDisplayFrame(self.shadow, "shadow0.png")
            elseif dy < 0 then
                self:setMoveAction("car_rb")
                if self.carGoods ~= nil then
                    setDisplayFrame(self.carGoods, self.carName[2])
                end
                setDisplayFrame(self.shadow, "shadow1.png")
            end
            local sca = getScaleY(self.changeDirNode)
            setScaleX(self.changeDirNode, -sca)
            setScaleX(self.shadow, -sca)
        end
    else
        local sca = getScaleY(self.changeDirNode)
        if dx > 0 then
            if dy > 0 then
                self:setMoveAction("people"..self.id.."_rt")
            elseif dy < 0 then
                self:setMoveAction("people"..self.id.."_rb")
            end
            setScaleX(self.changeDirNode, sca)
        elseif dx < 0 then
            if dy > 0 then
                self:setMoveAction("people"..self.id.."_rt")
            elseif dy < 0 then
                self:setMoveAction("people"..self.id.."_rb")
            end
            setScaleX(self.changeDirNode, -sca)
        end
    end
end

--从房子里面跳出来了
function MiaoPeople:clearHouse()
    print("clearHouse", self.myHouse)
    self.myHouse = nil
end

--农田被拆除或者移动了
--但是应该由人自己检测 来
--[[
function MiaoPeople:clearWork()
    if self.state == PEOPLE_STATE.IN_WORK then
        self.state = PEOPLE_STATE.FREE
    end
end
--]]
function MiaoPeople:hideSelf()
    if self.lastVisible then
        self.changeDirNode:runAction(fadeout(0.5))
        self.shadow:runAction(fadeout(0.5))
        self.lastVisible = false
    end
end
function MiaoPeople:showSelf()
    if not self.lastVisible then
        self.changeDirNode:runAction(fadein(0.5))
        self.shadow:runAction(fadein(0.5))
        self.lastVisible = true
    end
end

--在回到房屋之后 处理房屋被拆迁的问题
function MiaoPeople:handleHome()
    if self.actionContext == CAT_ACTION.GO_HOME then
        if self.realTarget.deleted then
            self:clearStateStack()
            self:resetState()
        else
            --设定猫的位置 为房间位置 不用了
            local function setNPos()
                local np = setBuildMap({1, 1, self.tempEndPoint[1], self.tempEndPoint[2]})
                setPos(self.bg, np)
            end
            self.changeDirNode:runAction(sequence({delaytime(0.5), callfunc(nil, setNPos)}))

            self.state = PEOPLE_STATE.IN_HOME
            self.restTime = 0
            self:hideSelf()
        end
    end
end
function MiaoPeople:handleStore()
    if self.actionContext == CAT_ACTION.PUT_PRODUCT then
        if self.realTarget.goodsKind == self.goodsKind then
            self.realTarget.workNum = self.realTarget.workNum+self.workNum
            self.realTarget.workNum = math.min(self.realTarget.workNum, self.realTarget.maxNum)
            self.realTarget.funcBuild:updateGoods()
        end
        self.workNum = 0
        self:putGoods()
        self:setDir(1, -1)
        self:popState()
        self:resetState()
        self:hideSelf()
    end
end
function MiaoPeople:handleQuarry()
    if self.actionContext ~= nil then
        if self.actionContext == CAT_ACTION.TAKE_MINE_TOOL then
            print("TAKE_MINE_TOOL")
            if self.realTarget.deleted then
                self:clearStateStack()
            else
                self.realTarget.funcBuild:takeTool()
                self:popState()
            end
            self:resetState()
        elseif self.actionContext == CAT_ACTION.PUT_STONE_QUARRY then
            if self.realTarget.deleted then
                self:clearStateStack()
            else
                self.realTarget:changeWorkNum(self.stone)
                self.stone = 0
                self:popState()
                self:putGoods()
            end
            self:resetState()
        elseif self.actionContext == CAT_ACTION.TAKE_STONE then
            if self.realTarget.deleted then
                self:clearStateStack()
            else

                local goodsKind = self.goodsKind
                --根据商品种类 决定消耗的资源  运送的数量 根据 伐木场上限决定 显示
                local stone = GoodsName[goodsKind].stone
                local mn = self.predictStore.maxNum
                local need = stone*mn
                --只运送需要的数量 测试生产某种酒
                self.stone = math.min(self.realTarget.workNum, need)
                --self.stone = self.predictTarget.workNum
                print("take stone number")
                self.realTarget:takeWorkNum(self.stone)
                self:sendGoods(self.realTarget.maxNum)
                self:popState()
            end
            self:resetState()
        end
    elseif self.stone == 0 then
        --从矿场运送矿石到工厂
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
        --获取工具去采矿 需要矿石
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
                --self.predictQuarry = self.realTarget
                self.tempQuarry = self.realTarget
                self.realTarget.funcBuild:takeTool()
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
        self.realTarget.funcBuild:putTool()
        self.realTarget.funcBuild:updateState()
        self.realTarget = nil
        self.state = PEOPLE_STATE.FREE
    end
end

function MiaoPeople:handleMine()
    print("handleMine now")
    --if self.actionContext == CAT_ACTION.BACK_STONE then
    --else
    if self.actionContext == CAT_ACTION.MINE_STONE then
        self.state = PEOPLE_STATE.IN_WORK
        self.workTime = 0
        self:hideSelf()
    end
end
function MiaoPeople:handleSmith()
    if self.actionContext == CAT_ACTION.PUT_PRODUCT then
        if self.realTarget.goodsKind == self.goodsKind then
            self.realTarget.workNum = self.realTarget.workNum+self.workNum
            self.realTarget.funcBuild:updateGoods()
        end
        self.workNum = 0
        self:popState()
        self:resetState()
    else
        self.realTarget.workNum = self.realTarget.workNum +self.product
        self.realTarget:setOwner(nil)
        self.realTarget = nil
        self.product = 0
        self.state = PEOPLE_STATE.FREE
    end
end

function MiaoPeople:refreshOwner()
    for k, v in ipairs(self.stateStack) do
        if type(v) == 'table' then
            v[2]:setOwner(self)
        end
    end
end
function MiaoPeople:finishHandle()
    self:refreshOwner()
end

function MiaoPeople:adjustScale()
    if self.send == true then
        self.changeDirNode:setScale(0.88)
        self.shadow:setScale(0.88)
    else
        self.changeDirNode:setScale(0.8)
        self.shadow:setScale(0.8)
    end
end
function MiaoPeople:adjustShadow()
    if self.send == true then
        setDisplayFrame(self.shadow, "shadow1.png")
        local sz = self.shadow:getContentSize()
        setPos(setAnchor(self.shadow, {244/512,  (512-357)/512}), {0, SIZEY})
    else
        removeSelf(self.shadow)
        self.shadow = CCSprite:create()
        self.heightNode:addChild(self.shadow, -1)
        --local sz = getContentSize(self.shadow)
        if self.data.girl == 1 then 
            setTexture(self.shadow, "roleShadow1.png")
        else
            setTexture(self.shadow, "roleShadow.png")
        end
        --local sz2 = getContentSize(self.shadow)
        --print("adjust shadow pos and anchor!!!!", simple.encode(sz), simple.encode(sz2))
        local sca = getScaleY(self.changeDirNode)
        setScaleX(setPos(setAnchor(self.shadow, {0.5, 0.5}), {0, SIZEY}), sca)
        --setAnchor(self.shadow, {0.5, 31/512})
    end
end

--清理每个状态的时候 self.food 也要清理一下 根据不同状态类型 调用状态的清理代码
function MiaoPeople:sendGoods(total)
    self.send = true
    self:adjustScale()
    self:adjustShadow()
    --停止移动动作
    setDisplayFrame(self.changeDirNode, "car_rb_0.png")
    self:setMoveAction("car_rb")
    local sca = getScaleY(self.changeDirNode)
    if self.food > 0 then
        local sp = setDisplayFrame(CCSprite:create(), "b3.png")
        self.changeDirNode:addChild(sp)
        local sz = self.changeDirNode:getContentSize()
        setPos(setAnchor(sp, {0.5, 0.5}), {sz.width/2, sz.height/2})
        self.carName = {"a3.png", "b3.png"}
        self.carGoods = sp
    elseif self.stone > 0 then
        if total == nil then
            total = self.stone
        end

        local sp = createSprite("f3.png")
        self.changeDirNode:addChild(sp)
        local sz = self.changeDirNode:getContentSize()
        setPos(setAnchor(sp, {0.5, 0.5}), {sz.width/2, sz.height/2})
        local n = math.max(math.min(math.ceil(self.stone*3/total), 3), 1)
        self.carName = {"e"..n..".png", 'f'..n..'.png'}
        self.carGoods = sp
        setDisplayFrame(sp, self.carName[2])
    elseif self.wood > 0 then
        if total == nil then
            total = self.wood
        end
        local sp = createSprite("d3.png")
        self.changeDirNode:addChild(sp)
        local sz = self.changeDirNode:getContentSize()
        setPos(setAnchor(sp, {0.5, 0.5}), {sz.width/2, sz.height/2})
        --self.fullCarName = {{'c1.png', 'c2.png', 'c3.png'}, {'d1.png', 'd2.png', 'd3.png'}}
        print("total wood number", total, self.wood)
        local n = math.max(math.min(math.ceil(self.wood*3/total), 3), 1)
        self.carName = {"c"..n..".png", 'd'..n..'.png'}
        self.carGoods = sp
        setDisplayFrame(sp, self.carName[2])
    elseif self.workNum > 0 then
        local sp = createSprite("h3.png")
        self.changeDirNode:addChild(sp)
        local sz = self.changeDirNode:getContentSize()
        setPos(setAnchor(sp, {0.5, 0.5}), {sz.width/2, sz.height/2})
        self.carName = {"g3.png", 'h3.png'}
        self.carGoods = sp
    end

    setScaleX(self.changeDirNode, sca)
    self.oldCarPos = getPos(self.changeDirNode)
    self.carVirAct = repeatForever(sequence({moveby(0.2, 0, 5), moveby(0.2, 0, -5)}))
    self.changeDirNode:runAction(self.carVirAct)
end
function MiaoPeople:putGoods()
    if self.send then
        self.send = false
        self:adjustScale()
        --放下物品
        setDisplayFrame(self.changeDirNode, "cat_"..self.id.."_rb_0.png")
        self:setMoveAction("people"..self.id.."_rb")

        local sca = getScaleY(self.changeDirNode)
        setScaleX(self.changeDirNode, sca)
        if self.carGoods ~= nil then
            removeSelf(self.carGoods)
            self.carGoods = nil
        end
        self:adjustShadow()
        self.changeDirNode:stopAction(self.carVirAct)
        setPos(self.changeDirNode, self.oldCarPos)
    end
end

function MiaoPeople:handleFarm()
    --新系统  
    if self.actionContext ~= nil then
        if self.actionContext == CAT_ACTION.TAKE_FOOD then
            if self.realTarget.deleted then
                self:clearStateStack()
            else
                --同一个对象身上可能 会 有多重的
                if self.realTarget.workNum > 0 then
                    self.food = self.realTarget.workNum
                    self.realTarget.workNum = 0
                    self:sendGoods()
                    self:setDir(1, -1)
                    self:popState()
                else
                    self:clearStateStack()
                end
            end
            self:resetState()
        elseif self.actionContext == CAT_ACTION.PLANT_FARM then
            if self.realTarget.deleted then
                self:clearStateStack()
                self:resetState()
            else
                local sf = CCSpriteFrameCache:sharedSpriteFrameCache()
                sf:addSpriteFramesWithFile("cat_labor.plist")
                local ani = createAnimation("cat_labor", "cat_labor_%d.png", 0, 19, 1, 1, true)
                self:setMoveAction("cat_labor")
                --self.changeDirNode:stopAllActions()
                --self.changeDirNode:runAction(repeatForever(CCAnimate:create(ani)))

                local sz = self.changeDirNode:getContentSize()
                setAnchor(self.changeDirNode, {184/sz.width, (sz.height-201)/sz.height})

                self.state = PEOPLE_STATE.IN_WORK
                self.workTime = 0
            end
        end
    end
end

--popState Factory 是当前的目标
--setOwner = self
--而在resetState 的时候 没有检查realTarget 是不是statecontext里面的目标导致被清理了
function MiaoPeople:popState()
    if #self.stateStack > 0 then
        for k, v in ipairs(self.stateStack) do
            if type(v) == 'table' then
                print("state", k, v[1], v[3])
            else
                print('state', k, v)
            end
        end
        local stop = self.stateStack[#self.stateStack]
        self.stateContext = stop
        table.remove(self.stateStack)
        --先去农田 工厂 伐木场 可能 获取资源就不需要多次设定owner了
        local needOcc = stop[4] or true
        if needOcc then
            self.stateContext[2]:setOwner(self)
        end
    else
        self.stateContext = nil
    end
end
function MiaoPeople:beforeHandle()
end
function MiaoPeople:resetState()
    --bug: 为什么realTarget 变成了nil
    if self.realTarget ~= nil then
        if self.stateContext ~= nil then
            if self.stateContext[2] ~= self.realTarget and not (self.needClearOwner == false) then
                if self.realTarget.owner == self then
                    self.realTarget:setOwner(nil)
                end
            end
        else
            if self.realTarget.owner == self then
                self.realTarget:setOwner(nil)
            end
        end
    end
    self.realTarget = nil
    self.state = PEOPLE_STATE.FREE
    self.needClearOwner = true
end
function MiaoPeople:handleFactory()
    print("self.actionContext", self.actionContext)
    if self.actionContext ~= nil then
        if self.actionContext == CAT_ACTION.PUT_WOOD then
            self.realTarget.wood = self.realTarget.wood + self.wood
            self.wood = 0
            self:putGoods()
            self:setDir(1, -1)
            self:popState()
            self:resetState()
            print("popState of wood ")
        elseif self.actionContext == CAT_ACTION.PUT_FOOD then
            if self.realTarget.deleted then
                self:clearStateStack()
            else
                self.realTarget.food = self.realTarget.food + self.food
                self.food = 0
                self:putGoods()
                self:setDir(1, -1)
                self:popState()
            end
            self:resetState()
        elseif self.actionContext == CAT_ACTION.PRODUCT then
            print("begin Product ")
            if self.realTarget.deleted then
                self:clearStateStack()
            else
                self.realTarget.goodsKind = self.goodsKind
                self.state = PEOPLE_STATE.IN_WORK
                self.workTime = 0
                self.realTarget.funcBuild:startWork()
            end
        elseif self.actionContext == CAT_ACTION.PUT_STONE then
            if self.realTarget.deleted then
                self:clearStateStack()
            else
                self.realTarget.stone = self.realTarget.stone + self.stone
                self.stone = 0
                self:putGoods()
                self:setDir(1, -1)
                self:popState()
            end
            self:resetState()
        end
        self:hideSelf()
        return 
    end
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


--计算工厂工作时间 可以cache一下这个时间 下次不用计算
function MiaoPeople:workInFactory()
    local le = self:getMyLaborEffect()
    local totalTime = 10
    local productNum = 5
    local healthCost = 5
    if le.time ~= nil then
        totalTime = totalTime+le.time
    end
    if le.product ~= nil then
        productNum = productNum + le.product
    end
    if le.health ~= nil then
        healthCost = healthCost+le.health
    end
    totalTime = math.max(1, totalTime)
    healthCost = math.max(1, healthCost)
    --计算出1个 的生产时间 和 消耗的 生命值
    local rate = totalTime/productNum
    local cost = healthCost/productNum
    --10s 生产5个

    self.realTarget.funcBuild:updateProcess(self.workTime, rate)
    if self.workTime >= rate then
        self.workTime = self.workTime - rate
        self.health = self.health - cost
        print("product what??", self.realTarget.goodsKind)

        if self.actionContext ~= nil then
            local gn = GoodsName[self.realTarget.goodsKind]
            print("gname", simple.encode(gn))
            local enough = true
            if self.realTarget.food >= (gn.food or 0 ) and self.realTarget.stone >= (gn.stone or 0) and self.realTarget.wood >= (gn.wood or 0) then
                self.realTarget:doProduct() 
            else
                enough = false
            end
            --走向商店 popState --->进入寻路状态 moveto 的过程中使用某个状态动画
            if self.realTarget.workNum >= self.realTarget.maxNum or not enough then
                self.realTarget.funcBuild:stopWork()
                self.workNum = self.realTarget.workNum
                self.realTarget:takeAllWorkNum()
                self.goodsKind = self.realTarget.goodsKind
                self:popState()
                self:sendGoods()
                self:setDir(1, -1)
                self:resetState()
                --self:showSelf()
            end
        end
        --生产结束 直到运送到工厂
    end
end
function MiaoPeople:getMyLaborEffect()
    local pdata = calAttr(self.id,  self.level, self)
    local le = getLaborEffect(pdata.labor)
    return le
end

--把actionList 打出来
--一个action 结束执行下一个action
function MiaoPeople:workInMine()
    --labor 包括自身和 装备总的劳动力
    local le = self:getMyLaborEffect()
    local totalTime = 10
    local productNum = 5
    local healthCost = 5
    if le.time ~= nil then
        totalTime = totalTime+le.time
    end
    if le.product ~= nil then
        productNum = productNum + le.product
    end
    if le.health ~= nil then
        healthCost = healthCost+le.health
    end
    totalTime = math.max(1, totalTime)
    healthCost = math.max(1, healthCost)
    --print("totalTime, productNum healthCost", totalTime, productNum, healthCost)
    --计算出1个 的生产时间 和 消耗的 生命值
    --self.myHouse.productNum 花费时间减少  消耗体力不变
    local rate = totalTime/(self.quarry.productNum/20)/productNum
    local cost = healthCost/productNum

    --print("workInMine", self.workTime, rate, totalTime, productNum, healthCost)
    if self.workTime > rate then
        self.workTime = self.workTime - rate
        self.health = self.health -cost
        --self.realTarget.workNum = self.realTarget.workNum + 1
        self.realTarget:changeWorkNum(1)
        --如果工厂生产数量超过上限 就不要生产了
        --离开矿坑 但是predictQuarry 不会消除
        --print("workInMine", self.goQuarry)
        if self.realTarget.workNum >= self.realTarget.maxNum then
            self.stone = self.realTarget.workNum
            self.realTarget:takeAllWorkNum()
            self:popState()
            self:resetState()
            self:sendGoods()
            self:setDir(1, -1)
            return
        end
    end
end

--10 10 10 10 5 = 5点体力值
--种植的时间 40s 算在这个生产过程里面的 
function MiaoPeople:workInFarm()
    local le = self:getMyLaborEffect()
    local totalTime = 10
    local productNum = 5
    local healthCost = 5
    if le.time ~= nil then
        totalTime = totalTime+le.time
    end
    if le.product ~= nil then
        productNum = productNum + le.product
    end
    if le.health ~= nil then
        healthCost = healthCost+le.health
    end
    totalTime = math.max(1, totalTime)
    healthCost = math.max(1, healthCost)
    --print("totalTime, productNum healthCost", totalTime, productNum, healthCost)
    --计算出1个 的生产时间 和 消耗的 生命值
    --self.myHouse.productNum 花费时间减少  消耗体力不变
    local rate = totalTime/(self.realTarget.productNum/20)/productNum
    local cost = healthCost/productNum

    if self.workTime > rate then
        self.workTime = 0
        --总要消耗掉劳动力 否则 会出现 不停停留在 农田上的情况
        self.health = self.health-cost
        if self.health <= 0 then
            self:clearStateStack()
            self:resetState()
            self:setDir(0, 0)
            local sz = self.changeDirNode:getContentSize()
            setAnchor(self.changeDirNode, {Logic.people[3].ax/sz.width, (sz.height-Logic.people[3].ay)/sz.height})
        else
            --self.health = self.health-cost
            if self.realTarget.workNum >= self.realTarget.maxNum then
                --[[
                self.state = PEOPLE_STATE.FREE
                self.realTarget:setOwner(nil)
                self.realTarget = nil
                --]]
                self:resetState()
                 
                self:setDir(0, 0)
                local sz = self.changeDirNode:getContentSize()
                setAnchor(self.changeDirNode, {Logic.people[3].ax/sz.width, (sz.height-Logic.people[3].ay)/sz.height})
            else
                self.realTarget:changeWorkNum(1)
            end
        end
    end
end
function MiaoPeople:workInHome(diff)
    --[[
    if self.realTarget.deleted then
        self.state = PEOPLE_STATE.FREE
        self.myHouse = nil
    end
    --]]
    self.restTime = self.restTime+diff
    --0.5 恢复一下 共8s 总共16下
    --调整一下时间频率即可
    --增加5% 生命值的时间   
    --大宅子1.5 倍率
    local rate = self.realTarget.data.rate
    local ntime = 1/(self.myHouse.productNum/20)/rate
    if self.restTime >= ntime then
        self.restTime = self.restTime-ntime
        --用小数表示health 但是 休息结束的时候 需要做成 整数 
        local r = math.max(math.floor(self.maxHealth/20), 1)
        self.health = self.health +r
    end
    --下一步开始寻路 去工作
    --如果找到可以工作的地方再出现并且根据 目标调整当前位置
    --找到可以去工作的目标 前提满足了出现在门口位置 四处找一个坐标可以移动
    --调整当前的位置 
    --开始行走
    self.health = math.min(self.health, self.maxHealth)
    if self.health >= self.maxHealth then
        self.tired = false
        self.lastState = PEOPLE_STATE.IN_HOME
        self.lastEndPoint = self.tempEndPoint
        self.state = PEOPLE_STATE.FREE
        --self:showSelf()
    end
end
function MiaoPeople:checkMeInHouse()
    local pxy = getPos(self.bg)
    local map = getPosMapFloat(1, 1, pxy[1], pxy[2]) 
    local housePos = nil
    if self.myHouse and not self.myHouse.deleted then
        local hxy = getBuildMap(self.myHouse)
        if map[3] == hxy[3] and map[4] == hxy[4] then
            return true
        end
    end
    return false
end
function MiaoPeople:showState()
    --拿到矿刀
    --[[
    if self.tempMine ~= nil then
        setTexture(self.statePic, "equip70.png")
    elseif self.stone > 0 then
        setTexture(self.statePic, "herb109.png")
    end
    --]]
end

--移动了之后 清理owner
function MiaoPeople:clearStateStack()
    --应该反向出堆栈 不应该正向
    for k =#self.stateStack, 1, -1 do
        local v = self.stateStack[k]
        if type(v) == 'table' then
            local needClearOwner = v[4] or true
            print("clear My State", needClearOwner, v[1], v[2], v[3], v[4])
            if needClearOwner then
                if v[2].owner == self then
                    v[2]:setOwner(nil)
                end
            end
        end
    end
    --self.needClearOwner = true
    self.stateStack = {}
    self.stateContext = nil
    self.actionContext = nil
    self.funcPeople.moveYet = nil
    
    --清理运输状态
    self:putGoods()
    self:setDir(1, -1)
end

function MiaoPeople:setPos(p)
    setPos(self.bg, p)
    self.funcPeople:setPos()
end
function MiaoPeople:moveSlope(dx, dy, val, cp)
    --就要上坡 下下个目标点高度
    --第一个阶段 走到到斜坡上面
    local mvOff = 6
    local mvDelta = 0.15
    if val == 0 then
        self.slopeAct = sequence({delaytime(self.waitTime/2), moveto(self.waitTime/2, 0, cp)})
        self.changeDirNode:runAction(sequence({delaytime(self.waitTime/2), repeatN(sequence({moveby(mvDelta, 0, mvOff), moveby(mvDelta, 0, -mvOff)}), math.floor(self.waitTime/2/mvDelta/2))}))
    --目标点高度位置 当前在斜坡上
    else
        local cax, cay = newNormalToAffine(cp[1], cp[2], self.map.scene.width, self.map.scene.height, MapWidth/2, FIX_HEIGHT)
        local chei = adjustNewHeight(self.map.scene.mask, self.map.scene.width, cax, cay) 
        self.slopeAct = sequence({moveto(self.waitTime/2, 0, chei*103), delaytime(self.waitTime/2)})
        --跌宕
        self.changeDirNode:runAction(repeatN(sequence({moveby(mvDelta, 0, mvOff), moveby(mvDelta, 0, -mvOff)}), math.floor(self.waitTime/2/mvDelta/2)))
    end
    self.heightNode:runAction(self.slopeAct)
end
function MiaoPeople:checkMoved()
    local moved = false
    if not self.realTarget.deleted then
        local pxy = self.tempEndPoint 
        --check tempEndPoint building is same with curBuilding 
        --local txy = getPos(self.realTarget.bg)

        local map = getBuildMap(self.realTarget)
        --sx sy nx ny
        local sx, sy = map[1], map[2]
        local moveYet = true
        for x = 0, sx-1, 1 do
            for y = 0, sy-1, 1 do
                local ax = x-y
                local ay = x+y
                if (map[3]+ax == pxy[1]) and (map[4]+ay == pxy[2]) then
                    moveYet = false
                    break
                end
            end
        end
        if moveYet then
            addBanner("目标被移动了 "..simple.encode(pxy).." "..simple.encode(map))
            moved = true
        end
        --if map[3] ~= pxy[1] or map[4] ~= pxy[2] then
        --    moved = true
        --end
    end
    return moved
end
function MiaoPeople:printState()
    print("printState", self.name)
    for k, v in ipairs(self.stateStack) do
        if type(v) == 'table' then
            print("state", k, v[1], v[3])
        else
            print('state', k, v)
        end
    end
end
function MiaoPeople:useStateContext()
    print("useStateContext")
    self.predictTarget = self.stateContext[2]
    self.actionContext = self.stateContext[3] 
    self.needClearOwner = self.stateContext.needClearOwner or true
    self.stateContext = nil
end
