FightBall = class()
function FightBall:ctor(s, t)
    local sf = CCSpriteFrameCache:sharedSpriteFrameCache()
    sf:addSpriteFramesWithFile("s583e.plist")
    self.bg = CCSprite:createWithSpriteFrameName("s583e0.png")
    setScale(setPos(self.bg, s), 0.5)
    if t[1] == 800 then
        setScaleX(self.bg, -0.5)
    end
    self.bg:runAction(sequence({moveto(2, t[1], t[2]), callfunc(nil, removeSelf, self.bg)}))
    --registerUpdate(self)
    --registerEnterOrExit(self)
end
function FightBall:update(diff)

end

FightGun = class(FightFunc)
function FightGun:genBall()
    local dir = self.soldier.changeDirNode:getScaleX()
    local p = getPos(self.soldier.bg)
    local tar
    if dir < 0 then
        tar = {800, p[2]}
    else
        tar = {0, p[2]}
    end
    local sp = FightBall.new(p, tar)
    self.soldier.map.battleScene:addChild(sp.bg, MAX_BUILD_ZORD)
end

function FightGun:doAttack()
    self.soldier.bg:runAction(sequence({delaytime(1), callfunc(self, self.genBall)}))
end

