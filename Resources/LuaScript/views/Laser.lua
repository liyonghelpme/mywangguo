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
function Laser:removeLaser()
    local chd = self.lb:getChildren()
    local n = self.lb:getChildrenCount()
    for k=0, n-1, 1 do
        local c = tolua.cast(chd:objectAtIndex(k), "CCSprite")
        c:runAction(fadeout(0.3))
    end
    self.lb:runAction(sequence({delaytime(0.3), callfunc(nil, removeSelf, self.lb)}))
    self.lb = nil
end

function Laser:update(diff)
    if self.baseBuild.broken then
        if self.lb ~= nil then
            self:removeLaser()
        end
        return 
    end
    if BattleLogic.paused then
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
                if minDis < 220*220 then
                    self.attackTarget = minTar
                end
            end
        end
        if self.attackTarget ~= nil then
            self.state = GOD_STATE.DO_ATTACK
            self.attackTime = 0
            self.totalTime = 0
        end
    end
    if self.state == LASER_STATE.DO_ATTACK then
        local bb = getPos(self.baseBuild.bg)
        bb[1] = bb[1]
        bb[2] = bb[2]+130
        local tb = getPos(self.attackTarget.bg)
        tb[2] = tb[2]+20

        local dist = distance(bb, tb)
        local n = math.ceil(dist/50)
        local initX = bb[1]
        local initY = bb[2]
        local offX = 50

        local lb = CCSpriteBatchNode:create("fig7.png")
        self.baseBuild.map.bg:addChild(lb, MAX_BUILD_ZORD)
        setPos(lb, bb)
        self.lb = lb
        local bf = ccBlendFunc()
        bf.src = GL_ONE
        bf.dst = GL_ONE
        lb:setBlendFunc(bf)
        for k=0, n-1, 1 do
            local sp = CCSprite:createWithSpriteFrameName("arrow0")
            sp:setFlipX(true)
            setAnchor(setColor(setPos(sp, {k*offX, 0}), {240, 64, 0}), {0, 0.5})
            lb:addChild(sp)
        end
        self.lbLen = n*50+210
        self.state = LASER_STATE.IN_ATTACK
    end
    if self.state == LASER_STATE.IN_ATTACK then
        local bb = getPos(self.baseBuild.bg)
        bb[1] = bb[1]
        bb[2] = bb[2]+130
        local tb = getPos(self.attackTarget.bg)
        tb[2] = tb[2]+20

        local dist = distance(bb, tb)
        setScaleX(self.lb, dist/self.lbLen)
        
        local dx = tb[1]-bb[1]
        local dy = tb[2]-bb[2]
        local angel = math.atan2(dy, dx)*180/math.pi
        setRotation(self.lb, -angel)

        self.attackTime = self.attackTime+diff
        self.totalTime = self.totalTime+diff
        if self.attackTime > self.baseBuild.data.attackSpeed then
            self.attackTime = 0
            local attack = 3
            if self.totalTime >= 5 then
                attack = 128
            elseif self.totalTime >= 2 then
                attack = 12.8
            end
            self.attackTarget:doHarm(self:getHarm())
        end

        if self.attackTarget.dead then
            self.state = LASER_STATE.FREE
            self.attackTarget = nil
            self:removeLaser()
        end
    end
end
