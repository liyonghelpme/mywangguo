SoldierFunc = class()
function SoldierFunc:ctor(s)
    self.soldier = s
end
function SoldierFunc:doAttack()
    self.soldier.attackTarget:doHarm(10)
end
