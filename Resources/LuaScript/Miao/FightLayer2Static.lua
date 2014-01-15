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

    self.passTime = self.passTime+diff
    if self.passTime >= 5 and not self.finishAttack then
        self.finishAttack = true
        for k, v in ipairs(self.allSoldiers) do
            --开始跑步和攻击
            v:finishAttack()
        end
    end

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

    if self.moveTarget ~= nil then
        local pos = getPos(self.battleScene)
        local smooth = diff*5
        smooth = math.min(smooth, 1)
        local px = pos[1]*(1-smooth)+self.moveTarget*smooth
        setPos(self.battleScene, {px, pos[2]}) 
        local fxy = getPos(self.farScene)
        setPos(self.farScene, {px*self.farRate, fxy[2]})
        local nxy = getPos(self.nearScene)
        setPos(self.nearScene, {px*self.nearRate, nxy[2]})
    end
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
        
        local fxy = getPos(self.farScene)
        setPos(self.farScene, {px*self.farRate, fxy[2]})
        local nxy = getPos(self.nearScene)
        setPos(self.nearScene, {px*self.nearRate, nxy[2]})

        if self.prepareFoot and dx <= 5 then
            self.day = 1
            self.passTime = 0
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
function FightLayer2:finishArrow()
    --self.day = 1
    --左侧屏幕宽度 第一排 步兵的位置
    --游戏开始就记录了步兵的位置
    local vs = getVS()
    local mv = self.leftWidth-vs.width/2
    self.moveTarget = -mv
    self.prepareFoot = true
    print("finishArrow", -mv)
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
