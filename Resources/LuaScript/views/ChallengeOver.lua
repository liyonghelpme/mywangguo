ChallengeOver = class()
function ChallengeOver:ctor(s, p)
    self.scene = s
    self.param = p
    BattleLogic.endDialog = self
    BattleLogic.paused = true
    self:initView()
end
function ChallengeOver:initView()
    self.bg = CCNode:create()
    local vs = getVS()
    local but0 
    local temp
    local suc = self.param.suc
    temp = setPos(setAnchor(addSprite(self.bg, "dialogRoundOver.png"), {0.5, 1}), {vs.width/2, vs.height})
    self.back = temp
    local sz = self.back:getContentSize()
    if suc then
        temp = setPos(addSprite(self.back, "dialogVic.png"), {271, fixY(sz.height, 54)})
    else
        temp = setPos(addSprite(self.back, "dialogFail.png"), {271, fixY(sz.height, 54)})
    end
    --无论打弱打强 都获得 10的经验么？ 还是根据建筑物数量计算经验 农田 多少分 矿多少分 主城多少分
    local reward = {}
    if suc then
        reward = {silver=math.floor(BattleLogic.resource["silver"]/2), crystal=math.floor(BattleLogic.resource["crystal"]/2), exp=10}
    end
    self.reward = reward

    temp = setPos(addSprite(self.back, "silver.png"), {127, fixY(sz.height, 180)})
    temp = ui.newBMFontLabel({text=str(0), size=22, color={218, 212, 94}})
    setAnchor(setPos(temp, {177, fixY(sz.height, 180)}), {0, 0.5})
    self.back:addChild(temp)
    local st = temp
    st:setVisible(false)

    temp = setPos(addSprite(self.back, "crystal.png"), {127, fixY(sz.height, 245)})
    temp = ui.newBMFontLabel({text=str(0), size=22, color={218, 212, 94}})
    setAnchor(setPos(temp, {177, fixY(sz.height, 245)}), {0, 0.5})
    self.back:addChild(temp)
    local ct = temp
    ct:setVisible(false)

    temp = setPos(addSprite(self.back, "exp.png"), {127, fixY(sz.height, 295)})
    temp = ui.newBMFontLabel({text=str(0), size=22, color={218, 212, 94}})
    setAnchor(setPos(temp, {177, fixY(sz.height, 295)}), {0, 0.5})
    self.back:addChild(temp)
    local et = temp
    et:setVisible(false)

    setPos(self.bg, {0, sz.height})
    local num = 1
    local function quake()
        self.bg:runAction(sequence({moveby(0.1, 0, 10/1), moveby(0.1, 0, -10/1)}))
        num = num+1
    end
    local function calNum()
        st:setVisible(true)
        st:runAction(fadein(0.2))

        ct:setVisible(true)
        ct:runAction(fadein(0.2))

        et:setVisible(true)
        et:runAction(fadein(0.2))

        numAct(st, 0, reward.silver)
        numAct(ct, 0, reward.crystal)
        numAct(et, 0, reward.exp)
    end
    self.bg:runAction(sequence({moveby(0.2, 0, -sz.height), repeatN(sequence({callfunc(nil, quake), delaytime(0.2)}), 4), callfunc(nil, calNum)}))

    local but0 = ui.newButton({image="roleNameBut0.png", conSize={125, 41}, text=getStr("ok", nil), size=20, callback=self.onOk, delegate=self})
    setPos(but0.bg, {266, fixY(sz.height, 357)})
    self.back:addChild(but0.bg)
    but0:setAnchor(0.5, 0.5)

end
function ChallengeOver:onOk()
    --成功同步奖励 失败 也要同步死亡的士兵
    --退出战斗场景也要杀死这些士兵在经营页面
    sendReq("synBattleRes", dict({{"uid", global.user.uid}, {"reward", simple.encode(self.reward)}, {'killedSoldier', simple.encode(BattleLogic.getKilled())}}))
    global.user:doAdd(self.reward)
    --BattleLogic.clearBattle()
    BattleLogic.quitBattle = true
    global.director:popView()
    global.director:pushView(Cloud.new(), 1, 0)
    --global.director:popScene()
end
