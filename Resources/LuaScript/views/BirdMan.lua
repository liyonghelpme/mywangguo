BirdMan = class(SoldierFunc)
function BirdMan:ctor(s)
    self.soldier = s
end
function BirdMan:showAttack()
    self.par = CCParticleSystemQuad:create("birdAtt.plist")
    self.soldier.bg:addChild(self.par)
    setPos(self.par, {0, 75})
    self.par:setPositionType(1)

    local function fadePower(p)
        p:setDuration(2)
    end
    local function removePar(p)
        removeSelf(p)
    end
    self.par:runAction(sequence({delaytime(3), callfunc(nil, fadePower, self.par), delaytime(1), callfunc(nil, removePar, self.par)}))
    --4 s
end
function BirdMan:doAttack()
    local tb = getPos(self.soldier.attackTarget.bg)
    local cp = getPos(self.soldier.bg)
    local function doHarm()
        self.soldier.attackTarget:doHarm(self.soldier.data.attack)
        --开启下一次攻击
        self:showAttack()
    end
    self.soldier.bg:runAction(sequence({jumpTo(0.3, tb[1], tb[2]+30, 40, 1), callfunc(nil, doHarm), jumpTo(0.3, cp[1], cp[2], 40, 1)}))
end

function BirdMan:finishAttack()
    --如何终止一个例子系统 将生命周期调短
    --if self.par ~= nil then
    --    removeSelf(self.par)
    --    self.par = nil
    --end
end

function BirdMan:adjustHeight()
    setPos(self.soldier.changeDirNode, {0, 50})
end
function BirdMan:setZord()
    self.soldier.bg:setZOrder(MAX_BUILD_ZORD)
end

function BirdMan:getAttTime()
    return 1
end
function BirdMan:checkFavorite(k)
    if k.kind == 202 or k.kind == 144 or k.kind == 140 or k.kind == 206 then
        return true
    end
    return false
end
function BirdMan:ignoreGround()
    return true
end

function BirdMan:waitTime()
    return 3
end

