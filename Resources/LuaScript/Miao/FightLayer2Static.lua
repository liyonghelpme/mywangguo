--不同士兵类型执行不同的剧本
function FightLayer2:footScript(diff)
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

    local mySolP = self.mySoldiers[1][1]
    local sp = getPos(mySolP.bg)
    local vs = getVS()
    --看一下4对象的位置
    if sp[1] >= math.abs(p[1])+vs.width/2 then
        self.moveTarget = -(sp[1])+vs.width/2
        --print("moveTarget", self.moveTarget)
    end

    if self.moveTarget ~= nil then
        local pos = getPos(self.battleScene)
        local smooth = diff*self.smooth
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
function FightLayer2:arrowScript(diff)
    if self.passTime == 0 then
        local p = getPos(self.battleScene)
        local vs = getVS()
        local fw = #self.myFootNum*FIGHT_OFFX
        local bp = self.leftWidth-fw
        self.moveTarget = -(bp-(vs.width/2-50))
        print("self.leftWidth ", self.moveTarget)
    end

    if self.moveTarget ~= nil then
        local pos = getPos(self.battleScene)
        local smooth = diff*10
        smooth = math.min(smooth, 1)
        local px = pos[1]*(1-smooth)+self.moveTarget*smooth
        setPos(self.battleScene, {px, pos[2]})
        
        local fxy = getPos(self.farScene)
        setPos(self.farScene, {px*self.farRate, fxy[2]})
        local nxy = getPos(self.nearScene)
        setPos(self.nearScene, {px*self.nearRate, nxy[2]})
    end
    --进入 动画状态
    local p = getPos(self.battleScene)
    if math.abs(p[1]-self.moveTarget) <= 5 then
        print("animation state")
    end
end
