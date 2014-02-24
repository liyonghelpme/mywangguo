FightFoot = class(FightFunc)
function FightFoot:ctor(s)
    if not self.soldier.isHero then
        self.soldier.attackA = createAnimation("cat_foot_attackA", "cat_foot_attackA_%d.png", 0, 14, 2, 1, true)
        self.soldier.attackB = createAnimation("cat_foot_attackB", "cat_foot_attackB_%d.png", 0, 14, 2, 1, true)
        self.soldier.runAni = createAnimation("cat_foot_run", 'cat_foot_run_%d.png', 0, 12, 2, 1, true)
        self.soldier.idleAni = createAnimation("cat_foot_idle", 'cat_foot_idle_%d.png', 0, 20, 2, 1, true)
        self.soldier.deadAni = createAnimation("cat_foot_dead", 'cat_foot_dead_%d.png', 0, 10, 2, 1, true)
        self.soldier.deadAni:setRestoreOriginalFrame(false)
    else
        self.soldier.attackA = createAnimation("cat_hero_foot_attackA", "cat_hero_foot_attackA_%d.png", 0, 16, 2, 1, true)
        self.soldier.attackB = createAnimation("cat_hero_foot_attackB", "cat_hero_foot_attackB_%d.png", 0, 16, 2, 1, true)
        self.soldier.runAni = createAnimation("cat_hero_foot_run", 'cat_hero_foot_run_%d.png', 0, 12, 2, 1, true)
        self.soldier.idleAni = createAnimation("cat_hero_foot_idle", 'cat_hero_foot_idle_%d.png', 0, 20, 2, 1, true)
        self.soldier.deadAni = createAnimation("cat_hero_foot_dead", 'cat_hero_foot_dead_%d.png', 0, 10, 2, 1, true)
        self.soldier.deadAni:setRestoreOriginalFrame(false)

    end
end
function FightFoot:initView()
    if not self.soldier.isHero then
        self.soldier.changeDirNode = CCSprite:createWithSpriteFrameName("cat_foot_idle_0.png")
    else
        self.soldier.changeDirNode = CCSprite:createWithSpriteFrameName("cat_hero_foot_idle_0.png")
    end
end

--清理一些状态变量
--恢复士兵位置
--快速移动屏幕
function FightFoot:finishAttack()
    self.soldier.state = FIGHT_SOL_STATE.FREE
    self.soldier.moveYet = false 
    self.soldier.inMove = false
    self.soldier.oneAttack = false 
    self.soldier.checkEneYet = false
    self.soldier.arrowHurt = 0
    self.soldier.midPoint = nil

    if self.soldier.dead then
        --setVisible(self.soldier.bg, false)
        --要等飞走之后 才invisible的
    else
        self.soldier.changeDirNode:stopAllActions()
        self.soldier.bg:stopAllActions()
        self.soldier.idleAction = repeatForever(CCAnimate:create(self.soldier.idleAni))
        self.soldier.changeDirNode:runAction(self.soldier.idleAction)
    end
end

function FightFoot:resetPos()
    if self.soldier.map.day == 2 then
        if not self.soldier.dead then
            print("reset Pos", self.soldier.sid, self.soldier.oldPos)
            setPos(self.soldier.bg, self.soldier.oldPos)
        end
    end
end

function FightFoot:findNearFoot()
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
