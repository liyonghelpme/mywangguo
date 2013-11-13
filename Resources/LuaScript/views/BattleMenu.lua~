BattleMenu = class()
function BattleMenu:ctor(s)
    self.INIT_X = 50
    self.INIT_Y = fixY(nil, 432)
    self.OFFX = 80

    print("initBattleMenu ##############")
    self.scene = s
    self.bg = CCNode:create()
    --100 倍率图片产生奇怪的效果
    local cancelBut = ui.newButton({image="mapMenuCancel.png", callback=self.onCancel, delegate=self})
    setPos(cancelBut.bg, {654, fixY(nil, 65)})
    self.bg:addChild(cancelBut.bg)
    
    local randomBut = ui.newButton({image="random.png", callback=self.onRandom, delegate=self})
    setPos(randomBut.bg, {731, fixY(nil, 65)})
    self.bg:addChild(randomBut.bg)
    self.randomBut = randomBut
    


    self.cl = setPos(addNode(self.bg), {self.INIT_X, self.INIT_Y})
    self.flowNode = addNode(self.cl)
    self.data = {}
    self:updateTab()
    self:choose(1)
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
    local exp = ui.newBMFontLabel({text=str(10), size=25, color={109, 170, 44}})
    setAnchor(setPos(exp, {55, fixY(nil, 154)}), {0, 0.5})
    self.bg:addChild(exp)
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
        self.randomBut.sp:runAction(fadeout(0.3))
        self.randomBut:setCallback(nil)
    end
end

function BattleMenu:onSoldier(data)
    self:choose(data.i)
end

function BattleMenu:getCurSol()
    return self.data[self.curChoose].id
end
function BattleMenu:updateKill(kind)
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
