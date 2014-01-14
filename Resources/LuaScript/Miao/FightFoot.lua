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

