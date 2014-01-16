function FightLayer2:finishFoot()
    print("finish Foot attack")
    self:clearMenu()
    local ret, left, right = self:oneFail()
    if ret then
    else
        self.finishAttack = false
        self.day = 0
        self.passTime = 0
        for k, v in ipairs(self.allSoldiers) do
            v.funcSoldier:resetPos()
        end
    end
end
function FightLayer2:countFoot()
    for k, v in ipairs(self.allSoldiers) do
        if v.id == 0 and not v.dead then
            return 1
        end
    end
    return 0
end
function FightLayer2:clearMenu()
    self.scene.menu:finishRound()
end
function FightLayer2:oneFail()
    local left = 0
    local right = 0
    for k, v in ipairs(self.allSoldiers) do
        if not v.dead then
            if v.color == 0 then
                left = left+1
            elseif v.color == 1 then
                right = right+1
            end
            if left > 0 and right > 0 then
                return false
            end
        end
    end
    print("oneFail", left, right)
    --只是士兵 跑动 一会大概几秒钟吧
    for k, v in ipairs(self.allSoldiers) do
        v:doWinMove(left, right)
    end
    if left == right then
        addBanner("平局")
    elseif left > 0 then
        addBanner("胜利")
    else
        addBanner("失败")
    end
    return true, left, right
end

--不同士兵类型执行不同的剧本
function FightLayer2:footScript(diff)
    --print("footScript")
    local p = getPos(self.battleScene)
    if self.passTime == 0 then
        self.moveTarget = p[1]
        for k, v in ipairs(self.allSoldiers) do
            --开始跑步和攻击
            v:doRunAndAttack(self.day)
        end
    end

    --第一天结束之后 场景应该回到那个位置呢？
    --开始的弓箭手位置
    self.passTime = self.passTime+diff
    local cf = self:countFoot()
    if (cf == 0 or self.passTime >= 20) and not self.finishAttack then
        print("finish foot attack now", cf, self.passTime)
        self.finishAttack = true
        for k, v in ipairs(self.allSoldiers) do
            v:finishAttack()
        end
        --回到弓箭位置
        --self.day = 0
        --等上一会才士兵回到初始位置
        self.bg:runAction(sequence({delaytime(1), callfunc(self, self.finishFoot)}))
    end
    --屏幕重新回到开始位置 
    if not self.finishAttack then
        local mySol
        --从外列 逐行搜索
        if self.mySol == nil or self.mySol.dead then
            local maxX = 0
            --从下行到上行 应该从上到下 
            --随便了 足够的空隙即可
            for k, v in ipairs(self.mySoldiers) do
                for tk, tv in ipairs(v) do
                    --活着的士兵
                    if not tv.dead then
                        --local p = getPos(tv.bg)
                        --if p[1] > maxX then 
                            mySol = tv
                            --maxX = p[1]
                            break
                        --end
                    end
                end
            end
        else
            mySol = self.mySol
        end
        --寻找影子步兵
        if  mySol ~= nil then
            self.mySol = mySol
            local sp = getPos(mySol.bg)
            local vs = getVS()
            --看一下4对象的位置
            --查看一下 当前最前端的步兵的 位置 如果步兵死亡了 那么 就使用影子步兵来移动
            --shadow 所有步兵移动都会 影响 
            if sp[1] >= math.abs(p[1])+vs.width/2 then
                self.moveTarget = -(sp[1])+vs.width/2
                --print("moveTarget", self.moveTarget)
            end
        end
    end

    if self.moveTarget ~= nil then
        local pos = getPos(self.battleScene)
        local smooth = diff*5
        smooth = math.min(smooth, 1)
        local px = pos[1]*(1-smooth)+self.moveTarget*smooth
        setPos(self.battleScene, {px, pos[2]}) 
        self:adjustBattleScene(px)
        --[[
        local fxy = getPos(self.farScene)
        setPos(self.farScene, {px*self.farRate, fxy[2]})
        local nxy = getPos(self.nearScene)
        setPos(self.nearScene, {px*self.nearRate, nxy[2]})
        --]]
    end
end

function FightLayer2:switchArrow()
    self.day = 1
    self.animateYet = false
    self.passTime = 0
end

--屏幕左侧宽度 要是 保证最后面的有半个屏幕可以显示 至少 
--当前最后面的 是弓箭手
--当前的命令队列 cmdList 解释命令 执行命令  
function FightLayer2:arrowScript(diff)
    if self.passTime == 0 then
        local p = getPos(self.battleScene)
        local vs = getVS()
        local fw = #self.myFootNum*FIGHT_OFFX
        local bp = self.leftWidth-fw
        self.moveTarget = -(bp-(vs.width/2-50))
        print("self.leftWidth ", self.moveTarget)
    end
    self.passTime = self.passTime+diff

    if self.moveTarget ~= nil then
        local pos = getPos(self.battleScene)
        local smooth = diff*5
        smooth = math.min(smooth, 1)
        local dx = math.abs(pos[1]-self.moveTarget)
        local px = pos[1]*(1-smooth)+self.moveTarget*smooth
        setPos(self.battleScene, {px, pos[2]})
        self:adjustBattleScene(px)
        --[[
        local fxy = getPos(self.farScene)
        setPos(self.farScene, {px*self.farRate, fxy[2]})
        local nxy = getPos(self.nearScene)
        setPos(self.nearScene, {px*self.nearRate, nxy[2]})
        --]]

        if self.prepareFoot and dx <= 5 then
            self.prepareFoot = false
            for k, v in ipairs(self.allSoldiers) do
                v:finishAttack()
            end
            self.bg:runAction(sequence({delaytime(0.5), callfunc(self, self.switchArrow)}))
            print("begin Foot Script")
        end
    end
    --进入 动画状态
    local p = getPos(self.battleScene)
    --print("battleScene pos and moveTarget", p[1], self.moveTarget)
    if not self.animateYet and math.abs(p[1]-self.moveTarget) <= 5 then
        self.animateYet = true
        for k, v in ipairs(self.allSoldiers) do
            --开始跑步和攻击
            v:doRunAndAttack(self.day)
        end
        print("animation state")
    end
    --trace Arrow 位置
    if self.arrow ~= nil then
        --弓箭死亡了 准备进入第二个节点
        if self.arrow.dead then
            self.arrow = nil
            self.bg:runAction(sequence({delaytime(1), callfunc(self, self.finishArrow)}))
        else
            local vs = getVS()
            local ap = getPos(self.arrow.changeDirNode)
            local abp = getPos(self.arrow.bg)
            ap[1] = abp[1]+ap[1]
            ap[2] = abp[2]+ap[2]
            local cp = getPos(self.battleScene)
            if (ap[1]+100) >= (-cp[1]+vs.width/2) then
                self.moveTarget = -(ap[1]+100-vs.width/2)
            end
        end
    end
end
--进入步兵回合 
--插入好多动作
function FightLayer2:finishArrow()
    --self.day = 1
    --左侧屏幕宽度 第一排 步兵的位置
    --游戏开始就记录了步兵的位置
    self:clearMenu()
    local ret, left, right = self:oneFail()
    if ret then
    else
        local vs = getVS()
        local mv = self.leftWidth-vs.width/2
        self.moveTarget = -mv
        self.prepareFoot = true
        print("finishArrow", -mv)
    end
end



--可能有多个 arrow
--先追踪 我方的弓箭
function FightLayer2:traceArrow(arr)
    if arr.color == 0 then
        if self.arrow ~= nil then
            local ap = getPos(self.arrow.bg)
            local np = getPos(arr.bg)
            --按照左侧追踪 我方镜头表现
            if np[1] >= ap[1] then
                self.arrow = arr
            end
        else
            self.arrow = arr
        end
    end
end
