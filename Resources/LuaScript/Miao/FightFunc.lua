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
