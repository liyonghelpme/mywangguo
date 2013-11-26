require "Miao.FightSoldier"
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
}
FightLayer = class()
function FightLayer:ctor(s)
    self.scene = s 
    self.bg = setPos(CCLayer:create(), {0, fixY(480, 333)})
    
    self.battleScene = CCNode:create()
    self.bg:addChild(self.battleScene)

    self.WIDTH = 800
    setContentSize(self.bg, {self.WIDTH, 480})
    local n = math.ceil(self.WIDTH/700)
    for i=1, n, 1 do
        local sp = setAnchor(setPos(setSize(CCSprite:create("battle_bg5.jpg"), {700, 525}), {(i-1)*700, 0}), {0, 0})
        self.battleScene:addChild(sp)

        if (i-1)%2 == 1 then
            local scax = sp:getScaleX()
            setAnchor(setScaleX(sp, -scax), {1, 0})
        end
    end

    --self.soldierLayer = CCNode:create()
    --self.bg:addChild(self.soldierLayer)

    self.columns = {}
    
    local initX = 48
    local initY = 300-266
    local offX = 20
    local offY = 40
    local col = {}
    table.insert(self.columns, col)
    for i=0, 4, 1 do
        local sp = FightSoldier.new(self, 473, 1, i+1)
        sp:setDir(1)
        setPos(sp.bg, {initX+offX*i, initY+offY*i})
        addChild(self.battleScene, sp.bg)
        table.insert(col, sp)
    end

    local col = {}
    table.insert(self.columns, col)
    local initX = 48+80
    for i=0, 4, 1 do
        local sp = FightSoldier.new(self, 23, 2, i+1)
        sp:setDir(1)
        setPos(sp.bg, {initX+offX*i, initY+offY*i})
        addChild(self.battleScene, sp.bg)
        table.insert(col, sp)
    end

    local col = {}
    table.insert(self.columns, col)
    local initX = 48+80+80
    for i=0, 4, 1 do
        local sp = FightSoldier.new(self, 583, 3, i+1)
        sp:setDir(1)
        setPos(sp.bg, {initX+offX*i, initY+offY*i})
        addChild(self.battleScene, sp.bg)
        table.insert(col, sp)
    end

    local col = {}
    table.insert(self.columns, col)
    local initX = 48+80+80+80
    for i=0, 4, 1 do
        local sp = FightSoldier.new(self, 3, 4, i+1)
        sp:setDir(1)
        setPos(sp.bg, {initX+offX*i, initY+offY*i})
        addChild(self.battleScene, sp.bg)
        table.insert(col, sp)
    end

    local col = {}
    table.insert(self.columns, col)
    local initX = 525 
    for i=0, 4, 1 do
        local sp = FightSoldier.new(self, 3, 5, i+1)
        sp:setDir(-1)
        setPos(sp.bg, {initX-offX*i, initY+offY*i})
        addChild(self.battleScene, sp.bg)
        table.insert(col, sp)
    end

    local col = {}
    table.insert(self.columns, col)
    local initX = 525+80 
    for i=0, 4, 1 do
        local sp = FightSoldier.new(self, 583)
        sp:setDir(-1)
        setPos(sp.bg, {initX-offX*i, initY+offY*i})
        addChild(self.battleScene, sp.bg)
        table.insert(col, sp)
    end

    local col = {}
    table.insert(self.columns, col)
    local initX = 525+80+80
    for i=0, 4, 1 do
        local sp = FightSoldier.new(self, 23)
        sp:setDir(-1)
        setPos(sp.bg, {initX-offX*i, initY+offY*i})
        addChild(self.battleScene, sp.bg)
        table.insert(col, sp)
    end

    local col = {}
    table.insert(self.columns, col)
    local initX = 525+80+80+80
    for i=0, 4, 1 do
        local sp = FightSoldier.new(self, 473, 8, i+1)
        sp:setDir(-1)
        setPos(sp.bg, {initX-offX*i, initY+offY*i})
        addChild(self.battleScene, sp.bg)
        table.insert(col, sp)
    end

    for k, v in ipairs(self.columns) do
        for tk, tv in ipairs(v) do
            tv:setZord()
        end
    end

    --self.touchDelegate = StandardTouchHandler.new()
    --self.touchDelegate.bg = self.bg

    registerEnterOrExit(self)
    registerMultiTouch(self)
    self.state = FIGHT_STATE.FREE

    local vs = getVS()

    self.leftRender = CCRenderTexture:create(400, 480, 0)
    self.bg:addChild(self.leftRender)
    self.leftRender:setVisible(false)
    self.rightRender = CCRenderTexture:create(400, 480, 0)
    self.bg:addChild(self.rightRender)
    self.rightRender:setVisible(false)
    setPos(self.rightRender, {vs.width*3/4, 240})

    self.sceneBox = display.newScale9Sprite("sceneBox.png")
    self.bg:addChild(self.sceneBox)
    setAnchor(setPos(setContentSize(self.sceneBox, {vs.width/2, vs.height-fixY(480, 333)}), {0, 0}), {0, 0})
    self.sceneBox:setVisible(false)
end
function FightLayer:enterScene()
    registerUpdate(self)
end

function FightLayer:renderScene()
    self.leftRender:setVisible(false)
    self.leftRender:beginWithClear(0, 0, 0, 1)
    setPos(self.battleScene, {0, 0})
    self.battleScene:visit()
    self.sceneBox:setVisible(true)
    self.sceneBox:visit()
    self.sceneBox:setVisible(false)
    self.leftRender:endToLua()
    self.leftRender:setVisible(true)
    setPos(self.leftRender, {200, 240})
    --self.state = FIGHT_STATE.WAIT
    --self.waitTime = 5

    --vs.width 
    self.rightRender:beginWithClear(0, 0, 0, 1)
    setPos(self.battleScene, {-self.WIDTH/2, 0})
    self.battleScene:visit()
    self.sceneBox:setVisible(true)
    self.sceneBox:visit()
    self.sceneBox:setVisible(false)
    self.rightRender:endToLua()
    self.rightRender:setVisible(true)
end
function FightLayer:update(diff)
    if self.state == FIGHT_STATE.FREE then
        self.state = FIGHT_STATE.MOVE
        --self.bg:runAction(moveto(5, ))
        self.passTime = 0
        self.curCol = 1
    end
    if self.state == FIGHT_STATE.MOVE then
        self.passTime = self.passTime+diff
        if self.passTime >= 0.1 then
            self.passTime = 0
            if self.curCol <= #self.columns then
                for k, v in ipairs(self.columns[self.curCol]) do
                    v:showPose()
                end
                self.curCol = self.curCol+1
            else
                self.state = FIGHT_STATE.FINISH_MOVE 
                self.round = 0
            end
        end
    end
    if self.state == FIGHT_STATE.FINISH_MOVE then
        local numToW = {
        [0]="一",
        [1]="二",
        [2]="三",
        }
        addBanner(numToW[self.round].."本目")
        self.waitTime = 2
        self.state = FIGHT_STATE.WAIT 
    end
    if self.state == FIGHT_STATE.WAIT then
        self.waitTime = self.waitTime-diff
        if self.waitTime <= 0 then
            --if self.round == 0 then
                self.state = FIGHT_STATE.GUN
                self.attYet = false
                self.passTime = 0
            --end
        end
    end
    --每一帧都这样绘制
    if self.state == FIGHT_STATE.GUN then
        if not self.attYet then
            self.attYet = true
            for k, v in ipairs(self.columns[3]) do
                v:doAttack()
            end
            for k, v in ipairs(self.columns[6]) do
                v:doAttack()
            end
        end
        self:renderScene()
        self.passTime = self.passTime+diff
        if self.passTime >= 5 then
            self.state = FIGHT_STATE.ARROW
            self.passTime = 0
            self.attYet = false
        end
    end
    if self.state == FIGHT_STATE.ARROW then
        if not self.attYet then
            self.attYet = true
            for k, v in ipairs(self.columns[2]) do
                v:doAttack()
            end
            for k, v in ipairs(self.columns[7]) do
                v:doAttack()
            end
        end
        self:renderScene()

        self.passTime = self.passTime+diff
        if self.passTime > 4 then
            self.state = FIGHT_STATE.INFANTRY
            self.passTime = 0
            self.attYet = false
        end
    end
    if self.state == FIGHT_STATE.INFANTRY then
        if not self.attYet then
            self.attYet = true
            for k, v in ipairs(self.columns[4]) do
                v:doAttack()
            end
            for k, v in ipairs(self.columns[5]) do
                v:doAttack()
            end
        end
        self:renderScene()
        self.passTime = self.passTime+diff
        if self.passTime > 4 then
            self.state = FIGHT_STATE.CAVALRY
            self.passTime = 0
            self.attYet = false
        end
    end
    if self.state == FIGHT_STATE.CAVALRY then
        if not self.attYet then
            self.attYet = true
            for k, v in ipairs(self.columns[1]) do
                v:doAttack()
            end
            for k, v in ipairs(self.columns[8]) do
                v:doAttack()
            end
        end
        self:renderScene()
        --5 1 5
        self.passTime = self.passTime+diff
        if self.passTime > 11.5 then
            --self.round = self.round+1
            self.round = 3
            if self.round >= 3 then
                self.state = FIGHT_STATE.FIGHT_OVER 
            else
                self.state = FIGHT_STATE.FINISH_MOVE
            end
        end
    end
    --部队撤退
    if self.state == FIGHT_STATE.FIGHT_OVER then
        addBanner("平局")
        for k, v in ipairs(self.columns) do
            for tk, tv in ipairs(v) do
                tv:doBack()
            end
        end
        self:renderScene()
        self.state = FIGHT_STATE.FIGHT_OVER2
        self.passTime = 0
    end
    if self.state == FIGHT_STATE.FIGHT_OVER2 then
        self:renderScene()
        self.passTime = self.passTime+diff
        if self.passTime >= 5 then
            global.director:popScene()
        end
    end
end


function FightLayer:touchesBegan(touches)
    --self.touchDelegate:tBegan(touches)
end

function FightLayer:touchesMoved(touches)
    --self.touchDelegate:tMoved(touches)
end
function FightLayer:touchesEnded(touches)
    --self.touchDelegate:tEnded(touches)
end

