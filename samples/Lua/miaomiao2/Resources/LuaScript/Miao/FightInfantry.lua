FightInfantry = class(FightFunc)
INFANTRY_STATE = {
    FREE=0, 
    IN_ATTACK=1,
}
function FightInfantry:ctor(s)
    self.bg = CCNode:create()
    self.soldier.bg:addChild(self.bg)
    self.state = INFANTRY_STATE.FREE
    registerEnterOrExit(self)
    registerUpdate(self)
end
function FightInfantry:update(diff)
    if self.state == INFANTRY_STATE.IN_ATTACK then
        self.attackTime = self.attackTime+diff
        if self.attackTime >= 1 then
            self.attackTime = self.attackTime-1
            self:stopAttack()
        end
    end
end
--停止攻击 跑回去
function FightInfantry:stopAttack()
    self.state = INFANTRY_STATE.FREE
    self.soldier.changeDirNode:stopAction(self.soldier.attAct)
    self.soldier.attAct = nil

    self.soldier.moveAct = repeatForever(CCAnimate:create(self.soldier.moveAni))
    self.soldier.changeDirNode:runAction(self.soldier.moveAct)

    if self.soldier.col == 4 then
        setScaleX(self.soldier.changeDirNode, 0.5)
    else
        setScaleX(self.soldier.changeDirNode, -0.5)
    end

    local function setDir()
        local sca = self.soldier.changeDirNode:getScaleX()
        setScaleX(self.soldier.changeDirNode, -sca)
        self.soldier.changeDirNode:stopAction(self.soldier.moveAct)
        self.soldier.moveAct = nil
    end
    self.soldier.bg:runAction(sequence({moveto(1, self.oldPos[1], self.oldPos[2]), callfunc(nil, setDir)}))
end

function FightInfantry:beginAttack()
    self.state = INFANTRY_STATE.IN_ATTACK
    self.soldier.changeDirNode:stopAction(self.soldier.moveAct)
    self.soldier.moveAct = nil

    self.soldier.attAct = repeatForever(CCAnimate:create(self.soldier.attAni))
    self.soldier.changeDirNode:runAction(self.soldier.attAct)
    self.attackTime = 0
end

function FightInfantry:doAttack()
    if self.soldier.moveAct == nil then
        self.soldier.moveAct = repeatForever(CCAnimate:create(self.soldier.moveAni))
        self.soldier.changeDirNode:runAction(self.soldier.moveAct)
    end

    self.oldPos = getPos(self.soldier.bg)
    local tar = {}
    local speed = 100 --p/s
    if self.soldier.col == 4 then
        tar = {380, self.oldPos[2]}
    else
        tar = {420, self.oldPos[2]}
    end
    self.soldier.bg:runAction(sequence({moveto(2, tar[1], tar[2]), callfunc(self, self.beginAttack)}))
end
function FightInfantry:ignoreAtt()
    return true
end
