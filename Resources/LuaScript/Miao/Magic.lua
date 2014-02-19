Magic = class()
local mid = 0
function Magic:ctor(s, t)
    self.soldier = s
    self.target = t
    self.color = self.soldier.color
    self.mid = mid
    self.dead = false
    mid = mid+1
    local bf = ccBlendFunc()
    bf.src = GL_ONE
    bf.dst = GL_ONE

    self.bg = CCNode:create()
    self.changeDirNode = createSprite("magic0")
    self.changeDirNode:setBlendFunc(bf)

    self.bg:addChild(self.changeDirNode)
    local ani = getAnimation("magicBall")
    self.changeDirNode:runAction(repeatForever(CCAnimate:create(ani)))
    setAnchor(self.changeDirNode, {119/192, (192-140)/192})
    
    self.needUpdate = true
    registerEnterOrExit(self)
end

--magic 目标如果中途死亡了 自动做 doHarm
function Magic:update(diff)
    local p = getPos(self.bg)
    local tp = getPos(self.target.bg)
    self.lastPos = p
    if self.target.dead then
        self:doHarm()
    else
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
end

function Magic:doHarm()
    print("Magic do Harm", self.mid)
    self.dead = true
    self.changeDirNode = nil
    local ra = self.soldier:getAttack()
    self.target:doHurt(ra, true, self.soldier, true)
    removeSelf(self.bg)
end

