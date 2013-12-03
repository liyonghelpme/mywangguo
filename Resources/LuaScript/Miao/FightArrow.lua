FightArrow = class(FightFunc)
FightRow = class()
function FightRow:ctor(p, t)
    self.lastPos = p
    self.bg = CCSprite:create("s23e0.png")
    setPos(self.bg, p)
    self.bg:runAction(sequence({jumpTo(2, t[1], t[2], 50, 1), callfunc(nil, removeSelf, self.bg)}))

    registerEnterOrExit(self)
    registerUpdate(self)
end

function FightRow:update(diff)
    local oldPos = self.lastPos
    self.lastPos = getPos(self.bg)
    local dx = self.lastPos[1]-oldPos[1]
    local dy = self.lastPos[2]-oldPos[2]
    
    local ang = math.atan2(dy, dx)*180/math.pi+180
    setRotation(self.bg, -ang)
end

FightArrow = class(FightFunc)
function FightArrow:genBall()

    local dir = self.soldier.changeDirNode:getScaleX()
    local p = getPos(self.soldier.bg)
    local tar
    if dir < 0 then
        tar = {800, p[2]}
    else
        tar = {0, p[2]}
    end
    local sp = FightRow.new(p, tar) 
    self.soldier.map.battleScene:addChild(sp.bg, MAX_BUILD_ZORD)
end
function FightArrow:doAttack()
    self.soldier.bg:runAction(sequence({delaytime(1), callfunc(self, self.genBall)}))
end
