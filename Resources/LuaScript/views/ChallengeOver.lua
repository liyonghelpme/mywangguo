ChallengeOver = class()
function ChallengeOver:ctor(s, p)
    self.scene = s
    self.param = p
    self:initView()
end
function ChallengeOver:initView()
    self.bg = CCNode:create()
    local vs = getVS()
    local but0 
    local temp
    local suc = param.suc
    temp = setPos(setAnchor(addSprite(self.bg, "dialogRoundOver.png"), {0.5, 1}), {vs.width/2, vs.height})
    self.back = temp
    local sz = self.back:getContentSize()
    if suc then
        temp = setPos(addSprite(self.back, "dialogVic.png"), {271, fixY(sz.height, 54)})
    else
        temp = setPos(addSprite(self.back, "dialogFail.png"), {271, fixY(sz.height, 54)})
    end

    temp = setPos(addSprite(self.back, "silver.png"), {127, fixY(sz.height, 180)})
    temp = ui.newBMFontLabel({text=str(0), size=22, color={218, 212, 94}})
    setAnchor(setPos(temp, {177, fixY(sz.height, 180)}), {0, 0.5})
    self.back:addChild(temp)

    temp = setPos(addSprite(self.back, "crystal.png"), {127, fixY(sz.height, 245)})

    temp = ui.newBMFontLabel({text=str(0), size=22, color={218, 212, 94}})
    setAnchor(setPos(temp, {177, fixY(sz.height, 245)}), {0, 0.5})
    self.back:addChild(temp)
    temp = setPos(addSprite(self.back, "crystal.png"), {127, fixY(sz.height, 295)})

    temp = ui.newBMFontLabel({text=str(0), size=22, color={218, 212, 94}})
    setAnchor(setPos(temp, {177, fixY(sz.height, 295)}), {0, 0.5})
    self.back:addChild(temp)
end
