COL_MAX=2
ROW_MAX=3
MAX_DELAY=1000
TS_Y = 991
TICK = 0.04
COL_X = {277,120}
ROW_Y = {336,256,176}


BuffType = {Vertigo=1, NoSkill=2, Poison=3, Fire=4, Unmatched=5, Chaos=6}
PropertyBuffType = {Attack=1, Defense=2}

DamageType = {Physic=1, Magic=2, Cure=3}
DamageArea = {Col=1, Row=2, Map=3, Single=4}
DamageSelector = {FirstCol=1, LastCol=2, Row=3, MaxLoseHp=4, Random=5}

require "Battle.BattleRand"

function removeSelf(node)
    node:removeFromParentAndCleanup(true)
end

--selector接受的参数是BattleRole类型的对象和数组；其中数组是COL_MAX*ROW_MAX形式的。
MapSelector = {}
function MapSelector.select(selfRole, targets)
    local ret={}
    for i=1, COL_MAX*ROW_MAX do
        if targets[i] then
            table.insert(ret, targets[i])
        end
    end
    return ret
end

SingleSelectors = {}

SingleSelectors[DamageSelector.FirstCol] = function(selfRole, targets)
    local selfRow = selfRole.row
    for i=1, COL_MAX do
        if targets[(i-1)*ROW_MAX+selfRow] then
            return targets[(i-1)*ROW_MAX+selfRow]
        end
        for j=1, ROW_MAX do
            if targets[(i-1)*ROW_MAX+j] then
                return targets[(i-1)*ROW_MAX+j]
            end
        end
    end
end

SingleSelectors[DamageSelector.LastCol] = function(selfRole, targets)
    local selfRow = selfRole.row
    for i=COL_MAX, 1, -1 do
        if targets[(i-1)*ROW_MAX+selfRow] then
            return targets[(i-1)*ROW_MAX+selfRow]
        end
        for j=1, ROW_MAX do
            if targets[(i-1)*ROW_MAX+j] then
                return targets[(i-1)*ROW_MAX+j]
            end
        end
    end
end

SingleSelectors[DamageSelector.Row] = function(selfRole, targets)
    local selfRow = selfRole.row
    for i=1, COL_MAX do
        if targets[(i-1)*ROW_MAX+selfRow] then
            return targets[(i-1)*ROW_MAX+selfRow]
        end
    end
    for j=1, ROW_MAX do
        for i=1, COL_MAX do
            if targets[(i-1)*ROW_MAX+j] then
                return targets[(i-1)*ROW_MAX+j]
            end
        end
    end
end
SingleSelectors[DamageSelector.MaxLoseHp] = function(selfRole, targets)
    local target = nil
    local maxLose = -1
    for i=1, COL_MAX*ROW_MAX do
        if targets[i] and targets[i].hpMax - targets[i].hp>maxLose then
            maxLose = targets[i].hpMax-targets[i].hp
            target = targets[i]
        end
    end
    return target
end

SingleSelectors[DamageSelector.Random] = function(selfRole, targets)
    local ret = {}
    for i=1, COL_MAX*ROW_MAX do
        if targets[i] then
            table.insert(ret, targets[i])
        end
    end
    return ret[BattleRand.random(#ret)]
end

AreaSelectors={}
AreaSelectors[DamageArea.Col] = function(targetRole, targets)
    local ret = {}
    local targetCol = targetRole.col
    for j=1, ROW_MAX do
        if targets[(targetCol-1)*ROW_MAX+i] then
            table.insert(ret, targets[(targetCol-1)*ROW_MAX+i])
        end
    end
    return ret
end

AreaSelectors[DamageArea.Row] = function(targetRole, targets)
    local ret = {}
    local targetRow = targetRole.row
    for i=1, COL_MAX do
        if targets[(i-1)*ROW_MAX+targetRow] then
            table.insert(ret, targets[(i-1)*ROW_MAX+targetRow])
        end
    end
    return ret
end
AreaSelectors[DamageArea.Single] = function(targetRole, targets)
    local ret = {targetRole}
    return ret
end

--注：在实现上，普通攻击也是一种技能
SkillModel=class()

--[[
    技能伤害系数，100表示100%威力；
    技能伤害类型，有物理、魔法和治疗3种
    技能伤害范围，有竖线、横线、全部、单体4种
    技能选择方案，有最前列、最后列、同一行、最多损失HP、随机 5种
    
    Buff附加概率，100表示100%附加
    Buff持续回合，表示被附加buff的对象需要经过几回合buff才会消除
    Buff类型，目前为眩晕（无法行动）、封技（无法发动技能）、中毒、燃烧、无敌、混乱 6种标准BUFF，以及攻击、防御两种属性Buff；通过buffValue是否为0来区分。
        眩晕表示该角色下一回合无法行动；（该buff最多只能持续1回合）
        封技表示该角色无法发动技能；
        中毒表示该角色每回合将损失当前生命的10%；（向下取整）
        燃烧表示该角色每回合将损失当前生命的20%；（向下取整，该buff最多只能持续2回合）
        无敌表示该角色本回合不会受到任何伤害；（该buff最多只能持续1回合）
        混乱表示该角色本回合将敌我倒置，即进攻自己一方；（该buff最多只能持续1回合）
        属性buff表示该角色的属性百分比将改变；属性buff不可叠加，同类型属性buff将直接覆盖（而不是叠加）
--]]
function SkillModel:ctor(damageValue, damageType, damageArea, damageSelector, buffPercent, buffTurn, buffType, buffValue)
    self.damageValue = damageValue
    self.damageType = damageType
    self.damageArea = damageArea
    self.damageSelector = damageSelector
    self.buffPercent = buffPercent
    self.buffTurn = buffTurn
    self.buffType = buffType
    if buffValue~=0 then
        self.isPropertyBuff = true
    end
    self.buffValue = buffValue
    self:initSelector()
end

--用于初始化selector
function SkillModel:initSelector()
    if self.damageArea==DamageArea.Map then
        self.selector = MapSelector
    else
        self.selector = {}
        local sselect = SingleSelectors[self.damageSelector]
        local aselect = AreaSelectors[self.damageArea]
        function self.selector.select(selfRole, targets)
            local role = sselect(selfRole, targets)
            return aselect(role, targets)
        end
    end
end



BattleRole = class()

--当role被初始化时，仅初始化其模型数据
function BattleRole:ctor(atk, def, adf, hp, delay, isRemote, normal, skill)
    self.atk = atk
    self.def = def
    self.adf = adf
    self.hpMax = hp
    self.delay = delay
    self.isRemote = isRemote
    self.normal = normal
    self.skill = skill
end

--初始化role的战斗数据；但仍不初始化view
function BattleRole:initBattle(row, col, ours, enemys)
    self.row = row
    self.col = col
    self.ours = ours
    self.enemys = enemys
    self.propertyBuffs = {}
    self.buffs = {}
    self.hp = self.hpMax
    self.skillPoint = 0
    self.leftDelay = self.delay
end

function BattleRole:getAttackValue()
    local atkPercent = 100
    if self.propertyBuffs[PropertyBuffType.Attack] then
        atkPercent = atkPercent + self.propertyBuffs[PropertyBuffType.Attack][1]
    end
    return self.atk * atkPercent/100
end

function BattleRole:executeDamage(damageType, value)
    local ret = 0
    local defPercent = 100
    if self.propertyBuffs[PropertyBuffType.Defense] then
        defPercent = defPercent + self.propertyBuffs[PropertyBuffType.Defense][1]
    end
    if damageType==DamageType.Physic then
        ret = value - self.def*defPercent/100
        if ret<0 then ret=0 end
        ret = -ret
    elseif damageType==DamageType.Magic then
        ret = value - self.adf*defPercent/100
        if ret<0 then ret=0 end
        ret = -ret
    end
    ret = math.floor(ret * BattleRand.randomBetween(85, 115)/100)
    if ret<0 and self:checkBuff(BuffType.Unmatched) then
        ret = 0
    end
    self:changeHp(ret)
    return ret
end

function BattleRole:changeHp(changeValue)
    self.hp = self.hp+changeValue
    if changeValue<0 then
        self.view:stopAllActions()
        local array = CCArray:create()
        array:addObject(CCDelayTime:create(0.5))
        array:addObject(CCAnimate:create(self.sjAnimation))
        array:addObject(CCCallFuncN:create(self.runDjAnimation))
        self.view:runAction(CCSequence:create(array))
    end
    if changeValue~=0 then
        local function valueChanged()
            self.blood:setTextureRect(CCRectMake(0,0,math.floor(self.bloodSize.width*self.hp/self.hpMax), self.bloodSize.height))
        end
        self.view:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(0.5),CCCallFunc:create(valueChanged)))
    end
    if self.hp > self.hpMax then
        self.hp = self.hpMax
    elseif self.hp <= 0 then
        self.hp = 0
        self.ours[(self.col-1)*ROW_MAX+self.row] = nil
        self:setDead()
    end
end

function BattleRole:setDead()
    self.dead = true
    local function destroySelf()
        self:destroy()
    end
    self.view:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(1), CCCallFunc:create(destroySelf)))
end

function BattleRole:checkBuff(buffType)
    return self.buffs[buffType]
end

function BattleRole:setBuff(buffType, buffTurn, buffValue)
    if buffValue~=0 then
        self.propertyBuffs[buffType] = {buffValue, buffTurn}
    else
        self.buffs[buffType] = buffTurn
    end
end

function BattleRole:decBuff()
    local todel = {}
    for k, v in pairs(self.buffs) do
        if v==1 then
            table.insert(todel, k)
        else
            self.buffs[k] = v-1
        end
    end
    for i=1, #todel do
        self.buffs[todel[i]] = nil
    end
    for k, v in pairs(self.propertyBuffs) do
        if v[2]==1 then
            table.insert(todel, k)
        else
            self.propertyBuffs[k] = {v[1],v[2]-1}
        end
    end
    for i=1, #todel do
        self.propertyBuffs[todel[i]] = nil
    end
end

--[[
    检测该角色是否可以行动
    当角色状态为眩晕时无法行动
    当角色为近战且前方有己方部队时无法行动
--]]
function BattleRole:isTurnable()
    if self:checkBuff(BuffType.Vertigo) then
        return false
    elseif not self.isRemote and self.col>1 then
        for i=1, self.col-1 do
            for j=1, ROW_MAX do
                if self.ours[(i-1)*ROW_MAX+j] then
                    return false
                end
            end
        end
    end
    return true
end

function BattleRole:updateDelay(delay)
    self.leftDelay = self.leftDelay-delay
    self.process:setTextureRect(CCRectMake(0,0,math.floor(self.processSize.width*(self.delay-self.leftDelay)/self.delay), self.processSize.height))
    if self.leftDelay<=0 then
        return true
    else
        return false
    end
end

function BattleRole:executeTurn()
    local ret = 0
    if self:isTurnable() then
        local attackAction = self.normal
        if self.skillPoint>=2 and not self:checkBuff(BuffType.NoSkill) then
            self.skillPoint = 0
            attackAction = self.skill
        else
            self.skillPoint = self.skillPoint+1
        end
        local targetsIsEnemy = true
        if attackAction.damageType==DamageType.Cure then
            targetsIsEnemy = false
        end
        if self:checkBuff(BuffType.Chaos) then
            targetsIsEnemy = not targetsIsEnemy
        end
        local targets = self.enemys
        if not targetsIsEnemy then targets=self.ours end
        targets = attackAction.selector.select(self, targets)
        if attackAction.buffPercent<0 then
            if BattleRand.random(100)<=-attackAction.buffPercent then
                --在自己回合内生效的buff自动多增加一回合，因为会在回合之后减掉
                self:setBuff(attackAction.buffType, attackAction.buffTurn+1, attackAction.buffValue)
            end
        end
        local atk = self:getAttackValue()*attackAction.damageValue/100
        for i=1, #targets do
            targets[i]:executeDamage(attackAction.damageType, atk)
            if attackAction.buffPercent>0 then
                if BattleRand.random(100)<=attackAction.buffPercent then
                    targets[i]:setBuff(attackAction.buffType, attackAction.buffTurn, attackAction.buffValue)
                end
            end
        end
        self.view:stopAllActions()
        self.view:runAction(CCSequence:createWithTwoActions(CCAnimate:create(self.gjAnimation), CCCallFuncN:create(self.runDjAnimation)))
        ret = 1.2
    end
    if self:checkBuff(BuffType.Poison) then
        self:changeHp(math.floor(self.hp/10))
    end
    if self:checkBuff(BuffType.Fire) then
        self:changeHp(math.floor(self.hp/5))
    end
    self:decBuff()
    self.leftDelay = self.delay
    return ret
end

function BattleRole:initView(bg, isLeft)
    self.isLeft = isLeft
    if not self.view then
        self.view = CCSprite:create("kulou_dj_00.png")
        bg:addChild(self.view)
        
        local animation = CCAnimation:create()
        for i = 0, 27, 3 do
    	    animation:addSpriteFrameWithFileName(string.format("kulou_dj_%02d.png", i))
    	end
	    animation:setDelayPerUnit(0.1)
	    animation:setRestoreOriginalFrame(true)
	    animation:retain()
	    self.djAnimation = animation
	    
        animation = CCAnimation:create()
        for i = 0, 19 do
    	    animation:addSpriteFrameWithFileName(string.format("kulou_gj_%02d.png", i))
    	end
	    animation:setDelayPerUnit(0.033)
	    animation:setRestoreOriginalFrame(true)
	    animation:retain()
	    self.gjAnimation = animation
	    
        animation = CCAnimation:create()
        for i = 0, 12, 2 do
    	    animation:addSpriteFrameWithFileName(string.format("kulou_sj_%02d.png", i))
    	end
	    animation:setDelayPerUnit(0.066)
	    animation:setRestoreOriginalFrame(true)
	    animation:retain()
	    self.sjAnimation = animation
	    
        animation = CCAnimation:create()
        for i = 0, 27, 3 do
    	    animation:addSpriteFrameWithFileName(string.format("kulou_zou_%02d.png", i))
    	end
	    animation:setDelayPerUnit(0.1)
	    animation:setRestoreOriginalFrame(true)
	    animation:retain()
	    self.zouAnimation = animation
	    
	    self.runDjAnimation = function(node)
	        node:runAction(CCRepeatForever:create(CCAnimate:create(self.djAnimation)))
	    end
    end
    local y = ROW_Y[self.row]
    local x = COL_X[self.col]
    x = x+(y-ROW_Y[3])*(512-x)/(TS_Y-ROW_Y[3])
    self.view:removeAllChildrenWithCleanup(true)
    if self.isLeft then
        self.view:setFlipX(true)
        self.view:setAnchorPoint(CCPointMake(0.403, 0.258))
        self.view:setPosition(x, y)
    else
        self.view:setAnchorPoint(CCPointMake(0.597, 0.258))
        self.view:setPosition(1024-x,y)
    end
    self.runDjAnimation(self.view)
    local back = CCSprite:create("loadingProcessBack.png")
    back:setAnchorPoint(CCPointMake(0.5, 0.5))
    local size = self.view:getContentSize()
    back:setPosition(size.width*self.view:getAnchorPoint().x, 178)
    back:setScale(0.25)
    local filler = CCSprite:create("loadingProcessFiller.png")
    back:addChild(filler)
    filler:setAnchorPoint(CCPointMake(0,0))
    filler:setPosition(2,2)
    local size = filler:getContentSize()
    self.processSize = {width=size.width, height=size.height}
    self.process = filler
    self.view:addChild(back)
    back = CCSprite:create("loadingProcessBack.png")
    back:setAnchorPoint(CCPointMake(0.5, 0.5))
    local size = self.view:getContentSize()
    back:setPosition(size.width*self.view:getAnchorPoint().x, 170)
    back:setScaleX(0.25)
    back:setScaleY(0.4)
    local filler = CCSprite:create("loadingProcessFiller.png")
    filler:setColor(ccc3(255,127,0))
    back:addChild(filler)
    filler:setAnchorPoint(CCPointMake(0,0))
    filler:setPosition(2,2)
    local size = filler:getContentSize()
    self.bloodSize = {width=size.width, height=size.height}
    self.blood = filler
    self.view:addChild(back)
    self:updateDelay(0)
end

function BattleRole:runZou()
    if self.view then
        self.view:stopAllActions()
        self.view:removeAllChildrenWithCleanup(true)
        self.view:runAction(CCRepeatForever:create(CCAnimate:create(self.zouAnimation))) 
        
        local y = ROW_Y[self.row]
        local x = 1024-COL_X[2]+(y-ROW_Y[3])*(512-COL_X[2])/(TS_Y-ROW_Y[3]) - COL_X[1]
        if not self.isLeft then x=-x end
        self.view:runAction(CCMoveBy:create(10,CCPointMake(x,0))) 
    end
end

function BattleRole:destroy()
    self.view:removeFromParentAndCleanup(true)
    self.view = nil
    self.runDjAnimation = nil
    self.djAnimation:release()
    self.djAnimation = nil
    self.gjAnimation:release()
    self.gjAnimation = nil
    self.sjAnimation:release()
    self.sjAnimation = nil
    self.zouAnimation:release()
    self.zouAnimation = nil
end
