require "Miao.Magic"
FightMagic = class(FightFunc)
function FightMagic:ctor(s)
    if not self.soldier.isHero then
        self.soldier.attackA = createAnimation("cat_magic_attackA", "cat_magic_attackA_%d.png", 0, 20, 1, 1, true)
        self.soldier.runAni = createAnimation("cat_magic_run", 'cat_magic_run_%d.png', 0, 12, 1, 1, true)
        self.soldier.idleAni = createAnimation("cat_magic_idle", 'cat_magic_idle_%d.png', 0, 20, 1, 1, true)
        self.soldier.deadAni = createAnimation("cat_magic_dead", 'cat_magic_dead_%d.png', 0, 10, 1, 1, true)
        self.soldier.deadAni:setRestoreOriginalFrame(false)
        self.showMagicTime = 0.76
    else
        self.soldier.attackA = createAnimation("cat_hero_magic_attackA", "cat_hero_magic_attackA_%d.png", 0, 20, 1, 1, true)
        self.soldier.runAni = createAnimation("cat_hero_magic_run", 'cat_hero_magic_run_%d.png', 0, 12, 1, 1, true)
        self.soldier.idleAni = createAnimation("cat_hero_magic_idle", 'cat_hero_magic_idle_%d.png', 0, 20, 1, 1, true)
        self.soldier.deadAni = createAnimation("cat_hero_magic_dead", 'cat_hero_magic_dead_%d.png', 0, 10, 1, 1, true)
        self.soldier.deadAni:setRestoreOriginalFrame(false)
    end
end

function FightMagic:initView()
    if not self.soldier.isHero then
        self.soldier.changeDirNode = CCSprite:createWithSpriteFrameName("cat_magic_idle_0.png")
    else
        self.soldier.changeDirNode = CCSprite:createWithSpriteFrameName("cat_hero_magic_idle_0.png")
    end
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
        table.insert(eneList, self.soldier.map.eneCavalrySoldiers)
    else
        table.insert(eneList, self.soldier.map.mySoldiers)
        table.insert(eneList, self.soldier.map.myMagicSoldiers)
        table.insert(eneList, self.soldier.map.myArrowSoldiers)
        table.insert(eneList, self.soldier.map.myCavalrySoldiers)
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
            --setPos(a.changeDirNode, {0, 34})

            if self.soldier.color == 1 then
                setScaleX(a.changeDirNode, -1)
            end

            local as = self.soldier.map.arrowSpeed
            local tpos = getPos(ene.bg)
            local tt = math.abs(tpos[1]-p[1])/as
            --y 方向相对偏移
            --a.changeDirNode:runAction(sequence({jumpBy(tt, tpos[1]-p[1], tpos[2]-p[2], 150+math.random(30), 1), callfunc(a, a.doHarm)}))
            --飞行到 目标 附近 则爆炸 
            a.bg:runAction(sequence({moveto(tt, tpos[1], tpos[2]), callfunc(a, a.doHarm)}))
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

--修改magic
function FightMagic:doFightBack(diff)
    if self.soldier.state == FIGHT_SOL_STATE.FIGHT_BACK then
        print("magic doFightBack now", self.shootYet, self.inFightBack)
        if not self.shootYet then
            self.shootYet = true
            local function addArrow()
                local p = getPos(self.soldier.bg)
                local a = Magic.new(self.soldier, self.soldier.attackTarget)
                self.soldier.map.battleScene:addChild(a.bg, MAX_BUILD_ZORD)
                local abg = a.bg
                local offX = 20
                if self.soldier.color == 1 then
                    offX = -20
                end
                setPos(abg, {p[1]+offX, p[2]})
                if self.soldier.color == 1 then
                    setScaleX(a.changeDirNode, -1)
                end
                local as = self.soldier.map.arrowSpeed
                local tpos = getPos(self.soldier.attackTarget.bg)
                local tt = math.abs(tpos[1]-p[1])/as
                a.bg:runAction(sequence({moveto(tt, tpos[1], tpos[2]), callfunc(a, a.doHarm)}))
            end
            if not self.dead then
                self.soldier.changeDirNode:stopAllActions()
                self.inFightBack = true
                local function clearFightBack()
                    self.inFightBack = false
                end
                self.soldier.changeDirNode:runAction(sequence({CCAnimate:create(self.soldier.attackA), callfunc(nil, clearFightBack)}))
                self.soldier.changeDirNode:runAction(sequence({delaytime(0.76), callfunc(nil, addArrow)}))
            end
        else
            --控制动画频率
            if self.soldier.map.day == 2 then
                if not self.inFightBack then
                    self.soldier.state = FIGHT_SOL_STATE.WAIT_ATTACK
                end
            end
        end
    end
end

function FightMagic:doNext(diff)
    if self.soldier.state == FIGHT_SOL_STATE.NEXT_TARGET then
        if self.soldier.attackTarget ~= nil and not self.soldier.attackTarget.dead then
            local p = getPos(self.soldier.attackTarget.bg)
            local mp = getPos(self.soldier.bg)
            if math.abs(p[1]-mp[1]) < FIGHT_NEAR_RANGE then
                --self.soldier.changeDirNode:stopAction(self.idleAction)
                self.soldier.changeDirNode:stopAllActions()
                --doNext 杀死一个目标 找下一个目标
                self.soldier.state = FIGHT_SOL_STATE.NEAR_ATTACK
                print("doNext NEAR_ATTACK")
                self.soldier.changeDirNode:runAction(sequence({CCAnimate:create(self.soldier.attackA), callfunc(self, self.doHarm)}))
                self.oneAttack = false
                --self:showAttackEffect()
                --print("next attack target get now attack him!!", self.sid, self.attackTarget.sid)
            end
        else
            --等待下一个士兵 但是 没有了
            --如果没有下一个士兵则不在搜索了
            self.soldier.attackTarget = self:findNearEnemy()
        end
    end
end

--未修改
function FightMagic:doNearAttack(diff)
    if self.soldier.state == FIGHT_SOL_STATE.NEAR_ATTACK then
        --print("doNearAttack", self.soldier.attackTarget.sid)
        if self.oneAttack then
            self.oneAttack = false
            --nearAttack 结束的时候 才会找下一个
            --近战攻击 等待下一个 靠近
            if self.soldier.attackTarget == nil or self.soldier.attackTarget.dead then
                self.soldier.state = FIGHT_SOL_STATE.NEXT_TARGET
                self.idleAction = repeatForever(CCAnimate:create(self.soldier.idleAni))
                self.soldier.changeDirNode:stopAllActions()
                self.soldier.changeDirNode:runAction(self.idleAction)
                local ene = self:findNearFoot()
                self.soldier.attackTarget = ene
            else
                print("near enemy is", self.soldier.attackTarget.sid)
                self.soldier.changeDirNode:runAction(sequence({CCAnimate:create(self.soldier.attackA), callfunc(self, self.doHarm)}))
            end
        end
    end
end

--魔法师 对 步兵
--未修改
function FightMagic:waitAttack(diff)
    if self.soldier.state == FIGHT_SOL_STATE.WAIT_ATTACK then
        --步兵周期
        if self.soldier.map.day == 2 then
            if self.soldier.attackTarget == nil or self.soldier.attackTarget.dead then
                local isHead = false
                local att
                if not self.isHead then
                    if self.soldier.color == 0 then
                        self:checkSide('right')
                        att = self.soldier.right
                        if self.soldier.right == nil or self.soldier.right.color ~= self.soldier.color then
                            isHead = true
                        end
                    else
                        self:checkSide('left')
                        att = self.soldier.left
                        if self.soldier.left == nil or self.soldier.left.color ~= self.soldier.color then
                            isHead = true
                        end
                    end
                end
                self.isHead = isHead
                --头 FightBack 只能攻击 同行的 不能 攻击 非同行的敌人 
                if isHead then
                    self.soldier.attackTarget = self:findNearFoot()
                --就是我的左侧或者右侧的朋友 或者敌人
                else
                    self.soldier.attackTarget = att
                end

            else
                --敌人攻击 攻击范围内 400-500 则放弓箭攻击 否则 移动攻击
                if self.soldier.attackTarget.color ~= self.soldier.color then
                    local p = getPos(self.soldier.bg)
                    local mp = getPos(self.soldier.attackTarget.bg)
                    local dis = self.soldier:getDis(p, mp) 
                    --射箭攻击
                    if dis >=400 and dis <= 500 then
                        local dy = math.abs(p[2]-mp[2])
                        --同行才能fightback
                        if dy < 5 then
                            self.soldier.state = FIGHT_SOL_STATE.FIGHT_BACK
                        end
                    elseif dis <= FIGHT_NEAR_RANGE then
                        self.soldier.changeDirNode:stopAllActions()
                        self.soldier.state = FIGHT_SOL_STATE.NEAR_ATTACK
                        print("WAIT_MOVE  NEAR_ATTACK")
                        self.oneAttack = false
                        self.attackAni = sequence({CCAnimate:create(self.soldier.attackA), callfunc(self, self.doHarm)})
                        self.soldier.changeDirNode:runAction(self.attackAni)
                    --足够靠近才反击
                    elseif dis < 400 then
                        --攻击目标已经开始 攻击别人了 则 我主动靠近即可
                        if self.soldier.attackTarget.state == FIGHT_SOL_STATE.IN_ATTACK then
                            self.soldier:moveOneStep(diff)
                        end
                    end

                --移动靠近我的 弓箭手 
                elseif self.soldier.attackTarget.id == self.soldier.id then
                    self.soldier:moveOneStep(diff)
                end
            end
        elseif self.soldier.map.day == 3 then
            self:waitCavalry(diff)
        end
    end
end

function FightMagic:findNearCavalry()
    local dx = 999999
    local dy = 999999
    local p = getPos(self.soldier.bg)
    local ene
    local eneList = {}
    if self.soldier.color == 0 then
        table.insert(eneList, self.soldier.map.eneCavalrySoldiers)
    else
        table.insert(eneList, self.soldier.map.myCavalrySoldiers)
    end
    
    --print("findNearEnemy isStart", isStart)
    --local firstEnable
    for ek, ev in ipairs(eneList) do
        for k, v in ipairs(ev) do
            for ck, cv in ipairs(v) do
                --没有在近战中 才考虑arrowHurt问题
                if not cv.dead then
                    local ep = getPos(cv.bg)
                    local tdisy = math.abs(ep[2]-p[2]) 
                    local tdisx = math.abs(ep[1]-p[1])
                    --同行
                    if tdisy < 5 then
                        if tdisx < dx then
                            dx = tdisx
                            ene = cv
                        end
                    end
                end
            end
        end
        if ene ~= nil then
            return ene
        end
    end
    return ene
end
function FightMagic:waitCavalry(diff)
    if self.soldier.attackTarget == nil or self.soldier.attackTarget.dead then
        local isHead = false
        local att
        if not self.isHead then
            if self.soldier.color == 0 then
                self:checkSide('right')
                att = self.soldier.right
                if self.soldier.right == nil or self.soldier.right.color ~= self.soldier.color then
                    isHead = true
                end
            else
                self:checkSide('left')
                att = self.soldier.left
                if self.soldier.left == nil or self.soldier.left.color ~= self.soldier.color then
                    isHead = true
                end
            end
        end
        self.isHead = isHead
        --头 FightBack 只能攻击 同行的 不能 攻击 非同行的敌人 
        if isHead then
            self.soldier.attackTarget = self:findNearCavalry()
        --就是我的左侧或者右侧的朋友 或者敌人
        else
            --self.soldier.attackTarget = att
        end

    else
        --敌人攻击 攻击范围内 400-500 则放弓箭攻击 否则 移动攻击
        if self.soldier.attackTarget.color ~= self.soldier.color then
            local p = getPos(self.soldier.bg)
            local mp = getPos(self.soldier.attackTarget.bg)
            local dis = self.soldier:getDis(p, mp) 
            --射箭攻击
            if dis >=400 and dis <= 500 then
                --local dy = math.abs(p[2]-mp[2])
                --同行才能fightback
                --if dy < 5 then
                self.soldier.state = FIGHT_SOL_STATE.FIGHT_BACK
                --end
            end
        end
    end
end


function FightMagic:finishAttack()
    --self.soldier.state = FIGHT_SOL_STATE.FREE
    --步兵移动会影响所有士兵的状态 包括弓箭手类型 所以弓箭手也要调整状态
    self.isHead = false 
    self.oneAttack = false
    self.firstCheckYet = false
    self.inFightBack = false
    self.inMove = false
    print("clear arrow or magic Hurt for arrow")
    self.soldier.arrowHurt = 0
    self.soldier.midPoint = nil
    self.soldier.attackTarget = nil

    if self.soldier.dead then
        --setVisible(self.soldier.bg, false)
        --fly away invisible
    else
        self.soldier.changeDirNode:stopAllActions()
        self.soldier.bg:stopAllActions()
        self.soldier.idleAction = repeatForever(CCAnimate:create(self.soldier.idleAni))
        self.soldier.changeDirNode:runAction(self.soldier.idleAction)
    end
end
