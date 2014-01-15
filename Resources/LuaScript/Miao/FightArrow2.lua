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

            if self.color == 1 then
                setScaleX(a.changeDirNode, -1)
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
            --self.soldier.attackTarget = nil
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
    if self.color == 0 then
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
    if self.state == FIGHT_SOL_STATE.WAIT_ATTACK then
        --目标不存在或者目标已经死亡了
        --我是当前 部队 的 头部 
        --检测 地方不对 是否向我开进了
        --left = nil left.dead = true
        --还要考虑我方步兵的 是否是我的left
        local isHead = false
        --考虑 我的 right 是否阵亡了 checkSide and fix Side
        if self.soldier.color == 0 then
            if self:checkSide('right') == nil then
                isHead = true
            end
        else
            if self:checkSide('left') == nil then
                isHead = true
            end
        end

        if isHead then
            local ene = self:findSameRow()
            if ene ~= nil then
                self.soldier.attackTarget = ene
            end
        end
        --对方向我移动中检测 一下距离 步兵正在向我靠近么 不一定可能正在向 地方
        --对方也在向我攻击移动
        if isHead and self.soldier.attackTarget.attackTarget == self.soldier  then
            local ap = getPos(self.soldier.attackTarget)
            local mp = getPos(self.soldier.bg)
            if math.abs(ap[1]-mp[1]) < 100 then
                self.soldier.state = FIGHT_SOL_STATE.FIGHT_BACK
            end
        end
    end
end


function FightArrow2:doFightBack(diff)
    if self.soldier.state == FIGHT_SOL_STATE.FIGHT_BACK then
        if not self.shootYet then
            self.shootYet = true
            local p = getPos(self.soldier.bg)
            local a = Arrow2.new(self.soldier, self.soldier.attackTarget)
            local abg = a.bg
            local offX = 20
            if self.soldier.color == 1 then
                offX = -20
            end
            setPos(abg, {p[1]+offX, p[2]})
            if self.color == 1 then
                setScaleX(a.changeDirNode, -1)
            end
            local as = self.soldier.map.arrowSpeed
            local tpos = getPos(self.soldier.attackTarget.bg)
            local tt = math.abs(tpos[1]-p[1])/as
            a.bg:runAction(sequence({moveto(tt, tpos[1], tpos[2]+34)}, callfunc(a, a.doHarm)))
        end
    end
end

