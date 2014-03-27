TestScene = class()
function TestScene:ctor()


    self.bg = CCScene:create()
    local sf = CCSpriteFrameCache:sharedSpriteFrameCache()
    sf:addSpriteFramesWithFile("car.plist")
    local sp = CCSprite:create()
    setDisplayFrame(sp, "car_lb_0.png")
    self.bg:addChild(sp)
    setPos(sp, {300, 200})
    local car = sp
    setAnchor(car, {0.3, 0.1})

    local sp = CCSprite:create()
    setDisplayFrame(sp, "b3.png")
    setPos(sp, {256, 256})
    addChild(car, sp)
    setScaleX(car, -1)

    self.carlbMove = createAnimation("car_lb", "car_lb_%d.png", 0, 9, 1, 1, true)
    self.carltMove = createAnimation("car_lt", "car_lt_%d.png", 0, 9, 1, 1, true)

    car:runAction(repeatForever(CCAnimate:create(self.carlbMove)))


    local sp = CCSprite:create()
    setDisplayFrame(sp, "car_lt_0.png")
    self.bg:addChild(sp)
    setPos(sp, {500, 200})
    local car = sp

    local sp = CCSprite:create()
    setDisplayFrame(sp, "a3.png")
    setPos(sp, {256, 256})
    addChild(car, sp)

    car:runAction(repeatForever(CCAnimate:create(self.carltMove)))
end
