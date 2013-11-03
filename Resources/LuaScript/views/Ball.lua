Ball = class()
function Ball:ctor(src, target, start, over)
    self.bg = CCParticleSystemQuad:create("ball.plist")
    self.bg:setPositionType(1)

    local ca = CCSpriteFrameCache:sharedSpriteFrameCache()
    local sp = ca:spriteFrameByName("ball0")
    local rect = sp:getRect()
    local tex = sp:getTexture()
    self.bg:setTextureWithRect(tex, rect)

    setPos(self.bg, start)

    local function doHarm()
        target:doHarm(src.data.attack)
        self.bg:stopSystem()
        removeSelf(self.bg)
    end
    self.bg:runAction(jumpTo(2, over[1], over[2], 30, 1))
    self.bg:runAction(sequence({delaytime(2), callfunc(nil, doHarm)}))
end
