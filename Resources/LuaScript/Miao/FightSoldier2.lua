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

    self.stateLabel = ui.newBMFontLabel({text="", font='bound.fnt', size=20, color={0, 0, 0}})
    self.bg:addChild(self.stateLabel)
    setPos(self.stateLabel, {0, 50})

    self.sLabel = ui.newBMFontLabel({text="", font="bound.fnt", size=20, color={255, 0, 0}})
    self.bg:addChild(self.sLabel)
    setPos(self.sLabel, {0, 80})
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
    --先弓箭 接着 步兵
    if day == 0 and self.id == 1 then
        self.state = FIGHT_SOL_STATE.START_ATTACK
    elseif day == 1 and self.id == 0 then
        self.state = FIGHT_SOL_STATE.START_ATTACK
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
    self.sLabel:setString(self.state..' '..str(tid))
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
            if self.color == 0 then
                self.attackTarget = self.right
                offX = -40
            else
                self.attackTarget = self.left
                offX  = 40
            end
            --同行没有士兵可以攻击 寻找最近的士兵
            if self.attackTarget == nil then
                self.attackTarget = self:findNearRow()
            end
            if self.attackTarget ~= nil then 
                self.speed = 100
                if self.attackTarget.color ~= self.color then
                    enePos = getPos(self.attackTarget.bg)
                    local midPoint = (self.oldPos[1]+enePos[1])/2
                    midPoint = midPoint+offX
                    local t = math.abs(midPoint-self.oldPos[1])/self.speed
                    self.moveAct = sinein(moveto(t, midPoint, self.oldPos[2]))
                    self.bg:runAction(self.moveAct)
                    self.midPoint = midPoint
                    print("attack MidPoint", self.midPoint)
                else
                    
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
end

function FightSoldier2:doPose(diff)
    if self.poseOver then
        self.poseOver = false
        self.idleAction = repeatForever(CCAnimate:create(self.idleAni))
        self.changeDirNode:runAction(self.idleAction)
    end
end
function FightSoldier2:doHarm()
    self.oneAttack = true
    self:showAttackEffect()
    self.attackTarget:doHurt(self.attack)
    local dir = self.map:getAttackDir(self, self.attackTarget)
    local rd = math.random(2)+2
    self.bg:runAction(moveby(0.2, dir*rd, 0))
end
function FightSoldier2:runAction(act)
    if self.curAct ~= nil then
        self.changeDirNode:stopAction(self.curAct)
        self.curAct = nil
    end
    self.changeDirNode:runAction(act)
end
--谁攻击高 对方就受到 被动伤害
function FightSoldier2:doHurt(harm)
    local rd = math.random(2)
    if rd == 1 then
        self:showBombEffect()
    end
    self.health = self.health-harm
    local num = ui.newBMFontLabel({text=harm, font='bound.fnt', size=25, color={128, 0, 0}})
    local p = getPos(self.bg)
    self.map.battleScene:addChild(num, MAX_BUILD_ZORD)
    setPos(num, {p[1], p[2]+50})
    num:runAction(sequence({fadein(0.2), moveby(0.5, 0, 20), fadeout(0.2), callfunc(nil, removeSelf, num)}))

    --没有受到攻击动作
    if self.health <= 0 and not self.dead then
        self.dead = true
        self.state = FIGHT_SOL_STATE.DEAD
        self.changeDirNode:stopAllActions()
        self.changeDirNode:runAction(CCAnimate:create(self.deadAni)) 
        local vs = getVS()
        if self.color == 0 then
            self.changeDirNode:runAction(jumpBy(2, -vs.width/2, 100, 200, 1))
            self.changeDirNode:runAction(sequence({delaytime(1), fadeout(1)}))
            self.shadow:runAction(sequence({delaytime(1), fadeout(1)}))
        else
            self.changeDirNode:runAction(jumpBy(2, vs.width/2, 100, 200, 1))
            self.changeDirNode:runAction(sequence({delaytime(1), fadeout(1)}))
            self.shadow:runAction(sequence({delaytime(1), fadeout(1)}))
        end
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
    sp:runAction(sequence({delaytime(0.2), CCAnimate:create(getAnimation("attackSpe1"))}))
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
            if p[1] == self.midPoint then
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
            if self.attackTarget.dead then
                print("my friend dead")
                if self.color == 0 then
                    self.right = self.attackTarget.right
                    self.attackTarget = self.attackTarget.right 
                else
                    self.left = self.attackTarget.left
                    self.attackTarget = self.attackTarget.left
                end
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
                
                --移动过了 并且
                --if self.moveFin and self.moveYet then
                --end
                --切换到 上面的分支 进行攻击了
                --开始攻击 重新计算midPoint
                --self.moveYet = false
                --self.state = FIGHT_SOL_STATE.START_ATTACK
                --接着向前移动
                --self.midPoint = nil
                --self.changeDirNode:stopAction(self.moveAct)
            end
            --如果没有同行 攻击 同列
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
    if self.color == 0 then
        for k, v in ipairs(self.map.eneSoldiers) do
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
    else
        for k, v in ipairs(self.map.mySoldiers) do
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
    end
    --等待攻击对方靠近 即可
    return ene
end

--调整了我的 左右之后 检查我的敌人距离
function FightSoldier2:doNext(diff)
    if self.state == FIGHT_SOL_STATE.NEXT_TARGET then
        if self.attackTarget ~= nil then
            --导致相关行错列了
            self.checkEneYet = false
            local p = getPos(self.attackTarget.bg)
            local mp = getPos(self.bg)
            if math.abs(p[1]-mp[1]) < 90 then
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
            end
        --当前行没有目标找相邻行的attackTarget 
        elseif not self.checkEneYet then
            print("find near row enemy")
            --找最近的目标攻击
            --k-1 ck-1 对应的列
            local ene = self:findNearRow()
            --等待攻击对方靠近 即可
            if ene ~= nil then
                self.attackTarget = ene
            --找了没有找到 证明没有敌人了
            else
                self.checkEneYet = true
            end
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
                self.idleAction = repeatForever(CCAnimate:create(self.idleAni))
                self.changeDirNode:runAction(self.idleAction)

                if self.color == 1 then
                    if self.attackTarget.left ~= nil then
                        self.left = self.attackTarget.left
                        self.attackTarget = self.left
                    else
                        self.left = nil
                        self.attackTarget = nil
                    end
                else
                    if self.attackTarget.right ~= nil then
                        self.right = self.attackTarget.right
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
end
function FightSoldier2:waitAttack(diff)
end
