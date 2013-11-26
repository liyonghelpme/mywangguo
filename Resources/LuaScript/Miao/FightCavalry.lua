CAVALRY_STATE = {
    FREE=0,
    IN_ATTACK=1,
}
FightCavalry = class(FightFunc)
function FightCavalry:ctor(s)
    self.bg = CCNode:create()
    self.soldier.bg:addChild(self.bg)
    self.state = CAVALRY_STATE.FREE
    registerEnterOrExit(self)
    registerUpdate(self)
end
function FightCavalry:update(diff)
end
function FightCavalry:beginAttack()
    if self.soldier.col == 1 then
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
    self.soldier.bg:runAction(sequence({moveto(5, self.oldPos[1], self.oldPos[2]), callfunc(nil, setDir)}))
end
function FightCavalry:doAttack()
    if self.soldier.moveAct == nil then
        self.soldier.moveAct = repeatForever(CCAnimate:create(self.soldier.moveAni))
        self.soldier.changeDirNode:runAction(self.soldier.moveAct)
    end

    self.oldPos = getPos(self.soldier.bg)
    local tar = {}
    local speed = 100 --p/s
    if self.soldier.col == 1 then
        if self.soldier.row == 1 then
            tar = {525, self.oldPos[2]}
        elseif self.soldier.row == 2 then
            tar = {505, self.oldPos[2]}
        elseif self.soldier.row == 3 then
            tar = {485, self.oldPos[2]}
        elseif self.soldier.row == 4 then
            tar = {465, self.oldPos[2]}
        elseif self.soldier.row == 5 then
            tar = {445, self.oldPos[2]}
        end
    else
        if self.soldier.row == 1 then
            tar = {288, self.oldPos[2]}
        elseif self.soldier.row == 2 then
            tar = {308, self.oldPos[2]}
        elseif self.soldier.row == 3 then
            tar = {328, self.oldPos[2]}
        elseif self.soldier.row == 4 then
            tar = {348, self.oldPos[2]}
        elseif self.soldier.row == 5 then
            tar = {368, self.oldPos[2]}
        end
    end
    self.soldier.bg:runAction(sequence({moveto(5, tar[1], tar[2]), delaytime(1), callfunc(self, self.beginAttack)}))
end
function FightCavalry:ignoreAtt()
    return true
end
function FightCavalry:getMoveTime()
    return 0.5
end
