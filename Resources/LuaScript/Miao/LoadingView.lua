LoadingView = class()
function LoadingView:ctor()
    self.bg = CCNode:create()

    local sf = CCSpriteFrameCache:sharedSpriteFrameCache()
    sf:addSpriteFramesWithFile("loadAni.plist")
    local ani = createAnimation("loadingAni", "load%d.png", 0, 8, 1, 1, true)
    local sp = createSprite("load0.png")
    addChild(self.bg, sp)
    local vs = getVS()
    setScale(setPos(sp, {vs.width-228*0.7, 101*0.7}), 1)
    sp:runAction(repeatForever(CCAnimate:create(ani)))

    local lab = ui.newTTFLabel({text="Loading...", size=25})
    setAnchor(setPos(addChild(self.bg, lab), {16, 768-743}), {0, 0.5})
end
