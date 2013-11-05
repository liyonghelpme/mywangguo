CRY_STATE = {
    FREE=0,
    DO_ATTACK=1,
    IN_ATTACK=2,
}
CrystalDef = class(FuncBuild)
function CrystalDef:ctor(b)
    self.baseBuild = b
end
function CrystalDef:initWorking()
    if self.par == nil then
        local par = CCParticleSystemQuad:create("bigCrystal2.plist")
        self.par = par
        self.par:setPositionType(1)
        setPos(self.par, {0, 40})
        self.baseBuild.bg:addChild(self.par)
        local sp = CCSprite:create("build144_fu.png")
        self.baseBuild.bg:addChild(sp)
        setPos(sp, {-2, 109-66})
        setColor(sp, {102, 0, 0})
        local bf = ccBlendFunc()
        bf.src = GL_ONE
        bf.dst = GL_ONE
        sp:setBlendFunc(bf)
        sp:runAction(repeatForever(sequence({fadeout(0.5), fadein(0.5)})))
    end

    if BattleLogic.inBattle then
        self.bg = CCNode:create()
        self.baseBuild.bg:addChild(self.bg)
        self.state = CRY_STATE.FREE
        registerUpdate(self)
        registerEnterOrExit(self)
    end
end
--如何测试攻击 另外一个账号 攻击自己
function CrystalDef:update(diff)
    if BattleLogic.paused or self.baseBuild.broken then
        return
    end
    if self.state == CRY_STATE.FREE then
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
                    --不能攻击鸟人
                    if dist < minDis and k.kind ~= 1130 then
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
            self.state = CRY_STATE.DO_ATTACK
            self.attackTime = 0
        end
    elseif self.state == CRY_STATE.DO_ATTACK then
        self.state = CRY_STATE.IN_ATTACK
        local sp = CCSprite:create("build144_fu.png")
        local bf = ccBlendFunc()
        bf.src = GL_ONE
        bf.dst = GL_ONE
        sp:setBlendFunc(bf)
        self.baseBuild.map.bg:addChild(sp, MAX_BUILD_ZORD)

        local bb = getPos(self.baseBuild.bg)
        bb[1] = bb[1]+0
        bb[2] = bb[2]+20
        local tb = getPos(self.attackTarget.bg)
        tb[2] = tb[2]+20
        setPos(sp, bb)
        local function doHarm()
            local arrange = {}
            local allSol = self.baseBuild.map.mapGridController.allSoldiers
            local bp = getPos(sp)
            local attDist = 50*50
            --范围攻击所有 小于30 的敌人
            for k, v in pairs(allSol) do
                if k.dead == false then
                    local kp = getPos(k.bg)
                    local dist = distance2(kp, bp)
                    if dist < attDist and k.kind ~= 1130 then
                        table.insert(arrange, k)
                        k:doHarm(self.baseBuild.data.attack)
                    end
                end 
            end
            removeSelf(sp)
        end
        sp:setScale(0.1)
        sp:runAction(sequence({fadein(0.2), jumpTo(1, tb[1], tb[2], 30, 1), fadeout(0.2), callfunc(nil, doHarm)}))
        sp:runAction(scaleto(0.5, 1, 1))
        
        local sz = sp:getContentSize()
        local function show()
            local temp = CCSprite:create("build144_fu.png")
            sp:addChild(temp)
            temp:setBlendFunc(bf)
            temp:setScale(0.1)
            temp:runAction(sequence({scaleto(0.5, 1, 1)}))
            setPos(temp, {sz.width/2, sz.height/2})
        end
        sp:runAction(repeatForever(sequence({delaytime(0.2), callfunc(nil, show)})))
    end

    if self.state == CRY_STATE.IN_ATTACK then
        self.attackTime = self.attackTime+diff    
        if self.attackTime > self.baseBuild.data.attackSpeed then
            self.state = CRY_STATE.FREE
        end
    end
end
