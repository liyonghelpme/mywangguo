FightFunc = class()
function FightFunc:ctor(s)
    self.soldier = s
end
function FightFunc:ignoreAtt()
    return false
end
function FightFunc:doAttack()
end
function FightFunc:stopAttack()
end
function FightFunc:getMoveTime()
    return 1
end
function FightFunc:initView()
end
function FightFunc:startAttack()
end
function FightFunc:waitAttack(diff)
end

function FightFunc:doFightBack(diff)
end
function FightFunc:doNearAttack(diff)
end
function FightFunc:doNext(diff)
end
function FightFunc:doNearMove(diff)
end
function FightFunc:doWaitMove(diff)
end
function FightFunc:resetPos()
end
function FightFunc:doWaitArrow()
end

function FightFunc:findNearEnemy()
end

function FightFunc:checkSide(s)
    while self.soldier[s] ~= nil do
        if self.soldier[s].dead then
            self.soldier[s] = self.soldier[s][s]
        else
            break
        end
    end
    return self.soldier[s]
end

function FightFunc:doHarm()
    if not self.dead then
        self.oneAttack = true
        --self:showAttackEffect()
        self.soldier.attackTarget:doHurt(self.soldier.attack)
        local dir = self.soldier.map:getAttackDir(self.soldier, self.soldier.attackTarget)
        local rd = math.random(2)+2
        self.soldier.bg:runAction(moveby(0.2, dir*rd, 0))
    end
end
function FightFunc:finishAttack()
end

function FightFunc:initShadow()
    self.soldier.shadow = CCSprite:create("roleShadow2.png")
    self.soldier.bg:addChild(self.soldier.shadow,  -1)
    setSize(self.soldier.shadow, {70, 44})
end
function FightFunc:doMove(diff)
end

function FightFunc:checkIsHead()
    local isHead = false
    local att
    if not self.isHead then
        if self.soldier.color == 0 then
            self:checkSide('right')
            att = self.soldier.right
            if self.soldier.right == nil or self.soldier.right.color ~= self.soldier.color then
                isHead = true
            end
        else
            self:checkSide('left')
            att = self.soldier.left
            if self.soldier.left == nil or self.soldier.left.color ~= self.soldier.color then
                isHead = true
            end
        end
    end
    self.isHead = isHead
    return isHead
end
function FightFunc:doWaitBack(diff)
end
function FightFunc:doMoveBack(diff)
end
function FightFunc:doFree(diff)
end
