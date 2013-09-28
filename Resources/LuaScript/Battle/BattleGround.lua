require "Battle.BattleRole"

BattleGround = class()

function BattleGround:ctor()
    self.left = {}
    self.right = {}
end

function BattleGround:setRole(isLeft, row, col, role)
    if isLeft then
        self.left[(col-1)*ROW_MAX+row] = role
        role:initBattle(row, col, self.left, self.right)
    else
        self.right[(col-1)*ROW_MAX+row] = role
        role:initBattle(row, col, self.right, self.left)
    end
end

function BattleGround:prepareBattle()
    self.queue = {}
    for i=1, ROW_MAX*COL_MAX do
        if self.left[i] then
            table.insert(self.queue, self.left[i])
        end
        if self.right[i] then
            table.insert(self.queue, self.right[i])
        end
    end
    self.totalDelay = 0
    self.actionTime = 0
    self.logicTime = 0
    self.delayTick = 1
    self.battleEnd = false
    BattleRand.setSeed(os.time())
    
    local function update(diff)
        self:update(diff)
    end
    
    self.updateEntry = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(update, 0, false)
end

function BattleGround:update(diff)
    self.logicTime = self.logicTime+diff
    while not self.battleEnd and self.logicTime>TICK and self.actionTime<self.logicTime+TICK do
        self.logicTime = self.logicTime - TICK
        local executableRole = nil
        local delay = self.delayTick
        if self.delayTick==0 then self.delayTick=1 end
        local leftnum, rightnum = 0, 0
        self.totalDelay = self.totalDelay + delay
        for i=1, #(self.queue) do
            if not self.queue[i].dead then
                if self.queue[i]:updateDelay(delay) then
                    if not executableRole then
                        executableRole = self.queue[i]
                    end
                end
                if self.queue[i].isLeft then
                    leftnum = leftnum+1
                else
                    rightnum = rightnum+1
                end
            end
        end
        if leftnum==0 or rightnum==0 then
            self.battleEnd = true
            self:showWinner(leftnum>rightnum)
        elseif self.totalDelay>=MAX_DELAY then
            self.battleEnd = true
            self:showWinner(false)
        elseif executableRole then
            self.delayTick = 0
            self.actionTime = executableRole:executeTurn()
        end
    end
    if self.actionTime>0 then
        self.actionTime = self.actionTime-self.logicTime
        if self.actionTime<0 then
            self.logicTime = -self.actionTime
            self.actionTime = 0
        else
            self.logicTime = 0
        end
    end
end

--生成战斗场景并返回
function BattleGround:initView()
    local screenSize = CCDirector:sharedDirector():getVisibleSize()
    if not self.view then
        self.sceneId=1
        self.view = CCSprite:create("background1.png")
        self.view:setScale(screenSize.width/1024)
        self.view:setAnchorPoint(CCPointMake(0.5, 0))
        self.view:setPosition(screenSize.width/2, 0)
    else
        self.view:setTexture(CCTextureCache:sharedTextureCache():addImage(string.format("background%d.png", self.sceneId)))
    end
    for i=1, ROW_MAX*COL_MAX do
        if self.left[i] then
            self.left[i]:initView(self.view, true)
        end
        if self.right[i] then
            self.right[i]:initView(self.view, false)
        end
    end
    return self.view
end

function BattleGround:showWinner(isWin)
    local function nextBattle()
        for i=1, ROW_MAX*COL_MAX do
            if self.left[i] then
                self.left[i]:destroy()
                self.left[i] = nil
            end
            if self.right[i] then
                self.right[i]:destroy()
                self.right[i] = nil
            end
        end
        self:initTest()
        self:initView()
    end
    local function nextBattle2(node)
        removeSelf(node)
        self:prepareBattle()
    end
    local size = self.view:getContentSize()
    local changeLayer = CCLayerColor:create(ccc4(255,255,255,0),size.width, size.height)
    self.view:addChild(changeLayer, 1)
    local array = CCArray:create()
    array:addObject(CCDelayTime:create(1))
    array:addObject(CCFadeIn:create(1.5))
    array:addObject(CCCallFunc:create(nextBattle))
    array:addObject(CCDelayTime:create(0.5))
    array:addObject(CCFadeOut:create(0.75))
    array:addObject(CCCallFuncN:create(nextBattle2))
    changeLayer:runAction(CCSequence:create(array))
    if isWin then
        self.sceneId = self.sceneId%3+1
        for i=1, ROW_MAX*COL_MAX do
            if self.left[i] then
                self.left[i]:runZou()
            end
        end
    else
        self.sceneId = (self.sceneId+1)%3+1
        for i=1, ROW_MAX*COL_MAX do
            if self.right[i] then
                self.right[i]:runZou()
            end
        end
    end
    if self.updateEntry then
        CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.updateEntry)
        self.updateEntry = nil
    end
end

function BattleGround:initTest()
    local normal = SkillModel.new(100, DamageType.Physic, DamageArea.Single, DamageSelector.FirstCol, 0, 0, 0, 0)
    local skill = SkillModel.new(150, DamageType.Physic, DamageArea.Row, DamageSelector.FirstCol, 0, 0, 0, 0)
    for i=1, 6 do
        local role1 = BattleRole.new(60, 20, 20, 200, math.random(20,40), false, normal, skill)
        self:setRole(true, (i-1)%3+1, math.ceil(i/3), role1)
        local role2 = BattleRole.new(60, 20, 20, 200, math.random(20,40), false, normal, skill)
        self:setRole(false, (i-1)%3+1, math.ceil(i/3), role2)
    end
end
