Cat = class(FuncPeople)
CAT_STATE = {
    FREE = 0, 
    RB = 1, 
    LB = 2,
    RT = 3,
    LT = 4,
}

function Cat:initView()
    local sf = CCSpriteFrameCache:sharedSpriteFrameCache()
    sf:addSpriteFramesWithFile("cat_jump.plist")
    local ani = createAnimation("cat_jump", "cat_jump_%d.png", 0, 12, 1, 2, true)
    self.people.changeDirNode = CCSprite:createWithSpriteFrame(sf:spriteFrameByName("cat_jump_0.png"))
    local sz = self.people.changeDirNode:getContentSize()
    setPos(setScale(setAnchor(self.people.changeDirNode, {Logic.people[3].ax/sz.width, (sz.height-Logic.people[3].ay)/sz.height}), 0.3), {0, SIZEY})
    
    self.people.changeDirNode:runAction(CCAnimate:create(ani))

    sf:addSpriteFramesWithFile("cat_smoke.plist")
    local ani = createAnimation("cat_smoke", "cat_smoke_%d.png", 0, 12, 1, 2, true)
    self.people.smoke = CCSprite:createWithSpriteFrame(sf:spriteFrameByName("cat_smoke_0.png"))
    local sz = self.people.smoke:getContentSize()
    setPos(setScale(setAnchor(self.people.smoke, {147/sz.width, (sz.height-208)/sz.height}), 0.6), {0, SIZEY})
    self.people.bg:addChild(self.people.smoke)
    
    self.people.smoke:runAction(sequence({CCAnimate:create(ani), callfunc(nil, removeSelf, self.people.smoke)}))

    sf:addSpriteFramesWithFile("cat_walk.plist")
    self.people.rbMove = createAnimation("people3_rb", "cat_rb_%d.png", 0, 9, 1, 1, true)
    self.people.lbMove = createAnimation("people3_lb", "cat_lb_%d.png", 0, 9, 1, 1, true)
    self.people.rtMove = createAnimation("people3_rt", "cat_rt_%d.png", 0, 9, 1, 1, true)
    self.people.ltMove = createAnimation("people3_lt", "cat_lt_%d.png", 0, 9, 1, 1, true)

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

function Cat:checkWork(k)
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
            --运送矿石到 商店 不同类型商店经营物品不同
        elseif k.id == 13 then
            ret = k.state == BUILD_STATE.FREE and k.workNum == 0
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
