require "Battle.BattleRole"
require "Battle.BattleData"
require "Battle.BattleAlertDialog"

BattleGround = class()

function BattleGround:ctor()
    self.left = {}
    self.right = {}
end

function BattleGround:createActionSprite(dir, data)
    local sprite = CCSprite:create("action/" .. dir .. "/" .. dir .. "_0.png")
    sprite:runAction(CCRepeatForever:create(CCAnimate:create(createAnimation(dir, "action/" .. dir .. "/" .. dir .. "_%d.png", 0, data.num-1, 1, data.time))))
    return sprite
end

function BattleGround:loadScene(data)
    if self.view then
        self.view:setTexture(CCTextureCache:sharedTextureCache():addImage("background/" .. data.background))
        local tag=100
        while true do
            local cd = self.view:getChildByTag(tag)
            if not cd then
                break
            else
                cd:removeFromParentAndCleanup(true)
                tag = tag+1
            end
        end
    else
        self.view = CCSprite:create("background/" .. data.background)
    end
    
    for i=1, #data.childs do
        local child = data.childs[i]
        if child.type=="object" then
            temp = CCSprite:create("object/" .. child.file)
            temp:setUserObject(CCString:create("object:" .. child.file))
        else
            temp = self:createActionSprite(child.dir, actionDatas[child.dir])
            temp:setUserObject(CCString:create("action:" .. child.dir))
        end
        temp:setScaleX(child.sx)
        temp:setScaleY(child.sy)
        temp:setAnchorPoint(CCPointMake(0.5,0.5))
        temp:setPosition(child.px, child.py)
        temp:setRotation(child.r)
        self.view:addChild(temp, child.z, 100+i)
    end
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
    BattleRand.setSeed(self.seed or os.time())
    
    local function update(diff)
        self:update(diff)
    end
    
    self.updateEntry = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(update, 0, false)
end

function BattleGround:update(diff)
    if self.pause then return end
    self.logicTime = self.logicTime+diff
    while not self.battleEnd and self.logicTime>TICK and self.actionTime<self.logicTime+TICK do
        self.logicTime = self.logicTime - TICK
        local executableRole = nil
        local delay = self.delayTick
        if self.delayTick==0 then self.delayTick=1 end
        local leftnum, rightnum = 0, 0
        self.totalDelay = self.totalDelay + delay
        self.roundLabel:setString("Left Round:" .. (MAX_DELAY-self.totalDelay))
        local lefthp, righthp = 0, 0
        for i=1, #(self.queue) do
            if not self.queue[i].dead then
                if self.queue[i]:updateDelay(delay) then
                    if not executableRole then
                        executableRole = self.queue[i]
                    end
                end
                if self.queue[i].isLeft then
                    leftnum = leftnum+1
                    lefthp = lefthp+self.queue[i].hp
                else
                    rightnum = rightnum+1
                    righthp = righthp+self.queue[i].hp
                end
            end
        end
        self.leftblood:setTextureRect(CCRectMake(0,0,math.ceil(self.bloodSize.width*lefthp/self.lefthpMax), self.bloodSize.height))
        self.rightblood:setTextureRect(CCRectMake(0,0,math.ceil(self.bloodSize.width*righthp/self.righthpMax), self.bloodSize.height))
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
    if not self.bg then
        self.bg = CCNode:create()
        self.sceneId=1
        self:loadScene(sceneDatas[self.sceneId])
        self.view:setScale(screenSize.width/self.view:getContentSize().width)
        self.view:setAnchorPoint(CCPointMake(0.5, 0.5))
        self.view:setPosition(screenSize.width/2, screenSize.height/2)
        self.bg:addChild(self.view, 0)
        self.roleBg = CCNode:create()
        self.view:addChild(self.roleBg, 1)
        self:initMenu()
        self.changeLayer = CCLayerColor:create(ccc4(255,255,255,0),screenSize.width, screenSize.height)
        self.bg:addChild(self.changeLayer, 2)
    else
        self:loadScene(sceneDatas[self.sceneId])
    end
    self.lefthpMax = 0
    self.righthpMax = 0
    for i=1, ROW_MAX*COL_MAX do
        if self.left[i] and not self.left[i].dead then
            self.left[i]:initView(self.roleBg, true)
            self.lefthpMax = self.lefthpMax + self.left[i].hpMax
        end
        if self.right[i] then
            self.right[i]:initView(self.roleBg, false)
            self.righthpMax = self.righthpMax + self.right[i].hpMax
        end
    end
    return self.bg
end

function BattleGround:nextBattle()
    local function initNextBattle()
        
        local normal = SkillModel.new(100, DamageType.Physic, DamageArea.Single, DamageSelector.FirstCol, 0, 0, 0, 0)
        local skill = SkillModel.new(150, DamageType.Physic, DamageArea.Row, DamageSelector.FirstCol, 0, 0, 0, 0)
        for i=1, 3 do
            local role2 = BattleRole.new(60, 20, 20, 200, math.random(20,40), false, 1,normal, skill)
            self:setRole(false, (i-1)%3+1, math.ceil(i/3), role2)
            if self.left[i] then
                self.left[i]:initBattle((i-1)%3+1, math.ceil(i/3), self.left, self.right)
                self.left[i].view:stopAllActions()
                if self.left[i].dead then
                    self.left[i] = nil
                end
            end
        end
        for i=4, 6 do
            local role2 = BattleRole.new(60, 20, 20, 200, math.random(20,40), true, 1,Skills.getSkill(math.random(2,4)), Skills.getSkill(math.random(6,8)))
            self:setRole(false, (i-1)%3+1, math.ceil(i/3), role2)
            if self.left[i] then
                self.left[i]:initBattle((i-1)%3+1, math.ceil(i/3), self.left, self.right)
                self.left[i].view:stopAllActions()
                if self.left[i].dead then
                    self.left[i] = nil
                end
            end
        end
        self:initView()
        self:prepareBattle()
        self.actionTime = 1
        self.changeLayer:runAction(CCFadeOut:create(1.5))
    end
    self.changeLayer:setTouchEnabled(false)
    for i=1, ROW_MAX*COL_MAX do
        if self.left[i] and not self.left[i].dead then
            self.left[i]:runZou()
        end
    end
    local array = CCArray:create()
    array:addObject(CCDelayTime:create(1))
    array:addObject(CCFadeIn:create(1.5))
    array:addObject(CCCallFunc:create(initNextBattle))
    self.changeLayer:runAction(CCSequence:create(array))
end

function BattleGround:showWinner(isWin)
    if isWin then
        if self.sceneId<3 then
            self.sceneId = self.sceneId+1
            for i=1, #(self.queue) do
                local role = self.queue[i]
                if role.isLeft then
                    self.left[(role.col-1)*ROW_MAX+role.row] = role
                    role:clearBattle()
                else
                    role.view:removeFromParentAndCleanup(true)
                end
            end
            local bt = ui.newButton({image="buttonNextBattle.png", callback=self.nextBattle, delegate=self})
            self.view:addChild(bt.bg, 1, 100)
            bt:setAnchor(0.5, 0.5)
            bt.bg:setPosition(755, 289)
            local selected = nil
            local function selectRole(event, x, y)
                if event=="ended" then
                    local sl = nil
                    local pt = self.roleBg:convertToNodeSpace(CCPointMake(x, y))
                    for j=ROW_MAX, 1, -1 do
                        for i=1, COL_MAX do
                            local index = (i-1)*ROW_MAX+j
                            if self.left[index] then
                                local view = self.left[index].view
                                local px,py = view:getPosition()
                                if px-55<pt.x and px+55>pt.x and py-10<pt.y and py+100>pt.y then
                                    sl = self.left[index]
                                    break
                                end
                            end
                        end
                        if sl then break end
                    end
                    if sl.dead then
                        local alert = BattleAlertDialog.new("是否要复活该角色？", "是", "否", self.reviveCallback, self, sl)
                        global.director:pushView(alert, 1, false, 0, 1)
                        return
                    end
                    if selected then
                        if sl and sl~=selected then
                            local x1, y1 = sl.view:getPosition()
                            
                            sl.view:retain()
                            sl.view:removeFromParentAndCleanup(false)
                            self.roleBg:addChild(sl.view, selected.row*COL_MAX-selected.col)
                            sl.view:release()
                            sl.view:setPosition(selected.view:getPosition())
                            
                            selected.view:retain()
                            selected.view:removeFromParentAndCleanup(false)
                            self.roleBg:addChild(selected.view, sl.row*COL_MAX-sl.col)
                            selected.view:release()
                            selected.view:setPosition(x1, y1)
                            
                            sl.row, sl.col, selected.row, selected.col = selected.row, selected.col, sl.row, sl.col
                        end
                        selected.view:removeChildByTag(2, true)
                        selected = nil
                    else
                        if sl then
                            selected = sl
                            local circle = CCSprite:create("roleSelect0.png")
                            circle:runAction(CCRepeatForever:create(CCAnimate:create(createAnimation("roleCircle", "roleSelect%d.png", 0, 2, 1, 0.3))))
                            circle:setAnchorPoint(CCPointMake(0.5, 0.5))
                            local size = sl.view:getContentSize()
                            local anchor = sl.view:getAnchorPoint()
                            circle:setPosition(size.width*anchor.x, size.height*anchor.y)
                            sl.view:addChild(circle, -1, 2)
                        end
                    end
                elseif event=="began" then
                    return true
                end
            end
            self.changeLayer:registerScriptTouchHandler(selectRole, false, 0, true)
            self.changeLayer:setTouchEnabled(true)
            --[[
        for i=1, ROW_MAX*COL_MAX do
            if self.left[i] then
                self.left[i]:runZou()
            end
        end
        --]]
        end
    else
    --[[
        self.sceneId = (self.sceneId+1)%3+1
        for i=1, ROW_MAX*COL_MAX do
            if self.right[i] then
                self.right[i]:runZou()
            end
        end
        --]]
    end
    if self.updateEntry then
        CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.updateEntry)
        self.updateEntry = nil
    end
end

function BattleGround:initTest()
    local normal = SkillModel.new(100, DamageType.Physic, DamageArea.Single, DamageSelector.FirstCol, 0, 0, 0, 0)
    local skill = SkillModel.new(150, DamageType.Physic, DamageArea.Row, DamageSelector.FirstCol, 0, 0, 0, 0)
    for i=1, 3 do
        local role1 = BattleRole.new(60, 20, 20, 200, math.random(20,40), false, 1,normal, skill)
        self:setRole(true, (i-1)%3+1, math.ceil(i/3), role1)
        local role2 = BattleRole.new(60, 10, 10, 160, math.random(20,40), false, 1,normal, skill)
        self:setRole(false, (i-1)%3+1, math.ceil(i/3), role2)
    end
    for i=4, 6 do
        local role1 = BattleRole.new(60, 20, 20, 200, math.random(20,40), true, 1,Skills.getSkill(math.random(2,4)), Skills.getSkill(math.random(6,8)))
        self:setRole(true, (i-1)%3+1, math.ceil(i/3), role1)
        local role2 = BattleRole.new(60, 10, 10, 160, math.random(20,40), true, 1,Skills.getSkill(math.random(2,4)), Skills.getSkill(math.random(6,8)))
        self:setRole(false, (i-1)%3+1, math.ceil(i/3), role2)
    end
end

function BattleGround:loadBattle(data)
    if type(data)=="string" then
        data=json.decode(data)
    end
    self.seed = data.seed
    self.left = {}
    self.right = {}
    local rdata
    for i=1, ROW_MAX*COL_MAX do
        rdata = data.left[i]
        if rdata then
            self:setRole(true, (i-1)%ROW_MAX+1, math.ceil(i/ROW_MAX), BattleRole.new(rdata[1], rdata[2], rdata[3], rdata[4], rdata[5], rdata[6], Skills.getSkill(rdata[7]), Skills.getSkill(rdata[8])))
        end
        rdata = data.right[i]
        if rdata then
            self:setRole(true, (i-1)%ROW_MAX+1, math.ceil(i/ROW_MAX), BattleRole.new(rdata[1], rdata[2], rdata[3], rdata[4], rdata[5], rdata[6], Skills.getSkill(rdata[7]), Skills.getSkill(rdata[8])))
        end
    end
end

function BattleGround:initMenu()
    local screenSize = CCDirector:sharedDirector():getVisibleSize()
    local s1, s2 = screenSize.width/1024, screenSize.height/768
    if s1<s2 then
        s1, s2 = s2, s1
    end
    local temp = nil
    temp = CCSprite:create("battleRoleBack.png")
    temp:setAnchorPoint(CCPointMake(0.5, 1))
    temp:setPosition(screenSize.width/2, screenSize.height-19)
    temp:setScale(s1)
    self.bg:addChild(temp)
    local top = temp
    temp = ui.newTTFLabel({text="UsernameRight", size=25})
    temp:setAnchorPoint(CCPointMake(1, 0.5))
    temp:setPosition(880,19)
    top:addChild(temp)
    temp = ui.newTTFLabel({text="UsernameLeft", size=25})
    temp:setAnchorPoint(CCPointMake(0, 0.5))
    temp:setPosition(102,19)
    top:addChild(temp)
    temp = CCSprite:create("roleHead1.png")
    temp:setAnchorPoint(CCPointMake(0,0))
    temp:setPosition(892, 16)
    temp:setFlipX(true)
    top:addChild(temp)
    temp = CCSprite:create("roleHead1.png")
    temp:setAnchorPoint(CCPointMake(0,0))
    temp:setPosition(7, 16)
    top:addChild(temp)
    temp = CCSprite:create("totalBloodFiller.png")
    temp:setAnchorPoint(CCPointMake(1,0))
    temp:setPosition(107, 71)
    temp:setScaleX(-1.3)
    top:addChild(temp)
    self.leftblood = temp
    temp = CCSprite:create("totalBloodFiller.png")
    temp:setAnchorPoint(CCPointMake(1,0))
    temp:setPosition(876, 71)
    temp:setScaleX(1.3)
    top:addChild(temp)
    self.rightblood = temp
    self.bloodSize = temp:getContentSize()
    temp = ui.newTTFLabel({text="21", size=25})
    temp:setAnchorPoint(CCPointMake(0, 0.5))
    temp:setPosition(926, 19)
    top:addChild(temp)
    temp = ui.newTTFLabel({text="21", size=22})
    temp:setAnchorPoint(CCPointMake(0, 0.5))
    temp:setPosition(38, 19)
    top:addChild(temp)
    temp = ui.newTTFLabel({text="Lv", size=25, color=ccc3(166,92,20)})
    temp:setAnchorPoint(CCPointMake(0, 0.5))
    temp:setPosition(899, 19)
    top:addChild(temp)
    temp = ui.newTTFLabel({text="Lv", size=25, color=ccc3(166,92,20)})
    temp:setAnchorPoint(CCPointMake(0, 0.5))
    temp:setPosition(11, 19)
    top:addChild(temp)
    temp = ui.newTTFLabel({text="Left Rounds: 23", size=25, color=ccc3(166,92,20)})
    temp:setAnchorPoint(CCPointMake(0.5, 0.5))
    temp:setPosition(492, 0)
    top:addChild(temp)
    self.roundLabel = temp
    temp = ui.newButton({image="buttonAcc1.png", callback=self.changeAcc, delegate=self})
    temp:setAnchor(0.5, 0.5)
    temp.bg:setPosition(screenSize.width-80, 57)
    temp.bg:setScale(s1)
    self.bg:addChild(temp.bg)
    self.accButton = temp.bg
    self.speed = 1
    temp = ui.newButton({image="buttonEnd.png", callback=self.endBattle, delegate=self})
    temp:setAnchor(0.5, 0.5)
    temp.bg:setPosition(83, 57)
    temp.bg:setScale(s1)
    self.bg:addChild(temp.bg)
end

function BattleGround:reviveCallback(param)
    if param.index==1 then
        local sl = param.param
        sl.view:removeFromParentAndCleanup(true)
        sl.view = nil
        sl:initView(self.roleBg, sl.isLeft, true)
        sl.dead = false
        local sprite = CCSprite:create("action/revive/00000.png")
        sprite:runAction(CCSequence:createWithTwoActions(CCAnimate:create(createAnimation("revive", "action/revive/%05d.png", 0,7,1, 0.8)), CCCallFuncN:create(removeSelf)))
        sl.view:addChild(sprite, 0, 2)
        sprite:setAnchorPoint(CCPointMake(0.5, 0.157))
        local size = sl.view:getContentSize()
        local anchor = sl.view:getAnchorPoint()
        sprite:setPosition(size.width*anchor.x, size.height*anchor.y)
    end
    global.director:popView()
end

function BattleGround:endBattleCallback(param)
    if param.index==1 then
        --do ok
        global.director:popScene()
    else
        --do cancel
        global.director:popView()
        self.pause = false
    end
end

function BattleGround:endBattle()
    self.pause = true
    local alert = BattleAlertDialog.new("是否要结束战斗？", "是", "否", self.endBattleCallback, self)
    global.director:pushView(alert, 1, false, 0, 1)
end

function BattleGround:changeAcc()
    local screenSize = CCDirector:sharedDirector():getVisibleSize()
    local s1, s2 = screenSize.width/1024, screenSize.height/768
    if s1<s2 then
        s1, s2 = s2, s1
    end
    self.speed = 3-self.speed
    CCDirector:sharedDirector():getScheduler():setTimeScale(self.speed)
    self.accButton:removeFromParentAndCleanup(true)
    local temp = ui.newButton({image="buttonAcc" .. self.speed .. ".png", callback=self.changeAcc, delegate=self})
    temp:setAnchor(0.5, 0.5)
    temp.bg:setPosition(screenSize.width-80, 57)
    temp.bg:setScale(s1)
    self.bg:addChild(temp.bg)
    self.accButton = temp.bg
end
