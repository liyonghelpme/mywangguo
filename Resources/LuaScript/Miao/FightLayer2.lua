require "Miao.FightUtil"
require "Miao.FightSoldier2"
require "Miao.Camera"

FIGHT_STATE = {
    FREE=0,
    MOVE=1,
    FINISH_MOVE=2,
    GUN = 3,
    ARROW = 4,
    INFANTRY = 5,
    CAVALRY = 6,

    WAIT = 7,
    FIGHT_OVER = 8,
    FIGHT_OVER2 = 9,

    FIGHT_OVER3 = 10,

    FAST_BACK = 11,
    DAY = 12,

}
FightLayer2 = class()

--Invisible 背后的场景 battleScene 上所有的东西 
--但是update 还是会调用的 
--3:7 战斗场景高度位置
--菜单的位置
--我方士兵数量 和 敌方士兵状态
--[num, num, num, num]
--将士兵数量转化成 5 列 5 行的士兵
--单个士兵的战斗力等级[0, 1, 2, 3] 或者战斗力数量
--阶梯 方式 来表现士兵数量
--超过2000个最多25个 每个能力平均 
--第一排 第二排
function FightLayer2:convertNumToSoldier(n)
    local temp = {}
    local num
    local pow
    if n == 0 then
        --至少一列空列
        --return {{0, 0, 0, 0, 0}}
        return {}
    end

    if n < 100 then
        num = math.max(math.floor(n/5), 1)
        if n > 5 then
            pow = 5
        else
            pow = n
        end
    --5 * 5 = 25 最多士兵数量
    elseif n < 250 then
        num = math.floor(n/10)
        pow = 10 
    elseif n < 500 then
        num = math.floor(n/20)
        pow = 20
    elseif n < 1000 then
        num = math.floor(n/40)
        pow = 40
    elseif n < 2000 then
        num = math.floor(n/80)
        pow = 80
    else
        pow = math.floor(n/25)
        num = 25
    end
    local leftNum = n-num*pow
    print("left Number is", n, num, pow, leftNum)

    local curCol
    for i =0, num-1, 1 do
        local col = math.floor(i/5)
        local row = math.floor(i%5)
        if row == 0 then
            curCol = {}
            table.insert(temp, curCol)
        end
        --每个士兵实力5
        table.insert(curCol, pow)
    end
    --保证所有士兵都有left 或者 right连接 至少有一个空列
    if leftNum > 0 then
        local col = math.floor(num/5)
        local row = math.floor(num%5)
        if row == 0 then
            curCol = {}
            table.insert(temp, curCol)
        end
        table.insert(curCol, leftNum)
    end
    --补全当前列
    while #curCol < 5 do
        table.insert(curCol, 0)
    end

    return temp
end

function FightLayer2:testNum()
    --几列士兵
    local temp = {{5, 1, 0, 0, 0}, {5, 1, 0, 0, 0}, {5, 1, 0, 0, 0}, {5, 0, 0, 0, 0}}
    return temp
end
--副作用 如果第一排转移了attackTarget 我就会跟着转移
function FightLayer2:testNum2(id)
    local temp
    if id == 0 then
        temp = {{5, 0, 0, 0, 0}, {5, 0, 0, 0, 0}, {5, 0, 0, 0, 0}, {5, 0, 0, 0, 0}}
    else
        --temp = {{0, 1, 0, 0, 0}, {0, 1, 0, 0, 0}, {0, 1, 0, 0, 0}, {0, 1, 0, 0, 0}}
        temp = {{0, 0, 1, 0, 0}, {0, 0, 1, 0, 0}, {0, 0, 1, 0, 0}, {0, 0, 1, 0, 0}}
    end
    return temp
end
function FightLayer2:testNum3(id)
    local temp
    if id == 0 then
        temp = {{5, 0, 0, 0, 0}, {5, 0, 0, 0, 0}, {0, 0, 0, 0, 0}, {0, 0, 0, 0, 0}}
    else
        --temp = {{0, 1, 0, 0, 0}, {0, 1, 0, 0, 0}, {0, 1, 0, 0, 0}, {0, 1, 0, 0, 0}}
        temp = {{1, 1, 1, 0, 0}, {1, 1, 1, 0, 0}, {0, 0, 1, 0, 0}, {0, 0, 1, 0, 0}}
    end
    return temp
end

function FightLayer2:testNum4(id)
    return {{1, 1, 1, 0, 0}, {1, 1, 1, 0, 0}}
end
function FightLayer2:testNum5(id)
    return {{1, 0, 0, 0, 0}}
end
function FightLayer2:testNum6()
    return {{1, 1, 0, 0, 0}}
end


function FightLayer2:testNum7()
    return {{1, 0, 0, 0, 0}}
end
function FightLayer2:testNum8()
    return {{1, 0, 0, 0, 0}, {1, 0, 0, 0, 0}, {1, 0, 0, 0, 0}}
end
function FightLayer2:testNum9()
    return {{1, 0, 0, 0, 0}}
end
function FightLayer2:testNum10()
    return {{1, 0, 0, 0, 0}, {1, 0, 0, 0, 0}}
end

--case
function FightLayer2:testNum11()
    return {{1, 0, 0, 0, 0}}
end
function FightLayer2:testNum12()
    return {{1, 0, 0, 0, 0}, {1, 0, 0, 0, 0},{1, 0, 0, 0, 0},}
end
function FightLayer2:testNum13()
    return {{1, 0, 0, 0, 0}, }
end
function FightLayer2:testNum14()
    return {{1, 1, 0, 0, 0}, {1, 1, 0, 0, 0}}
end



function FightLayer2:adjustBattleScene(p)
    local pos = getPos(self.battleScene)
    setPos(self.battleScene, {p, pos[2]})
    pos[1] = p
    --根据battleScene 位置 调整farScene 位置
    local fp = getPos(self.farScene)
    local farPos = {pos[1]*self.farRate, fp[2]}
    setPos(self.farScene, farPos)

    local np = getPos(self.nearScene)
    local nearPos = {pos[1]*self.nearRate, np[2]}
    setPos(self.nearScene, nearPos)

    local gp = getPos(self.grass)
    local ggp = {pos[1]*self.grassRate, gp[2]}
    setPos(self.grass, ggp)
end

function FightLayer2:initCamera()
    local vs = getVS()
    self.leftCamera = Camera.new(self, vs.width/2-1)
    self.bg:addChild(self.leftCamera.bg)
    setPos(self.leftCamera.renderTexture, {vs.width/4-1, FIGHT_HEIGHT/2})
    setVisible(self.leftCamera.renderTexture, false)

    self.rightCamera = Camera.new(self, vs.width/2-1)
    self.bg:addChild(self.rightCamera.bg)
    setPos(self.rightCamera.renderTexture, {vs.width/2+vs.width/4+1, FIGHT_HEIGHT/2})
    setVisible(self.rightCamera.renderTexture, false)

    self.mainCamera = Camera.new(self, vs.width)
    self.bg:addChild(self.mainCamera.bg)
    setPos(self.mainCamera.renderTexture, {vs.width/2, FIGHT_HEIGHT/2})
    setVisible(self.mainCamera.renderTexture, false)
end

function FightLayer2:ctor(s, my, ene)
    self.scene = s 
    local vs = getVS()
    print("FightLayer2")
    self.passTime = 0
    --当前动作的列
    self.poseRowNum = 0
    self.poseRowTime = 0

    self.myFootNum = self:convertNumToSoldier(my[1])
    self.myArrowNum = self:convertNumToSoldier(my[2])
    self.myMagicNum = self:convertNumToSoldier(my[3])
    self.myCavalryNum = self:convertNumToSoldier(my[4])
    --self.myFootNum = self:testNum12(1)
    --self.myArrowNum = self:testNum11()

    self.eneFootNum = self:convertNumToSoldier(ene[1])
    self.eneArrowNum = self:convertNumToSoldier(ene[2])
    self.eneMagicNum = self:convertNumToSoldier(ene[3])
    self.eneCavalryNum = self:convertNumToSoldier(ene[4])
    --self.eneFootNum = self:testNum13(0)
    --self.eneArrowNum = self:testNum14()

    
    --最后留上一列的宽度
    --最后一种兵至少需要半个屏幕的宽度
    local leftWidth = #self.myFootNum*FIGHT_OFFX+#self.myArrowNum*FIGHT_OFFX+#self.myMagicNum*FIGHT_OFFX
    self.solLeftWidth = leftWidth
    self.leftWidth = leftWidth+vs.width
    self.leftBack = self.leftWidth-self.solLeftWidth

    local rightWidth = #self.eneFootNum*FIGHT_OFFX+#self.eneArrowNum*FIGHT_OFFX+#self.eneMagicNum*FIGHT_OFFX
    self.solRightWidth = rightWidth
    self.rightWidth = rightWidth+vs.width

    --单张战斗图调整为 self.HEIGHT
    --战斗场景高度不变 483 高度
    self.HEIGHT = FIGHT_HEIGHT
    self.bg = setPos(CCLayer:create(), {0, vs.height-self.HEIGHT})
    --tempNode not visible
    --规避 not visible的顶点 调用visit 失效的情况
    self.tempNode = addNode(self.bg)
    self.physicScene = addNode(self.tempNode)

    self.farScene = addNode(self.physicScene)
    self.grass = addNode(self.physicScene)
    setPos(self.grass, {0, 267})
    self.battleScene = CCNode:create()
    addChild(self.physicScene, self.battleScene)
    self.nearScene = addNode(self.physicScene)

    if DEBUG_FIGHT then
        self.stateLabel = ui.newBMFontLabel({text="", color={0, 0, 0}, size=25})
        self.physicScene:addChild(self.stateLabel)
        setAnchor(setPos(self.stateLabel, {10, FIGHT_HEIGHT-40}), {0, 0})
    end
    --场景宽度受士兵的数量决定 1:1的士兵
    --刚开始 1: 0.618 
    --战斗高度不变 但是宽度可以自由增加
    --比屏幕宽一点这样就不能同时看到 左右两边的士兵了
    --一个屏幕的宽度差值
    self.WIDTH = vs.width*1.5+self.leftWidth+self.rightWidth
    --test 
    --[[
    self.bg:setScale(0.3)
    setPos(setContentSize(setAnchor(self.bg, {0, 0}), {0, 0}), {400, 400})
    --]]
    --从左到右面的士兵 宽度
    self.rightBack = self.WIDTH-self.rightWidth+self.solRightWidth
    print("self.rightBack", self.rightBack, self.rightWidth, self.WIDTH, self.solRightWidth)

    print("width", self.WIDTH, vs.width, leftWidth, rightWidth)

    setContentSize(self.bg, {self.WIDTH, self.HEIGHT})
    local tex = CCTextureCache:sharedTextureCache():addImage("battle_mid.png")
    local tsz = tex:getContentSize()
    local tsca = self.HEIGHT/480
    self.oneWidth = tsca*tsz.width
    self.farRate = 0.2
    self.nearRate = 1.0
    self.grassRate = 0.5

    local n = math.ceil(self.WIDTH/self.oneWidth)
    for i=1, n, 1 do
        local sp = setAnchor(setPos(setSize(CCSprite:create("battle_mid.png"), {self.oneWidth, self.HEIGHT}), {(i-1)*self.oneWidth, 0}), {0, 0})
        self.battleScene:addChild(sp)
        local far = setAnchor(setPos(setScale(CCSprite:create("battle_far.png"), tsca), {(i-1)*self.oneWidth, 258}), {0, 0})
        self.farScene:addChild(far)

        if (i-1)%2 == 1 then
            local scax = sp:getScaleX()
            setAnchor(setScaleX(sp, -scax), {1, 0})
            setAnchor(setScaleX(far, -scax), {1, 0})
        end
    end
    local tex = CCTextureCache:sharedTextureCache():addImage("battle_grass.png")
    local tsz = tex:getContentSize()
    local grassN = math.ceil(self.WIDTH/tsz.width)
    for i=1, grassN, 1 do
        local sp = setScale(createSprite("battle_grass.png"), tsca)
        setAnchor(setPos(sp, {(i-1)*tsz.width*tsca, 0}), {0, 0})
        self.grass:addChild(sp)
    end

    --nearScene 1.5 比例
    local nearN = math.ceil(self.WIDTH*1.5/self.oneWidth) 
    for i=1, nearN, 1 do
        local near = setAnchor(setPos(setScale(CCSprite:create("battle_near.png"), tsca), {(i-1)*self.oneWidth, 10}), {0, 0})
        self.nearScene:addChild(near)
    end

    self:adjustBattleScene(-self.leftBack+vs.width/3)
    self.smooth = 1
    self.arrowSpeed = 500
    self.solId = 0
    self.state = FIGHT_STATE.FREE
    self.curCol = 0
    self.cache = {}

    self:initPic()
    self:initSoldier()
    self:initCamera()

    self.needUpdate = true
    registerEnterOrExit(self)
end

--dark 变成明亮 之后就开始战斗
--掏出武器
function FightLayer2:doFree(diff)
    if self.state == FIGHT_STATE.FREE then
        self.state = FIGHT_STATE.MOVE
        self.passTime = 0
        self.curCol = 1

        self.moveSpeed = 500
        --使用ease 函数调整move 状态
        local vs = getVS()
        local p = getPos(self.battleScene)
        local endPoint = self.rightBack-vs.width+100
        print("endPoint is", endPoint)
        self.endPoint = endPoint
        self.totalTime = (endPoint-p[1])/self.moveSpeed
        self.battleScene:runAction(sinein(moveto(self.totalTime, -endPoint, 0)))
    end
end
--测试不同数量的士兵的战斗效果
function FightLayer2:doMove(diff)
    if self.state == FIGHT_STATE.MOVE then
        local pos = getPos(self.battleScene)
        self:adjustBattleScene(pos[1])

        for k, v in ipairs(self.allSoldiers) do
            v:showPose(pos[1])  
        end

        if math.abs(pos[1]) >= self.endPoint-10 then
            self.state = FIGHT_STATE.FAST_BACK 
            self.passTime = 0
            self.totalTime = self.endPoint/(self.moveSpeed*2)
            --回到第一排士兵的位置
            self.finShow = false
            local function showOver()
                self.finShow = true
            end
            local vs = getVS()
            local lw = self.leftWidth+vs.width*1.5/2-vs.width/2
            print("fastBack position", self.leftWidth, self.rightWidth, lw, self.totalTime)
            self.battleScene:runAction(sequence({delaytime(1), sinein(moveto(0.5, -lw, 0)), callfunc(nil, showOver)}))
        end
    end
end
function FightLayer2:doFastBack(diff)
    if self.state == FIGHT_STATE.FAST_BACK then
        print("fast back scene")
        local pos = getPos(self.battleScene)
        self:adjustBattleScene(pos[1])

        if self.finShow then
            self.state = FIGHT_STATE.DAY
            self.day = 0
            self.passTime = 0
        end
    end
end
--士兵开始跑步 战斗 交给士兵控制
--步兵剧本
--弓箭手剧本
--火枪剧本
--骑兵剧本
--单个士兵的剧本
function FightLayer2:doDay(diff)
    if self.state == FIGHT_STATE.DAY then
        if self.day == 0 then
            self:magicScript(diff)
        elseif self.day == 1 then
            self:arrowScript(diff)
        elseif self.day == 2 then
            self:footScript(diff)
        elseif self.day == 3 then
            self:cavalryScript(diff)
        end
    end
end

function FightLayer2:update(diff)
    if DEBUG_FIGHT then
        self.stateLabel:setString(str(self.finishAttack).." "..str(math.floor(self.passTime)))
    end
    self.poseRowTime = self.poseRowTime+diff

    self:doFree(diff)
    self:doMove(diff)
    self:doFastBack(diff)
    self:doDay(diff)
end

function FightLayer2:initPic()
    local sf = CCSpriteFrameCache:sharedSpriteFrameCache()
    sf:addSpriteFramesWithFile("cat_foot.plist")
    sf:addSpriteFramesWithFile("cat_arrow.plist")
    sf:addSpriteFramesWithFile("cat_magic.plist")
    sf:addSpriteFramesWithFile("cat_cavalry.plist")
    sf:addSpriteFramesWithFile("attackAni.plist")
    createAnimation("attackSpe1", "attack%d.png", 5, 8, 1, 0.5, true)
    createAnimationWithNum("attackSpe2", "attack%d.png", 0.5, true, {1, 3, 4})
     
    local tex = CCTextureCache:sharedTextureCache():addImage("magic.png")

    for i=0, 11, 1 do
        local row = math.floor(i/5)
        local col = i%5
        local r = CCRectMake(col*192, row*192, 192, 192)
        local sp = CCSpriteFrame:createWithTexture(tex, r)
        sf:addSpriteFrame(sp, "magic"..i)
    end
    createAnimation("magicBall", "magic%d", 0, 11, 1, 0.5, true)
end
function FightLayer2:getSolId()
    self.solId = self.solId+1
    return self.solId
end
function FightLayer2:printSoldier(sol)
    print("printSoldier")
    local s = ''
    for k, v in ipairs(sol) do
        for tk, tv in ipairs(v) do
            if tv then
                s = s..tv.sid..' '
            end
        end
        s = s ..'\n'
    end
    print(s)
end
--输入参数 各种士兵
function FightLayer2:initSoldier()
    print("left Num")
    print(simple.encode(self.myFootNum))
    print(simple.encode(self.eneFootNum))
    print(simple.encode(self.myArrowNum))
    print(simple.encode(self.eneArrowNum))
    print(simple.encode(self.myMagicNum))
    print(simple.encode(self.eneMagicNum))
    self.mySoldiers = {}
    self.allSoldiers = {}
    self.solOffY = 80
    self.scaleCoff = 0.05

    self.soldierNet = {}


    local colId = #self.myCavalryNum+#self.myArrowNum+#self.myMagicNum+#self.myFootNum-1
    --每一列
    --我方步兵的列编号
    for k, v in ipairs(self.myFootNum) do 
        --row
        local temp = {}
        table.insert(self.mySoldiers, temp) 
        --行
        local lastOne = nil
        for ck, cv in ipairs(v) do 
            --col
            if cv > 0 then
                local sp = FightSoldier2.new(self, 0, colId, ck-1, {level=cv, color=0}, self:getSolId()) 
                sp.low = lastOne
                if lastOne ~= nil then
                    lastOne.up = sp
                end
                lastOne = sp

                self.battleScene:addChild(sp.bg)
                setPos(sp.bg, {self.leftWidth-(k-1)*FIGHT_OFFX+(ck-1)*FIGHT_COL_OFFX, self.solOffY+(ck-1)*FIGHT_ROW_OFFY})
                --setPos(sp.bg, {0, 0})
                sp:setZord()
                table.insert(temp, sp)
                table.insert(self.allSoldiers, sp)
                local sca = 1-(ck-1)*self.scaleCoff
                setScale(sp.bg, sca)
            else
                local sp = {dead=true, color=0, sid=-1, id=-1, initLeftRight=initSolLeftRight, map=self, col=colId, row=ck-1}
                table.insert(temp, sp)
                self.soldierNet[getMapKey(colId, ck-1)] = sp
            end
        end
        colId = colId-1
    end

    --列  行
    --最后一列 对齐 敌方士兵 士兵
    --数据是第一排 第二排
    --还想知道 每种 士兵 所包含的列数 
    --如果直到了所有的这种士兵 其实 可以 计算出 包围盒子的

    --敌方步兵所在的列编号
    local colId = #self.myCavalryNum+#self.myArrowNum+#self.myMagicNum+#self.myFootNum

    self.eneSoldiers = {}
    for k, v in ipairs(self.eneFootNum) do
        local temp = {}
        table.insert(self.eneSoldiers, temp)
        local lastOne = nil
        for ck, cv in ipairs(v) do
            if cv > 0 then
                local sp = FightSoldier2.new(self, 0, colId, ck-1, {level=cv, color=1}, self:getSolId()) 
                sp.low = lastOne
                if lastOne ~= nil then
                    lastOne.up = sp
                end
                lastOne = sp

                self.battleScene:addChild(sp.bg)
                setPos(sp.bg, {self.WIDTH-self.rightWidth+(k-1)*FIGHT_OFFX-(ck-1)*FIGHT_COL_OFFX, self.solOffY+(ck-1)*FIGHT_ROW_OFFY})
                sp:setZord()
                sp:setDir()
                table.insert(temp, sp)
                table.insert(self.allSoldiers, sp)

                local sca = 1-(ck-1)*self.scaleCoff
                setScale(sp.bg, sca)
            else
                local sp = {dead=true, color=0, sid=-1, id=-1, initLeftRight=initSolLeftRight, map=self, col=colId, row=ck-1}
                table.insert(temp, sp)
                self.soldierNet[getMapKey(colId, ck-1)] = sp
            end
        end
        colId = colId+1
    end


    --初始化 魔法兵  调整弓箭手的 所在列 colId
    self.myMagicSoldiers = {}
    self.eneMagicSoldiers = {}
    local footWidth = #self.myFootNum
    local colId = #self.myCavalryNum+#self.myArrowNum+#self.myMagicNum-1
    for k, v in ipairs(self.myMagicNum) do
        local temp = {}
        table.insert(self.myMagicSoldiers, temp)
        local lastOne = nil
        for ck, cv in ipairs(v) do
            if cv > 0 then
                local sp = FightSoldier2.new(self, 2, colId, ck-1, {level=cv, color=0}, self:getSolId())
                sp.low = lastOne
                if lastOne ~= nil then
                    lastOne.up = sp
                end
                lastOne = sp
                self.battleScene:addChild(sp.bg)

                setPos(sp.bg, {self.leftWidth-(k+footWidth-1)*FIGHT_OFFX+(ck-1)*FIGHT_COL_OFFX, self.solOffY+(ck-1)*FIGHT_ROW_OFFY})
                --setPos(sp.bg, {0, 0})
                sp:setZord()
                table.insert(temp, sp)
                table.insert(self.allSoldiers, sp)

                local sca = 1-(ck-1)*self.scaleCoff
                setScale(sp.bg, sca)
            else
                local sp = {dead=true, color=0, sid=-1, id=-1, initLeftRight=initSolLeftRight, map=self, col=colId, row=ck-1}
                table.insert(temp, sp)
                self.soldierNet[getMapKey(colId, ck-1)] = sp
            end
        end
        colId = colId-1
    end

    local footWidth = #self.eneFootNum
    --更新状态 检测 myArrow eneArrowSoldiers
    local colId = #self.myCavalryNum+#self.myArrowNum+#self.myMagicNum+#self.myFootNum+#self.eneFootNum 
    for k, v in ipairs(self.eneMagicNum) do
        local temp = {}
        table.insert(self.eneMagicSoldiers, temp)
        local lastOne = nil
        for ck, cv in ipairs(v) do
            if cv > 0 then
                local sp = FightSoldier2.new(self, 2, colId, ck-1, {level=cv, color=1}, self:getSolId()) 
                sp.low = lastOne
                if lastOne ~= nil then
                    lastOne.up = sp
                end
                lastOne = sp

                self.battleScene:addChild(sp.bg)
                setPos(sp.bg, {self.WIDTH-self.rightWidth+(k-1+footWidth)*FIGHT_OFFX-(ck-1)*FIGHT_COL_OFFX, self.solOffY+(ck-1)*FIGHT_ROW_OFFY})
                sp:setZord()
                sp:setDir()
                table.insert(temp, sp)
                table.insert(self.allSoldiers, sp)
                local sca = 1-(ck-1)*self.scaleCoff
                setScale(sp.bg, sca)
            else
                local sp = {dead=true, color=0, sid=-1, id=-1, initLeftRight=initSolLeftRight, map=self, col=colId, row=ck-1}
                table.insert(temp, sp)
                self.soldierNet[getMapKey(colId, ck-1)] = sp
            end
        end
        colId = colId+1
    end



    --士兵死亡动态调整 左右两侧

    --新的位置
    --弓箭手的位置  屏幕的
    self.myArrowSoldiers = {}
    self.eneArrowSoldiers = {}
    local footWidth = #self.myMagicNum+#self.myFootNum
    --leftWidth 士兵所在的列 和 行 全局的 
    --先考虑 步兵 炮兵 弓箭 最后骑兵
    local colId = #self.myCavalryNum+#self.myArrowNum-1
    for k, v in ipairs(self.myArrowNum) do 
        --row
        local temp = {}
        table.insert(self.myArrowSoldiers, temp) 
        local lastOne = nil
        for ck, cv in ipairs(v) do 
            --col
            if cv > 0 then
                --弓箭手需要 自己所在部队的编号么 需要一个全局列编号
                local sp = FightSoldier2.new(self, 1, colId, ck-1, {level=cv, color=0}, self:getSolId()) 
                sp.low = lastOne
                if lastOne ~= nil then
                    lastOne.up = sp
                end
                lastOne = sp

                self.battleScene:addChild(sp.bg)
                setPos(sp.bg, {self.leftWidth-(k+footWidth-1)*FIGHT_OFFX+(ck-1)*FIGHT_COL_OFFX, self.solOffY+(ck-1)*FIGHT_ROW_OFFY})
                --setPos(sp.bg, {0, 0})
                sp:setZord()
                table.insert(temp, sp)
                table.insert(self.allSoldiers, sp)

                local sca = 1-(ck-1)*self.scaleCoff
                setScale(sp.bg, sca)
            else
                local sp = {dead=true, color=0, sid=-1, id=-1, initLeftRight=initSolLeftRight, map=self, col=colId, row=ck-1}
                table.insert(temp, sp)
                self.soldierNet[getMapKey(colId, ck-1)] = sp
            end
        end
        colId = colId-1
    end


    local footWidth = #self.eneFootNum+#self.eneMagicNum
    --更新状态 检测 myArrow eneArrowSoldiers
    local colId = #self.myCavalryNum+#self.myArrowNum+#self.myMagicNum+#self.myFootNum+#self.eneFootNum+#self.eneMagicNum
    for k, v in ipairs(self.eneArrowNum) do
        local temp = {}
        table.insert(self.eneArrowSoldiers, temp)
        local lastOne = nil
        for ck, cv in ipairs(v) do
            if cv > 0 then
                local sp = FightSoldier2.new(self, 1, colId, ck-1, {level=cv, color=1}, self:getSolId()) 
                sp.low = lastOne
                if lastOne ~= nil then
                    lastOne.up = sp
                end
                lastOne = sp

                self.battleScene:addChild(sp.bg)
                setPos(sp.bg, {self.WIDTH-self.rightWidth+(k-1+footWidth)*FIGHT_OFFX-(ck-1)*FIGHT_COL_OFFX, self.solOffY+(ck-1)*FIGHT_ROW_OFFY})
                sp:setZord()
                sp:setDir()
                table.insert(temp, sp)
                table.insert(self.allSoldiers, sp)
                local sca = 1-(ck-1)*self.scaleCoff
                setScale(sp.bg, sca)
            else
                local sp = {dead=true, color=0, sid=-1, id=-1, initLeftRight=initSolLeftRight, map=self, col=colId, row=ck-1}
                table.insert(temp, sp)
                self.soldierNet[getMapKey(colId, ck-1)] = sp
            end
        end
        colId = colId+1
    end

    self.myCavalrySoldiers = {}
    self.eneCavalrySoldiers = {}
    local footWidth = #self.myArrowNum+#self.myMagicNum+#self.myFootNum
    --leftWidth 士兵所在的列 和 行 全局的 
    --先考虑 步兵 炮兵 弓箭 最后骑兵
    local colId = #self.myCavalryNum-1

    for k, v in ipairs(self.myCavalryNum) do 
        --row
        local temp = {}
        table.insert(self.myCavalrySoldiers, temp) 
        local lastOne = nil
        for ck, cv in ipairs(v) do 
            --col
            if cv > 0 then
                --弓箭手需要 自己所在部队的编号么 需要一个全局列编号
                local sp = FightSoldier2.new(self, 3, colId, ck-1, {level=cv, color=0}, self:getSolId()) 
                sp.low = lastOne
                if lastOne ~= nil then
                    lastOne.up = sp
                end
                lastOne = sp

                self.battleScene:addChild(sp.bg)
                setPos(sp.bg, {self.leftWidth-(k+footWidth-1)*FIGHT_OFFX+(ck-1)*FIGHT_COL_OFFX, self.solOffY+(ck-1)*FIGHT_ROW_OFFY})
                --setPos(sp.bg, {0, 0})
                sp:setZord()
                table.insert(temp, sp)
                table.insert(self.allSoldiers, sp)

                local sca = 1-(ck-1)*self.scaleCoff
                setScale(sp.bg, sca)
            else
                local sp = {dead=true, color=0, sid=-1, id=-1, initLeftRight=initSolLeftRight, map=self, col=colId, row=ck-1}
                table.insert(temp, sp)
                self.soldierNet[getMapKey(colId, ck-1)] = sp
            end
        end
        colId = colId-1
    end

    local footWidth = #self.eneFootNum+#self.eneMagicNum+#self.eneArrowNum
    --更新状态 检测 myArrow eneArrowSoldiers
    local colId = #self.myCavalryNum+#self.myArrowNum+#self.myMagicNum+#self.myFootNum+#self.eneFootNum+#self.eneMagicNum+#self.eneArrowNum
    for k, v in ipairs(self.eneCavalryNum) do
        local temp = {}
        table.insert(self.eneCavalrySoldiers, temp)
        local lastOne = nil
        for ck, cv in ipairs(v) do
            if cv > 0 then
                local sp = FightSoldier2.new(self, 3, colId, ck-1, {level=cv, color=1}, self:getSolId()) 
                sp.low = lastOne
                if lastOne ~= nil then
                    lastOne.up = sp
                end
                lastOne = sp

                self.battleScene:addChild(sp.bg)
                setPos(sp.bg, {self.WIDTH-self.rightWidth+(k-1+footWidth)*FIGHT_OFFX-(ck-1)*FIGHT_COL_OFFX, self.solOffY+(ck-1)*FIGHT_ROW_OFFY})
                sp:setZord()
                sp:setDir()
                table.insert(temp, sp)
                table.insert(self.allSoldiers, sp)
                local sca = 1-(ck-1)*self.scaleCoff
                setScale(sp.bg, sca)
            else
                local sp = {dead=true, color=0, sid=-1, id=-1, initLeftRight=initSolLeftRight, map=self, col=colId, row=ck-1}
                table.insert(temp, sp)
                self.soldierNet[getMapKey(colId, ck-1)] = sp
            end
        end
        colId = colId+1
    end

    --列  行
    --最后一列 对齐 敌方士兵 士兵
    --数据是第一排 第二排
    --还想知道 每种 士兵 所包含的列数 
    --如果直到了所有的这种士兵 其实 可以 计算出 包围盒子的
    --弓箭手直接 打第一排

    self:printNet()
    --初始化所有士兵 的 left right 属性
    for k, v in pairs(self.soldierNet) do
        v:initLeftRight()
    end
    self:printLeftRight()
end
function FightLayer2:printNet()
    print("soldier Net")
    for k, v in pairs(self.soldierNet) do
        local x, y = getXY(k)
        print("cr", x, y, v.sid)
    end
end
function FightLayer2:printLeftRight()
    print("left right")
    for k, v in pairs(self.soldierNet) do
    end
end

--根据 当前双方的 方向决定
function FightLayer2:getAttackDir(a, b)
    local k = a.sid*a.sid+b.sid*b.sid
    if self.cache[k] == nil then
        local ap = getPos(a.bg)
        local bp = getPos(b.bg)
        local mid = (ap[1]+bp[1])/2
        local bp = getPos(self.battleScene)
        local vs = getVS()
        local scMid = (-bp[1]-bp[1]+vs.width)/2
        if mid < scMid then
            self.cache[k] = 1
        elseif mid > scMid then
            self.cache[k] = -1
        else
            local rd = math.random(2)
            if rd == 1 then
                self.cache[k] = 1
            else
                self.cache[k] = -1
            end
        end
    end
    return self.cache[k]
end

require "Miao.FightLayer2Static"
