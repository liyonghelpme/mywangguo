GodBall = class()
function GodBall:ctor(src, tar, start, over)
    --self.bg = CCSprite:create("god0.png")
    self.bg = CCNode:create()
    setPos(self.bg, start)
    local function doHarm()
        tar:doHarm(30)
    end
    local par = CCParticleSystemQuad:create("god1.plist")
    par:setPositionType(1)
    self.bg:addChild(par)
    self.bg:runAction(sequence({moveto(0.7, over[1], over[2]), callfunc(nil, doHarm), callfunc(nil, removeSelf, self.bg)}))
    --self.bg:runAction(sequence({fadein(0.1), delaytime(0.5), fadeout(0.1)}))
    --[[
    local function genBall()
        local temp = CCSprite:create("god0.png")
        local bf = ccBlendFunc()
        bf.src = GL_ONE
        bf.dst = GL_ONE
        temp:setBlendFunc(bf)
        self.bg:addChild(temp)
        setPos(setScale(temp, 0.1), {28, 21})
        
        temp:runAction(sequence({spawn({fadein(0.5), scaleto(0.5, 1.0, 1.0)}), delaytime(0.2), fadeout(0.5)}))
    end
    self.bg:runAction(repeatForever(sequence({callfunc(nil, genBall), delaytime(1)})))
    --]]
end

GodBuild = class(FuncBuild)
GOD_STATE = {
    FREE = 0,
    DO_ATTACK = 1,
    IN_ATTACK = 2,
}
function GodBuild:ctor(b)
    self.baseBuild = b
    self.state = GOD_STATE.FREE
end
function GodBuild:initWorking(data)
    if BattleLogic.inBattle == true then
        self.bg = CCNode:create()
        self.baseBuild.bg:addChild(self.bg)
        registerUpdate(self)
        registerEnterOrExit(self)
    end
end
function GodBuild:update(diff)
    if BattleLogic.paused or self.baseBuild.broken then
        return
    end
    --findTarget
    if self.state == GOD_STATE.FREE then
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
                if minDis < 500*500 then
                    self.attackTarget = minTar
                end
            end
        end
        if self.attackTarget ~= nil then
            self.state = GOD_STATE.DO_ATTACK
            self.attackTime = 0
        end
    end
    if self.state == GOD_STATE.DO_ATTACK then
        self.state = GOD_STATE.IN_ATTACK
        local bb = getPos(self.baseBuild.bg)
        bb[1] = bb[1]+37
        bb[2] = bb[2]+161
        local tb = getPos(self.attackTarget.bg)
        tb[2] = tb[2]+20
        local b = GodBall.new(self.baseBuild, self.attackTarget, bb, tb)
        self.baseBuild.map.bg:addChild(b.bg, MAX_BUILD_ZORD)
    end
    --doAttack
    if self.state == GOD_STATE.IN_ATTACK then
        self.attackTime = self.attackTime+diff
        if self.attackTime > 1.5 then
            self.state = GOD_STATE.FREE
        end
    end
end

