require "Miao.Magic"
FightMagic = class(FightFunc)
function FightMagic:ctor(s)
    self.soldier.attackA = createAnimation("cat_magic_attackA", "cat_magic_attackA_%d.png", 0, 20, 1, 1, true)
    self.soldier.runAni = createAnimation("cat_magic_run", 'cat_magic_run_%d.png', 0, 12, 1, 1, true)
    self.soldier.idleAni = createAnimation("cat_magic_idle", 'cat_magic_idle_%d.png', 0, 20, 1, 1, true)
    self.soldier.deadAni = createAnimation("cat_magic_dead", 'cat_magic_dead_%d.png', 0, 10, 1, 1, true)
    self.soldier.deadAni:setRestoreOriginalFrame(false)
end

function FightMagic:initView()
    self.soldier.changeDirNode = CCSprite:createWithSpriteFrameName("cat_magic_idle_0.png")
end

--法师 和 弓箭手 寻找 最近的敌人 去 攻击
function FightMagic:findNearEnemy()
    print("find Near of arrow")
    local dx = 999999
    local dy = 999999
    local p = getPos(self.soldier.bg)
    local ene
    local eneList = {}
    if self.soldier.color == 0 then
        table.insert(eneList, self.soldier.map.eneSoldiers)
        table.insert(eneList, self.soldier.map.eneMagicSoldiers)
        table.insert(eneList, self.soldier.map.eneArrowSoldiers)
    else
        table.insert(eneList, self.soldier.map.mySoldiers)
        table.insert(eneList, self.soldier.map.myMagicSoldiers)
        table.insert(eneList, self.soldier.map.myArrowSoldiers)
    end

    --这两个状态 不累计arrowHurt数值
    --local inNext = (self.state == FIGHT_SOL_STATE.NEXT_TARGET or self.state == FIGHT_SOL_STATE.WAIT_ATTACK)
    --使用arrowHurt 来计数 魔法伤害
    local isStart = (self.soldier.state == FIGHT_SOL_STATE.START_ATTACK)
    print("findNearEnemy isStart", isStart)
    local firstEnable
    for ek, ev in ipairs(eneList) do
        for k, v in ipairs(ev) do
            for ck, cv in ipairs(v) do
                --没有在近战中 才考虑arrowHurt问题
                if not cv.dead and (not isStart or cv.arrowHurt < cv.health) then
                    local ep = getPos(cv.bg)
                    local tdisy = math.abs(ep[2]-p[2]) 
                    local tdisx = math.abs(ep[1]-p[1])
                    if tdisy < dy then
                        dy = tdisy
                        dx = tdisx
                        ene = cv
                    elseif tdisy == dy then
                        if tdisx < dx then
                            dx = tdisx
                            ene = cv
                        end
                    end
                end
                if not cv.dead and firstEnable == nil then
                    firstEnable = cv
                end
            end
        end
        if ene ~= nil then
            if isStart then
                ene.arrowHurt = ene.arrowHurt+ene:calHurt(self.soldier.attack)
            end
            return ene, firstEnable
        end
    end
    return ene, firstEnable
end
function FightMagic:startAttack()
    local ene, firstEnable = self:findNearEnemy()
    self.soldier.attackTarget = ene
    if ene == nil then
        ene = firstEnable
    end
    if ene ~= nil then
        print("magic ene sid", ene.sid)
        self.soldier.changeDirNode:stopAllActions()
        --self.soldier.changeDirNode:stopAction(self.soldier.idleAction)
        self.soldier.changeDirNode:runAction(CCAnimate:create(self.soldier.attackA))
        --自动追踪 屏幕移动镜头 根据弓箭位置
        local function addArrow()
            print("addMagic", self.soldier.sid, self.soldier.attackTarget.sid)
            local a = Magic.new(self.soldier, self.soldier.attackTarget)
            local abg = a.bg
            self.soldier.map.battleScene:addChild(a.bg, MAX_BUILD_ZORD)
            local p = getPos(self.soldier.bg)
            local offX = 20
            if self.soldier.color == 1 then
                offX = -20
            end
            --changeDirNode pos
            setPos(abg, {p[1]+offX, p[2]})
            setPos(a.changeDirNode, {0, 34})

            if self.soldier.color == 1 then
                setScaleX(a.changeDirNode, -1)
            end

            local as = self.soldier.map.arrowSpeed
            local tpos = getPos(ene.bg)
            local tt = math.abs(tpos[1]-p[1])/as
            --y 方向相对偏移
            --a.changeDirNode:runAction(sequence({jumpBy(tt, tpos[1]-p[1], tpos[2]-p[2], 150+math.random(30), 1), callfunc(a, a.doHarm)}))
            --飞行到 目标 附近 则爆炸 
            a.bg:runAction(sequence({moveto(tt, tpos[1], tpos[2]), callfunc(nil, removeSelf, a.bg)}))
            --a.color = self.soldier.color
            --a.soldier = self.soldier
            --a.target = ene
            self.soldier.map:traceArrow(a)
            
            --死亡时停止所有的action 
            if not self.soldier.dead then
                self.soldier.changeDirNode:stopAllActions()
                self.idleAction = repeatForever(CCAnimate:create(self.soldier.idleAni))
                self.soldier.changeDirNode:runAction(self.idleAction)
            end
        end
        self.soldier.changeDirNode:runAction(sequence({delaytime(0.76), callfunc(nil, addArrow)}))
    end

    self.soldier.state = FIGHT_SOL_STATE.WAIT_ATTACK
end
function FightMagic:waitAttack(diff)
    if self.soldier.state == FIGHT_SOL_STATE.WAIT_ATTACK then
    end
end

