
Merchant = class(FuncPeople)
function Merchant:checkWork(k)
    local ret = false
    if k.owner == nil and k.picName == 'build' and not k.deleted and k.workNum > 0 then
        if k.id == 2 or k.data.IsStore == 1 then
            ret = true
        end
    end
    --[[
    ret = (k.picName == 'build' and k.id == 2 and k.state == BUILD_STATE.FREE and k.workNum > 0 and k.owner == nil)
    --去商店
    if not ret then
        ret = (k.picName == 'build' and k.id == 6 and k.state == BUILD_STATE.FREE and k.workNum > 0 and k.owner == nil)
    end
    --采矿场
    if not ret then
        print("stone ", k.stone)
        ret = (k.picName == 'build' and k.id == 12 and k.state == BUILD_STATE.FREE and k.stone > 0 and k.owner == nil)
    end
    --铁匠铺
    if not ret then
        ret = (k.picName == 'build' and k.id == 13 and k.state == BUILD_STATE.FREE and k.workNum > 0 and k.owner == nil)
    end
    --塔
    if not ret then
        print("try tower goods")
        ret = (k.picName == 'build' and k.id == 14 and k.state == BUILD_STATE.FREE and k.workNum > 0 and k.owner == nil)
    end
    --]]
    return ret
end
function Merchant:initView()
    local sf = CCSpriteFrameCache:sharedSpriteFrameCache()
    sf:addSpriteFramesWithFile(string.format("cat_%d_walk.plist", self.people.id))
    self.people.rbMove = createAnimation(string.format("people%d_rb", self.people.id), "cat_"..self.people.id.."_rb_%d.png", 0, 9, 1, 1, true)
    self.people.lbMove = createAnimation(string.format("people%d_lb", self.people.id), "cat_"..self.people.id.."_lb_%d.png", 0, 9, 1, 1, true)
    self.people.rtMove = createAnimation(string.format("people%d_rt", self.people.id), "cat_"..self.people.id.."_rt_%d.png", 0, 9, 1, 1, true)
    self.people.ltMove = createAnimation(string.format("people%d_lt", self.people.id), "cat_"..self.people.id.."_lt_%d.png", 0, 9, 1, 1, true)

    self.people.changeDirNode = CCSprite:createWithSpriteFrame(sf:spriteFrameByName(string.format("cat_%d_rt_0.png", self.people.id)))
    local sz = self.people.changeDirNode:getContentSize()
    setPos(setScale(setAnchor(self.people.changeDirNode, {Logic.people[3].ax/sz.width, (sz.height-Logic.people[3].ay)/sz.height}), 0.7), {0, SIZEY})
    self.people.shadow = CCSprite:create("roleShadow.png")

    self.people.changeDirNode:setOpacity(0) 
    self.people.lastVisible = false
    self.people.shadow:setOpacity(0)

    self.people.heightNode:addChild(self.people.shadow, -1)

    setScale(setPos(self.people.shadow, {0, SIZEY}), 3.5)
    --self.people.shadow:runAction(sequence({scaleto(1, 1.2, 1.2), scaleto(1, 1.5, 1.5)}))

    self.people.stateLabel = ui.newBMFontLabel({text=str(self.people.state), size=20})
    if not DEBUG then
        setVisible(self.people.stateLabel)
    end
    setPos(self.people.stateLabel, {0, 100})
    self.people.heightNode:addChild(self.people.stateLabel)
end

function Merchant:findTarget()
    local allPossible = {}
    self.allPossible = allPossible
    --寻路所有可以访问的商店建筑物
    --按照pool的机制来访问不用管商店的距离
    if publicMiaoPath == nil then
        publicMiaoPath = MiaoPath.new(self.people)
    end
    self.people.miaoPath = publicMiaoPath
    if not publicMiaoPath.inSearch then
        if publicMiaoPath.allBuilding == nil or publicMiaoPath.dirty == true then
            publicMiaoPath.dirty = false
            local p = getPos(self.people.bg)
            local mxy = getPosMapFloat(1, 1, p[1], p[2])
            local mx, my = mxy[3], mxy[4]
            self.people.miaoPath:init(mx, my)
            table.insert(self.people.stateStack, self.people.state)
            self.people.state = PEOPLE_STATE.FIND_NEAR_BUILDING
        else
            allBuild = self.people.miaoPath.allBuilding
            for k, v in pairs(allBuild) do
                local ret = false
                ret = self:checkWork(k)
                if ret then
                    table.insert(allPossible, k)
                end
            end

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
            if self.people.predictTarget == nil then
                self.people.predictTarget = self.people.map.backPoint
                self.people.actionContext = CAT_ACTION.MER_BACK 
            end
        end
    else
        table.insert(self.people.stateStack, self.people.state)
        self.people.state = PEOPLE_STATE.FIND_NEAR_BUILDING
    end
end

function Merchant:checkAllPossible()
    for _, k in ipairs(self.allPossible) do
        table.insert(self.people.stateStack, {PEOPLE_STATE.GO_TARGET, self.people.map.backPoint, CAT_ACTION.MER_BACK})
        k:setOwner(self)
        self.people.predictTarget = k
        self.people.actionContext = CAT_ACTION.BUY_GOODS
        if Logic.inNew and not Logic.checkFarm then
            Logic.checkFarm = true
            self.people.merch = 0
            local w = Welcome2.new(self.people.onMerch, self)
            w:updateWord("你好啊!!!没想到这里还会有村落。。。我正在行商途中，正好过来走一遭。")
            global.director:pushView(w, 1, 0)
        end
        break
    end
end
function Merchant:handleAction()
    if self.people.actionContext == CAT_ACTION.MER_BACK then
        self.people.state = PEOPLE_STATE.GO_AWAY
        self.people.changeDirNode:runAction(sequence({fadeout(1), callfunc(nil, removeSelf, self.people.bg)}))
        self.people.map.mapGridController:removeSoldier(self.people)
    elseif self.people.actionContext == CAT_ACTION.BUY_GOODS then
        print("BUY_GOODS", self.people.predictTarget.id)
        if self.people.predictTarget.stone > 0 then
            local sp = CCSprite:create("silver.png")
            local p = getPos(self.people.predictTarget.heightNode)
            self.people.map.bg:addChild(sp)
            setPos(sp, p)
            local rx = math.random(20)-10
            sp:runAction(sequence({jumpBy(1, rx, 10, 40, 1), fadeout(0.2), callfunc(nil, removeSelf, sp)}))
            local pay = self.people.predictTarget.stone*math.floor(self.people.predictTarget.rate+1)
            local num = ui.newBMFontLabel({text=str(pay), font="bound.fnt", size=30})
            sp:addChild(num)
            setPos(num, {50, 0})
            doGain(pay)
            self.people.predictTarget.stone = 0
        elseif self.people.predictTarget.id == 13 or self.people.predictTarget.id == 6 then
            getNum = self.people.predictTarget.workNum
            local sp = CCSprite:create("silver.png")
            local p = getPos(self.people.predictTarget.heightNode)
            self.people.map.bg:addChild(sp)
            setPos(sp, p)
            local rx = math.random(20)-10
            sp:runAction(sequence({jumpBy(1, rx, 10, 40, 1), fadeout(0.2), callfunc(nil, removeSelf, sp)}))
            
            local bn = math.min(2, self.people.predictTarget.workNum) 
            local wn = self.people.predictTarget.workNum
            self.people.predictTarget.workNum = wn-bn
            self.people.predictTarget.funcBuild:updateGoods()

            local val = GoodsName[self.people.predictTarget.goodsKind].price*bn
            local num = ui.newBMFontLabel({text=str(val), font="bound.fnt", size=30})
            sp:addChild(num)
            setPos(num, {50, 0})
            --+商店的贩卖能力
            doGain(val)
        --去农田
        --去商店
        --去铁匠铺
        elseif self.people.predictTarget.workNum > 0 then
            getNum = self.people.predictTarget.workNum
            local sp = CCSprite:create("silver.png")
            local p = getPos(self.people.predictTarget.heightNode)
            self.people.map.bg:addChild(sp)
            setPos(sp, p)
            local rx = math.random(20)-10
            sp:runAction(sequence({jumpBy(1, rx, 10, 40, 1), fadeout(0.2), callfunc(nil, removeSelf, sp)}))
            local num = ui.newBMFontLabel({text=str(self.people.predictTarget.workNum*math.floor(self.people.predictTarget.rate+1)), font="bound.fnt", size=30})
            sp:addChild(num)
            setPos(num, {50, 0})
            doGain(3)
            self.people.predictTarget.workNum = 0
        end
        if Logic.inNew and not Logic.buyIt then
            Logic.buyIt = true
            local w = Welcome2.new(self.people.onBuy, self.people)
            w:updateWord("好了，那么我就收购食材<0000ff"..getNum..">个，并付给你<0000ff"..getNum.."贯>")
            global.director:pushView(w, 1, 0)
        end
        self.people:popState()
        self.people:resetState()
    end
end

