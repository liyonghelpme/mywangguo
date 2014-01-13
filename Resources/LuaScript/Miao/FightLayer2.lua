require "Miao.FightSoldier2"

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
    if n < 100 then
        num = math.max(math.floor(n/5), 1)
        pow = 5
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
    return temp
end

function FightLayer2:testNum()
    local temp = {{5, 0, 0, 0, 0}, {5, 0, 0, 0, 0}}
    return temp
end
function FightLayer2:ctor(s, my, ene)
    self.scene = s 
    local vs = getVS()
    print("FightLayer2")

    self.myFootNum = self:convertNumToSoldier(my[1])
    self.myFootNum = self:testNum()
    self.eneFootNum = self:convertNumToSoldier(ene[1])
    self.eneFootNum = self:testNum()
    local leftWidth = #self.myFootNum*FIGHT_OFFX
    self.leftWidth = math.max(leftWidth, vs.width*0.618)

    local rightWidth = #self.eneFootNum*FIGHT_OFFX
    self.rightWidth = rightWidth
    --单张战斗图调整为 self.HEIGHT
    --战斗场景高度不变 483 高度
    self.HEIGHT = FIGHT_HEIGHT
    self.bg = setPos(CCLayer:create(), {0, vs.height-self.HEIGHT})
    self.battleScene = CCNode:create()
    self.farScene = addNode(self.bg)
    self.bg:addChild(self.battleScene)
    self.nearScene = addNode(self.bg)

    --场景宽度受士兵的数量决定 1:1的士兵
    --刚开始 1: 0.618 
    --战斗高度不变 但是宽度可以自由增加
    --比屏幕宽一点这样就不能同时看到 左右两边的士兵了
    --一个屏幕的宽度差值
    self.WIDTH = vs.width*1.5+leftWidth+rightWidth
    print("width", self.WIDTH, vs.width, leftWidth, rightWidth)

    setContentSize(self.bg, {self.WIDTH, self.HEIGHT})
    local tex = CCTextureCache:sharedTextureCache():addImage("battle_mid.png")
    local tsz = tex:getContentSize()
    local tsca = self.HEIGHT/480
    self.oneWidth = tsca*tsz.width
    self.farRate = 0.2
    self.nearRate = 1.0

    local n = math.ceil(self.WIDTH/self.oneWidth)
    for i=1, n, 1 do
        local sp = setAnchor(setPos(setSize(CCSprite:create("battle_mid.png"), {self.oneWidth, self.HEIGHT}), {(i-1)*self.oneWidth, 0}), {0, 0})
        self.battleScene:addChild(sp)
        if (i-1)%2 == 1 then
            local scax = sp:getScaleX()
            setAnchor(setScaleX(sp, -scax), {1, 0})
        end
        local far = setAnchor(setPos(setScale(CCSprite:create("battle_far.png"), tsca), {(i-1)*self.oneWidth, 268}), {0, 0})
        self.farScene:addChild(far)

    end
    --nearScene 1.5 比例
    local nearN = math.ceil(self.WIDTH*1.5/self.oneWidth) 
    for i=1, nearN, 1 do
        local near = setAnchor(setPos(setScale(CCSprite:create("battle_near.png"), tsca), {(i-1)*self.oneWidth, 0}), {0, 0})
        self.nearScene:addChild(near)
    end

    self.smooth = 1
    self.solId = 0
    self.state = FIGHT_STATE.FREE
    self.curCol = 0
    self.cache = {}

    self:initPic()
    self:initSoldier()

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
        self.moveSpeed = 300
        --使用ease 函数调整move 状态
        local vs = getVS()
        local endPoint = self.WIDTH-vs.width
        self.endPoint = endPoint
        self.totalTime = endPoint/self.moveSpeed
        self.battleScene:runAction(sinein(moveto(self.totalTime, -endPoint, 0)))
    end
end
--测试不同数量的士兵的战斗效果
function FightLayer2:doMove(diff)
    if self.state == FIGHT_STATE.MOVE then
        local pos = getPos(self.battleScene)
        --根据battleScene 位置 调整farScene 位置
        local fp = getPos(self.farScene)
        local farPos = {pos[1]*self.farRate, fp[2]}
        setPos(self.farScene, farPos)

        local np = getPos(self.nearScene)
        local nearPos = {pos[1]*self.nearRate, np[2]}
        setPos(self.nearScene, nearPos)

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
            self.battleScene:runAction(sequence({delaytime(1), sinein(moveto(self.totalTime, -self.leftWidth+100, 0)), callfunc(nil, showOver)}))
        end
    end
end
function FightLayer2:doFastBack(diff)
    if self.state == FIGHT_STATE.FAST_BACK then
        local pos = getPos(self.battleScene)
        --根据battleScene 位置 调整farScene 位置
        local fp = getPos(self.farScene)
        local farPos = {pos[1]*self.farRate, fp[2]}
        setPos(self.farScene, farPos)

        local np = getPos(self.nearScene)
        local nearPos = {pos[1]*self.nearRate, np[2]}
        setPos(self.nearScene, nearPos)
        if self.finShow then
            self.state = FIGHT_STATE.DAY
            self.day = 0
            self.passTime = 0

        end
        --[[
        local pos = getPos(self.bg)
        local mx = 200*diff
        pos[1] = math.min(pos[1]+mx, 0)
        setPos(self.bg, pos)
        if pos[1] == 0 then
            self.state = FIGHT_STATE.WAIT 
            self.passTime = 0
        end
        --]]
    end
end
--士兵开始跑步 战斗 交给士兵控制
function FightLayer2:doDay(diff)
    if self.state == FIGHT_STATE.DAY then
        local p = getPos(self.battleScene)
        if self.passTime == 0 then
            self.moveTarget = p[1]
            for k, v in ipairs(self.allSoldiers) do
                --开始跑步和攻击
                v:doRunAndAttack()
            end
        end
        self.passTime = self.passTime+diff
        if self.passTime >= 5 and not self.finishAttack then
            self.finishAttack = true
            for k, v in ipairs(self.allSoldiers) do
                --开始跑步和攻击
                v:finishAttack()
            end
        end

        local mySolP = self.mySoldiers[1][1]
        local sp = getPos(mySolP.bg)
        local vs = getVS()
        --看一下4对象的位置
        if sp[1] >= math.abs(p[1])+vs.width/2 then
            self.moveTarget = -(sp[1])+vs.width/2
            print("moveTarget", self.moveTarget)
        end

        if self.moveTarget ~= nil then
            local pos = getPos(self.battleScene)
            local smooth = diff*self.smooth
            smooth = math.min(smooth, 1)
            local px = pos[1]*(1-smooth)+self.moveTarget*smooth
            setPos(self.battleScene, {px, pos[2]}) 
            local fxy = getPos(self.farScene)
            setPos(self.farScene, {px*self.farRate, fxy[2]})
            local nxy = getPos(self.nearScene)
            setPos(self.nearScene, {px*self.nearRate, nxy[2]})
        end
    end
end

function FightLayer2:update(diff)
    self:doFree(diff)
    self:doMove(diff)
    self:doFastBack(diff)
    self:doDay(diff)
end

function FightLayer2:initPic()
    local sf = CCSpriteFrameCache:sharedSpriteFrameCache()
    sf:addSpriteFramesWithFile("cat_foot.plist")
    sf:addSpriteFramesWithFile("attackAni.plist")
    createAnimation("attackSpe1", "attack%d.png", 5, 8, 1, 0.5, true)
    createAnimationWithNum("attackSpe2", "attack%d.png", 0.5, true, {1, 3, 4})

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
            s = s..tv.sid..' '
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
    self.mySoldiers = {}
    self.allSoldiers = {}
    self.solOffY = 80
    --每一列 每一行
    for k, v in ipairs(self.myFootNum) do
        local temp = {}
        table.insert(self.mySoldiers, temp)
        for ck, cv in ipairs(v) do
            if cv > 0 then
                local sp = FightSoldier2.new(self, 0, k-1, ck-1, {level=cv, color=0}, self:getSolId()) 
                self.battleScene:addChild(sp.bg)
                setPos(sp.bg, {self.leftWidth-(k-1)*FIGHT_OFFX+(ck-1)*FIGHT_COL_OFFX, self.solOffY+(ck-1)*FIGHT_ROW_OFFY})
                --setPos(sp.bg, {0, 0})
                sp:setZord()
                table.insert(temp, sp)
                table.insert(self.allSoldiers, sp)
            end
        end
    end
    --列  行
    --最后一列 对齐 敌方士兵 士兵
    --数据是第一排 第二排
    --还想知道 每种 士兵 所包含的列数 
    --如果直到了所有的这种士兵 其实 可以 计算出 包围盒子的
    self:printSoldier(self.mySoldiers)
    for k, v in ipairs(self.mySoldiers) do
        for tk, tv in ipairs(v) do
            if self.mySoldiers[k-1] ~= nil then
                tv.right = self.mySoldiers[k-1][tk] 
            end
            if self.mySoldiers[k+1] ~= nil then
                tv.left = self.mySoldiers[k+1][tk]
            end
        end
    end

    self.eneSoldiers = {}
    for k, v in ipairs(self.eneFootNum) do
        local temp = {}
        table.insert(self.eneSoldiers, temp)
        for ck, cv in ipairs(v) do
            if cv > 0 then
                local sp = FightSoldier2.new(self, 0, k-1, ck-1, {level=cv, color=1}, self:getSolId()) 
                self.battleScene:addChild(sp.bg)
                setPos(sp.bg, {self.WIDTH-self.rightWidth+(k-1)*FIGHT_OFFX-(ck-1)*FIGHT_COL_OFFX, self.solOffY+(ck-1)*FIGHT_ROW_OFFY})
                sp:setZord()
                sp:setDir()
                table.insert(temp, sp)
                table.insert(self.allSoldiers, sp)
            end
        end
    end
    self:printSoldier(self.eneSoldiers)
    for k, v in ipairs(self.eneSoldiers) do
        for tk, tv in ipairs(v) do
            if self.eneSoldiers[k-1] ~= nil then
                tv.left = self.eneSoldiers[k-1][tk]
            end
            if self.eneSoldiers[k+1] ~= nil then
                tv.right = self.eneSoldiers[k+1][tk]
            end
            print("set left right", tk, tv.sid, tv.left, tv.right)
        end
    end

    for tk, tv in ipairs(self.mySoldiers[1]) do
        tv.right = self.eneSoldiers[1][tk]
    end
    for tk, tv in ipairs(self.eneSoldiers[1]) do
        tv.left = self.mySoldiers[1][tk]
    end
    --士兵死亡动态调整 左右两侧
end

function FightLayer2:getAttackDir(a, b)
    local k = a.sid*a.sid+b.sid*b.sid
    if self.cache[k] == nil then
        local ap = getPos(a.bg)
        local bp = getPos(b.bg)
        --谁满血就向那边移动
        if a.health > b.health then
            self.cache[k] =  Sign(bp[1]-ap[1])
        elseif a.health < b.health then
            self.cache[k] = Sign(ap[1]-bp[1])
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
