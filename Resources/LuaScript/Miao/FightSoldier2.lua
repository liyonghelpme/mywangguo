require "Miao.FightFunc"
require "Miao.FightArrow2"
require "Miao.FightFoot"
FIGHT_SOL_STATE = {
    FREE=0,
    START_ATTACK=1,
    IN_MOVE = 2,
    IN_ATTACK=3,
    DEAD = 4,

    NEXT_TARGET=5,
    WAIT_ATTACK=6,
    KILL_ALL = 7,
    FAR_ATTACK = 8,
    FIGHT_BACK=9,
    NEAR_ATTACK=10,
    NEAR_MOVE = 11,
    WAIT_MOVE= 12,
}

FightSoldier2 = class()
--调整每个士兵的左右 我方的 右侧 敌方的左侧
function FightSoldier2:ctor(m, id, col, row, data, sid)
    self.sid = sid
    self.id = id
    self.map = m
    self.left = nil
    self.right = nil
    --up low 敌方所在行 我方可能已经没有了士兵
    self.up = nil
    self.low = nil

    --print('left right', self.left, self.right)
    self.health = 20
    self.attack = 10
    --所在列
    self.col = col
    self.row = row
    --相当于几个士兵的能力
    self.data = data
    self.color = data.color
    self.dead = false
    self.speed = 200
    self.arrowHurt = 0

    local myab = getSolAbility(self.id+1, self.data.level, self.map.scene.maxSoldier[self.color+1][self.id+1])
    self.health = myab.health
    self.maxHealth = myab.health
    self.attack = myab.attack
    self.defense = myab.defense
    --地图记录每个网格状态 
    --士兵类型kind
    if self.id == 0  then
        self.funcSoldier = FightFoot.new(self)
    elseif self.id == 1 then
        self.funcSoldier = FightArrow2.new(self)
    end

    self.bg = CCNode:create()
    self.funcSoldier:initView()
    self.bg:addChild(self.changeDirNode)
    setAnchor(self.changeDirNode, {262/512, (512-352)/512})
    self.state = FIGHT_SOL_STATE.FREE
    self.shadow = CCSprite:create("roleShadow2.png")
    self.bg:addChild(self.shadow,  -1)
    setSize(self.shadow, {70, 44})
    self.needUpdate = true
    registerEnterOrExit(self)

    self.stateLabel = ui.newBMFontLabel({text="", font='bound.fnt', size=14, color={0, 0, 0}})
    self.bg:addChild(self.stateLabel)
    setPos(self.stateLabel, {0, 50})

    self.sLabel = ui.newBMFontLabel({text="", font="bound.fnt", size=20, color={255, 0, 0}})
    self.bg:addChild(self.sLabel)
    setPos(self.sLabel, {0, 80})
    
    self.sidLabel = ui.newBMFontLabel({text=self.sid, font="bound.fnt", size=20, color={0, 255, 0}})
    self.bg:addChild(self.sidLabel)
    setPos(self.sidLabel, {0, 100})
end
function FightSoldier2:showPose(x)
    if not self.showYet then
        local vs = getVS()
        local p = getPos(self.bg)
        --print("my pos", p[1], x)
        self.finPos = false
        local function poseOver()
            self.finPos = true
        end
        if p[1]-vs.width-50 <= math.abs(x) then
            self.changeDirNode:runAction(sequence({CCAnimate:create(self.attackA), callfunc(nil, poseOver)}))
            self.showYet = true
        end
    end
end

function FightSoldier2:setZord()
    local p = getPos(self.bg)
    self.bg:setZOrder(MAX_BUILD_ZORD-p[2])
end
function FightSoldier2:setDir()
    if self.color == 1 then
        setScaleX(self.changeDirNode, -1)
    else
        setScaleX(self.changeDirNode, 1)
    end
end
function FightSoldier2:doRunAndAttack(day)
    if not self.dead then
        --先弓箭 接着 步兵
        if day == 0 and self.id == 1 then
            self.state = FIGHT_SOL_STATE.START_ATTACK
        elseif day == 1 and self.id == 0 then
            self.state = FIGHT_SOL_STATE.START_ATTACK
        end
    end
end
function FightSoldier2:updateLabel()
    local s = self.sid..' '
    if self.left ~= nil then
        s = s..'l '..self.left.sid
    end
    if self.right ~= nil then
        s = s..'r '..self.right.sid
    end
    if self.attackTarget ~= nil then
        s = s..'t '..self.attackTarget.sid
    end
    local p = getPos(self.bg)
    s = s..'x:'..math.floor(p[1])..' '..math.floor(p[2])
    self.stateLabel:setString(s)

    local tid
    if self.attackTarget ~= nil then
        tid = self.attackTarget.sid
    end

    --self.sLabel:setString(self.state..' '..str(tid)..' '..str(self.funcSoldier.isHead))
    self.sLabel:setString(self.arrowHurt.." "..self.health)
end
function FightSoldier2:findFastTarget()
    local temp
    if self.color == 0 then
        temp = getFirstNotDead(self, 'right') 
    else
        temp = getFirstNotDead(self, 'left')
    end
    return temp
end
function FightSoldier2:startAttack(diff)
    if self.state == FIGHT_SOL_STATE.START_ATTACK then
        --步兵移动
        if self.id == 0 then
            self.moveAni = repeatForever(CCAnimate:create(self.runAni))
            self.changeDirNode:stopAction(self.idleAction)
            self.idleAction = nil
            self.changeDirNode:runAction(self.moveAni)
            self.state = FIGHT_SOL_STATE.IN_MOVE
            self.velocity = 0
            self.oldPos = getPos(self.bg)
            local enePos
            local offX

            --因为 不是head 所以不能攻击这
            --寻找第一个非死亡对象 步兵  同行
            self.attackTarget = self:findFastTarget()
            if self.color == 0 then
                offX = -40+self.row*5
            else
                offX  = 40-self.row*5
            end

            --同行没有
            if self.attackTarget == nil then
                print("start Attack find near row")
                self.attackTarget = self:findNearRow()
            end
            --同行没有士兵可以攻击 寻找最近的士兵
            if self.attackTarget ~= nil then 
                if self.attackTarget.color ~= self.color then
                    enePos = getPos(self.attackTarget.bg)
                    if self.attackTarget.id == 0 then
                        local midPoint = (self.oldPos[1]+enePos[1])/2
                        midPoint = midPoint+offX+math.random(20)-10
                        local t = math.abs(midPoint-self.oldPos[1])/self.speed
                        self.moveAct = sinein(moveto(t, midPoint, self.oldPos[2]))
                        self.bg:runAction(self.moveAct)
                        self.midPoint = midPoint
                        print("attack MidPoint", self.midPoint)
                    else
                        local offE = -110
                        if self.color == 1 then
                            offE = 110
                        end
                        local midPoint = enePos[1]+offE
                        local t = math.abs(midPoint-self.oldPos[1])/self.speed
                        self.moveAct = sinein(moveto(t, midPoint, self.oldPos[2]))
                        self.bg:runAction(self.moveAct)
                        self.midPoint = midPoint
                        print("foot attack arrow")
                    end
                else
                    print("no enemy to attack same color")
                end
            end
        else
            self.funcSoldier:startAttack()
        end
    end
end

--跟随我前面的 我方士兵
function FightSoldier2:update(diff)
    self:updateLabel()
    self:startAttack(diff)
    self:doPose(diff)
    self:doMove(diff)
    self:doAttack(diff)
    self:doDead(diff)
    self:doNext(diff)
    self:waitAttack(diff)
    self:doKillAll(diff)
    self:doFightBack(diff)
    self:doNearAttack(diff)
    self:doNearMove(diff)
    self.funcSoldier:doWaitMove(diff)
end

function FightSoldier2:doPose(diff)
    if self.poseOver then
        self.poseOver = false
        self.idleAction = repeatForever(CCAnimate:create(self.idleAni))
        self.changeDirNode:runAction(self.idleAction)
    end
end

function FightSoldier2:doHarm()
    --自己没死才能造成伤害
    if not self.dead then
        self.oneAttack = true
        --开始攻击一段时间后 才出现这个 action
        if not self.attackTarget.dead then
            --敌人没挂 才出攻击动作
            self:showAttackEffect()
        end
        self.attackTarget:doHurt(self.attack, false, self)
        local dir = 1
        if self.color == 1 then
            dir = -1
        end
        local rd = math.random(10)+5
        self.bg:runAction(moveby(0.2, dir*rd, 0))
    end
end

function FightSoldier2:runAction(act)
    if self.curAct ~= nil then
        self.changeDirNode:stopAction(self.curAct)
        self.curAct = nil
    end
    self.changeDirNode:runAction(act)
end
function FightSoldier2:calHurt(harm)
    return math.max(1, harm-self.defense)
end
--谁攻击高 对方就受到 被动伤害
function FightSoldier2:doHurt(harm, showBomb, whoAttack)
    --死亡了就不接受 伤害了
    if self.dead then
        return
    end
    local rd = math.random(2)
    if rd == 1 or showBomb then
        self:showBombEffect()
    end

    print("doHurt", harm, self.defense, self.health)
    local harm = harm-self.defense
    harm = math.max(harm, 1)
    --伤害小于 生命值上限
    harm = math.min(self.health, harm)
    print("real hurt", harm)
    local lastHealth = self.health
    self.health = self.health-harm
    --平均每人的生命值
    local eachHealth = math.floor(self.maxHealth/self.data.level) 
    --之前剩余的人数量
    local lastNum = math.ceil(lastHealth/eachHealth)
    local nowNum = math.ceil(self.health/eachHealth)
    local dnum = lastNum-nowNum
    print("hurt soldier Num", lastNum, nowNum, dnum)
    --损失的士兵数量 损失的生命值数量
    self.map.scene.menu:killSoldier(self, dnum, harm)

    local num = ui.newBMFontLabel({text=harm, font='bound.fnt', size=25, color={128, 0, 0}})
    local p = getPos(self.bg)
    self.map.battleScene:addChild(num, MAX_BUILD_ZORD)
    setPos(num, {p[1], p[2]+50})
    num:runAction(sequence({fadein(0.2), moveby(0.5, 0, 20), fadeout(0.2), callfunc(nil, removeSelf, num)}))
    
    local dir = 1 
    if self.color == 0 then
        dir = -1
    end
    local rd = math.random(10)+5
    self.bg:runAction(moveby(0.2, dir*rd, 0))

    --attackDir
    if not self.dead then
    end
    --没有受到攻击动作
    if self.health <= 0 and not self.dead then
        print("doDead action", self.color)
        self.dead = true
        self.state = FIGHT_SOL_STATE.DEAD
        self.changeDirNode:stopAllActions()
        self.changeDirNode:runAction(CCAnimate:create(self.deadAni)) 
        local vs = getVS()
        if self.color == 0 then
            print("jump0")
            self.changeDirNode:runAction(jumpBy(2, -vs.width/2, 100, 200, 1))
            self.changeDirNode:runAction(sequence({delaytime(1), fadeout(1)}))
            self.shadow:runAction(sequence({delaytime(1), fadeout(1)}))
        else
            print("jump1")
            self.changeDirNode:runAction(jumpBy(2, vs.width/2, 100, 200, 1))
            self.changeDirNode:runAction(sequence({delaytime(1), fadeout(1)}))
            self.shadow:runAction(sequence({delaytime(1), fadeout(1)}))
        end
        self.bg:runAction(sequence({delaytime(3), disappear(self.bg)}))
    end
end


function FightSoldier2:showAttackEffect()
    local p = getPos(self.bg)
    local sp = createSprite("attack5.png")
    self.map.battleScene:addChild(sp)
    if self.color == 0 then
        setPos(sp, {p[1]+20, p[2]+20})
    else
        setPos(sp, {p[1]-20, p[2]+20})
        setScaleX(sp, -1)
    end
    sp:setZOrder(MAX_BUILD_ZORD)
    sp:runAction(sequence({delaytime(0.5), CCAnimate:create(getAnimation("attackSpe1"))}))
    sp:runAction(sequence({fadeout(0.8), callfunc(nil, removeSelf, sp)}))
end
function FightSoldier2:showBombEffect()
    local p = getPos(self.bg)
    local sp = createSprite("attack1.png")
    self.map.battleScene:addChild(sp)
    setPos(sp, {p[1]+math.random(20)-10, p[2]+20+math.random(5)})
    sp:setZOrder(MAX_BUILD_ZORD)
    sp:runAction(CCAnimate:create(getAnimation("attackSpe2")))
    sp:runAction(sequence({fadeout(0.6), callfunc(nil, removeSelf, sp)}))
end

function FightSoldier2:doMove(diff)
    if self.state == FIGHT_SOL_STATE.IN_MOVE then
        if self.attackTarget.color ~= self.color then
            local p = getPos(self.bg)
            print("not same color move", p[1], self.midPoint)
            if math.abs(p[1]-self.midPoint) < 5 then
                self.inMove = false
                self.bg:stopAction(self.moveAct)
                self.changeDirNode:stopAction(self.moveAni)
                self.state = FIGHT_SOL_STATE.IN_ATTACK
                local rd = math.random(2)
                local aa 
                if rd == 1 then
                    aa = self.attackA
                else
                    aa = self.attackB
                end
                self.changeDirNode:runAction(sequence({CCAnimate:create(aa), callfunc(self, self.doHarm)}))
                self.oneAttack = false
                self:showAttackEffect()
            end
        --同方士兵 
        else
            --print("same color just move ", self.moveYet)
            --前方士兵开始移动之后 我也紧随其移动即可
            local p = getPos(self.bg)
            --local attPos = getPos(self.attackTarget.bg)
            --local dx = math.abs(attPos[1]-p[1])
            --dx > FIGHT_OFFX+10 and
            --移动 到 attackTarget 后面
            if not self.moveYet then
                local offX = FIGHT_OFFX
                if self.color == 0 then
                    offX = -FIGHT_OFFX
                end
                if self.attackTarget.midPoint ~= nil then
                    self.moveYet = true
                    self.midPoint = self.attackTarget.midPoint+offX 
                    print("midPoint", self.sid, self.midPoint)
                    print('other midPoint', self.attackTarget.midPoint)
                    local diffx = self.midPoint-p[1]
                    local t = math.abs(diffx/self.speed)
                    self.moveFin = false
                    local function finishMove()
                        print("soldier finishMove", self.midPoint)
                        self.moveFin = true
                        --self.changeDirNode:stopAction(self.moveAni)
                        --空闲等待状态
                        --self.changeDirNode:runAction(CCAnimate:create(self.idleAction))
                    end
                    print("bg move action", t, p[2], self.midPoint)
                    self.bg:runAction(sequence({sinein(moveto(t, self.midPoint, p[2])), callfunc(nil, finishMove)}))
                end
            end
            --我方士兵处于移动状态 自己没有在移动状态 前列 士兵跑步向前
            if self.attackTarget.inMove and not self.inMove then
                local offX
                local offX = FIGHT_OFFX
                if self.color == 0 then
                    offX = -FIGHT_OFFX
                end
                local p = getPos(self.bg)
                self.midPoint = self.attackTarget.midPoint+offX
                local diffx = self.midPoint-p[1]
                local t = math.abs(diffx/self.speed)
                self.bg:runAction(sinein(moveto(t, self.midPoint, p[2])))
                --需要几个frame 来广播移动
                self.inMove = true
            end
            if self.inMove then
                local p = getPos(self.bg)
                if p[1] == self.midPoint then
                    self.inMove = false
                end
            end
            --如果同行死亡
            --后续的同行也要跟进 攻击目标
            --同行死亡自己没有在移动才可以移动
            if self.attackTarget.dead and not self.inMove then
                print("my friend dead then find my friend's enemy to attack if exists ")
                self.attackTarget = self:findNearRow()
                if self.attackTarget ~= nil then
                    local nap = getPos(self.attackTarget.bg)
                    local mmid 
                    if self.color == 0 then
                        mmid = nap[1]-80
                    else
                        mmid = nap[1]+80
                    end
                    self.midPoint = mmid
                    local p = getPos(self.bg)
                    local diffx = self.midPoint-p[1]
                    local t = math.abs(diffx/self.speed)
                    self.bg:runAction(sinein(moveto(t, self.midPoint, p[2])))
                    --需要几个frame 来广播移动
                    self.inMove = true
                else
                    print("my Friend's attackTarget dead and I can't find attackTarget ")
                    self.state = FIGHT_SOL_STATE.KILL_ALL 
                end
            end
            --如果没有同行 攻击 同列
        end
    end
end
--同种相同士兵都杀死了 接着向后移动把
--寻找弓箭手 去攻击
--弓箭手进入 戒备状态
function FightSoldier2:doKillAll(diff)
    if self.state == FIGHT_SOL_STATE.KILL_ALL then
        if not self.findYet then
            print("killAll now")
            local dx = 999999
            local dy = 999999
            local p = getPos(self.soldier.bg)
            local ene
            local eneList = {}
            if self.soldier.color == 0 then
                table.insert(eneList, self.soldier.map.eneArrowSoldiers)
            else
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
            self.attackTarget = ene
            self.findYet = true
            --找到弓箭手去攻击之
            --next 调整mySoldier 为 myArrowSoldiers
            --跳转到正常的 攻击动画里面 动作中
            if self.attackTarget ~= nil then
                local tp = getPos(self.attackTarget.bg)
                local mp = getPos(self.bg)
                self.changeDirNode:stopAction(self.idleAction)
                self.changeDirNode:runAction(repeatForever(CCAnimate:create(self.runAni)))
                local offX = 40
                if self.color == 0 then
                    offX = -40
                end
                local midPoint = tp[1]+offX
                self.midPoint = midPoint
                local t = math.abs(midPoint-mp[1])/self.speed
                print("kill all move point", t, midPoint)
                self.moveAct = sinein(moveto(t, midPoint, self.oldPos[2]))
                self.bg:runAction(self.moveAct)
            --通知弓箭手警戒
            --即便不是目标也要警戒
                self.state = FIGHT_SOL_STATE.IN_MOVE
            end
        end
        if self.attackTarget ~= nil then
        end
    end
end
--正常直接找同行的 同行的找不到 开始找 最近的 x y 值的
--先考虑y 方向距离 接着 考虑x 方向距离

function FightSoldier2:findNearRow()
    print("find near row enemy")
    --找最近的目标攻击
    --k-1 ck-1 对应的列
    local dx = 999999
    local dy = 999999
    local p = getPos(self.bg)
    local ene
    local eneList = {}
    if self.color == 0 then
        table.insert(eneList, self.map.eneSoldiers)
        table.insert(eneList, self.map.eneArrowSoldiers)
    else
        table.insert(eneList, self.map.mySoldiers)
        table.insert(eneList, self.map.myArrowSoldiers)
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
    --选择所有士兵 包括弓箭手
    return ene
    --等待攻击对方靠近 即可
end
--自己移动对方不移动 所以 距离要大一些 
function FightSoldier2:moveToTarget()
    local tp = getPos(self.attackTarget.bg)
    local mp = getPos(self.bg)
    --self.changeDirNode:stopAction(self.idleAction)
    self.changeDirNode:stopAllActions()
    self.moveAni = repeatForever(CCAnimate:create(self.runAni))
    self.changeDirNode:runAction(self.moveAni)
    local offX = 80
    if self.color == 0 then
        offX = -80
    end
    local midPoint = tp[1]+offX
    self.midPoint = midPoint
    local t = math.abs(midPoint-mp[1])/self.speed
    print("kill all move point", t, midPoint)
    self.moveAct = sinein(moveto(t, midPoint, self.oldPos[2]))
    self.bg:runAction(self.moveAct)
    --通知弓箭手警戒
    --即便不是目标也要警戒
    self.state = FIGHT_SOL_STATE.IN_MOVE
    self.inMove = true
end

--调整了我的 左右之后 检查我的敌人距离
--bug 两者 都杀死了 同行的目标 然后 等待 对方靠近
--两者 不同行  并且距离太大就导致无法攻击了
function FightSoldier2:doNext(diff)
    if self.state == FIGHT_SOL_STATE.NEXT_TARGET then
        if self.id == 0 then
            if self.attackTarget ~= nil then
                --导致相关行错列了
                self.checkEneYet = false
                local p = getPos(self.attackTarget.bg)
                local mp = getPos(self.bg)
                --因为双方攻击的都是 不同行 而行之间存在移动的 偏移 导致 超出了攻击范围 超出了90范围
                --少量一方移动即可
                if math.abs(p[1]-mp[1]) < 100 then
                    self.changeDirNode:stopAction(self.idleAction)
                    self.state = FIGHT_SOL_STATE.IN_ATTACK
                    local rd = math.random(2)
                    local aa 
                    if rd == 1 then
                        aa = self.attackA
                    else
                        aa = self.attackB
                    end
                    self.changeDirNode:runAction(sequence({CCAnimate:create(aa), callfunc(self, self.doHarm)}))
                    self.oneAttack = false
                    self:showAttackEffect()
                    print("next attack target get now attack him!!", self.sid, self.attackTarget.sid)
                --处理对方也在发呆的情况
                else
                    self.nextTime = self.nextTime+diff
                    if self.nextTime >= 0.4 and self.attackTarget.state == FIGHT_SOL_STATE.NEXT_TARGET then
                        self:moveToTarget() 
                    end
                end
            --当前行没有目标找相邻行的attackTarget 
            elseif not self.checkEneYet then
                --找最近的目标攻击
                --k-1 ck-1 对应的列
                local ene = self:findNearRow()
                print("find near row enemy", ene)
                --没有找到 步兵 则开始 寻找弓箭手 所有的 士兵 最近的 
                --等待攻击对方靠近 即可
                --找到弓箭手 之后要相距 80的距离攻击 不能冲太近了
                if ene ~= nil then
                    print("find attackTarget ok")
                    self.attackTarget = ene
                    --攻击步兵 则等待第一波 已经杀光了 所以进入移动攻击 状态
                    if self.attackTarget.id == 0 then
                    --攻击弓箭手 则 跑过去攻击 对手是进入 近战状态 还是 远程状态
                    --对手 补位 还是 自己补位
                    else
                        --步兵自己跑过去 补位
                        --检测两者距离 如果距离 < 400 则 等待对方过来  否则 步兵主动过去攻击
                        local myp = getPos(self.bg)
                        local ap = getPos(self.attackTarget.bg)
                        --等待弓箭手过来攻击我
                        if math.abs(myp[1]-ap[1]) < 400 then
                        --我过去攻击弓箭手
                        else
                            self:moveToTarget()
                        end
                    end
                --找了没有找到 证明没有敌人了
                else
                    print("checkEneYet ok")
                    self.checkEneYet = true
                end
            end
        else
            self.funcSoldier:doNext(diff)
        end
    end
end


function FightSoldier2:doAttack(diff)
    if self.state == FIGHT_SOL_STATE.IN_ATTACK then
        if self.oneAttack then
            self.oneAttack = false
            if self.attackTarget.dead then
                print("enemy dead now", self.attackTarget.sid)
                self.state = FIGHT_SOL_STATE.NEXT_TARGET
                self.nextTime = 0
                self.idleAction = repeatForever(CCAnimate:create(self.idleAni))
                self.changeDirNode:runAction(self.idleAction)

                if self.color == 1 then
                    if self.attackTarget.left ~= nil then
                        self.left = getSidest(self.attackTarget, 'left')
                        self.attackTarget = self.left
                    else
                        self.left = nil
                        self.attackTarget = nil
                    end
                else
                    if self.attackTarget.right ~= nil then
                        self.right = getSidest(self.attackTarget, 'right')
                        self.attackTarget = self.right
                    else
                        self.right = nil
                        self.attackTarget = nil
                    end
                end
            else
                local rd = math.random(2)
                local aa 
                if rd == 1 then
                    aa = self.attackA
                else
                    aa = self.attackB
                end
                self.changeDirNode:runAction(sequence({CCAnimate:create(aa), callfunc(self, self.doHarm)}))
            end
        end
    end
end
function FightSoldier2:doDead(diff)
    if self.state == FIGHT_SOL_STATE.DEAD then
        local p = getPos(self.changeDirNode)
        setPos(self.shadow, {p[1], 0})
    end
end

function FightSoldier2:finishAttack()
    self.funcSoldier:finishAttack()
end

function FightSoldier2:waitAttack(diff)
    self.funcSoldier:waitAttack(diff)
end
function FightSoldier2:doFightBack(diff)
    self.funcSoldier:doFightBack(diff)
end
function FightSoldier2:doNearAttack(diff)
    self.funcSoldier:doNearAttack(diff)
end

function FightSoldier2:doNearMove(diff)
    self.funcSoldier:doNearMove(diff)
end
function FightSoldier2:doWinMove(left, right)
    if not self.dead then
        print("doWinMove", left, right)
        if self.color == 0 and left > 0 then
            --self.bg:stopAllActions()
            self.changeDirNode:stopAllActions()
            self.changeDirNode:runAction(repeatForever(CCAnimate:create(self.runAni)))
            local vs = getVS()
            local t = vs.width/self.speed
            self.bg:runAction(moveby(t, vs.width, 0))
        elseif self.color == 1 and right > 0 then
            self.changeDirNode:stopAllActions()
            self.changeDirNode:runAction(repeatForever(CCAnimate:create(self.runAni)))
            local vs = getVS()
            local t = vs.width/self.speed
            self.bg:runAction(moveby(t, -vs.width, 0))
        end
    end
end
