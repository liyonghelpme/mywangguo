FightCavalry = class(FightFunc)
function FightCavalry:ctor(s)
    if not self.soldier.isHero then
        self.soldier.attackA = createAnimation("cat_cavalry_attackA", "cat_cavalry_attackA_%d.png", 0, 16, 1, 1, true)
        self.soldier.attackB = createAnimation("cat_cavalry_attackB", "cat_cavalry_attackB_%d.png", 0, 20, 1, 1, true)
        self.soldier.runAni = createAnimation("cat_cavalry_run", 'cat_cavalry_run_%d.png', 0, 12, 1, 1, true)
        self.soldier.idleAni = createAnimation("cat_cavalry_idle", 'cat_cavalry_idle_%d.png', 0, 20, 1, 1, true)
        self.soldier.deadAni = createAnimation("cat_cavalry_dead", 'cat_cavalry_dead_%d.png', 0, 10, 1, 1, true)
        self.soldier.deadAni:setRestoreOriginalFrame(false)
    else
        self.soldier.attackA = createAnimation("cat_hero_cavalry_attackA", "cat_hero_cavalry_attackA_%d.png", 0, 16, 1, 1, true)
        self.soldier.attackB = createAnimation("cat_hero_cavalry_attackB", "cat_hero_cavalry_attackB_%d.png", 0, 20, 1, 1, true)
        self.soldier.runAni = createAnimation("cat_hero_cavalry_run", 'cat_hero_cavalry_run_%d.png', 0, 12, 1, 1, true)
        self.soldier.idleAni = createAnimation("cat_hero_cavalry_idle", 'cat_hero_cavalry_idle_%d.png', 0, 20, 1, 1, true)
        self.soldier.deadAni = createAnimation("cat_hero_cavalry_dead", 'cat_hero_cavalry_dead_%d.png', 0, 10, 1, 1, true)
        self.soldier.deadAni:setRestoreOriginalFrame(false)
    end
end

function FightCavalry:initView()
    if not self.soldier.isHero then
        self.soldier.changeDirNode = CCSprite:createWithSpriteFrameName("cat_cavalry_idle_0.png")
        setScale(self.soldier.changeDirNode, 0.8)
    else
        self.soldier.changeDirNode = CCSprite:createWithSpriteFrameName("cat_hero_cavalry_idle_0.png")
        setScale(self.soldier.changeDirNode, 0.8)
    end
end

function FightCavalry:initShadow()
    self.soldier.shadow = CCSprite:create("roleShadow2.png")
    self.soldier.bg:addChild(self.soldier.shadow,  -1)
    setSize(self.soldier.shadow, {115, 73})

    setAnchor(self.soldier.changeDirNode, {548/1024, (512-400)/512})
end

--多个攻击目标
--同一行的 3个 目标
--同一行没有 则 最近的 3个 攻击目标  
--插入的 计算 和 这个 目标是否 已经 插入 则 产生 第一次伤害 即可 
--第一个目标 之后 深入 的 距离  OFFX*2  
--检测 伤害的 同行目标 或者 同行上列的目标
--简化值攻击 最近的3个目标
--如果 目标 没有反抗 过 则 反抗一次即可
function FightCavalry:getMaxDif()
    local p = getPos(self.soldier.bg)
    local diff = 0
    local maxFarEne
    for k, v in ipairs(self.nearThree) do
        local ep = getPos(v.bg)
        local dx = math.abs(ep[1]-p[1])
        if dx > diff then
            diff = dx
            maxFarEne = ep[1]
        end
    end
    --得到最远的敌人
    return maxFarEne
end

--后续的 骑兵 造成 相同于头骑士的伤害 持续的伤害
--判定是否是 骑士的 第一排士兵
function FightCavalry:checkIsCavalryHead()
    local isHead = false
    local att
    --if not self.isHead then
    if self.soldier.color == 0 then
        self:checkSide('right')
        att = self.soldier.right
        if self.soldier.right == nil or self.soldier.right.color ~= self.soldier.color or self.soldier.right.id ~= self.soldier.id then
            isHead = true
        end
    else
        self:checkSide('left')
        att = self.soldier.left
        if self.soldier.left == nil or self.soldier.left.color ~= self.soldier.color or self.soldier.left.id ~= self.soldier.id then
            isHead = true
        end
    end
    print("checkIsCavalryHead", self.soldier.sid, isHead, att)
    --end
    --self.isHead = isHead
    return isHead, att
end

function FightCavalry:startAttack()
    --头部 则 向目标移动攻击
    --最近的3个目标
    local isHead, att = self:checkIsCavalryHead()
    self.attackEffect = {}
    self.soldier.oldPos = getPos(self.soldier.bg)
    print("self.cavalry head", self.soldier.sid, isHead, att)
    --骑兵头
    self.cavalryHead = isHead
    if isHead then
        local nearThree = self:findNearEnemy()
        self.nearThree = nearThree
        self.moveAni = repeatForever(CCAnimate:create(self.soldier.runAni))
        self.soldier.changeDirNode:stopAllActions()
        self.soldier.changeDirNode:runAction(self.moveAni)
        self.soldier.state = FIGHT_SOL_STATE.IN_MOVE

        local maxDx = self:getMaxDif()
        --后面的 骑士 只是跟随 本骑士一起 奔跑而已 不会去攻击
        --骑士受到 攻击 导致 位置偏移了 所以 误差 导致没有撞击到目标 造成 对弓箭手的伤害
        if #self.nearThree > 0 then
            local offX = 20
            if self.soldier.color == 1 then
                offX = -20
            end
            local midPoint = maxDx+offX
            local t = math.abs(midPoint-self.soldier.oldPos[1])/self.soldier.speed
            --self.beginMove = true
            self.midPoint = midPoint
            self.moveTime = t 
            print("startAttack", self.soldier.sid, self.moveTime)
            --self.totalMoveTime = t
        end
    --非头部骑兵 则 使用 头部的 nearThree 作为自己的 nearThree 属性
    else
        print("back soldier move", self.soldier.sid, att)
        self.soldier.attackTarget = att
        self.soldier.state = FIGHT_SOL_STATE.IN_MOVE
    end
end
--前排 骑兵 跑动
--后排 骑兵 跑动
function FightCavalry:doMove(diff)
    print("self move time", self.soldier.sid, self.moveTime)
    if self.moveTime ~= nil then
        local dx = self.soldier:getSpeed() * diff
        local p = getPos(self.soldier.bg)
        p[1] = p[1]+dx
        setPos(self.soldier.bg, p)
        self.moveTime = self.moveTime-diff
        if self.moveTime <= 0 then
            self.soldier.state = FIGHT_SOL_STATE.WAIT_BACK
        end
    else
        
    end

    --攻击 我方 第一排的 骑兵的 nearThree 目标 
    --print("doMove", self.soldier.attackTarget, self.nearThree, self.soldier.attackTarget.funcSoldier.nearThree)
    if self.soldier.attackTarget ~= nil and self.nearThree == nil and self.soldier.attackTarget.funcSoldier.nearThree ~= nil then
        print("set near Three of front", self.soldier.sid)
        self.nearThree = copyTable(self.soldier.attackTarget.funcSoldier.nearThree)
        --设定 移动 目标 为 我方骑兵的 移动目标
        --这个骑兵 设定 midpoint 和 移动时间
        if self.nearThree ~= nil then
            self.moveAni = repeatForever(CCAnimate:create(self.soldier.runAni))
            self.soldier.changeDirNode:stopAllActions()
            self.soldier.changeDirNode:runAction(self.moveAni)
            local offX = 100
            if self.soldier.color == 1 then
                offX = -100
            end
            self.midPoint = self.soldier.attackTarget.funcSoldier.midPoint+offX
            local t = math.abs(self.midPoint-self.soldier.oldPos[1])/self.soldier.speed
            self.moveTime = t 
        end
    end
    --检查当前是否和 目标碰撞在一起 如果是 则 产生攻击效果
    --检测和 目标碰撞在一起 比较消耗资源为什么？非常卡顿
    if self.nearThree ~= nil then
        print("nearThree is", #self.nearThree)
        local p = getPos(self.soldier.bg)
        for k, v in ipairs(self.nearThree) do
            if not v.dead and self.attackEffect[v] == nil then
                local ep = getPos(v.bg)
                print("attackEffect", p[1], ep[1])
                if self.soldier.color == 0 then
                    if p[1] >= ep[1] then
                        self:harmOne(v)
                        self.attackEffect[v] = true
                        break
                    end
                else
                    if p[1] <= ep[1] then
                        self:harmOne(v)
                        self.attackEffect[v] = true
                        break
                    end
                end
            end
        end
    end
end

function FightCavalry:harmOne(ene)
    if not self.dead then
        --显示一个攻击动作么？
        --self.beginAttack = true
        local ra = self.soldier:getAttack()
        ene:doHurt(ra, true, self.soldier)
        --步兵反击一下
        --人马分离
        if ene.id == 0 and self.cavalryHead then
            self.soldier:doHurt(ene.attack, nil, ene)
        end
    end
end


function FightCavalry:doMoveBack(diff)
    if self.soldier.state == FIGHT_SOL_STATE.MOVE_BACK then
        local dx = self.soldier:getSpeed() * diff
        local p = getPos(self.soldier.bg)
        p[1] = p[1]+dx
    end
end

function FightCavalry:doWaitBack(diff)
    if self.soldier.state == FIGHT_SOL_STATE.WAIT_BACK then
        --如果所有的 cavalry 都进入了 waitback 状态
        --[[
        local allW = self.soldier.map:cavalryAllWait()
        if allW then
            if self.color == 0 then
                setScaleX(self.changeDirNode, -1) 
            else
                setScaleX(self.changeDirNode, 1)
            end
            self.soldier.state = FIGHT_SOL_STATE.MOVE_BACK
            
        end
        --]]
    end
end

--对方士兵总是 头部存在的 如果不存在 则 攻击相临行的士兵
--1 个 骑士的攻击方式
--最近的 3个 目标
function FightCavalry:findNearEnemy()
    local p = getPos(self.soldier.bg)
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
    local nearThree = {}
    local function inThree(cv)
        for k, v in ipairs(nearThree) do
            if cv == v then
                return true
            end
        end
        return false
    end
    --寻找最近的 3个敌人
    --只找两个 敌人 还是 3个敌人
    for i=1, 3, 1 do
        local dx = 999999
        local dy = 999999
        local ene = nil
        for ek, ev in ipairs(eneList) do
            for k, v in ipairs(ev) do
                for ck, cv in ipairs(v) do
                    if not cv.dead and not inThree(cv) then
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
            --[[
            if ene ~= nil then
                return ene
            end
            --]]
            if ene ~= nil then
                table.insert(nearThree, ene)
            end
        end
    end
    --选择所有士兵 包括弓箭手
    --return ene
    return nearThree
end

--近战 步兵 敌人
function FightCavalry:findCloseEnemy()
    print("find close Enemy")
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
            return ene, firstEnable
        end
    end
    return ene, firstEnable
end

--后排的 步兵 只是 移动靠近 我方士兵
function FightCavalry:doFree(diff)
    if self.soldier.state == FIGHT_SOL_STATE.FREE then
        if self.soldier.map.day == 2 then
            print("doFree day 2")
            --寻找 进攻的 步兵 目标
            if self.soldier.attackTarget == nil or self.soldier.attackTarget.dead then
                print("attackTarget nil dead")
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
                print("cavalry is head other", self.soldier.sid, self.isHead, att)
                --头 FightBack 只能攻击 同行的 不能 攻击 非同行的敌人 
                if isHead then
                    self.soldier.attackTarget = self:findCloseEnemy()
                    print("attackTarget is who", self.soldier.attackTarget)
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
                    --准备近战攻击步兵
                    print("cavalry dis is",  self.soldier.sid, dis)
                    if dis <= FIGHT_NEAR_RANGE then
                        self.soldier.changeDirNode:stopAllActions()
                        self.soldier.state = FIGHT_SOL_STATE.NEAR_ATTACK
                        print("WAIT_MOVE  NEAR_ATTACK")
                        self.oneAttack = false

                        local rd = math.random(2)
                        local aa 
                        if rd == 1 then
                            aa = self.soldier.attackA
                        else
                            aa = self.soldier.attackB
                        end
                        self.attackAni = sequence({CCAnimate:create(aa), callfunc(self, self.doHarm)})
                        self.soldier.changeDirNode:runAction(self.attackAni)
                        --self.attackAni = sequence({CCAnimate:create(self.soldier.attackA), callfunc(self, self.doHarm)})
                        --self.soldier.changeDirNode:runAction(self.attackAni)
                    --足够靠近才反击
                    elseif dis < 400 then
                        --攻击目标已经开始 攻击别人了 则 我主动靠近即可
                        if self.soldier.attackTarget.state == FIGHT_SOL_STATE.IN_ATTACK then
                            self.soldier:moveOneStep(diff)
                        end
                    end
                --移动靠近我的 骑兵 
                elseif self.soldier.attackTarget.id == self.soldier.id then
                    self.soldier:moveOneStep(diff)
                end
            end
        end
    end
end

function FightCavalry:doNearAttack(diff)
    if self.soldier.state == FIGHT_SOL_STATE.NEAR_ATTACK then
        --print("cavalry doNearAttack", self.soldier.attackTarget.sid)
        if self.oneAttack then
            self.oneAttack = false
            --nearAttack 结束的时候 才会找下一个
            --近战攻击 等待下一个 靠近
            if self.soldier.attackTarget == nil or self.soldier.attackTarget.dead then
                self.soldier.state = FIGHT_SOL_STATE.FREE
                self.idleAction = repeatForever(CCAnimate:create(self.soldier.idleAni))
                self.soldier.changeDirNode:stopAllActions()
                self.soldier.changeDirNode:runAction(self.idleAction)
                local ene = self:findCloseEnemy()
                self.soldier.attackTarget = ene
            else
                print("near enemy is", self.soldier.attackTarget.sid)

                local rd = math.random(2)
                local aa 
                if rd == 1 then
                    aa = self.soldier.attackA
                else
                    aa = self.soldier.attackB
                end
                self.soldier.changeDirNode:runAction(sequence({CCAnimate:create(aa), callfunc(self, self.doHarm)}))
            end
        end
    end
end

function FightCavalry:finishAttack(oneDead)
    --步兵移动会影响所有士兵的状态 包括弓箭手类型 所以弓箭手也要调整状态
    self.soldier.state = FIGHT_SOL_STATE.FREE
    print("finishAttack moveTime", self.soldier.sid, self.moveTime)
    self.moveTime = nil
    self.isHead = false 
    self.oneAttack = false
    self.firstCheckYet = false
    self.inFightBack = false
    self.inMove = false
    print("clear arrow or magic Hurt for arrow")
    self.soldier.arrowHurt = 0
    self.soldier.midPoint = nil
    self.midPoint = nil
    self.soldier.attackTarget = nil
    self.nearThree = nil

    if self.soldier.dead then
        --setVisible(self.soldier.bg, false)
        --fly away invisible
    else
        self.soldier.changeDirNode:stopAllActions()
        self.soldier.bg:stopAllActions()
        --自己回合结束
        --其它回合结束
        print("map day", self.soldier.map.day, oneDead)
        if self.soldier.map.day == 3 and not oneDead then
            self.moveAni = repeatForever(CCAnimate:create(self.soldier.runAni))
            self.soldier.changeDirNode:runAction(self.moveAni)

            --self.soldier.state = FIGHT_SOL_STATE.MOVE_BACK
            local scay = getScaleY(self.soldier.changeDirNode)
            if self.soldier.color == 0 then
                setScaleX(self.soldier.changeDirNode, -scay) 
                self.soldier.bg:runAction(sequence({delaytime(0.5), moveby(1, -self.soldier:getSpeed()*1, 0)}))
            else
                setScaleX(self.soldier.changeDirNode, scay)
                self.soldier.bg:runAction(sequence({delaytime(0.5), moveby(1, -self.soldier:getSpeed()*1, 0)}))
            end
        else
            self.soldier.idleAction = repeatForever(CCAnimate:create(self.soldier.idleAni))
            self.soldier.changeDirNode:runAction(self.soldier.idleAction)

        end
    end
end
function FightCavalry:runBack()
end

function FightCavalry:resetPos()
    if self.soldier.map.day == 3 then
        if not self.soldier.dead then
            print("cavalry reset Pos", self.soldier.sid, self.soldier.oldPos)
            setPos(self.soldier.bg, self.soldier.oldPos)
            local scay = getScaleY(self.soldier.changeDirNode)
            if self.soldier.color == 0 then
                setScaleX(self.soldier.changeDirNode, scay)
            else
                setScaleX(self.soldier.changeDirNode, -scay)
            end
        end
    end
end
