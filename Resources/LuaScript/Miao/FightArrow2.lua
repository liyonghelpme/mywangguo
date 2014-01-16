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
    print("Arrow start Attack")
    local ene = self:findNearEnemy()
    self.soldier.attackTarget = ene
    print("near ene", ene)
    if ene ~= nil then
        self.soldier.changeDirNode:stopAllActions()
        self.soldier.changeDirNode:runAction(CCAnimate:create(self.soldier.attackA))
        --自动追踪 屏幕移动镜头 根据弓箭位置
        local function addArrow()
            local a = Arrow.new()
            local abg = a.bg
            self.soldier.map.battleScene:addChild(a.bg)
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
            a.changeDirNode:runAction(sequence({jumpBy(tt, tpos[1]-p[1], tpos[2]-p[2], 300, 1), callfunc(a, a.doHarm)}))
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

    for ek, ev in ipairs(eneList) do
        for k, v in ipairs(ev) do
            for ck, cv in ipairs(v) do
                if not cv.dead then
                    local ep = getPos(cv.bg)
                    local tdisy = math.abs(ep[2]-p[2]) 
                    --同行 第一个 
                    if tdisy == 0 then
                        ene = cv
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
        if isHead then
            --对方等我上前移动攻击
            --对方正在攻击我方 部队 肉搏近身战的特性是什么呢？
            --距离
            --第一次测试距离就小于400则已经进入了近身肉搏战状态
            if not self.firstCheckYet then
                self.firstCheckYet = true
                if self.soldier.attackTarget ~= nil then
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
                        --等待步兵移动过来攻击之 不在同一排
                        else
                            self.soldier.state = FIGHT_SOL_STATE.WAIT_MOVE
                        end
                    end
                end
            else
                if self.soldier.attackTarget ~= nil then
                    local ap = getPos(self.soldier.attackTarget.bg)
                    local mp = getPos(self.soldier.bg)
                    local dx = math.abs(ap[1]-mp[1])
                    print("other is not my color so attack it! after check soldier never go near me so fight back", dx)
                    if dx <= 400 then
                        self.firstCheckYet = false
                        self.soldier.state = FIGHT_SOL_STATE.FIGHT_BACK
                    end
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
                self.soldier.changeDirNode:stopAction(self.moveAni)
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
                if math.abs(ap[1]-p[1]) < 90 then
                    --self.soldier.changeDirNode:stopAction(self.idleAction)
                    self.soldier.changeDirNode:stopAllActions()
                    self.soldier.state = FIGHT_SOL_STATE.NEAR_ATTACK
                    print("WAIT_MOVE  NEAR_ATTACK")
                    self.oneAttack = false
                    self.attackAni = sequence({CCAnimate:create(self.soldier.attackA), callfunc(self, self.doHarm)})
                    self.soldier.changeDirNode:runAction(self.attackAni)
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
                self.soldier.map.battleScene:addChild(a.bg)
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
                a.bg:runAction(moveto(tt, tpos[1], tpos[2]))
            end
            if not self.dead then
                self.soldier.changeDirNode:stopAllActions()
                self.soldier.changeDirNode:runAction(CCAnimate:create(self.soldier.attackA))
                self.soldier.changeDirNode:runAction(sequence({delaytime(0.2), callfunc(nil, addArrow)}))
            end
        else
            local p = getPos(self.soldier.bg)
            local ap = getPos(self.soldier.attackTarget.bg)
            if math.abs(p[1]-ap[1]) < 90 then
                self.soldier.state = FIGHT_SOL_STATE.NEAR_ATTACK
                print('FIGHT_BACK NEAR_ATTACK')
                self.shootYet = false
                self.oneAttack = false
                self.soldier.changeDirNode:runAction(sequence({CCAnimate:create(self.soldier.attackA), callfunc(self, self.doHarm)}))
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
            if self.soldier.attackTarget.dead then
                self.soldier.state = FIGHT_SOL_STATE.NEXT_TARGET
                self.idleAction = repeatForever(CCAnimate:create(self.soldier.idleAni))
                self.soldier.changeDirNode:runAction(self.idleAction)
                local ene = self:findNearFoot()
                self.soldier.attackTarget = ene
            else
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
function FightArrow2:doNext(diff)
    if self.soldier.state == FIGHT_SOL_STATE.NEXT_TARGET then
        if self.soldier.attackTarget ~= nil then
            local p = getPos(self.soldier.attackTarget.bg)
            local mp = getPos(self.soldier.bg)
            if math.abs(p[1]-mp[1]) < 90 then
                self.soldier.changeDirNode:stopAction(self.idleAction)
                --doNext 杀死一个目标 找下一个目标
                self.soldier.state = FIGHT_SOL_STATE.NEAR_ATTACK
                print("doNext NEAR_ATTACK")
                self.soldier.changeDirNode:runAction(sequence({CCAnimate:create(self.soldier.attackA), callfunc(self, self.doHarm)}))
                self.oneAttack = false
                --self:showAttackEffect()
                --print("next attack target get now attack him!!", self.sid, self.attackTarget.sid)
            end
        end
    end
end

function FightArrow2:finishAttack()
    --self.soldier.state = FIGHT_SOL_STATE.FREE
    --步兵移动会影响所有士兵的状态 包括弓箭手类型 所以弓箭手也要调整状态
    self.isHead = false 
    self.oneAttack = false
    self.firstCheckYet = false

    if self.soldier.dead then
        setVisible(self.soldier.bg, false)
    else
        self.soldier.changeDirNode:stopAllActions()
        self.soldier.bg:stopAllActions()
        self.soldier.idleAction = repeatForever(CCAnimate:create(self.soldier.idleAni))
        self.soldier.changeDirNode:runAction(self.soldier.idleAction)
    end
end
