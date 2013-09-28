COL_MAX=2
ROW_MAX=3
MAX_DELAY=30
TS_Y = 947
TICK = 0.04
COL_X = {295,154}
ROW_Y = {362,292,209}


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
        if targets[(targetCol-1)*ROW_MAX+j] then
            table.insert(ret, targets[(targetCol-1)*ROW_MAX+j])
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

function createAnimation(name, format, a,b,c,t)
    local animation = CCAnimationCache:sharedAnimationCache():animationByName(name)
    if not animation then
        animation = CCAnimation:create()
        for i=a, b, c do
            animation:addSpriteFrameWithFileName(string.format(format, i))
        end
        animation:setDelayPerUnit(t*c/(b-a+c))
        animation:setRestoreOriginalFrame(true)
        CCAnimationCache:sharedAnimationCache():addAnimation(animation, name)
    end
    return animation
end



BattleRoleView = class()

function BattleRoleView:ctor(roleViewId)
    self.roleId = roleViewId
    self.ax = 0.597
    self.ay = 0.258
    self.attackDelay = 0.6
    self.damageDelay = 0.3
    self.defenseDelay = 0.3
    self.shadowX = 1
    self.shadowY = 1
end

function BattleRoleView:createView()
    local view = CCSprite:create("kulou_dj_00.png")
        
    local animation = CCAnimation:create()
    self.djAnimation = createAnimation("role" .. self.roleId .. "_dj", "kulou_dj_%02d.png", 0, 27, 3, 0.5)
    self.gjAnimation = createAnimation("role" .. self.roleId .. "_gj", "kulou_gj_%02d.png", 0, 19, 1, 0.33)
    self.sjAnimation = createAnimation("role" .. self.roleId .. "_sj", "kulou_sj_%02d.png", 0, 12, 2, 0.25)
    self.zouAnimation = createAnimation("role" .. self.roleId .. "_zou", "kulou_zou_%02d.png", 0, 27, 3, 0.5)

    self.runDjAnimation = function(node)
        self:runAction(node, "dj", false)
	    --node:runAction(CCRepeatForever:create(CCAnimate:create(self.djAnimation)))
	end
	return view
end

function BattleRoleView:runAction(view, actionName, stopOthers)
    if view then
        if stopOthers then
            view:stopAllActions()
        end
        local animation = CCAnimationCache:sharedAnimationCache():animationByName("role" .. self.roleId .. "_" .. actionName)
        view:runAction(CCRepeatForever:create(CCAnimate:create(animation)))
    end
end

function BattleRoleView:runActionOnceAndRestore(view, actionName)
    if view then
        view:stopAllActions()
        local animation = CCAnimationCache:sharedAnimationCache():animationByName("role" .. self.roleId .. "_" .. actionName)
        view:runAction(CCSequence:createWithTwoActions(CCAnimate:create(animation), CCCallFuncN:create(self.runDjAnimation)))
    end
end

BattleRole = class()

--当role被初始化时，仅初始化其模型数据
function BattleRole:ctor(atk, def, adf, hp, delay, isRemote, roleViewId, normal, skill)
    self.atk = atk
    self.def = def
    self.adf = adf
    self.hpMax = hp
    --self.delay = delay
    self.delay = 1
    self.isRemote = (isRemote==true) or (isRemote==1)
    self.viewModel = BattleRoleView.new(roleViewId)
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

function BattleRole:executeDamage(damageType, value, damageDelay)
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
    else
        ret = value
    end
    ret = math.floor(ret * BattleRand.randomBetween(85, 115)/100)
    if ret<0 and self:checkBuff(BuffType.Unmatched) then
        ret = 0
    end
    self:changeHp(ret)
    local function damageOver()
        local bloodText = CCLabelTTF:create("" .. ret, "", 25)
        if ret<0 then
            self.view:stopAllActions()
            self.viewModel:runActionOnceAndRestore(self.view, "sj")
            bloodText:setColor(ccc3(255,0,0))
        else
            bloodText:setColor(ccc3(0,255,0))
        end
        self.blood:addChild(bloodText)
        bloodText:setAnchorPoint(CCPointMake(0.5,0.5))
        bloodText:setPosition(self.blood:getContentSize().width/2, -50)
        bloodText:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(1), CCCallFuncN:create(removeSelf)))
        bloodText:runAction(CCMoveBy:create(1,CCPointMake(0, 100)))
        self.blood:setTextureRect(CCRectMake(0,0,math.floor(self.bloodSize.width*self.hp/self.hpMax), self.bloodSize.height))
        if self.dead then
            self:runDelayDead(self.viewModel.defenseDelay)
        end
    end
    self.blood:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(damageDelay), CCCallFunc:create(damageOver)))
    return ret
end

function BattleRole:runDelayDead(delay)
    local function destroySelf()
        local temp = CCSprite:create("roleDeadTomb.png")
        temp:setPosition(self.view:getPosition())
        if self.isLeft then
            temp:setAnchorPoint(CCPointMake(0.432, 0.158))
        else
            temp:setFlipX(true)
            temp:setAnchorPoint(CCPointMake(0.568, 0.158))
        end
        self.view:getParent():addChild(temp, self.row*COL_MAX-self.col)
        self:destroy()
        self.view = temp
    end
    self.view:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(delay), CCCallFunc:create(destroySelf)))
end

function BattleRole:changeHp(changeValue)
    self.hp = self.hp+changeValue
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
    --self.process:setTextureRect(CCRectMake(0,0,math.floor(self.processSize.width*(self.delay-self.leftDelay)/self.delay), self.processSize.height))
    if self.leftDelay<=0 then
        return true
    else
        return false
    end
end

function BattleRole:executeTurn()
    local ret = 0
    if self:isTurnable() then
        ret = self.viewModel.attackDelay
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
            targets[i]:executeDamage(attackAction.damageType, atk, self.viewModel.damageDelay)
            if attackAction.buffPercent>0 then
                if BattleRand.random(100)<=attackAction.buffPercent then
                    targets[i]:setBuff(attackAction.buffType, attackAction.buffTurn, attackAction.buffValue)
                end
            end
        end
        self.viewModel:runActionOnceAndRestore(self.view, "gj")
    end
    local buffDelay = 0
    if self:checkBuff(BuffType.Poison) then
        self:changeHp(math.floor(self.hp/10))
        buffDelay = 0.2
    end
    if self:checkBuff(BuffType.Fire) then
        self:changeHp(math.floor(self.hp/5))
        buffDelay = 0.2
    end
    if self.dead then
        self:runDelayDead(0.2)
    end
    self:decBuff()
    self.leftDelay = self.delay
    return ret+buffDelay
end

function BattleRole:initView(bg, isLeft, noBattle)
    self.isLeft = isLeft
    if not self.view then
        self.view = self.viewModel:createView()
        bg:addChild(self.view, self.row*COL_MAX-self.col)
    end
    local y = ROW_Y[self.row]
    local x = COL_X[self.col]
    x = x+(y-ROW_Y[3])*(512-x)/(TS_Y-ROW_Y[3])
    self.view:removeAllChildrenWithCleanup(true)
    if self.isLeft then
        self.view:setFlipX(true)
        self.view:setAnchorPoint(CCPointMake(1-self.viewModel.ax,self.viewModel.ay))
        self.view:setPosition(x, y)
    else
        self.view:setAnchorPoint(CCPointMake(self.viewModel.ax, self.viewModel.ay))
        self.view:setPosition(1024-x,y)
    end
    local otherNode = self.view:getChildByTag(1)
    if otherNode then
        otherNode:removeAllChildrenWithCleanup(true)
    else
        otherNode = CCNode:create()
        self.view:addChild(otherNode, 1, 1)
    end
    local anchor = self.view:getAnchorPoint()
    local size = self.view:getContentSize()
    local shadow = CCSprite:create("roleShadow.png")
    shadow:setScaleX(self.viewModel.shadowX)
    shadow:setScaleY(self.viewModel.shadowY)
    shadow:setAnchorPoint(CCPointMake(0.5, 0.5))
    shadow:setPosition(anchor.x*size.width, anchor.y*size.height)
    self.view:addChild(shadow, -1)
    self.viewModel.runDjAnimation(self.view)
    if not noBattle then
        local back = CCSprite:create("roleBloodBack.png")
        back:setAnchorPoint(CCPointMake(0.5, 0.5))
        back:setPosition(size.width*anchor.x, 170)
        local filler = CCSprite:create("roleBloodFiller.png")
        back:addChild(filler)
        filler:setAnchorPoint(CCPointMake(0,0))
        filler:setPosition(1,1)
        local size = filler:getContentSize()
        self.bloodSize = {width=size.width, height=size.height}
        self.blood = filler
        otherNode:addChild(back)
        self:updateDelay(0)
    end
end

function BattleRole:runZou()
    if self.view then
        self.viewModel:runAction(self.view, "zou", true)
        local y = ROW_Y[self.row]
        local x = 1024-COL_X[2]+(y-ROW_Y[3])*(512-COL_X[2])/(TS_Y-ROW_Y[3]) - COL_X[1]
        if not self.isLeft then x=-x end
        self.view:runAction(CCMoveBy:create(5,CCPointMake(x,0))) 
    end
end

function BattleRole:destroy()
    self.view:removeFromParentAndCleanup(true)
    self.view = nil
end

function BattleRole:clearBattle()
    local cd = self.view:getChildByTag(1)
    if cd then
        cd:removeFromParentAndCleanup(true)
    end
    self.ours = nil
    self.enemys = nil
    self.propertyBuffs = nil
    self.buffs = nil
    self.hp = self.hpMax
    self.skillPoint = 0
end
