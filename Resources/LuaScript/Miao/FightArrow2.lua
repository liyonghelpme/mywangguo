require "Miao.Arrow"

FightArrow2 = class(FightFunc)
function FightArrow2:ctor(s)
    self.soldier.attackA = createAnimation("cat_arrow_attackA", "cat_arrow_attackA_%d.png", 0, 14, 1, 1, true)
    self.soldier.runAni = createAnimation("cat_arrow_run", 'cat_arrow_run_%d.png', 0, 12, 1, 1, true)
    self.soldier.idleAni = createAnimation("cat_arrow_idle", 'cat_arrow_idle_%d.png', 0, 20, 1, 1, true)
    self.soldier.deadAni = createAnimation("cat_arrow_dead", 'cat_arrow_dead_%d.png', 0, 10, 1, 1, true)
    self.soldier.deadAni:setRestoreOriginalFrame(false)
end
function FightArrow2:initView()
    self.soldier.changeDirNode = CCSprite:createWithSpriteFrameName("cat_arrow_idle_0.png")
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
            local a = Arrow.new()
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
            a.soldier = self.soldier
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
        table.insert(eneList, self.soldier.map.eneArrowSoldiers)
    else
        table.insert(eneList, self.soldier.map.mySoldiers)
        table.insert(eneList, self.soldier.map.myArrowSoldiers)
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
function FightArrow2:checkSide(s)
    while self.soldier[s] ~= nil do
        if self.soldier[s].dead then
            self.soldier[s] = self.soldier[s][s]
        else
            break
        end
    end
    return self.soldier[s]
end

--等待 步兵过来攻击我
--确定 是进入步兵回合了
--确定步兵进入移动攻击状态了
--isHead 了则等待 检测 连接的 敌方步兵是否会过来
function FightArrow2:waitAttack(diff)
    if self.soldier.state == FIGHT_SOL_STATE.WAIT_ATTACK then
        --目标不存在或者目标已经死亡了
        --我是当前 部队 的 头部 
        --检测 地方不对 是否向我开进了
        --left = nil left.dead = true
        --还要考虑我方步兵的 是否是我的left
        local isHead = false
        --isHead 但是同一行没有找到士兵
        if not self.isHead then
            --考虑 我的 right 是否阵亡了 checkSide and fix Side
            --全部挂掉了则没有 isHead 的意义了
            --print("self. sid check head", self.isHead)
            if self.soldier.color == 0 then
                self:checkSide('right')
                if self.soldier.right == nil or self.soldier.right.color ~= self.soldier.color then
                    isHead = true
                end
            else
                --步兵数量比较少 没有占够1列导致 我的前方没有士兵么 dead 士兵也行呀
                self:checkSide('left')
                if self.soldier.left == nil or self.soldier.left.color ~= self.soldier.color then
                    isHead = true
                end
            end
            --当left right == nil 同一行没有敌人那么也在head 位置了
            print("isHead", isHead, self.soldier.sid)
            if isHead then
                --对付步兵 和 骑兵的fightback 时使用 这时候不用 增加arrowHurt
                local ene = self:findSameRow()
                self.soldier.attackTarget = ene
            end
            self.isHead = isHead
        end
        isHead = self.isHead
        

        --对方向我移动中检测 一下距离 步兵正在向我靠近么 不一定可能正在向 地方
        --对方也在向我攻击移动
        --对方颜色 不同
        --整个部队的头部 所以敌方 必然是 color 不同
        --对方已经靠近攻击我方部队 这时候 我就向前移动攻击 而不是 
        --淡化远程攻击FIGHT_BACK 也可以这样做 < 400 FIGHT_BACK即可
        if isHead then
            --对方等我上前移动攻击
            --对方正在攻击我方 部队 肉搏近身战的特性是什么呢？
            --距离
            --第一次测试距离就小于400则已经进入了近身肉搏战状态
            print("arrow is head do what", self.firstCheckYet, self.soldier.attackTarget)
            --若同行存在 步兵则等待fightback

            if not self.firstCheckYet then
                self.firstCheckYet = true
                if self.soldier.attackTarget ~= nil and not self.soldier.attackTarget.dead then
                    local ap = getPos(self.soldier.attackTarget.bg)
                    local mp = getPos(self.soldier.bg)
                    local dx = math.abs(ap[1]-mp[1])
                    --print("other is not my color so attack it!", dx)
                    --第一次就<400 则近战攻击
                    if dx <= 400 then
                        self.soldier.state = FIGHT_SOL_STATE.NEAR_MOVE 
                        print("waitAttack firstCheckYet attackTarget", self.soldier.attackTarget.sid)
                    end
                --第一次没有找到目标 可能两种情况 远程 射击没有找到目标 则等待对方靠近了 再攻击  等待近战
                --近战攻击没有找到同行目标 则再找一下目标 如果找到了 接着判定是否在 400 距离内  接着找不同行目标 找到 并且距离 小于400 则是 可以肉搏的目标 靠近攻击
                else
                    self.soldier.attackTarget = self:findNearEnemy() 
                    if self.soldier.attackTarget ~= nil then
                        local ap = getPos(self.soldier.attackTarget.bg)
                        local mp = getPos(self.soldier.bg)
                        local dx = math.abs(ap[1]-mp[1])
                        if dx <= 400 then
                            print("firstCheckYet no attackTarget ", self.soldier.attackTarget.sid)
                            self.soldier.state = FIGHT_SOL_STATE.NEAR_MOVE 
                        --等待步兵移动过来攻击之 不在同一排  确信是在等待步兵 但是状态没有调整过来为什么？
                        else
                            print("firstCheck not find attackTarget then search all Enemy if far away then wait enemy move here")
                            self.soldier.state = FIGHT_SOL_STATE.WAIT_MOVE
                            self.nearTime = 0
                        end
                    end
                end
            else
                if self.soldier.attackTarget ~= nil and not self.soldier.attackTarget.dead then
                    local ap = getPos(self.soldier.attackTarget.bg)
                    local mp = getPos(self.soldier.bg)
                    local dx = math.abs(ap[1]-mp[1])
                    print("other is not my color so attack it! after check soldier never go near me so fight back", dx)
                    if dx <= 400 then
                        self.firstCheckYet = false
                        self.soldier.state = FIGHT_SOL_STATE.FIGHT_BACK
                    end
                --WAIT_MOVE 状态
                --或者NEAR_MOVE 状态 等待对方靠近
                end
            end
        end
    end
end
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
        print("doFightBack now")
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
            if not self.dead then
                self.soldier.changeDirNode:stopAllActions()
                self.inFightBack = true
                local function clearFightBack()
                    self.inFightBack = false
                end
                self.soldier.changeDirNode:runAction(sequence({CCAnimate:create(self.soldier.attackA), callfunc(nil, clearFightBack)}))
                self.soldier.changeDirNode:runAction(sequence({delaytime(0.2), callfunc(nil, addArrow)}))
            end
        else
            local p = getPos(self.soldier.bg)
            local ap = getPos(self.soldier.attackTarget.bg)
            --控制动画频率
            if not self.inFightBack then
                if math.abs(p[1]-ap[1]) < FIGHT_NEAR_RANGE then
                    self.soldier.state = FIGHT_SOL_STATE.NEAR_ATTACK
                    print('FIGHT_BACK NEAR_ATTACK')
                    self.shootYet = false
                    self.oneAttack = false
                    self.soldier.changeDirNode:stopAllActions()
                    --又开始执行另外的攻击动作了 执行的太多了
                    self.soldier.changeDirNode:runAction(sequence({CCAnimate:create(self.soldier.attackA), callfunc(self, self.doHarm)}))
                --对方超出攻击范围 且已经靠近则移动近战攻击
                else

                end
            end
        end
    end
end

function FightArrow2:doHarm()
    if not self.dead then
        self.oneAttack = true
        --self:showAttackEffect()
        self.soldier.attackTarget:doHurt(self.soldier.attack)
        local dir = self.soldier.map:getAttackDir(self.soldier, self.soldier.attackTarget)
        local rd = math.random(2)+2
        self.soldier.bg:runAction(moveby(0.2, dir*rd, 0))
    end
end

--类似步兵的处理方案
function FightArrow2:doNearAttack(diff)
    if self.soldier.state == FIGHT_SOL_STATE.NEAR_ATTACK then
        print("doNearAttack", self.soldier.attackTarget.sid)
        if self.oneAttack then
            self.oneAttack = false
            --nearAttack 结束的时候 才会找下一个
            --近战攻击 等待下一个 靠近
            if self.soldier.attackTarget.dead then
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
