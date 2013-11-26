require "Miao.FightFunc"
require "Miao.FightGun"
require "Miao.FightArrow"
require "Miao.FightInfantry"
require "Miao.FightCavalry"
FIGHT_SOL_STATE = {
    FREE=0,
    START_ATTACK=1,
    IN_ATTACK=2,
}

FightSoldier = class()
function FightSoldier:ctor(m, id, col, row)
    self.id = id
    self.map = m
    --所在列
    self.col = col
    self.row = row

    self.bg = CCNode:create()
    if self.id == 583 then
        self.funcSoldier = FightGun.new(self)
    elseif self.id == 23 then
        self.funcSoldier = FightArrow.new(self)
    elseif self.id == 3 then
        self.funcSoldier = FightInfantry.new(self)
    elseif self.id == 473 then
        self.funcSoldier = FightCavalry.new(self)
    else
        self.funcSoldier = FightFunc.new(self)
    end

    local sf = CCSpriteFrameCache:sharedSpriteFrameCache()
    sf:addSpriteFramesWithFile("soldiera"..id..".plist")
    self.attAni = createAnimation("soldiera"..id, "ss"..id.."a%d.png", 0, 7, 1, 1, true)
    sf:addSpriteFramesWithFile("soldierm"..id..".plist")
    self.moveAni = createAnimation("soldierm"..id, "ss"..id.."m%d.png", 0, 6, 1, self.funcSoldier:getMoveTime(), true)

    self.changeDirNode = CCSprite:createWithSpriteFrameName("ss"..id.."m0.png")
    self.bg:addChild(self.changeDirNode)
    setAnchor(setScale(self.changeDirNode, 0.5), {0.5, 0})


    local shadow = setScale(CCSprite:create("roleShadow.png"), 0.5)
    self.bg:addChild(shadow, -1)
    self.shadow = shadow
    self.state = FIGHT_SOL_STATE.FREE
    registerEnterOrExit(self)
end
function FightSoldier:enterScene()
    registerUpdate(self)
end
function FightSoldier:update(diff)
    if self.state == FIGHT_SOL_STATE.START_ATTACK then
    end
end
function FightSoldier:setDir(d)
    if d > 0 then
        setScaleX(self.changeDirNode, -0.5)
    elseif d < 0 then
        setScaleX(self.changeDirNode, 0.5)
    end
end
function FightSoldier:setZord()
    local p = getPos(self.bg)
    self.bg:setZOrder(MAX_BUILD_ZORD-p[2])
end
function FightSoldier:showPose()
    self.moveAct = repeatForever(CCAnimate:create(self.moveAni))
    self.changeDirNode:runAction(self.moveAct)
    self.idleAct = sequence({jumpBy(1, 10, 0, 20, 1), jumpBy(1, -10, -0, 20, 1)})
    self.changeDirNode:runAction(self.idleAct)

    self.shadow:runAction(
        sequence({
            spawn({moveby(1, 5, 0), sequence({scaleto(0.5, 0.35, 0.35), scaleto(0.5, 0.5, 0.5)})}), 
            spawn({moveby(1, -5, 0), sequence({scaleto(0.5, 0.35, 0.35), scaleto(0.5, 0.5, 0.5)})})
        })
    )
end
--射击攻击
function FightSoldier:doAttack()
    if not self.funcSoldier:ignoreAtt() then
        if self.moveAct ~= nil then
            self.changeDirNode:stopAction(self.moveAct)
            self.moveAct = nil
        end
        self.attAct = CCAnimate:create(self.attAni)
        self.changeDirNode:runAction(self.attAct)
    end
    self.funcSoldier:doAttack()
end
--调整动画
function FightSoldier:doBack()
    local sca = self.changeDirNode:getScaleX()
    setScaleX(self.changeDirNode, -sca)
    
    self.oldPos = getPos(self.bg)
    local tar = {}
    if sca < 0 then
        tar = {self.oldPos[1]-300, self.oldPos[2]}
    else
        tar = {self.oldPos[1]+300, self.oldPos[2]}
    end

    print("doBack", simple.encode(tar))
    self.moveAct = repeatForever(CCAnimate:create(self.moveAni))
    self.changeDirNode:runAction(self.moveAct)
    self.bg:runAction(sequence({moveto(5, tar[1], tar[2])}))
end
