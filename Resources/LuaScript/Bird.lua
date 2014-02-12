Bird = class()
BIRD_STATE = {
    FREE = 0,
    LIVE = 1,
    DEAD = 2,
}
function Bird:ctor(s)
    self.scene = s

    local sf = CCSpriteFrameCache:sharedSpriteFrameCache()
    sf:addSpriteFramesWithFile("greenbird.plist")
    self.ani = createAnimation("birdAni", "greenbirds%d.png", 1, 4, 1, 0.133, true)

    self.bg = createSprite("greenbirds1.png")
    setAnchor(self.bg, {378/768, (1024-360)/1024})
    self.bg:runAction(repeatForever(CCAnimate:create(self.ani)))

    self.state = BIRD_STATE.FREE

    local vs = getVS()
    setPos(self.bg, {vs.width/2, vs.height/2})
    --setPos(self.bg, {0, 0})

    --self.bg:addChild(createSprite("greenbirds1.png"))
    self.vy = 0
    self.tap = false
    
    self.touch = ui.newFullTouch({delegate=self, touchBegan=self.touchBegan, touchMoved=self.touchMoved, touchEnded = self.touchEnded})
    self.bg:addChild(self.touch.bg)
    
    self.needUpdate = true
    registerUpdate(self)
end
function Bird:update(diff)
    if self.state == BIRD_STATE.FREE then
        print("bird update")
        self.vy = self.vy - 20*diff 
        if self.tap then
            self.vy = 20
        end
        local p = getPos(self.bg)
        p[2] = p[2]+self.vy*diff
        setPos(self.bg, p)

        if p[2] <= 164 then
            self.state = BIRD_STATE.DEAD    
            addBanner("你死了")
        end
    elseif self.state == BIRD_STATE.DEAD then
    end
end
function Bird:touchBegan(x, y)
    self.tap = true
end
function Bird:touchMoved()
end
function Bird:touchEnded()
end
