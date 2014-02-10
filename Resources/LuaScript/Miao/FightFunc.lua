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
function FightFunc:finishAttack(diff)
end
function FightFunc:resetPos()
end
function FightFunc:doWaitArrow()
end

function FightFunc:findNearEnemy()
end

