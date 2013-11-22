MsgModel = {}
MsgModel.msg = nil 
MsgModel.initYet = false
function MsgModel.initMsg()
    sendReq("getMessage", dict({{"uid", global.user.uid}}), MsgModel.initOver)
end
function MsgModel.initOver(rep, param)
    MsgModel.msg = rep
    Event:sendMsg(EVENT_TYPE.INIT_MSG)
end

Message = class()
function Message:ctor()
    self.bg = CCNode:create()
    setDesignXY(self.bg)
    setMidPos(self.bg)
    
    local temp = CCSprite:create("back.png")
    self.bg:addChild(temp)
    setAnchor(temp, {0, 0})
    local temp = addSprite(self.bg, "rightBack.png")
    setPos(setSize(temp, {754, 391}), {400, fixY(480, 66+391/2)})
    local temp = setPos(addSprite(self.bg, "map_label_small.png"), {400, fixY(480, 28)})
    local tit = ui.newTTFLabel({text="战报消息", size=18, color={0, 0, 0}})
    temp:addChild(tit)
    setPos(tit, {75, 22})

    --touchLayer 要在cl 下面
    self.touch = ui.newTouchLayer({size={600, 388}, delegate=self, touchBegan=self.touchBegan, touchMoved=self.touchMoved, touchEnded=self.touchEnded})
    self.bg:addChild(self.touch.bg)
    setPos(self.touch.bg, {50, 22})

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



    MyPlugins:getInstance():sendCmd("hideAds", "")

    
    --if MsgModel.msg == nil then
        --sendReq("getMessage", dict({{"uid", global.user.uid}}), self.initMessage, nil, self)
    --else
        self:initMessage(MsgModel.msg)
    --end
end

function Message:touchBegan(x, y)
    self.lastPoints = {x, y}
    self.accMove = 0
end
function Message:moveBack(dify)
    local ox, oy = self.flowNode:getPosition()
    self.flowNode:setPosition(ccp(ox, oy+dify))
end
function Message:touchMoved(x, y)
    local oldPoints = self.lastPoints
    self.lastPoints = {x, y}
    local dify = self.lastPoints[2]-oldPoints[2]
    self.accMove = self.accMove+math.abs(dify)
    self:moveBack(dify)
end
function Message:touchEnded(x, y)
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

function Message:initMessage(rep, param)
    if rep ~= nil then
        local totalCrystal = 0
        local totalSilver = 0
        local initYet = MsgModel.initYet
        MsgModel.initYet = true
        for k, v in ipairs(rep.res) do
            if not initYet then
                v.text = simple.decode(v.text)
            end

            local temp = CCSprite:create("scroll.png")
            setAnchor(temp, {0.5, 1})
            setPos(temp, {400, -self.flowHeight})
            self.flowNode:addChild(temp)
            self.flowHeight = self.flowHeight+72
            print("read", v.read)
            if v.read == 0 then
                totalCrystal = totalCrystal+v.text.crystal
                totalSilver = totalSilver+v.text.silver
                v.read = 1
            end

            if v.text.name == nil then
                v.text.name = "无名"
            end
            local lab = ui.newTTFLabel({text=k.." "..v.text.name.." 抢劫你: ", size=18, color={0, 0, 0}})
            temp:addChild(lab)
            setPos(setAnchor(lab, {0, 0.5}), {40, 33})

            local cry = CCSprite:create("crystal.png")
            temp:addChild(cry)
            setPos(cry, {197, 33})
            setSize(cry, {30, 30})
            
            local num = ui.newBMFontLabel({text=str(v.text.crystal), size=15, color={109, 194, 202}})
            temp:addChild(num)
            setAnchor(setPos(num, {217, 33}), {0, 0.5})

            local sil = CCSprite:create("silver.png")
            temp:addChild(sil)
            setSize(setPos(sil, {298, 33}), {30, 30})

            local num = ui.newBMFontLabel({text=str(v.text.silver), size=15, color={122, 123, 120}})
            temp:addChild(num)
            setAnchor(setPos(num, {319, 33}), {0, 0.5})
            
            local but = ui.newButton({image="blueButton.png", text="复仇", conSize={80, 33}, size=18, callback=self.onScroll, delegate=self, param=v.uid})
            temp:addChild(but.bg)
            but:setAnchor(0.5, 0.5)
            setPos(but.bg, {472, 33})

        end
        totalCrystal = math.floor(math.min(totalCrystal, global.user:getValue("crystal")/2))
        totalSilver = math.floor(math.min(totalSilver, global.user:getValue("silver")/2))

        if totalCrystal > 0 or totalSilver > 0 then
            local cost = {crystal=totalCrystal, silver=totalSilver}
            global.user:doCost(cost)
            sendReq("readMessage", dict({{"uid", global.user.uid}, {"cost", simple.encode(cost)}}))
        end
    end
end
function Message:onScroll(param)
    global.director:popView()
    BattleLogic.prepareState()
    --挑战自我功能
    BattleLogic.challengeWho = param
    global.director:pushView(Cloud.new(), 1, 0)
    sendReq("deleteMessage", dict({{"uid", param}, {"eid", global.user.uid}}))
end
function Message:onClose()
    global.director:popView()
end
