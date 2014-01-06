CAT_ACTION = {
    TAKE_STONE=0,
    TAKE_FOOD=1,
    PUT_FOOD=2,
    PRODUCT=3,
    PUT_PRODUCT=4,
    PLANT_FARM=5,
    PUT_STONE=6,
    
    PUT_STONE_QUARRY=7,
    MINE_STONE=8,
    TAKE_MINE_TOOL=9,

    MER_BACK=10,
    BUY_GOODS=11,
    GO_HOME = 12,

    CHECK_ACCESS = 13,

    PUT_WOOD_LUMBER = 14,
    LOGGING = 15,
    TAKE_WOOD_TOOL = 16,

    PUT_WOOD = 17,
    TAKE_WOOD = 18,
    --WOOD_CENTER=17,
    --移动到树木位置开始伐木
    --MOVE_CUT = 17,

    --运送矿石到采矿场
    --BACK_STONE = 14,
}

Cat2 = class(FuncPeople)
function Cat2:initView()
    local sf = CCSpriteFrameCache:sharedSpriteFrameCache()
    sf:addSpriteFramesWithFile(string.format("cat_%d_jump.plist", self.people.id))
    local ani = createAnimation(string.format("cat_%d_jump", self.people.id), "cat_"..self.people.id.."_jump_%d.png", 0, 12, 1, 2, true)
    self.people.changeDirNode = CCSprite:createWithSpriteFrame(sf:spriteFrameByName(string.format("cat_%d_jump_0.png", self.people.id)))
    local sz = self.people.changeDirNode:getContentSize()
    --在当前基础上再缩小0.8 倍率 0.64 * 0.8 = 0.512 尺寸 然后是位置
    setPos(setScale(setAnchor(self.people.changeDirNode, {Logic.people[self.people.id].ax/sz.width, (sz.height-Logic.people[self.people.id].ay)/sz.height}), 0.8), {0, SIZEY})
    
    if self.people.privData.needAppear == false then
    else
        self.people.changeDirNode:runAction(CCAnimate:create(ani))
    end

    sf:addSpriteFramesWithFile("cat_smoke.plist")
    local ani = createAnimation("cat_smoke", "cat_smoke_%d.png", 0, 12, 1, 2, true)
    self.people.smoke = CCSprite:createWithSpriteFrame(sf:spriteFrameByName("cat_smoke_0.png"))
    local sz = self.people.smoke:getContentSize()
    setPos(setScale(setAnchor(self.people.smoke, {147/sz.width, (sz.height-208)/sz.height}), 1.4), {0, SIZEY})
    self.people.heightNode:addChild(self.people.smoke, 1)
    
    self.people.smoke:runAction(sequence({CCAnimate:create(ani), callfunc(nil, removeSelf, self.people.smoke)}))

    sf:addSpriteFramesWithFile(string.format("cat_%d_walk.plist", self.people.id))
    --需要调整scaleX 的值 类似于小车
    local aniTime = 1
    if self.people.data.skill == 42 then
        aniTime = 0.5
    end
    self.people.rbMove = createAnimation(string.format("people%d_rb", self.people.id), "cat_"..self.people.id.."_rb_%d.png", 0, 9, 1, aniTime, true)
    self.people.lbMove = createAnimation(string.format("people%d_lb", self.people.id), "cat_"..self.people.id.."_rb_%d.png", 0, 9, 1, aniTime, true)
    self.people.rtMove = createAnimation(string.format("people%d_rt", self.people.id), "cat_"..self.people.id.."_rt_%d.png", 0, 9, 1, aniTime, true)
    self.people.ltMove = createAnimation(string.format("people%d_lt", self.people.id), "cat_"..self.people.id.."_rt_%d.png", 0, 9, 1, aniTime, true)

    if self.people.data.girl == 1 then 
        self.people.shadow = CCSprite:create("roleShadow1.png")
    else
        self.people.shadow = CCSprite:create("roleShadow.png")
    end
    self.people.heightNode:addChild(self.people.shadow, -1)

    setScale(setPos(self.people.shadow, {0, SIZEY}), 0.8)
    self.people.shadow:runAction(sequence({scaleto(1, 0.6, 0.6), scaleto(1, 0.8, 0.8)}))

    --self.passTime = 0
    --registerEnterOrExit(self)

    self.people.stateLabel = ui.newBMFontLabel({text=str(self.people.state), size=30})
    setPos(self.people.stateLabel, {0, 100})
    self.people.heightNode:addChild(self.people.stateLabel, 10)
    if not DEBUG then
        setVisible(self.people.stateLabel, false)
    end


    sf:addSpriteFramesWithFile("car.plist")
    print("add car plist")
    self.carrbMove = createAnimation("car_rb", "car_rb_%d.png", 0, 9, 1, 1, true)
    self.carrtMove = createAnimation("car_rt", "car_rt_%d.png", 0, 9, 1, 1, true)


    local banner = setSize(CCSprite:create("probg.png"), {200, 38})
    local pro = display.newScale9Sprite("pro1.png")
    banner:addChild(pro)
    setAnchor(setPos(pro, {27, fixY(76, 40)}), {0, 0.5})
    setPos(banner, {271, fixY(280, 91)})
    self.banner = banner
    setPos(self.banner, {0, 200})
    self.people.heightNode:addChild(self.banner)
    self.pro = pro

    self.people.actionLabel = ui.newBMFontLabel({text=str(0), color={255, 0, 0}, size=25})
    self.people.heightNode:addChild(self.people.actionLabel, 1)
    setPos(self.people.actionLabel, {0, 200})
    if not DEBUG then
        setVisible(banner, false)
        setVisible(self.people.actionLabel, false)
    end
end
function Cat2:updateState(diff)
    setProNum(self.pro, self.people.health, self.people.maxHealth)
end

function Cat2:checkWork(k)
    local ret = false
    --两种情况 给 其它工厂运输农作物 丰收状态 
    --生产农作物
    --先不允许并行处理
    print("checkWork", k.id, k,owner)
    if k.picName == 'build' and k.owner == nil then
        --farm
        if k.id == 2 then
            ret = (k.state == BUILD_STATE.FREE and k.workNum < k.maxNum)
        elseif k.data.IsStore == 1 then
            --print('try goto store')
            ret = k.state == BUILD_STATE.FREE and k.workNum < k.maxNum
        elseif k.id == 12 then
            print("mine stone", k.stone)
            ret = k.workNum < k.maxNum 
        --铁匠铺可以生产物品
        elseif k.id == 19 then
            print("lumber ")
            ret = k.workNum < k.maxNum
        elseif k.id == 11 then
            --ret = k.stone ~= nil and k.stone > 0 
        --灯塔可以生产
        elseif k.id == 14 then
            ret = k.workNum < k.maxNum
        end
        --工厂 空闲状态 没有粮食储备 且没有其它用户 
    end
    return ret
end

function Cat2:findTarget()
    local allPossible = {}
    local allFreeFactory = {}
    local allFreeStore = {}
    local allFreeMine = {}
    local allFreeSmith = {}
    local allFreeQuarry = {}
    local allBuild
    local allFoodFarm = {}
    local allStoneQuarry = {}
    local allWoodLumber = {}
    --只要建筑物不移动 这些数据都不会改变的 所以只需要寻路一次即可
    self.allPossible = allPossible
    self.allFreeFactory = allFreeFactory
    self.allFreeStore = allFreeStore
    self.allFreeMine = allFreeMine
    self.allFreeSmith = allFreeSmith
    self.allFreeQuarry = allFreeQuarry
    self.allFoodFarm = allFoodFarm
    self.allStoneQuarry = allStoneQuarry
    self.allWoodLumber = allWoodLumber

    --规划一个 附近可能建筑物的列表 和 附近建筑物的寻路方法10*10 的格子
    print("path dirty ", self.people.dirty)
    --初始化路径信息
    if self.people.miaoPath.allBuilding == nil or self.people.dirty == true then
        self.people.dirty = false
        print("miao Path init find!!!!!!!!!!!!")
        local p = getPos(self.people.myHouse.bg)
        local mxy = getPosMapFloat(1, 1, p[1], p[2])
        local mx, my = mxy[3], mxy[4]
        self.people.miaoPath:init(mx, my)
        --寻找目标开始 miaoPath 未初始化
        table.insert(self.people.stateStack, self.people.state)
        self.people.state = PEOPLE_STATE.FIND_NEAR_BUILDING
    --寻找房屋
    else
        allBuild = self.people.miaoPath.allBuilding
        for k, v in pairs(allBuild) do
            --休息结束
            --找农田
            local ret = false
            --商人 不需要 占用 建筑物
            if k.deleted == false then
                print("build kind ", k.id, k.food, k.owner, k.workNum)
                ret = self:checkWork(k)
                --空闲工厂 没有生产产品
                if k.id == 5 and k.owner == nil then
                    print("free factory")
                    table.insert(allFreeFactory, k)
                end
                --普通商店
                if k.id == 6 and k.workNum < 10 and k.owner == nil then
                    table.insert(allFreeStore, k)
                end
                --矿坑
                if k.id == 11 and k.owner == nil then
                    table.insert(allFreeMine, k)
                end
                --铁匠铺 测试酒水 
                if k.id == 13 and k.workNum < k.maxNum and k.owner == nil then
                    table.insert(allFreeSmith, k)
                end

                --可以收集的 农田和矿市场 
                if k.id == 2 and k.workNum > 0 then
                    table.insert(allFoodFarm, k)
                end
                --采矿场
                if k.id == 12 and k.workNum > 0 then
                    table.insert(allStoneQuarry, k)
                end
                if k.id == 19 and k.workNum > 0 then
                    table.insert(allWoodLumber, k)
                end
                if k.id == 12 and k.owner == nil then
                    table.insert(allFreeQuarry, k)
                end
            end

            --print("building state", ret)
            if ret then
                table.insert(allPossible, k)
            end
        end
    end

    print("people kind", self.people.data.kind)
    if allBuild ~= nil then
        print("allBuildNum", getLen(allBuild))
    end
    print("allPossible", #allPossible)
    print("allFreeFactory num", #allFreeFactory)
    print("allFreeStore num", #allFreeStore)
    print("allFreeSmith num", #allFreeSmith)
    print("allFreeMine num", #allFreeMine)
    print("allFoodFarm num", #allFoodFarm)
    print("allStoneQuarry num", #allStoneQuarry)
    print("allFreeQuarry num", #allFreeQuarry)
    global.director.curScene.menu.stateLabel:setString(string.format("allPossible %d\nallFoodFarm %d\nallStoneQuarry %d\n", #allPossible, #allFoodFarm, #allStoneQuarry))

    if #allPossible > 0 then
        --按照建筑物的距离排序
        self:sortBuildings(allPossible)
        self:checkAllPossible() 
    end
end
function Cat2:sortBuildings(blist)
    local myp = getPos(self.people.bg)
    local function cmp(a, b)
        local ap = getPos(a.bg)
        local bp = getPos(b.bg)
        local ad = mdist(myp, ap) 
        local bd = mdist(myp, bp)
        return ad < bd
    end
    table.sort(blist, cmp)
end
function Cat2:checkAllPossible()
    --按照距离排序的建筑物
    for _, k in ipairs(self.allPossible) do
        --print("allPossible", k.id)
        --新商店只有 粮食物品
        if k.data.IsStore == 1 then
            local nbuilding = k.buildPath.nearby
            local allFreeFactory = {}
            local allFoodFarm = {}
            local allStoneQuarry = {}

            print("store Factory")
            local storeFactory = k.buildPath:getAllFreeFactory()

            local food = GoodsName[k.goodsKind].food
            local wood = GoodsName[k.goodsKind].wood
            local stone = GoodsName[k.goodsKind].stone

            local gotoFarm = nil
            local farmFac = nil
            local quarryFac = nil
            local lumberFac = nil
            local gotoQuarry = nil
            local gotoLumber = nil
            --如果工厂 food = 0 且 farm 可以到达工厂则 去这个工厂 ---> PRODUCT　 的时候检查没有产品　 那么就放弃这次工作重新寻路　 找另外一种资源　 
            --farmFactory 包含 food > 0 的工厂
            --quarryFactory 包含 stone > 0 的工厂
            local allPosFac = {}
            if food > 0 then
                self:sortBuildings(self.allFoodFarm)
                --寻找 农田附近的空闲工厂 
                --和 商店附近的空闲工厂
                for nk, nv in ipairs(self.allFoodFarm) do
                    local tempFactory = nv.buildPath:getAllFreeFactory()
                    local interFac = interSet(tempFactory, storeFactory)  
                    if interFac.count > 0 then
                        gotoFarm = nv
                        farmFac = interFac
                        farmFac.count = nil
                        table.insert(allPosFac, farmFac)
                        break
                    end
                end
            end
            --如果停止的位置 不能去 采矿 怎么办？
            --findPath Error gotoHome 即可
            print("stone factory")
            if stone > 0 then
                self:sortBuildings(self.allStoneQuarry)
                print("get stone Quarry factory", #self.allStoneQuarry)
                for nk, nv in ipairs(self.allStoneQuarry) do
                    local tempFactory = nv.buildPath:getAllFreeFactory()
                    local interFac = interSet(tempFactory, storeFactory)  
                    if interFac.count > 0 then
                        gotoQuarry = nv
                        quarryFac = interFac
                        quarryFac.count = nil
                        table.insert(allPosFac, quarryFac)
                        break
                    end
                end
            end

            if wood > 0 then
                self:sortBuildings(self.allWoodLumber)
                print("get wood lumber factory", #self.allWoodLumber)
                for nk, nv in ipairs(self.allWoodLumber) do
                    local tempFactory = nv.buildPath:getAllFreeFactory()
                    local interFac = interSet(tempFactory, storeFactory)  
                    if interFac.count > 0 then
                        gotoLumber = nv
                        lumberFac = interFac
                        lumberFac.count = nil
                        table.insert(allPosFac, lumberFac)
                        break
                    end
                end
            end

            --不一定是同一个工厂
            --不求完美方案  可能有 4个 考虑 第一个 对象 或者前几个可能方案
            --可以 考虑 若干个 农田 和 采矿场 的 工厂 不过运算量会增大
            local checkRes = true
            print("stone and quarryFac", food, farmFac, stone, quarryFac, wood, lumberFac)
            if (food > 0 and farmFac == nil) or (stone > 0 and quarryFac == nil) or (wood > 0 and  lumberFac == nil ) then
                checkRes = false
            end
            --还有一种只考虑 每个house 的 连接点连接的建筑物
            --求几个fac的并集合
            local findFac = true
            local resSet
            --所有工厂的交集 
            if checkRes then
                resSet = allPosFac[1]
                for k, v in ipairs(allPosFac) do
                    if k > 1 then
                        resSet = interSet(resSet, v)
                        if resSet.count > 0 then
                            resSet.count = nil
                        else
                            findFac = false
                            break
                        end
                    end
                end
            end
            print("allPosFac", checkRes, findFac, resSet)
            gotoFac = resSet
            
            --同时去 石头采矿场 和 农田 应该怎么处理呢？ 最近的农田运送到工厂

            --求交集

            --民居可达的农田 ----> 农田可达的工厂-----》工厂可达这个商店

            --建筑物 路径确定
            --检查 工厂 可达性 以及 农田可达性 以及 
            if checkRes and findFac then
            --if gotoFarm ~= nil and gotoFac ~= nil then
            --if checkRes and #allFreeFactory > 0 then
                gotoFac = setToArr(gotoFac)
                print("allFactory", printTable(gotoFac))
                self:sortBuildings(gotoFac)
                self.people.predictFactory = gotoFac[1]
                self.people.predictFactory:setOwner(self.people)
                self.people.predictStore = k
                self.people.predictStore:setOwner(self.people)
                table.insert(self.people.stateStack, {PEOPLE_STATE.GO_STORE, self.people.predictStore, CAT_ACTION.PUT_PRODUCT, needClearOwner = true})
                table.insert(self.people.stateStack, {PEOPLE_STATE.PRODUCT, self.people.predictFactory, CAT_ACTION.PRODUCT, needClearOwner = true})
                --popStateContext 即可
                if food > 0 then
                    table.insert(self.people.stateStack, {PEOPLE_STATE.GO_FACTORY, self.people.predictFactory, CAT_ACTION.PUT_FOOD, needClearOwner = true})
                    table.insert(self.people.stateStack, {PEOPLE_STATE.GO_FACTORY, gotoFarm, CAT_ACTION.TAKE_FOOD, needClearOwner = false})
                end
                if wood > 0 then
                    table.insert(self.people.stateStack, {PEOPLE_STATE.GO_FACTORY, self.people.predictFactory, CAT_ACTION.PUT_WOOD, needClearOwner = true})
                    table.insert(self.people.stateStack, {PEOPLE_STATE.GO_FACTORY, gotoLumber, CAT_ACTION.TAKE_WOOD, needClearOwner = false})
                end
                if stone > 0 then
                    table.insert(self.people.stateStack, {PEOPLE_STATE.GO_FACTORY, self.people.predictFactory, CAT_ACTION.PUT_STONE, needClearOwner = true})
                    table.insert(self.people.stateStack, {PEOPLE_STATE.GO_FACTORY, gotoQuarry, CAT_ACTION.TAKE_STONE, needClearOwner = false})
                end
                self.people.goodsKind = k.goodsKind
                --state == FREE 之后就MiaoPeople 里面就不要根据predictTarget 来进入INIT_FIND 状态
                self.people.stateContext = table.remove(self.people.stateStack)
                --不用也可以 predictTarget = nil 会接着循环的
                self.people:useStateContext()

                --获取资源不用占用 农田 和 采矿场 
                --cpu 资源调度程序
                --[[
                if food > 0 and stone == 0 then
                    table.insert(self.people.stateStack, {PEOPLE_STATE.GO_FACTORY, self.people.predictFactory, CAT_ACTION.PUT_FOOD, needClearOwner = true})
                    --self:sortBuildings(allFoodFarm)
                    self.people.predictTarget = gotoFarm
                    --no needClear Owner 不用占用这个农田 通过其它方式写入 Queue之类的
                    --self.people.predictTarget:setOwner(self.people)
                    self.people.actionContext= CAT_ACTION.TAKE_FOOD
                    --不用再清理 owner 默认需要 clearOwner needClearOwner = nil
                    self.people.needClearOwner = false
                    self.people.goodsKind = k.goodsKind
                elseif stone > 0 and food == 0 then
                    table.insert(self.people.stateStack, {PEOPLE_STATE.GO_FACTORY, self.people.predictFactory, CAT_ACTION.PUT_STONE, needClearOwner = true})
                    self.people.predictTarget = gotoQuarry
                    --self.people.predictTarget:setOwner(self.people)
                    self.people.actionContext= CAT_ACTION.TAKE_STONE
                    self.people.goodsKind = k.goodsKind
                elseif food > 0 and stone > 0 then
                    table.insert(self.people.stateStack, {PEOPLE_STATE.GO_FACTORY, self.people.predictFactory, CAT_ACTION.PUT_FOOD, needClearOwner = true})
                    table.insert(self.people.stateStack, {PEOPLE_STATE.GO_FARM, self.people.gotoFarm, CAT_ACTION.TAKE_FOOD, needClearOwner = false})
                    table.insert(self.people.stateStack, {PEOPLE_STATE.GO_FACTORY, self.people.predictFactory, CAT_ACTION.PUT_STONE, needClearOwner = false})
                    self.people.predictTarget = gotoQuarry
                    --self.people.predictTarget:setOwner(self.people)
                    self.people.actionContext= CAT_ACTION.TAKE_STONE
                    self.people.goodsKind = k.goodsKind
                end
                --]]
                self.people:printState()
                print("find Factory !!!!!!!!!!!!!!!!!!!!!", self.people.predictFactory)
                --记住找完可能建筑物 之后 就return 即可
                return
            end
        --寻找采矿场附近的空闲 矿坑
        elseif k.id == 12 then
            local freeMine, count = k.buildPath:getAllFreeMine()
            if count > 0 then
                local gotoMine = setToArr(freeMine)
                self:sortBuildings(gotoMine)
                table.insert(self.people.stateStack, {PEOPLE_STATE.GO_TARGET, k, CAT_ACTION.PUT_STONE_QUARRY, needClearOwner=true})
                --table.insert(self.people.stateStack, {PEOPLE_STATE.GO_TARGET, gotoMine[1], CAT_ACTION.BACK_STONE, needClearOwner = true})
                table.insert(self.people.stateStack, {PEOPLE_STATE.GO_TARGET, gotoMine[1], CAT_ACTION.MINE_STONE, needClearOwner = true})
                self.people.actionContext = CAT_ACTION.TAKE_MINE_TOOL
                self.people.predictTarget = k
                k:setOwner(self.people)
                self.people.quarry = k
                return
            end
        --寻找伐木场 附近空闲的 树木
        elseif k.id == 19 then
            local freeTree, count = k.buildPath:getAllFreeTree()
            if count > 0 then
                local gotoTree = setToArr(freeTree)
                self:sortBuildings(gotoTree)
                gotoTree[1]:setOwner(self.people)
                table.insert(self.people.stateStack, {PEOPLE_STATE.GO_TARGET, k, CAT_ACTION.PUT_WOOD_LUMBER, needClearOwner=true})
                table.insert(self.people.stateStack, {PEOPLE_STATE.GO_TARGET, gotoTree[1], CAT_ACTION.LOGGING, needClearOwner = true})
                --移动到树林位置 开始伐木动作 93 -9
                --table.insert(self.people.stateStack, {PEOPLE_STATE.GO_TARGET, gotoTree[1], CAT_ACTION.MOVE_CUT, needClearOwner = true})
                self.people.actionContext = CAT_ACTION.TAKE_WOOD_TOOL
                self.people.predictTarget = k
                k:setOwner(self.people)
                self.people.lumber = k
                return
            end
        --商店
        elseif k.id == 13 then
            local food = GoodsName[k.goodsKind].food
            local wood = GoodsName[k.goodsKind].wood
            local stone = GoodsName[k.goodsKind].stone
            local checkRes = true
            if food > 0 and #self.allFoodFarm == 0 then
                checkRes = false
            end
            if stone > 0 and #self.allStoneQuarry == 0 then
                checkRes = false
            end
        
            --findTarget gotoTarget
            --取石头 去工厂 取粮食 去工厂 生产  送到商店 
            if checkRes and #self.allFreeFactory > 0 then
                self.people.predictFactory = self.allFreeFactory[1] 
                self.people.predictFactory:setOwner(self.people)
                self.people.predictSmith = k
                self.people.predictSmith:setOwner(self.people)
                if food > 0 and stone > 0 then
                    self.people.predictFarm = self.allFoodFarm[1]
                    self.people.predictFarm:setOwner(self.people)
                    self.people.predictTarget = self.allStoneQuarry[1]
                    self.people.predictTarget:setOwner(self.people)

                    table.insert(self.people.stateStack, {PEOPLE_STATE.GO_STORE, self.people.predictSmith, CAT_ACTION.PUT_PRODUCT})
                    table.insert(self.people.stateStack, {PEOPLE_STATE.PRODUCT, self.people.predictFactory, CAT_ACTION.PRODUCT})
                    table.insert(self.people.stateStack, {PEOPLE_STATE.GO_FACTORY, self.people.predictFactory, CAT_ACTION.PUT_FOOD})
                    table.insert(self.people.stateStack, {PEOPLE_STATE.GO_FARM, self.people.predictFarm, CAT_ACTION.TAKE_FOOD})
                    table.insert(self.people.stateStack, {PEOPLE_STATE.GO_FACTORY, self.people.predictFactory, CAT_ACTION.PUT_STONE})
                    self.people.actionContext= CAT_ACTION.TAKE_STONE
                    self.people.goodsKind = k.goodsKind
                elseif food > 0 then
                    table.insert(self.people.stateStack, {PEOPLE_STATE.GO_STORE, self.people.predictSmith, CAT_ACTION.PUT_PRODUCT})
                    table.insert(self.people.stateStack, {PEOPLE_STATE.PRODUCT, self.people.predictFactory, CAT_ACTION.PRODUCT})
                    table.insert(self.people.stateStack, {PEOPLE_STATE.GO_FACTORY, self.people.predictFactory, CAT_ACTION.PUT_FOOD})
                    self.people.predictTarget = self.allFoodFarm[1]
                    self.people.predictTarget:setOwner(self.people)
                    self.people.actionContext= CAT_ACTION.TAKE_FOOD
                    self.people.goodsKind = k.goodsKind
                elseif stone > 0 then
                    table.insert(self.people.stateStack, {PEOPLE_STATE.GO_STORE, self.people.predictSmith, CAT_ACTION.PUT_PRODUCT})
                    table.insert(self.people.stateStack, {PEOPLE_STATE.PRODUCT, self.people.predictFactory, CAT_ACTION.PRODUCT})
                    table.insert(self.people.stateStack, {PEOPLE_STATE.GO_FACTORY, self.people.predictFactory, CAT_ACTION.PUT_STONE})
                    self.people.predictTarget = self.allStoneQuarry[1]
                    self.people.predictTarget:setOwner(self.people)
                    self.people.actionContext= CAT_ACTION.TAKE_STONE
                    self.people.goodsKind = k.goodsKind
                end
                return
            end
            --种地去
        elseif k.id == 2 and k.workNum < k.maxNum then
            self.people.predictTarget = k
            k:setOwner(self.people)
            self.people.actionContext = CAT_ACTION.PLANT_FARM
            return
        elseif k.id == 5 then
            --开始生产了
            --还有剩余粮食
            if k.food > 0 then
                k:setOwner(self.people)
                self.people.predictTarget = k
                return
            --只有生产好的商品
            else
                if #self.allFreeStore > 0 then
                    self.people.predictStore = self.allFreeStore[1]
                    self.people.predictStore:setOwner(self.people)
                    k:setOwner(self.people)
                    self.people.predictTarget = k
                    return
                end
            end
        --采矿场
        elseif k.id == 12 then
            print("try to collect stone")
            --还可以采集石头
            if #self.allFreeMine > 0 then
                self.people.predictMine = self.allFreeMine[1]
                self.people.predictMine:setOwner(self.people)
                self.people.predictTarget = k
                k:setOwner(self.people)

                table.insert(self.people.stateStack, {PEOPLE_STATE.GO_TARGET, self.people.predictTarget, CAT_ACTION.PUT_STONE_QUARRY})
                table.insert(self.people.stateStack, {PEOPLE_STATE.GO_TARGET, self.people.predictMine, CAT_ACTION.MINE_STONE})
                self.people.actionContext = CAT_ACTION.TAKE_MINE_TOOL
                return
            end
        elseif k.id == 14 then
            --很难攒够原材料
            print("goto Tower")
            if #self.allFoodFarm > 0 and #self.allStoneQuarry > 0 and #self.allFreeFactory > 0 then
                self.people.predictTower = k
                k:setOwner(self.people)
                self.people.predictFactory = self.allFreeFactory[1]
                self.people.predictFactory:setOwner(self.people)
                self.people.predictQuarry = self.allStoneQuarry[1]
                self.people.predictQuarry:setOwner(self.people)
                self.people.predictTarget = self.allFoodFarm[1]
                self.people.predictTarget:setOwner(self.people)
                return
            end
        end
    end
end

function Cat2:findPathError()
    --回家没有找到路径
    if self.people.actionContext == CAT_ACTION.GO_HOME then
        self.people.state = PEOPLE_STATE.FREE 
        self.people.stateContext = {PEOPLE_STATE.GO_TARGET, self.people.myHouse, CAT_ACTION.GO_HOME}
        self.people.ignoreTerrian = true
    --去工厂没有找到路径 去农田没有找到路径
    --去商店没有找到路径
    --放弃这次操作
    else    
        self.people:clearStateStack()
        --bug: 大量移动建筑物之后 为什么 self.realTarget 没见了呢？
        self.people:resetState()
        
        --尝试回家 重新开始看看 可能存在问题  
        --
        --                                                  store
        --                                                  factory
        --                                                  quarry
        --store  ------  factory    -----  farm   -----   house  
        --这时候 先去 farm的商店 就不能找到 去矿石商店的路径了
        self.people.stateContext = {PEOPLE_STATE.GO_TARGET, self.people.myHouse, CAT_ACTION.GO_HOME}
    end
end

function Cat2:handleAction(diff)
    local needResetState = true
    --if self.people.realTarget.deleted then
    --    self.people:clearStateStack()
    --else
        if self.people.actionContext == CAT_ACTION.TAKE_WOOD_TOOL then
            self.people.realTarget.funcBuild:takeTool()
            self.people:popState()
        elseif self.people.actionContext == CAT_ACTION.LOGGING then
            --moveYet 状态如何reset掉呢
            if self.moveYet == nil then
                self.moveCutTime = 0
                self.moveYet = true
                local p = getPos(self.people.realTarget.bg)
                local myP = getPos(self.people.bg)
                self.people.state = PEOPLE_STATE.WAIT_ANI
                self.oldMyP = myP
                --93 -9
                local function setD(n)
                    if n == 0 then
                        self.people:setDir(1, 1)
                    else
                        self.people:setDir(1, -1)
                    end
                end
                self.people.bg:runAction(sequence({callfunc(nil, setD, 0), moveto(0.5, myP[1]+84, myP[2]+42), callfunc(nil, setD, 1), moveto(0.5, p[1]+93, p[2]-9)}))
            else
                self.moveCutTime = self.moveCutTime+diff
                print("TestCat2 begin work", self.moveCutTime)
                if self.moveCutTime >= 1 then
                    self.moveYet = nil
                    local ani = createAnimation("cat_cut", "cat_cut_%d.png", 0, 14, 1, 1, true)
                    self.people:setMoveAction("cat_cut")
                    local sca = getScaleY(self.people.changeDirNode)
                    setScaleX(self.people.changeDirNode, sca)

                    self.people.state = PEOPLE_STATE.IN_WORK
                    self.people.workTime = 0
                end
            end
            needResetState = false
        elseif self.people.actionContext == CAT_ACTION.PUT_WOOD_LUMBER then
            print("put wood in lumber", self.people.wood)
            self.people.realTarget:changeWorkNum(self.people.wood)
            self.people.wood = 0
            self.people:popState()
            self.people:putGoods()
        --[[
        elseif self.people.actionContext == CAT_ACTION.WOOD_CENTER then
            self.moveCutTime = self.moveCutTime+diff
            if self.moveCutTime >= 1 then
                self.people.state = PEOPLE_STATE.FREE
            end
        --]]
        --[[
        elseif self.people.actionContext == CAT_ACTION.PUT_WOOD then
            self.people.realTarget.wood = self.people.realTarget.wood + self.people.wood
            self.people.wood = 0
            self.people:putGoods()
            self.people:setDir(1, -1)
            self.people:popState()
        --]]
        --运送木材到工厂
        elseif self.people.actionContext == CAT_ACTION.TAKE_WOOD then
            self.people.wood = self.people.predictTarget.workNum
            self.people.realTarget:takeAllWorkNum()
            self.people:sendGoods()
            self.people:popState()
        end
        print("action Context", self.people.actionContext)
    --end
    if needResetState then
        self.people:resetState()
    end
end
function Cat2:workNow()
    local le = self.people:getMyLaborEffect()
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
    --self.people.myHouse.productNum 花费时间减少  消耗体力不变
    
    if self.people.actionContext == CAT_ACTION.LOGGING then
        local rate = totalTime/(self.people.lumber.productNum/20)/productNum
        local cost = healthCost/productNum
        if self.people.workTime > rate then
            self.people.workTime = self.people.workTime - rate
            self.people.health = self.people.health -cost
            self.people.realTarget:changeWorkNum(1)
            if self.people.realTarget.workNum >= self.people.realTarget.maxNum then
                self.people.wood = self.people.realTarget.workNum
                --树木应该将showState = -1 接着将 lifeState = 0 
                self.people.realTarget:takeAllWorkNum()
                self.people:popState()
                self.people:resetState()
                self.people:sendGoods()
                self.people:setDir(1, -1)
                
                --setPos(self.bg, self.oldMyP)
                print("finish Logging reset Pos", self.people.wood)
                --[[
                self.moveCutTime = 0
                self.people.actionContext = CAT_ACTION.WOOD_CENTER
                self.people.state = PEOPLE_STATE.WAIT_ANI
                self.people.bg:runAction(moveto(0.5, self.oldMyP[1], self.oldMyP[2]))
                --]]

                setPos(self.people.bg, self.oldMyP)
                --local sz = self.changeDirNode:getContentSize()
                --setAnchor(self.changeDirNode, {Logic.people[3].ax/sz.width, (sz.height-Logic.people[3].ay)/sz.height})
                return
            end
        end
    end
end
