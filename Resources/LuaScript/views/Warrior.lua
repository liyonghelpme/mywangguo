Warrior = class(SoldierFunc)
function Warrior:ctor(s)
    self.soldier = s
end
function Warrior:doAttack()
    local tex = self.soldier.changeDirNode:getTexture()
    local rect = self.soldier.changeDirNode:getTextureRect()
    local n = math.random(4)+2
    local sca = getSign(self.soldier.changeDirNode:getScaleX())

    for i=1, n do
        local temp = CCSprite:createWithTexture(tex, rect)
        local bf = ccBlendFunc()
        bf.src = GL_ONE
        bf.dst = GL_ONE
        temp:setBlendFunc(bf)
        local rx=math.random(10)-5+7*i
        local ry=math.random(10)-5
        setScaleX(setPos(setColor(setAnchor(temp, {0.5, 0}), {102, 0, 0, 100}), {rx, ry}), sca)
        self.soldier.bg:addChild(temp)
        temp:runAction(sequence({scaleto(0.2, sca*1.2, 1.2), fadeout(0.2), callfunc(nil, removeSelf, temp)}))
    end

    self.soldier.attackTarget:doHarm(self.soldier.data.attack)
end
