Arrow = class()
function Arrow:ctor(s)
    self.soldier = s
    --self.bg = CCSprite:create("catArrow.png") 
    self.bg = CCNode:create()
    self.changeDirNode = addSprite(self.bg, "catArrow.png")
    self.shadow = addSprite(self.bg, "arrowShadow.png")

    self.needUpdate = true
    registerEnterOrExit(self)
end
function Arrow:update(diff)
    local p = getPos(self.changeDirNode)
    if self.lastPos ~= nil then
        local oldPos = self.lastPos
        local dx = p[1]-oldPos[1]
        local dy = p[2]-oldPos[2]
        if dx == 0 and dy == 0 then
        else
            local ang = math.atan2(dy, dx)*180/math.pi
            setRotation(self.changeDirNode, -ang)
        end
        setPos(self.shadow, {p[1], 0})
    end
    self.lastPos = p
end
function Arrow:doHarm()
    local ra = self.soldier:getAttack()
    self.target:doHurt(ra, true, self.soldier, true)
    self.dead = true
    removeSelf(self.bg)
end


Arrow2 = class()
function Arrow2:ctor(s, t)
    self.soldier = s
    self.target = t
    self.bg = CCNode:create()
    self.changeDirNode = addSprite(self.bg, "catArrow.png")
    self.shadow = addSprite(self.bg, "arrowShadow.png")
    setPos(self.changeDirNode, {0, 34})

    self.needUpdate = true
    registerEnterOrExit(self)
end
function Arrow2:update(diff)
    local p = getPos(self.bg)
    local tp = getPos(self.target.bg)
    if self.soldier.color == 0 then
        if p[1] >= tp[1]-20 then
            self:doHarm()
        end
    else
        if p[1] <= tp[1]+20 then
            self:doHarm()
        end
    end
end

function Arrow2:doHarm()
    local ra = self.soldier:getAttack()
    self.target:doHurt(ra, true, self.soldier, true)
    self.dead = true
    removeSelf(self.bg)
end

