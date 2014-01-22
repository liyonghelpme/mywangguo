FightFoot = class(FightFunc)
function FightFoot:ctor(s)
    self.soldier.attackA = createAnimation("cat_foot_attackA", "cat_foot_attackA_%d.png", 0, 14, 1, 1, true)
    self.soldier.attackB = createAnimation("cat_foot_attackB", "cat_foot_attackB_%d.png", 0, 14, 1, 1, true)
    self.soldier.runAni = createAnimation("cat_foot_run", 'cat_foot_run_%d.png', 0, 12, 1, 1, true)
    self.soldier.idleAni = createAnimation("cat_foot_idle", 'cat_foot_idle_%d.png', 0, 20, 1, 1, true)
    self.soldier.deadAni = createAnimation("cat_foot_dead", 'cat_foot_dead_%d.png', 0, 10, 1, 1, true)
    self.soldier.deadAni:setRestoreOriginalFrame(false)
end
function FightFoot:initView()
    self.soldier.changeDirNode = CCSprite:createWithSpriteFrameName("cat_foot_idle_0.png")
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
    if not self.soldier.dead then
        print("reset Pos", self.soldier.sid, self.soldier.oldPos)
        setPos(self.soldier.bg, self.soldier.oldPos)
    end
end

