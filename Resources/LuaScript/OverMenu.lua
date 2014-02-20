OverMenu = class()
function OverMenu:ctor(s)
    self.scene = s

    local u = CCUserDefault:sharedUserDefault()
    local r = u:getStringForKey("bestScore")
    local bestScore = self.scene.score
    if r ~= "" then
        local temp = simple.decode(r)
        bestScore = math.max(bestScore, temp)
    end
    u:setStringForKey("bestScore", simple.encode(bestScore)) 
    

    local vs = getVS()
    self.bg = CCNode:create()
    local sz = {width=768, height=1024}
    self.temp = setPos(addNode(self.bg), {0, fixY(sz.height, 0+sz.height)+0})
    
    local butNode = addNode(self.temp)
    setVisible(butNode, false)

    local but = ui.newButton({image="start.png", text="", font="f1", size=18, delegate=self, param=1, callback=self.onBut, shadowColor={0, 0, 0}, color={255, 255, 255}})
    but:setContentSize(276, 106)
    setPos(addChild(butNode, but.bg), {219, fixY(sz.height, 725)})
    local but = ui.newButton({image="ranking.png", text="", font="f1", size=18, delegate=self, param=2, callback=self.onBut, shadowColor={0, 0, 0}, color={255, 255, 255}})
    but:setContentSize(276, 106)
    setPos(addChild(butNode, but.bg), {550, fixY(sz.height, 725)})
    local function showBut()
        self.showYet = true
        setVisible(butNode, true)
    end
    butNode:runAction(sequence({delaytime(1), callfunc(nil, showBut)}))

    local midBoard = addNode(self.temp)
    setVisible(midBoard, false)
    local sp = setOpacity(setAnchor(setSize(setPos(addSprite(midBoard, "over.png"), {384, fixY(sz.height, 443)}), {621, 350}), {0.50, 0.50}), 255)
    local sp = setOpacity(setAnchor(setSize(setPos(addSprite(midBoard, "1.png"), {555, fixY(sz.height, 539)}), {89, 68}), {0.50, 0.50}), 255)
    local n = genNum(bestScore)
    removeSelf(sp)
    addChild(midBoard, n)
    setPos(n, {575-n.width/2, fixY(sz.height, 539)})

    local sp = setOpacity(setAnchor(setSize(setPos(addSprite(midBoard, "2.png"), {575, fixY(sz.height, 398)}), {45, 64}), {0.50, 0.50}), 255)
    self.score = sp
    local n = genNum(self.scene.score)
    removeSelf(sp)
    self.score = n
    addChild(midBoard, self.score)
    setPos(self.score, {575-self.score.width/2, fixY(sz.height, 398)})

    local sp = setOpacity(setAnchor(setSize(setPos(addSprite(midBoard, "silverMedal.png"), {231, fixY(sz.height, 459)}), {151, 152}), {0.50, 0.50}), 255)
    self.medal = sp
    
    setPos(midBoard, {0, -300})
    midBoard:runAction(sequence({delaytime(0.5), appear(midBoard), moveto(0.5, 0, 0)}))

    local sp = setOpacity(setAnchor(setSize(setPos(addSprite(self.temp, "gameOver.png"), {387, fixY(sz.height, 169)}), {545, 105}), {0.50, 0.50}), 255)
    sp:runAction(jumpBy(0.4, 0, 0, 30, 1))
    
    self:adjustUI()
    centerNode(self.temp)


    --[[
    local bottom = addNode(self.bg)
    local sca = vs.width/sz.width
    local sp = setScale(setOpacity(setAnchor(setPos(addSprite(bottom, "intro.png"), {vs.width/2, 0}), {0.50, 0.0}), 255), sca)

    self.touch = ui.newTouchLayer({size={vs.width, 100*self.scene.scale}, touchBegan=self.touchBegan, touchMoved=self.touchMoved, touchEnded=self.touchEnded, delegate=self})
    bottom:addChild(self.touch.bg)

    local butNode = addNode(self.bg)
    local but = ui.newButton({image="free.png", text="", font="f1", size=18, delegate=self, callback=self.onBut, param=3, shadowColor={0, 0, 0}, color={255, 255, 255}})
    but:setContentSize(123, 47)
    setPos(addChild(butNode, but.bg), {657, fixY(sz.height, 992)})
    rightBottomUI(butNode)
    --]]
end

--下载游戏
function OverMenu:touchBegan()
    CCNative:openURL(NOZOMI_URL)
    MyPlugins:getInstance():sendCmd("logUrl", '')
end
function OverMenu:touchMoved()
end
function OverMenu:touchEnded()
end

function OverMenu:adjustUI()
    if self.scene.score >= 50 then
        setTexture(self.medal, "goldMedal.png")
    elseif self.scene.score >= 20 then
        setTexture(self.medal, "silverMedal.png")
    elseif self.scene.score >= 10 then
        setTexture(self.medal, "copper.png")
    else
        setVisible(self.medal, false)
    end
end

function OverMenu:onBut(p) 
    if p == 1 then
        if self.showYet then
            global.director:popView()
            --removeSelf(self.scene.bird.bg)
            self.scene:resetScene()
            self.scene:startGame()
        end
    elseif p == 2 then
    elseif p == 3 then
        CCNative:openURL(NOZOMI_URL)
        MyPlugins:getInstance():sendCmd("logUrl", '')
    end
end
