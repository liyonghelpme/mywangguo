Rank = class()
function Rank:ctor()
    self.bg = CCNode:create()
    setDesignXY(self.bg)
    setMidPos(self.bg)
    
    local temp = CCSprite:create("back.png")
    self.bg:addChild(temp)
    setAnchor(temp, {0, 0})
    local temp = addSprite(self.bg, "rightBack.png")
    setPos(setSize(temp, {754, 391}), {400, fixY(480, 66+391/2)})
    local temp = setPos(addSprite(self.bg, "map_label_small.png"), {400, fixY(480, 28)})
    local tit = ui.newTTFLabel({text="英雄榜", size=18, color={0, 0, 0}})
    temp:addChild(tit)
    setPos(tit, {75, 22})

    local cl = Scissor:create()
    self.bg:addChild(cl)
    setPos(cl, {0, fixY(480, 458)})
    local vs = getVS()
    --scissor 需要转化到世界坐标高度
    self.HEIGHT = fixY(480, 68)-fixY(480, 458)
    print("panel Height", self.HEIGHT)
    local sca = self.bg:getScale()
    setContentSize(cl, {vs.width, self.HEIGHT*sca})
    self.cl = cl
    
    local flowNode = addNode(self.cl)
    self.flowNode = flowNode
    self.flowHeight = 0
    setPos(flowNode, {0, self.HEIGHT})

    local close = ui.newButton({image="closeBut.png", delegate=self, callback=self.onClose})
    self.bg:addChild(close.bg)
    close:setAnchor(0.5, 0.5)
    setPos(close.bg, {763, fixY(480, 30)})


    self.touch = ui.newTouchLayer({size={700, 388}, delegate=self, touchBegan=self.touchBegan, touchMoved=self.touchMoved, touchEnded=self.touchEnded})
    self.bg:addChild(self.touch.bg)
    setPos(self.touch.bg, {50, 22})

    MyPlugins:getInstance():sendCmd("hideAds", "")
    sendReq("getRank", dict({{"uid", global.user.uid}}), self.initRank, nil, self)
end

function Rank:touchBegan(x, y)
    self.lastPoints = {x, y}
    self.accMove = 0
end
function Rank:moveBack(dify)
    local ox, oy = self.flowNode:getPosition()
    self.flowNode:setPosition(ccp(ox, oy+dify))
end
function Rank:touchMoved(x, y)
    local oldPoints = self.lastPoints
    self.lastPoints = {x, y}
    local dify = self.lastPoints[2]-oldPoints[2]
    self.accMove = self.accMove+math.abs(dify)
    self:moveBack(dify)
end
function Rank:touchEnded(x, y)
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

function Rank:initRank(rep, param)
    if rep ~= nil then
        for k, v in ipairs(rep.res) do
            --local temp = ui.newButton({image="scroll.png", callback=self.onScroll, delegate=self, param=0})
            local temp = CCSprite:create("scroll.png")
            setAnchor(temp, {0.5, 1})
            setPos(temp, {400, -self.flowHeight})
            self.flowNode:addChild(temp)
            self.flowHeight = self.flowHeight+72

            if v.name == nil then
                v.name = "无名"
            end
            local lab = ui.newTTFLabel({text=k.." "..v.name.." 得分: "..v.score, size=18, color={0, 0, 0}})
            temp:addChild(lab)
            setPos(setAnchor(lab, {0, 0.5}), {40, 33})
            
            local but = ui.newButton({image="blueButton.png", text="挑战", conSize={80, 33}, size=18, callback=self.onScroll, delegate=self, param=v.uid})
            temp:addChild(but.bg)
            but:setAnchor(0.5, 0.5)
            setPos(but.bg, {472, 33})

        end
    end
end
function Rank:onScroll(param)
    global.director:popView()
    BattleLogic.prepareState()
    --挑战自我功能
    BattleLogic.challengeWho = param
    global.director:pushView(Cloud.new(), 1, 0)
end
function Rank:onClose()
    global.director:popView()
end
