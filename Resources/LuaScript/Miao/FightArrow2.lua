require "Miao.Arrow"

FightArrow2 = class(FightFunc)
function FightArrow2:ctor(s)
    if not self.soldier.isHero then
        self.soldier.attackA = createAnimation("cat_arrow_attackA", "cat_arrow_attackA_%d.png", 0, 14, 1, 1, true)
        self.soldier.runAni = createAnimation("cat_arrow_run", 'cat_arrow_run_%d.png', 0, 12, 1, 1, true)
        self.soldier.idleAni = createAnimation("cat_arrow_idle", 'cat_arrow_idle_%d.png', 0, 20, 1, 1, true)
        self.soldier.deadAni = createAnimation("cat_arrow_dead", 'cat_arrow_dead_%d.png', 0, 10, 1, 1, true)
        self.soldier.deadAni:setRestoreOriginalFrame(false)
    else
        self.soldier.attackA = createAnimation("cat_hero_arrow_attackA", "cat_hero_arrow_attackA_%d.png", 0, 20, 1, 1, true)
        self.soldier.runAni = createAnimation("cat_hero_arrow_run", 'cat_hero_arrow_run_%d.png', 0, 12, 1, 1, true)
        self.soldier.idleAni = createAnimation("cat_hero_arrow_idle", 'cat_hero_arrow_idle_%d.png', 0, 20, 1, 1, true)
        self.soldier.deadAni = createAnimation("cat_hero_arrow_dead", 'cat_hero_arrow_dead_%d.png', 0, 10, 1, 1, true)
        self.soldier.deadAni:setRestoreOriginalFrame(false)
    end
end
function FightArrow2:initView()
    if not self.soldier.isHero then
        self.soldier.changeDirNode = CCSprite:createWithSpriteFrameName("cat_arrow_idle_0.png")
    else
        self.soldier.changeDirNode = CCSprite:createWithSpriteFrameName("cat_hero_arrow_idle_0.png")
    end
end
--屏幕应该移动到 弓箭手 然后 开始 攻击动画
--快速滑动屏幕 到最后的所有弓箭手
--弓箭手 准备动作
--弓箭手 射击动作
--电影脚本 控制器 fileController 在Layer 那里进行
--但是每个角色 移动多少 怎么移动是 自适应的控制的
--command 以及自适应策略 
--ask Soldier adjustSelf  调整自身 反馈 
--移动
--剧本控制 结构
--挨个调用函数 接着 stop 函数
--调用某段剧本
function FightArrow2:startAttack()
    local ene, firstEnable = self:findNearEnemy()
    print("Arrow start Attack", self.soldier.sid, ene, firstEnable)
    self.soldier.attackTarget = ene
    if ene == nil then
        ene = firstEnable
    end

    print("near ene", ene, firstEnable)
    if ene ~= nil then
        print("ene sid", ene.sid)
        self.soldier.changeDirNode:stopAllActions()
        --self.soldier.changeDirNode:stopAction(self.soldier.idleAction)
        self.soldier.changeDirNode:runAction(CCAnimate:create(self.soldier.attackA))
        --自动追踪 屏幕移动镜头 根据弓箭位置
        local function addArrow()
            print("addArrow", self.soldier.sid, self.soldier.attackTarget.sid)
            local a = Arrow.new(self.soldier)
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
                --setScaleX(a.changeDirNode, -1)
            end
            local as = self.soldier.map.arrowSpeed
            local tpos = getPos(ene.bg)
            local tt = math.abs(tpos[1]-p[1])/as
            --y 方向相对偏移
            a.changeDirNode:runAction(sequence({jumpBy(tt, tpos[1]-p[1], tpos[2]-p[2], 150+math.random(30), 1), callfunc(a, a.doHarm)}))
            a.color = self.soldier.color
            --a.soldier = self.soldier
            a.target = ene
            self.soldier.map:traceArrow(a)
            
            --死亡时停止所有的action 
            if not self.soldier.dead then
                self.soldier.changeDirNode:stopAllActions()
                self.idleAction = repeatForever(CCAnimate:create(self.soldier.idleAni))
                self.soldier.changeDirNode:runAction(self.idleAction)
            end
        end

        self.soldier.changeDirNode:runAction(sequence({delaytime(0.2), callfunc(nil, addArrow)}))
    end
    print("goto wait Attack")
    self.soldier.state = FIGHT_SOL_STATE.WAIT_ATTACK
    --self.soldier.state = FIGHT_SOL_STATE.ARROW_WAIT
end

function FightArrow2:doWaitArrow(diff)
    if self.soldier.state == FIGHT_SOL_STATE.ARROW_WAIT then

    end
end

--委任自动攻击 最近的敌人
--指派 攻击 某种类型的最近的敌人
function FightArrow2:findNearEnemy()
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

--步兵正在靠近攻击我
--步兵无人可达 时候再测试
function FightArrow2:findSameRow()
    print("wait Attack")
    local dx = 999999
    local dy = 999999
    local p = getPos(self.soldier.bg)
    local ene
    local eneList = {}
    if self.soldier.color == 0 then
        table.insert(eneList, self.soldier.map.eneSoldiers) 
    else
        table.insert(eneList, self.soldier.map.mySoldiers)
    end
    --近战的时候 多个弓箭手可以 攻击同一个步兵
    for ek, ev in ipairs(eneList) do
        for k, v in ipairs(ev) do
            for ck, cv in ipairs(v) do
                if not cv.dead then
                    local ep = getPos(cv.bg)
                    local tdisy = math.abs(ep[2]-p[2]) 
                    --同行 第一个 
                    if tdisy == 0 then
                        ene = cv
                        --ene.arrowHurt = ene.arrowHurt+ene:calHurt(self.soldier.attack)
                        return ene
                    end
                end
            end
        end
    end
    return ene
end

--距离远则放弓箭 否则 就近身战斗
function FightArrow2:waitAttack(diff)
    if self.soldier.state == FIGHT_SOL_STATE.WAIT_ATTACK then
        if self.soldier.map.day == 2 then
            if self.soldier.attackTarget == nil or self.soldier.attackTarget.dead then
                --射击完之后清空attackTarget 属性
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
                
                --寻找头部的步兵敌人
                if isHead then
                    self.soldier.attackTarget = self:findNearFoot()
                --就是我的左侧或者右侧的朋友
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
                elseif self.soldier.attackTarget.id == 1 then
                    self.soldier:moveOneStep(diff)
                end
            end
        elseif self.soldier.map.day == 3 then
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
                --寻找就近的骑兵
                if isHead then
                    self.soldier.attackTarget = self:findNearCavalry()
                --就是我的左侧或者右侧的朋友
                else
                    --不反抗
                    --self.soldier.attackTarget = att
                end
            else
                --射箭攻击 骑兵
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
                    end
                end
            end
        end
    end
end

--只射击 同行的 骑兵
function FightArrow2:findNearCavalry()
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



--等待 步兵过来攻击我
--确定 是进入步兵回合了
--确定步兵进入移动攻击状态了
--isHead 了则等待 检测 连接的 敌方步兵是否会过来

function FightArrow2:doNearMove(diff)
    if self.soldier.state == FIGHT_SOL_STATE.NEAR_MOVE then
        if not self.inMove then
            local nap = getPos(self.soldier.attackTarget.bg)
            local mmid 
            if self.soldier.color == 0 then
                mmid = nap[1]-80
            else
                mmid = nap[1]+80
            end
            self.midPoint = mmid
            local p = getPos(self.soldier.bg)
            local diffx = self.midPoint-p[1]
            local t = math.abs(diffx/self.soldier.speed)
            self.soldier.bg:runAction(sinein(moveto(t, self.midPoint, p[2])))
            
            self.soldier.changeDirNode:stopAction(self.idleAction)
            self.moveAni = repeatForever(CCAnimate:create(self.soldier.runAni))
            self.soldier.changeDirNode:runAction(self.moveAni)
            --需要几个frame 来广播移动
            self.inMove = true
        else
            --向特定位置移动 接着攻击对方
            local myp = getPos(self.soldier.bg)
            if myp[1] == self.midPoint then
                --self.soldier.changeDirNode:stopAction(self.moveAni)
                self.soldier.changeDirNode:stopAllActions()
                self.soldier.state = FIGHT_SOL_STATE.NEAR_ATTACK
                print("NEAR_MOVE NEAR_ATTACK")
                self.oneAttack = false
                self.attackAni = sequence({CCAnimate:create(self.soldier.attackA), callfunc(self, self.doHarm)})
                self.soldier.changeDirNode:runAction(self.attackAni)
            end 
        end
    end
end
function FightArrow2:doWaitMove(diff)
    --等待对方步兵靠近 然后射杀之
    if self.soldier.state == FIGHT_SOL_STATE.WAIT_MOVE then
        --死亡重新找新的 攻击目标
        --waitMove 没有敌方步兵靠近了
        if self.soldier.attackTarget ~= nil then
            if self.soldier.attackTarget.dead then
                self.soldier.attackTarget = self:findNearEnemy()
            --没有死亡则 检测距离足够近则攻击
            else
                local p = getPos(self.soldier.bg)
                local ap = getPos(self.soldier.attackTarget.bg)
                local dis = math.abs(ap[1]-p[1])
                if dis < FIGHT_NEAR_RANGE then
                    --self.soldier.changeDirNode:stopAction(self.idleAction)
                    self.soldier.changeDirNode:stopAllActions()
                    self.soldier.state = FIGHT_SOL_STATE.NEAR_ATTACK
                    print("WAIT_MOVE  NEAR_ATTACK")
                    self.oneAttack = false
                    self.attackAni = sequence({CCAnimate:create(self.soldier.attackA), callfunc(self, self.doHarm)})
                    self.soldier.changeDirNode:runAction(self.attackAni)
                --等待对方靠近
                else
                    --步兵也在等待 没有移动 可能在攻击等其它状态
                    --尝试靠近目标攻击
                    --我方自己的士兵就别攻击了
                    --小于200 再尝试移动过去 攻击对方
                    --步兵回合
                    --并且步兵回合没有结束
                    self.nearTime = self.nearTime+diff
                    if self.nearTime > 1 and self.soldier.map.day == 1 and not self.soldier.map.finishAttack then
                        if self.soldier.attackTarget.state ~= FIGHT_SOL_STATE.IN_MOVE and self.soldier.attackTarget.color ~= self.soldier.color and dis < 200 then
                            print("enemy is nearing so move to attack him")
                            self.soldier.state = FIGHT_SOL_STATE.NEAR_MOVE 
                        end
                    end
                end
            end
        end
    end
end


function FightArrow2:doFightBack(diff)
    if self.soldier.state == FIGHT_SOL_STATE.FIGHT_BACK then
        print("doFightBack now", self.shootYet, self.inFightBack)
        if not self.shootYet then
            self.shootYet = true
            local function addArrow()
                local p = getPos(self.soldier.bg)
                local a = Arrow2.new(self.soldier, self.soldier.attackTarget)
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
                a.bg:runAction(sequence({moveto(tt, tpos[1], tpos[2]), callfunc(nil, removeSelf, a.bg)}))
            end
            if not self.soldier.dead then
                self.soldier.changeDirNode:stopAllActions()
                self.inFightBack = true
                local function clearFightBack()
                    self.inFightBack = false
                end
                self.soldier.changeDirNode:runAction(sequence({CCAnimate:create(self.soldier.attackA), callfunc(nil, clearFightBack)}))
                self.soldier.changeDirNode:runAction(sequence({delaytime(0.2), callfunc(nil, addArrow)}))
            end
        else
            --local p = getPos(self.soldier.bg)
            --local ap = getPos(self.soldier.attackTarget.bg)
            --控制动画频率
            --对上步兵 才会近战攻击
            if self.soldier.map.day == 2 then
                if not self.inFightBack then
                    self.soldier.state = FIGHT_SOL_STATE.WAIT_ATTACK
                end
            end
        end
    end
end

function FightArrow2:doHarm()
    if not self.soldier.dead then
        self.oneAttack = true
        --self:showAttackEffect()
        self.soldier.attackTarget:doHurt(self.soldier.attack, nil, self.soldier)
        local dir = self.soldier.map:getAttackDir(self.soldier, self.soldier.attackTarget)
        local rd = math.random(2)+2
        self.soldier.bg:runAction(moveby(0.2, dir*rd, 0))
    end
end

--类似步兵的处理方案
function FightArrow2:doNearAttack(diff)
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

function FightArrow2:findNearFoot()
    print("find Near of arrow")
    local dx = 999999
    local dy = 999999
    local p = getPos(self.soldier.bg)
    local ene
    local eneList = {}
    if self.soldier.color == 0 then
        table.insert(eneList, self.soldier.map.eneSoldiers)
    else
        table.insert(eneList, self.soldier.map.mySoldiers)
    end

    for ek, ev in ipairs(eneList) do
        for k, v in ipairs(ev) do
            for ck, cv in ipairs(v) do
                if not cv.dead then
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
            end
        end
        if ene ~= nil then
            return ene
        end
    end
    return ene
end

--只能找 步兵 findNear enemy
--如果下一个目标也死亡掉了 则 不再攻击
--没有找到next 那么就结束了
function FightArrow2:doNext(diff)
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

function FightArrow2:finishAttack()
    --self.soldier.state = FIGHT_SOL_STATE.FREE
    --步兵移动会影响所有士兵的状态 包括弓箭手类型 所以弓箭手也要调整状态
    self.isHead = false 
    self.oneAttack = false
    self.firstCheckYet = false
    self.inFightBack = false
    self.inMove = false
    print("clear arrow Hurt for arrow")
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
