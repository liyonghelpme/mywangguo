Goblin = class(SoldierFunc)
function Goblin:ctor(s)
    self.soldier = s
end

function Goblin:doAttack()
    --加上特效
    if self.soldier.attackTarget.kind == 0 or self.soldier.attackTarget.kind == 300 then
        self.soldier.attackTarget:doHarm(self.soldier.data.specialAttack)
    else
        self.soldier.attackTarget:doHarm(self.soldier.data.attack)
    end
end
