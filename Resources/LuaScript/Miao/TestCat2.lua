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
    BUG_GOODS=11,
}

Cat2 = class(FuncPeople)
function Cat2:initView()
    self.people.bg = CCNode:create()
    local sf = CCSpriteFrameCache:sharedSpriteFrameCache()
    sf:addSpriteFramesWithFile(string.format("cat_%d_jump.plist", self.people.id))
    local ani = createAnimation(string.format("cat_%d_jump", self.people.id), "cat_"..self.people.id.."_jump_%d.png", 0, 12, 1, 2, true)
    self.people.changeDirNode = CCSprite:createWithSpriteFrame(sf:spriteFrameByName(string.format("cat_%d_jump_0.png", self.people.id)))
    local sz = self.people.changeDirNode:getContentSize()
    setPos(setScale(setAnchor(self.people.changeDirNode, {Logic.people[3].ax/sz.width, (sz.height-Logic.people[3].ay)/sz.height}), 0.3), {0, SIZEY})
    self.people.bg:addChild(self.people.changeDirNode)
    
    self.people.changeDirNode:runAction(CCAnimate:create(ani))

    sf:addSpriteFramesWithFile("cat_smoke.plist")
    local ani = createAnimation("cat_smoke", "cat_smoke_%d.png", 0, 12, 1, 2, true)
    self.people.smoke = CCSprite:createWithSpriteFrame(sf:spriteFrameByName("cat_smoke_0.png"))
    local sz = self.people.smoke:getContentSize()
    setPos(setScale(setAnchor(self.people.smoke, {147/sz.width, (sz.height-208)/sz.height}), 0.6), {0, SIZEY})
    self.people.bg:addChild(self.people.smoke)
    
    self.people.smoke:runAction(sequence({CCAnimate:create(ani), callfunc(nil, removeSelf, self.people.smoke)}))

    sf:addSpriteFramesWithFile(string.format("cat_%d_walk.plist", self.people.id))
    self.people.rbMove = createAnimation(string.format("people%d_rb", self.people.id), "cat_"..self.people.id.."_rb_%d.png", 0, 9, 1, 1, true)
    self.people.lbMove = createAnimation(string.format("people%d_lb", self.people.id), "cat_"..self.people.id.."_lb_%d.png", 0, 9, 1, 1, true)
    self.people.rtMove = createAnimation(string.format("people%d_rt", self.people.id), "cat_"..self.people.id.."_rt_%d.png", 0, 9, 1, 1, true)
    self.people.ltMove = createAnimation(string.format("people%d_lt", self.people.id), "cat_"..self.people.id.."_lt_%d.png", 0, 9, 1, 1, true)

    self.people.shadow = CCSprite:create("roleShadow.png")
    self.people.bg:addChild(self.people.shadow, -1)
    setScale(setPos(self.people.shadow, {0, SIZEY}), 1.5)
    self.people.shadow:runAction(sequence({scaleto(1, 1.2, 1.2), scaleto(1, 1.5, 1.5)}))

    --self.passTime = 0
    --registerEnterOrExit(self)

    self.people.stateLabel = ui.newBMFontLabel({text=str(self.people.state), size=20})
    setPos(self.people.stateLabel, {0, 100})
    self.people.bg:addChild(self.people.stateLabel)
end

function Cat2:checkWork(k)
    local ret = false
    --两种情况 给 其它工厂运输农作物 丰收状态 
    --生产农作物
    --先不允许并行处理
    if k.picName == 'build' and k.owner == nil then
        if k.id == 2 then
            ret = (k.state == BUILD_STATE.FREE and k.workNum < 10)
        --去工厂生产产品 运送粮食到工厂 或者 到工厂生产产品
        --运送物资到工厂 如果工厂 的 stone > 0 就可以开始生产了  
        --或者将生产好的产品运送到 商店
        --没有直接去工厂的说法
        --采矿场
        elseif k.id == 6 then
            print('try goto store')
            ret = k.state == BUILD_STATE.FREE and k.workNum == 0
        elseif k.id == 12 then
            print("mine stone", k.stone)
            ret = k.stone < 10 
        --铁匠铺可以生产物品
        elseif k.id == 13 then
            ret = k.state == BUILD_STATE.FREE and k.workNum < k.maxNum
        elseif k.id == 11 then
            --ret = k.stone ~= nil and k.stone > 0 
        --灯塔可以生产
        elseif k.id == 14 then
            ret = k.workNum < 10
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
    --只要建筑物不移动 这些数据都不会改变的 所以只需要寻路一次即可
    self.allPossible = allPossible
    self.allFreeFactory = allFreeFactory
    self.allFreeStore = allFreeStore
    self.allFreeMine = allFreeMine
    self.allFreeSmith = allFreeSmith
    self.allFreeQuarry = allFreeQuarry
    self.allFoodFarm = allFoodFarm
    self.allStoneQuarry = allStoneQuarry


    --初始化路径信息
    if self.people.miaoPath.allBuilding == nil or self.people.dirty == true then
        self.people.dirty = false
        print("miao Path init find!!!!!!!!!!!!")
        local p = getPos(self.people.myHouse.bg)
        local mxy = getPosMapFloat(1, 1, p[1], p[2])
        local mx, my = mxy[3], mxy[4]
        self.people.miaoPath:init(mx, my)
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
                ret = self.people.funcPeople:checkWork(k)
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
                if k.id == 12 and k.stone > 0 then
                    table.insert(allStoneQuarry, k)
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
    global.director.curScene.menu.stateLabel:setString(string.format("allFoodFarm %d\nallStoneQuarry %d\n", #allFoodFarm, #allStoneQuarry))

    if #allPossible > 0 then
        --按照建筑物的距离排序
        local myp = getPos(self.people.bg)
        local function cmp(a, b)
            local ap = getPos(a.bg)
            local bp = getPos(b.bg)
            local ad = mdist(myp, ap) 
            local bd = mdist(myp, bp)
            return ad < bd
        end
        table.sort(allPossible, cmp)
        self:checkAllPossible() 
    end
end
function Cat2:checkAllPossible()
    --按照距离排序的建筑物
    for _, k in ipairs(self.allPossible) do
        if k.id == 6 then
            if #self.allFoodFarm > 0 and #self.allFreeFactory > 0 then
                self.people.stateLabel:setString("findFactory!!!")
                self.people.predictFactory = self.allFreeFactory[1]
                self.people.predictFactory:setOwner(self.people) 
                self.people.predictStore = k 
                self.people.predictStore:setOwner(self.people)

                self.people.predictTarget = self.allFoodFarm[1]
                self.people.predictTarget:setOwner(self.people)
                print("find Factory !!!!!!!!!!!!!!!!!!!!!", self.people.predictFactory)
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

