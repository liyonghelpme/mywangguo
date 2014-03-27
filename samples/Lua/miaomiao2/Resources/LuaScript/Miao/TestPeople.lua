require "Miao.TestPath"
BIG_STATE = {
    FREE=0,
    START_FIND=1,
    IN_FIND=2,
    FIND=3,
    IN_MOVE=4,
    DO_ATTACK = 5,
    OVER = 6,
}

TestPeople = class()
function TestPeople:ctor(m)
    self.map = m
    self.id = 3
    self.bg = CCNode:create()

    local sf = CCSpriteFrameCache:sharedSpriteFrameCache()
    sf:addSpriteFramesWithFile("cat_walk.plist")
    self.rbMove = createAnimation("people3_rb", "cat_rb_%d.png", 0, 9, 1, 1, true)
    self.lbMove = createAnimation("people3_lb", "cat_lb_%d.png", 0, 9, 1, 1, true)
    self.rtMove = createAnimation("people3_rt", "cat_rt_%d.png", 0, 9, 1, 1, true)
    self.ltMove = createAnimation("people3_lt", "cat_lt_%d.png", 0, 9, 1, 1, true)

    self.changeDirNode = CCSprite:createWithSpriteFrame(sf:spriteFrameByName("cat_rb_0.png"))
    local sz = self.changeDirNode:getContentSize()
    setPos(setScale(setAnchor(self.changeDirNode, {Logic.people[3].ax/sz.width, (sz.height-Logic.people[3].ay)/sz.height}), 0.3), {0, SIZEY})
    self.bg:addChild(self.changeDirNode)
    
    self.shadow = CCSprite:create("roleShadow.png")
    self.bg:addChild(self.shadow, -1)
    setScale(setPos(self.shadow, {0, SIZEY}), 1.5)
    self.state = BIG_STATE.FREE

    self.peoplePath = TestPath.new(self)

    registerEnterOrExit(self)
    --战斗时间根据开始时间决定
end
function TestPeople:enterScene()
    registerUpdate(self)
end

function TestPeople:setTarget(t)
    self.predictTarget = t
end
--根据战斗时间计算移动到的网格的编号
function TestPeople:update(diff)
    self:findPath()
    self:initFind()
    self:doFind()
    self:initMove()
    self:doMove(diff)
    self:doAttack()
end
function TestPeople:findPath()
    if self.state == BIG_STATE.FREE then
        self.state = BIG_STATE.START_FIND
    end
end
function TestPeople:initFind()
    if self.state == BIG_STATE.START_FIND then
        local p = getPos(self.bg)
        local mxy = getPosMapFloat(1, 1, p[1], p[2])
        local p = getPos(self.predictTarget.bg)
        local exy = getPosMapFloat(1, 1, p[1], p[2])

        self.peoplePath:init(mxy[3], mxy[4], exy[3], exy[4])
        self.state = BIG_STATE.IN_FIND
    end
end
function TestPeople:doFind()
    if self.state == BIG_STATE.IN_FIND then
        self.peoplePath:update()
        if self.peoplePath.searchYet then
            self.path = self.peoplePath:getPath()
            self.state = BIG_STATE.FIND
        end
    end
end
function TestPeople:initMove()
    if self.state == BIG_STATE.FIND then
        self.state = PEOPLE_STATE.IN_MOVE
        self.curPoint = 1
        self.passTime = 1
    end

end
function TestPeople:setDir(x, y)
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
function TestPeople:doMove(diff)
    if self.state == BIG_STATE.IN_MOVE then
        self.passTime = self.passTime+diff
        if self.passTime > 1 then
            self.passTime = 0
            local nextPoint = self.curPoint+1
            if nextPoint > #self.path then
                self.state = BIG_STATE.DO_ATTACK 
            else
                local np = self.path[nextPoint]
                local cxy = setBuildMap({1, 1, np[1], np[2]})
                self.bg:runAction(moveto(1, cxy[1], cxy[2]))    
                self:setDir(cxy[1], cxy[2])
                self:setZord()
                self.curPoint = self.curPoint+1
            end
        else
        end
    end
end
function TestPeople:doAttack()
    if self.state == BIG_STATE.DO_ATTACK then
        table.insert(Logic.waitPeople, 1)
        --self.changeDirNode:stopAllActions()
        self.changeDirNode:runAction(sequence({fadeout(2), callfunc(nil, removeSelf, self.bg)}))
        self.state = BIG_STATE.OVER
        addCmd({cmd="fightNow"})
    end
end
function TestPeople:setZord()
    local p = getPos(self.bg)
    local zOrd = MAX_BUILD_ZORD-p[2]
    self.bg:setZOrder(zOrd)
end

