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
    local ene = self:findNearEnemy()
    self.soldier.attackTarget = ene
    if ene ~= nil then
        self.soldier.changeDirNode:runAction(self.soldier.attackA)
        --[[
        local a = CCSprite:create("cat_arrow.png") 
        self.soldier.map.battleScene:addChild(a)
        local p = getPos(self.bg)
        setPos(a, {p[1], p[2]})
        if self.color == 1 then
            setScaleX(a, -1)
        end
        local tpos = getPos(ene.bg)
        a:runAction(jumpTo(2, tpos[1], tpos[2], 200, 1))
        --]]
    end
    self.soldier.state = FIGHT_SOL_STATE.WAIT_ATTACK
end

--委任自动攻击 最近的敌人
--指派 攻击 某种类型的最近的敌人
function FightArrow2:findNearEnemy()
    local dx = 999999
    local dy = 999999
    local p = getPos(self.soldier.bg)
    local ene
    if self.color == 0 then
        for k, v in ipairs(self.soldier.map.eneSoldiers) do
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
        for k, v in ipairs(self.soldier.map.eneArrowSoldiers) do
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
        return ene
    end
end
