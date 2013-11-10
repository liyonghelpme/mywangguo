BigMap = class()
function BigMap:ctor()
    self.bg = CCNode:create()
    setDesignXY(self.bg)
    setMidPos(self.bg)
    
    local temp = CCSprite:create("back.png")
    self.bg:addChild(temp)
    setAnchor(temp, {0, 0})
    local temp = addSprite(self.bg, "rightBack.png")
    setPos(setSize(temp, {754, 391}), {400, fixY(480, 66+391/2)})
    local temp = setPos(addSprite(self.bg, "map_label.png"), {400, fixY(480, 28)})
    
    local flowNode = addNode(self.bg)
    self.flowNode = flowNode
    local temp = ui.newButton({image="scroll.png", callback=self.onScroll, delegate=self, param=0})
    temp:setAnchor(0.5, 0.5)
    setPos(temp.bg, {400, fixY(480, 123)})
    flowNode:addChild(temp.bg)

    local lab = ui.newTTFLabel({text="0 挑战自我", size=18, color={0, 0, 0}})
    temp.bg:addChild(lab)
    setPos(setAnchor(lab, {0, 0.5}), {40-541/2, 0})

    local close = ui.newButton({image="closeBut.png", delegate=self, callback=self.onClose})
    self.bg:addChild(close.bg)
    close:setAnchor(0.5, 0.5)
    setPos(close.bg, {763, fixY(480, 30)})
    MyPlugins:getInstance():sendCmd("hideAds", "")

    local levelBack = display.newScale9Sprite("infoBack.png")
    self.bg:addChild(levelBack)
    levelBack:setContentSize(CCSizeMake(742, 292))
    setPos(levelBack, {400, fixY(480, 300)})

    self:initLevel()
end

function BigMap:touchBegan(x, y)
    self.lastPoints = {x, y}
    self.accMove = 0
end
function BigMap:moveBack(dify)
    local ox, oy = self.flowNode:getPosition()
    self.flowNode:setPosition(ccp(ox, oy+dify))
end
function BigMap:touchMoved(x, y)
    local oldPoints = self.lastPoints
    self.lastPoints = {x, y}
    local dify = self.lastPoints[2]-oldPoints[2]
    self.accMove = self.accMove+math.abs(dify)
    self:moveBack(dify)
end
function BigMap:touchEnded(x, y)
    local oldPos = getPos(self.flowNode)

    local ty = oldPos[2]-self.HEIGHT
    local maxPos = 0
    if self.flowHeight > self.HEIGHT then
        maxPos = self.flowHeight-self.HEIGHT
    end
    ty = math.max(0, math.min(ty, maxPos))
    oldPos[2] = ty+self.HEIGHT
    self.flowNode:setPosition(ccp(oldPos[1], oldPos[2]))
end
function BigMap:initLevel()
    self.HEIGHT = fixY(480, 153)-30
    self.touch = ui.newTouchLayer({size={700, 299}, delegate=self, touchBegan=self.touchBegan, touchMoved=self.touchMoved, touchEnded=self.touchEnded})
    self.bg:addChild(self.touch.bg)
    setPos(self.touch.bg, {50, 22})

    local cl = Scissor:create()
    self.bg:addChild(cl)
    setPos(cl, {0, 30})
    local vs = getVS()
    print("panel Height", self.HEIGHT)
    local sca = self.bg:getScale()
    setContentSize(cl, {vs.width, self.HEIGHT*sca})
    self.cl = cl
    
    local flowNode = addNode(self.cl)
    self.flowNode = flowNode
    self.flowHeight = 0
    setPos(flowNode, {0, self.HEIGHT})

    

    local levels = BattleLogic.levels
    if levels == nil then
        local wp = "gameLevel.json"
        local fcon = getFileData(wp)
        levels = simple.decode(fcon)
        BattleLogic.levels = levels
    end
    local level = CCUserDefault:sharedUserDefault():getIntegerForKey("level")
    for k, v in ipairs(levels) do
        --显示附近的几个关卡
        if k > level-6 then
            --只显示当前用户没有闯关的关卡
            if k >= level+2 then
                break
            end
            local temp = CCSprite:create("scroll.png")
            setAnchor(temp, {0.5, 1})
            setPos(temp, {400, -self.flowHeight})
            self.flowNode:addChild(temp)
            self.flowHeight = self.flowHeight+72

            local levelName = BattleLogic.levelData[k].name
            if levelName == nil then
                levelName = "未知关卡"
            end
            local crystal = BattleLogic.levelData[k].crystal or 1000
            local silver = BattleLogic.levelData[k].crystal or 1000

            local lab = ui.newTTFLabel({text=k.." "..levelName, size=18, color={0, 0, 0}})
            temp:addChild(lab)
            setPos(setAnchor(lab, {0, 0.5}), {40, 33})
            
            local cry = CCSprite:create("crystal.png")
            temp:addChild(cry)
            setPos(cry, {197, 33})
            setSize(cry, {30, 30})
            
            local num = ui.newBMFontLabel({text=str(crystal), size=15, color={109, 194, 202}})
            temp:addChild(num)
            setAnchor(setPos(num, {217, 33}), {0, 0.5})

            local sil = CCSprite:create("silver.png")
            temp:addChild(sil)
            setSize(setPos(sil, {298, 33}), {30, 30})

            local num = ui.newBMFontLabel({text=str(silver), size=15, color={122, 123, 120}})
            temp:addChild(num)
            setAnchor(setPos(num, {319, 33}), {0, 0.5})

            local cl = {0, 0, 0}
            if k == level+1 then
                cl = {102, 0, 0}
            end
            local but = ui.newButton({image="blueButton.png", text="挑战", conSize={80, 33}, size=18, callback=self.onLevel, delegate=self, param=k})
            setColor(but.text, cl)
            temp:addChild(but.bg)
            but:setAnchor(0.5, 0.5)
            setPos(but.bg, {472, 33})
        end
    end

    local temp = CCSprite:create("scroll.png")
    setAnchor(temp, {0.5, 1})
    setPos(temp, {400, -self.flowHeight})
    self.flowNode:addChild(temp)
    self.flowHeight = self.flowHeight+72

    local lab = ui.newTTFLabel({text="???", size=18, color={0, 0, 0}})
    temp:addChild(lab)
    setPos(setAnchor(lab, {0, 0.5}), {40, 33})
end
function BigMap:onLevel(k)
    global.director:popView()
    BattleLogic.prepareState()
    --挑战自我功能
    BattleLogic.challengeLevel = true
    BattleLogic.challengeWho = k
    global.director:pushView(Cloud.new(), 1, 0)
end

function BigMap:onScroll()
    global.director:popView()
    BattleLogic.prepareState()
    --挑战自我功能
    BattleLogic.challengeWho = global.user.uid
    global.director:pushView(Cloud.new(), 1, 0)
end
function BigMap:onClose()
    global.director:popView()
end
