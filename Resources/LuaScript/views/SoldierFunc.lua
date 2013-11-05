SoldierFunc = class()
function SoldierFunc:ctor(s)
    self.soldier = s
end
function SoldierFunc:doAttack()
    self.soldier.attackTarget:doHarm(10)
end
--调整高度
function SoldierFunc:adjustHeight()
end
function SoldierFunc:setZord()
    local p = getPos(self.soldier.bg)
    local zOrd = MAX_BUILD_ZORD-p[2]
    self.soldier.bg:setZOrder(zOrd)
end
function SoldierFunc:showAttack()
end
function SoldierFunc:finishAttack()
end
function SoldierFunc:getAttTime()
    return self.soldier.data.attSpeed
end
function SoldierFunc:checkFavorite(k)
    return true
end
function SoldierFunc:waitTime()
    return self.soldier.data.attSpeed
end
