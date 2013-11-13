Cat = class(FuncPeople)
CAT_STATE = {
    FREE = 0, 
    RB = 1, 
    LB = 2,
    RT = 3,
    LT = 4,
}

function Cat:initView()
    self.people.bg = CCNode:create()
    local sf = CCSpriteFrameCache:sharedSpriteFrameCache()
    sf:addSpriteFramesWithFile("cat_jump.plist")
    local ani = createAnimation("cat_jump", "cat_jump_%d.png", 0, 12, 1, 2, true)
    self.people.changeDirNode = CCSprite:createWithSpriteFrame(sf:spriteFrameByName("cat_jump_0.png"))
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
--[[
function Cat:enterScene()
    registerUpdate(self)
end
function Cat:setZord()
    local p = getPos(self.bg)
    local zOrd = MAX_BUILD_ZORD-p[2]
    self.bg:setZOrder(zOrd)
end
function Cat:update(diff)
    self.passTime = self.passTime+diff
    if self.passTime > 5 then
        self.passTime = 0
        print("self.state ", self.state)
        if self.state == CAT_STATE.FREE then
            self.state = CAT_STATE.RB
            self.changeDirNode:stopAllActions()
            self.changeDirNode:runAction(repeatForever(CCAnimate:create(self.rbMove)))
        elseif self.state == CAT_STATE.RB then
            print("left bottom")
            self.state = CAT_STATE.LB
            self.changeDirNode:stopAllActions()
            self.changeDirNode:runAction(repeatForever(CCAnimate:create(self.lbMove)))
        elseif self.state == CAT_STATE.LB then
            self.state = CAT_STATE.RT
            self.changeDirNode:stopAllActions()
            self.changeDirNode:runAction(repeatForever(CCAnimate:create(self.rtMove)))
        elseif self.state == CAT_STATE.RT then
            self.state = CAT_STATE.LT
            self.changeDirNode:stopAllActions()
            self.changeDirNode:runAction(repeatForever(CCAnimate:create(self.ltMove)))
        elseif self.state == CAT_STATE.LT then
            self.state = CAT_STATE.FREE
            self.changeDirNode:stopAllActions()
            self.passTime = 5
        end
    end
end
--]]
