Wind = class(FuncBuild)
WIND_STATE = {
    FREE=0, 
    DO_ATTACK=1,
    IN_ATTACK=2,
}
function Wind:ctor(b)
    self.baseBuild = b
end
local testRange = 140
local testHurt = 6
function Wind:initWorking()
    if self.gear == nil then
        self.gear = CCSprite:create("f0.png")
        self.baseBuild.changeDirNode:addChild(self.gear)
        local sz = self.baseBuild.changeDirNode:getContentSize()
        setPos(self.gear, {87, (sz.height-38)})
        self.gear:runAction(repeatForever(rotateby(2, 360)))
    end

    if BattleLogic.inBattle then
        self.gear:runAction(repeatForever(sequence({scaleto(1, 3, 3), scaleto(1, 1, 1)})))
        self.bg = CCNode:create()
        self.baseBuild.bg:addChild(self.bg)
        self.state = WIND_STATE.FREE
        registerUpdate(self)
        registerEnterOrExit(self)
    end
end
function Wind:update(diff)
    if BattleLogic.paused or self.baseBuild.broken then
        return
    end
    
    --大风车可以攻击 空中单位
    if self.state == WIND_STATE.FREE then
        if self.attackTarget == nil or self.attackTarget.dead then
            self.attackTarget = nil
            local allSol = self.baseBuild.map.mapGridController.allSoldiers
            local minDis = 9999999
            local minTar = nil
            local bp = getPos(self.baseBuild.bg)
            for k, v in pairs(allSol) do
                if k.dead == false then
                    local sp = getPos(k.bg)
                    local dist = distance2(sp, bp)
                    if dist < minDis then
                        minDis = dist
                        minTar = k
                    end
                end 
            end
            if minTar ~= nil then
                if minDis < testRange*testRange then
                    self.attackTarget = minTar
                end
            end
        end
        if self.attackTarget ~= nil then
            self.state = WIND_STATE.DO_ATTACK
            self.attackTime = 0
        end
    elseif self.state == WIND_STATE.DO_ATTACK then
        self.state = WIND_STATE.IN_ATTACK
    end

    if self.state == WIND_STATE.IN_ATTACK then
        self.attackTime = self.attackTime+diff    
        if self.attackTime > self.baseBuild.data.attackSpeed then
            self.state = WIND_STATE.FREE
            local allSol = self.baseBuild.map.mapGridController.allSoldiers
            local bp = getPos(self.baseBuild.bg)
            local attDist = testRange*testRange 
            --范围攻击所有 小于30 的敌人
            for k, v in pairs(allSol) do
                if k.dead == false then
                    local kp = getPos(k.bg)
                    local dist = distance2(kp, bp)
                    if dist < attDist then
                        k:doHarm(self:getHarm())
                    end
                end 
            end
        end
    end
end

function Wind:getHarm()
    return testHurt*(self.baseBuild.level+1)
end
