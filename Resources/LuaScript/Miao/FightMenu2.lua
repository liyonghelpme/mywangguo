FightMenu2 = class()
function FightMenu2:adjustPos()
    local vs = getVS()
    local ds = global.director.designSize
    --local realHeight = vs.height-FIGHT_HEIGHT
    --+80
    local scaY = self.realHeight/self.tsz.height
    local scaX = scaY
    --缩放Y 方向
    setScale(self.temp, scaY)
    local cx = ds[1]/2
    local nx = vs.width/2-cx*scaX
    setPos(self.temp, {nx, 0})
end
--从Scene 获得 场景 士兵数量数据
--使用convertToNum 来显示 不同士兵
function FightMenu2:ctor(s)
    self.scene = s
    self.bg = CCNode:create()
    local sz = {width=1024, height=768}
    local bc = addNode(self.bg)
    local sp = CCSprite:create("battleUI.png")

    --[[
    local tex = CCTextureCache:sharedTextureCache():addImage("battleUI.png")
    local r = CCRectMake(0, 0, 405, 291)
    local left = createSpriteFrame(tex, r, 'leftBattle')
    local r = CCRectMake(619, 0, 405, 291)
    local right = createSpriteFrame(tex, r, 'rightBattle')

    local sp = CCSpriteBatchNode:create("buildUI.png")
    --]]



    self.bui = sp
    bc:addChild(sp)
    local vs = getVS()
    setAnchor(setPos(sp, {vs.width/2, 0}), {0.5, 0})

    local tsz = sp:getContentSize()
    self.tsz =tsz
    --bottom center cust height
    local nh = vs.height-FIGHT_HEIGHT+10
    self.realHeight = nh
    print("ui height", nh)
    setScaleY(sp, nh/tsz.height)
    setScaleX(sp, vs.width/tsz.width)
    --[[
    setPos(sp, {512, fixY(sz.height, 592)})
    centerYRate(bc)  
    local vs = getVS()
    setScaleY(bc, (vs.height-FIGHT_HEIGHT+80)/tsz.height)
    --]]



    --高度缩放但是X 位置 基本根据宽度重新布局
    self.temp = addNode(self.bg)
    local sp = setAnchor(setSize(setPos(addSprite(self.temp, "upTitle.png"), {512, fixY(sz.height, 449)}), {932, 74}), {0.50, 0.50})
    --local sz = {width=97, height=46}
    --self.temp = setPos(addNode(self.bg), {579, fixY(sz.height, 487+sz.height)+0})
    local banner = setAnchor(setSize(setPos(addSprite(self.temp, "battleNumBar.png"), {627, fixY(sz.height, 510)}), {97, 46}), {0.50, 0.50})
    local pro = setAnchor(setPos(addSprite(banner, "battleNumCol.png"), {97-3, 2}), {1.0, 0.0})
    self.eneFoot = pro
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="50", size=35, color={32, 112, 220}, font="f2", shadowColor={255, 255, 255}})), {0.00, 0.50}), {691, fixY(sz.height, 510)})
    self.eneFootNum = w

    local banner = setAnchor(setSize(setPos(addSprite(self.temp, "battleNumBar.png"), {627, fixY(sz.height, 569)}), {97, 46}), {0.50, 0.50})
    local pro = setAnchor(setPos(addSprite(banner, "battleNumCol.png"), {97-3, 2}), {1.0, 0.0})
    self.eneArrow = pro

    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="50", size=35, color={32, 112, 220}, font="f2", shadowColor={255, 255, 255}})), {0.00, 0.50}), {691, fixY(sz.height, 569)})
    self.eneArrowNum = w

    local banner = setAnchor(setSize(setPos(addSprite(self.temp, "battleNumBar.png"), {627, fixY(sz.height, 629)}), {97, 46}), {0.50, 0.50})
    local pro = setAnchor(setPos(addSprite(banner, "battleNumCol.png"), {97-3, 2}), {1.0, 0.0})
    self.eneMagic = pro

    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="50", size=35, color={32, 112, 220}, font="f2", shadowColor={255, 255, 255}})), {0.00, 0.50}), {691, fixY(sz.height, 629)})
    self.eneMagicNum = w

    local banner = setAnchor(setSize(setPos(addSprite(self.temp, "battleNumBar.png"), {627, fixY(sz.height, 683)}), {97, 46}), {0.50, 0.50})
    local pro = setAnchor(setPos(addSprite(banner, "battleNumCol.png"), {97-3, 2}), {1.0, 0.0})
    self.eneCav = pro
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="50", size=35, color={32, 112, 220}, font="f2", shadowColor={255, 255, 255}})), {0.00, 0.50}), {691, fixY(sz.height, 683)})
    self.eneCavNum = w

    local banner = setAnchor(setSize(setPos(addSprite(self.temp, "battleNumBar.png"), {391, fixY(sz.height, 510)}), {97, 46}), {0.50, 0.50})
    local pro = setAnchor(setPos(addSprite(banner, "battleNumCol.png"), {3, 2}), {0.0, 0.0})
    self.myFoot = pro
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="50", size=35, color={32, 112, 220}, font="f2", shadowColor={255, 255, 255}})), {1.00, 0.50}), {331, fixY(sz.height, 507)})
    self.myFootNum = w
    local banner = setAnchor(setSize(setPos(addSprite(self.temp, "battleNumBar.png"), {391, fixY(sz.height, 569)}), {97, 46}), {0.50, 0.50})
    local pro = setAnchor(setPos(addSprite(banner, "battleNumCol.png"), {3, 2}), {0.0, 0.0})
    self.myArrow = pro
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="50", size=35, color={32, 112, 220}, font="f2", shadowColor={255, 255, 255}})), {1.00, 0.50}), {331, fixY(sz.height, 569)})
    self.myArrowNum = w
    local banner = setAnchor(setSize(setPos(addSprite(self.temp, "battleNumBar.png"), {391, fixY(sz.height, 629)}), {97, 46}), {0.50, 0.50})
    local pro = setAnchor(setPos(addSprite(banner, "battleNumCol.png"), {3, 2}), {0.0, 0.0})
    self.myMagic = pro
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="50", size=35, color={32, 112, 220}, font="f2", shadowColor={255, 255, 255}})), {1.00, 0.50}), {331, fixY(sz.height, 629)})
    self.myMagicNum = w
    local banner = setAnchor(setSize(setPos(addSprite(self.temp, "battleNumBar.png"), {391, fixY(sz.height, 683)}), {97, 46}), {0.50, 0.50})
    local pro = setAnchor(setPos(addSprite(banner, "battleNumCol.png"), {3, 2}), {0.0, 0.0})
    self.myCav = pro
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="50", size=35, color={32, 112, 220}, font="f2", shadowColor={255, 255, 255}})), {1.00, 0.50}), {331, fixY(sz.height, 683)})
    self.myCavNum = w

    --分离battle 的血条背景
    --local scaX = getScaleX(self.bui)
    --self.scaX = scaX
    --self.realSizeX = self.scaX*888
    local sp = setAnchor(setSize(setPos(addSprite(self.temp, "vsbloodA.png"), {508, fixY(sz.height, 474)}), {888, 13}), {0.50, 0.50})
    self.leftBlood = sp
    local sp = setAnchor(setSize(setPos(addSprite(self.temp, "vsbloodB.png"), {953, fixY(sz.height, 474)}), {443, 13}), {1.00, 0.50})
    self.rightBlood = sp
    self.totalLeft = 0
    self.totalRight = 0
    self.leftAll = 0
    self.rightAll = 0
    for k, v in ipairs(self.scene.layer.allSoldiers) do
        if not v.dead then
            if v.color == 0 then
                self.leftAll = self.leftAll+v.health
            elseif v.color == 1 then
                self.rightAll = self.rightAll+v.health
            end
        end
    end

    local sp = setAnchor(setSize(setPos(addSprite(self.temp, "battleWord.png"), {717, fixY(sz.height, 444)}), {116, 83}), {0.50, 0.50})
    self.eneWord = sp
    setVisible(sp, false)
    local w = setPos(setAnchor(addChild(sp, ui.newBMFontLabel({text="0", size=35, color={128, 0, 0}, font="bound.fnt"})), {0.50, 0.50}), {56, 40})
    self.eneNum = w

    local sp = setAnchor(setSize(setPos(addSprite(self.temp, "battleWord.png"), {317, fixY(sz.height, 444)}), {116, 83}), {0.50, 0.50})
    self.myWord = sp
    setVisible(sp, false)
    local w = setPos(setAnchor(addChild(sp, ui.newBMFontLabel({text="0", size=35, color={128, 0, 0}, font="bound.fnt"})), {0.50, 0.50}), {56, 40})
    self.myNum = w


    self.leftBottom = addNode(self.bg)
    local but = ui.newButton({image="buta.png", text="返回", font="f2", size=30, delegate=self, callback=self.onBut, shadowColor={255, 255, 255}, color={206, 78, 0}})
    but:setContentSize(107, 113)
    setPos(addChild(self.leftBottom, but.bg), {76, fixY(sz.height, 706)})
    leftBottomUI(self.leftBottom)




    self.leftHurt = 0
    self.rightHurt = 0

    self:adjustPos()
    self:adjustNum()

    self.passTime = 0
    self.needUpdate = true
    registerEnterOrExit(self)
end
function fightNumPro(banner, n, max)
    print("fightNumPro", banner, n, max)
    if n <= 0 then
        banner:setVisible(false)
    else
        banner:setVisible(true)
        local wid = math.floor((n/max)*92)
        wid = math.max(0, wid)
        setSize(banner, {wid, 39})
    end
end

function FightMenu2:onBut()
    CAMERA_SMOOTH = 1
end

--初始化的时候 根据 
--调整数字 和 banner 显示
--从FightScene 获取数据
function FightMenu2:adjustNum()
    local sol = self.scene.menuSoldier
    local maxSol = self.scene.maxSoldier

    fightNumPro(self.eneFoot, sol[2][1], maxSol[2][1])
    self.eneFootNum:setString(sol[2][1])
    fightNumPro(self.eneArrow, sol[2][2], maxSol[2][2])
    self.eneArrowNum:setString(sol[2][2])
    fightNumPro(self.eneMagic, sol[2][3], maxSol[2][3])
    self.eneMagicNum:setString(sol[2][3])
    fightNumPro(self.eneCav, sol[2][4], maxSol[2][4])
    self.eneCavNum:setString(sol[2][4])

    fightNumPro(self.myFoot, sol[1][1], maxSol[1][1])
    self.myFootNum:setString(sol[1][1])
    fightNumPro(self.myArrow, sol[1][2], maxSol[1][2])
    self.myArrowNum:setString(sol[1][2])
    fightNumPro(self.myMagic, sol[1][3], maxSol[1][3])
    self.myMagicNum:setString(sol[1][3])
    fightNumPro(self.myCav, sol[1][4], maxSol[1][4])
    self.myCavNum:setString(sol[1][4])
end
function FightMenu2:update(diff)
    local function clearS(k)
        if k == 0 then
            self.leftInS = false
        else
            self.rightInS = false
        end
    end
    --战斗结束 passTime 清理一下
    if self.passTime == 0 then
        if self.leftHurt > 0 or self.rightHurt > 0 then
            self.passTime = self.passTime+diff
            if self.leftHurt > 0 then
                setVisible(self.myWord, true)
                self.myNum:setString(self.leftHurt)
                self.myWord:runAction(sequence({scaleto(0.1, 1.5, 1.5), scaleto(0.1, 1, 1), callfunc(nil, clearS, 0)}))
                self.leftInS = true
            end
            if self.rightHurt > 0 then
                setVisible(self.eneWord, true)
                self.eneNum:setString(self.rightHurt)
                self.eneWord:runAction(sequence({scaleto(0.1, 1.5, 1.5), scaleto(0.1, 1, 1), callfunc(nil, clearS, 1)}))
                self.rightInS = true
            end

            self.oldLeft = self.leftHurt
            self.oldRight = self.rightHurt
        end
    else
        self.passTime = self.passTime+diff
        if self.leftHurt > self.oldLeft and not self.leftInS then
            self.oldLeft = self.leftHurt
            setVisible(self.myWord, true)
            self.myWord:runAction(sequence({scaleto(0.1, 1.5, 1.5), scaleto(0.1, 1, 1), callfunc(nil, clearS, 0)}))
            self.myNum:setString(self.leftHurt)
            self.leftInS = true
        end
        if self.rightHurt > self.oldRight and not self.rightInS then
            self.oldRight = self.rightHurt
            setVisible(self.eneWord, true)
            self.eneWord:runAction(sequence({scaleto(0.1, 1.5, 1.5), scaleto(0.1, 1, 1), callfunc(nil, clearS, 1)}))
            self.eneNum:setString(self.rightHurt)
            self.rightInS = true
        end
    end

    local leftLeft = self.leftAll - self.totalLeft
    local leftRight = self.rightAll - self.totalRight
    if leftLeft > 0 then
        print("total left ", self.leftAll, self.rightAll, leftLeft, leftRight)
        local rate = (leftRight/self.rightAll)/(leftLeft/self.leftAll)
        local size = rate/(1+rate)
        setSize(self.rightBlood, {888*size, 13})
    elseif leftLeft <= 0 and leftRight <= 0 then
        setSize(self.rightBlood, {444, 13})
    else
        setSize(self.rightBlood, {888, 13})
    end
end

--士兵死亡
function FightMenu2:killSoldier(soldier, killNum, healthHurt)
    local sol = self.scene.menuSoldier
    local maxSol = self.scene.maxSoldier
    print("killSoldier", soldier.color, soldier.id, killNum, healthHurt)
    if soldier.color == 0 then
        if soldier.id == 0 then
            sol[1][1] = sol[1][1]-killNum
            fightNumPro(self.myFoot, sol[1][1], maxSol[1][1])
            self.myFootNum:setString(sol[1][1])
        elseif soldier.id == 1 then
            sol[1][2] = sol[1][2]-killNum
            fightNumPro(self.myArrow, sol[1][2], maxSol[1][2])
            self.myArrowNum:setString(sol[1][2])
        elseif soldier.id == 2 then
            sol[1][3] = sol[1][3]-killNum
            fightNumPro(self.myMagic, sol[1][3], maxSol[1][3])
            self.myMagicNum:setString(sol[1][3])
        elseif soldier.id == 3 then
            sol[1][4] = sol[1][4]-killNum
            fightNumPro(self.myCav, sol[1][4], maxSol[1][4])
            self.myCavNum:setString(sol[1][4])
        end
        --有个跳动频率 
        --有个触发条件
        --1s 跳动一下 显示当前的伤害
        --出现的时候 突然出现
        self.leftHurt = self.leftHurt+healthHurt
        self.totalLeft = self.totalLeft+healthHurt
    else
        if soldier.id == 0 then
            sol[2][1] = sol[2][1]-killNum
            fightNumPro(self.eneFoot, sol[2][1], maxSol[2][1])
            self.eneFootNum:setString(sol[2][1])
        elseif soldier.id == 1 then
            sol[2][2] = sol[2][2]-killNum
            fightNumPro(self.eneArrow, sol[2][2], maxSol[2][2])
            self.eneArrowNum:setString(sol[2][2])
        elseif soldier.id == 2 then
            sol[2][3] = sol[2][3]-killNum
            fightNumPro(self.eneMagic, sol[2][3], maxSol[2][3])
            self.eneMagicNum:setString(sol[2][3])
        elseif soldier.id == 3 then
            sol[2][4] = sol[2][4]-killNum
            fightNumPro(self.eneCav, sol[2][4], maxSol[2][4])
            self.eneCavNum:setString(sol[2][4])
        end
        self.rightHurt = self.rightHurt+healthHurt
        self.totalRight = self.totalRight+healthHurt
    end
    print("left solNum", simple.encode(sol))
end

function FightMenu2:finishRound()
    self.rightHurt = 0
    self.leftHurt = 0
    self.oldLeft = 0
    self.oldRight = 0
    self.passTime = 0
    setVisible(self.myWord, false)
    setVisible(self.eneWord, false)
end


