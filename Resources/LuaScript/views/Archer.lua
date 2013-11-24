Archer = class(SoldierFunc)
function Archer:ctor(s)
    self.soldier = s
end
function Archer:doAttack()
    local start = getPos(self.soldier.bg)
    start[2] = start[2]+15
    local over = getPos(self.soldier.attackTarget.bg)
    over[1] = over[1]+math.random(20)-10
    over[2] = over[2]+math.random(20)+20
    self.soldier.map.bg:addChild(Arrow.new(self.soldier, self.soldier.attackTarget, start, over).bg, MAX_BUILD_ZORD)
end
function Archer:getRange()
    return 200
end
