BattleMenu = class()
function BattleMenu:ctor(s)
    self.INIT_X = 50
    self.INIT_Y = fixY(global.director.designSize[2], 432)
    self.OFFX = 80

    print("initBattleMenu ##############")
    self.scene = s
    self.bg = CCNode:create()
    --100 倍率图片产生奇怪的效果
    local cancelBut = ui.newButton({image="mapMenuCancel.png", callback=self.onCancel, delegate=self})
    setPos(cancelBut.bg, {fixX(654), fixY(nil, 65)})
    self.bg:addChild(cancelBut.bg)
    
    if BattleLogic.challengeWho == nil then
        local randomBut = ui.newButton({image="random.png", callback=self.onRandom, delegate=self})
        setPos(randomBut.bg, {fixX(731), fixY(nil, 65)})
        self.bg:addChild(randomBut.bg)
        self.randomBut = randomBut
    end

    if DEBUG then
        local randomBut = ui.newButton({image="random.png", callback=self.save, delegate=self})
        setPos(randomBut.bg, {fixX(731), fixY(nil, 65)})
        self.bg:addChild(randomBut.bg)
        self.randomBut = randomBut
    end


    self.cl = setPos(addNode(self.bg), {self.INIT_X, self.INIT_Y})
    self.flowNode = addNode(self.cl)
    self.data = {}
    self:updateTab()
    self:choose(1)

    registerEnterOrExit(self)
end
--写到level.txt 文件里面
function BattleMenu:save()
    local bData = simple.encode(BattleLogic.buildings)
    local wp = CCFileUtils:sharedFileUtils():getWritablePath()
    wp = wp.."level.txt"
    writeFile(wp, bData, #bData)
end
function BattleMenu:enterScene()
    Event:registerEvent(EVENT_TYPE.ROB_RESOURCE, self)
end
function BattleMenu:receiveMsg(name, msg)
    if name == EVENT_TYPE.ROB_RESOURCE then
        local ures = {silver=BattleLogic.silver, crystal=BattleLogic.crystal, exp=BattleLogic.exp}
        local oldSilver = tonumber(self.silverText:getString())
        local oldExp = tonumber(self.expText:getString())
        local oldCrystal = tonumber(self.crystalText:getString())
        if oldSilver ~= ures.silver then
            self.silverText:stopAllActions()
            numAct(self.silverText, oldSilver, ures.silver)
        end
        if oldExp ~= ures.exp then
            self.expText:stopAllActions()
            numAct(self.expText, oldExp, ures.exp)
        end
        if oldCrystal ~= ures.crystal then
            self.crystalText:stopAllActions()
            numAct(self.crystalText, oldCrystal, ures.crystal)
        end
    end
end
function BattleMenu:exitScene()
    Event:unregisterEvent(EVENT_TYPE.ROB_RESOURCE, self)
end
function BattleMenu:initDataOver()
    if BattleLogic.resource.name == nil then
        BattleLogic.resource.name = str(1)
    end
    local temp = setSize(setPos(addSprite(self.bg, "name.png"), {33, fixY(nil, 36)}), {30, 30})
    local name = ui.newTTFLabel({text=BattleLogic.resource.name, size=25, color={202, 70, 70}})
    setAnchor(setPos(name, {55, fixY(nil, 36)}), {0, 0.5})
    self.bg:addChild(name)

    local temp = setSize(setPos(addSprite(self.bg, "silver.png"), {33, fixY(nil, 88)}), {30, 30})
    local silver = ui.newBMFontLabel({text=str(BattleLogic.resource.silver), size=25, color={133, 149, 161}})
    setAnchor(setPos(silver, {55, fixY(nil, 88)}), {0, 0.5})
    self.bg:addChild(silver)

    local temp = setSize(setPos(addSprite(self.bg, "crystal.png"), {33, fixY(nil, 124)}), {30, 30})
    local crystal = ui.newBMFontLabel({text=str(BattleLogic.resource.crystal), size=25, color={48, 52, 109}})
    setAnchor(setPos(crystal, {55, fixY(nil, 124)}), {0, 0.5})
    self.bg:addChild(crystal)

    local temp = setSize(setPos(addSprite(self.bg, "exp.png"), {33, fixY(nil, 154)}), {30, 30})
    local exp = ui.newBMFontLabel({text=str(math.floor((BattleLogic.resource.crystal+BattleLogic.resource.silver)/2)), size=25, color={109, 170, 44}})
    setAnchor(setPos(exp, {55, fixY(nil, 154)}), {0, 0.5})
    self.bg:addChild(exp)


    local temp = setColor(setSize(setPos(addSprite(self.bg, "silver.png"), {33, fixY(nil, 194)}), {30, 30}), {102, 0, 0})
    local silver = ui.newBMFontLabel({text=str(0), size=25, color={133, 149, 161}})
    setAnchor(setPos(silver, {55, fixY(nil, 194)}), {0, 0.5})
    self.bg:addChild(silver)
    self.silverText = silver

    local temp = setColor(setSize(setPos(addSprite(self.bg, "crystal.png"), {33, fixY(nil, 234)}), {30, 30}), {102, 0, 0})
    local crystal = ui.newBMFontLabel({text=str(0), size=25, color={48, 52, 109}})
    setAnchor(setPos(crystal, {55, fixY(nil, 234)}), {0, 0.5})
    self.bg:addChild(crystal)
    self.crystalText = crystal

    local temp = setColor(setSize(setPos(addSprite(self.bg, "exp.png"), {33, fixY(nil, 274)}), {30, 30}), {102, 0, 0})
    local exp = ui.newBMFontLabel({text=str(0), size=25, color={109, 170, 44}})
    setAnchor(setPos(exp, {55, fixY(nil, 274)}), {0, 0.5})
    self.bg:addChild(exp)
    self.expText = exp
end
function BattleMenu:choose(n)
    if self.curChoose ~= nil then
        local tex = CCTextureCache:sharedTextureCache():addImage("mapUnSel.png")
        self.data[self.curChoose].but.sp:setTexture(tex)
        self.curChoose = nil
    end
    self.curChoose = n
    local tex = CCTextureCache:sharedTextureCache():addImage("mapSel.png")
    self.data[self.curChoose].but.sp:setTexture(tex)
    
end
--根据我方的士兵显示
function BattleMenu:updateTab()
    local i = 0
    for k, v in ipairs(storeSoldier) do
        local data = {}
        local panel = setPos(addNode(self.flowNode), {i*self.OFFX, 0})
        local but = ui.newButton({image="mapUnSel.png", callback=self.onSoldier, delegate=self, param=data})
        panel:addChild(but.bg)
        but:setAnchor(0.5, 0.5)

        local sol = setPos(CCSprite:create("soldier"..v..".png"), {0, 0})
        local sca = getSca(sol, {60, 60})
        setScale(sol, sca)
        panel:addChild(sol)

        local x = math.random(10)
        local y = math.random(5)
        sol:runAction(repeatForever(spawn({sequence({moveby(0.2, x, y), moveby(0.2, -x, -y)}), sequence({rotateby(0.2, 10), rotateby(0.2, -10)})})))
        
        local n = getDefault(global.user.soldiers, v, 0)
        local num = ui.newBMFontLabel({text=str(n), size=20, color={52, 101, 36}})
        if n == 0 then
            setColor(sol, {0, 0, 0})
        end
        setPos(num, {24, -17})
        panel:addChild(num)
        data.num = num
        data.total = n
        data.sol = sol
        data.id = v
        data.i = i+1
        data.but = but
        table.insert(self.data, data)
        i = i+1
    end
end

--显示我方可以使用的士兵的类型 和数量
--bound Num
--退出战斗
function BattleMenu:onCancel()
    --没有显示对话框  
    if BattleLogic.endDialog == nil then
        --没有战斗结束
        if BattleLogic.gameOver == false then
            --正在战斗过程中 显示 失败对话框
            if self.scene.state == BATTLE_STATE.IN_BATTLE then
                global.director:pushView(ChallengeOver.new(self.scene, {suc=false}), 1, 0)
                --没有开始战斗 直接云朵结束
                --BattleLogic.clearBattle()
            else
                --BattleLogic.clearBattle()
                BattleLogic.quitBattle = true
                global.director:pushView(Cloud.new(), 1, 0)
            end
        end

    end
end
function BattleMenu:onRandom()
    global.director:pushView(Cloud.new(), 1, 0)
end
function BattleMenu:startBattle()
    if self.hideYet == nil then
        self.hideYet = true
        if self.randomBut ~= nil then
            self.randomBut.sp:runAction(fadeout(0.3))
            self.randomBut:setCallback(nil)
        end
    end
end

function BattleMenu:onSoldier(data)
    self:choose(data.i)
end

function BattleMenu:getCurSol()
    return self.data[self.curChoose].id
end
function BattleMenu:getNum()
    return self.data[self.curChoose].total
end
function BattleMenu:updateKill(kind)
    print("updateKill", kind)
    for k, v in ipairs(self.data) do
        if v.id == kind then
            v.total = v.total-1
            v.num:setString(str(v.total))
            if v.total == 0 then
                setColor(v.sol, {0, 0, 0})
            end
            break
        end
    end
end
