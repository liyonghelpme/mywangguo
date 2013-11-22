LASER_STATE = {
    FREE=0, 
    DO_ATTACK=1,
    IN_ATTACK=2,
}
Laser = class(FuncBuild)
function Laser:initWorking()
    if BattleLogic.inBattle then
        self.bg = CCNode:create()
        self.baseBuild.bg:addChild(self.bg)
        self.state = LASER_STATE.FREE
        registerUpdate(self)
        registerEnterOrExit(self)
    end
end
function Laser:update(diff)
    if BattleLogic.paused or self.baseBuild.broken then
        return
    end

    if self.state == LASER_STATE.FREE then
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
                if minDis < self.baseBuild.data.attackRange*self.baseBuild.data.attackRange then
                    self.attackTarget = minTar
                end
            end
        end
        if self.attackTarget ~= nil then
            self.state = GOD_STATE.DO_ATTACK
            self.attackTime = 0
        end
    end
    if self.state == LASER_STATE.DO_ATTACK then
        local bb = getPos(self.baseBuild.bg)
        bb[1] = bb[1]
        bb[2] = bb[2]+20
        local tb = getPos(self.attackTarget.bg)
        tb[2] = tb[2]+20

        local dist = distance(bb, tb)
        local n = math.ceil(dist/50)
        local initX = bb[1]
        local initY = bb[2]
        for k=1, n, 1 do
            local sp = CCSprite:create()
        end
    end
    if self.state == LASER_STATE.IN_ATTACK then
    end
end
