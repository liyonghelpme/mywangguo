BirdMenu = class()
function BirdMenu:ctor(s)
    self.scene = s
    local vs = getVS()
    self.bg = CCNode:create()
    local sz = {width=768, height=1024}
    self.temp = setPos(addNode(self.bg), {0, fixY(sz.height, 0+sz.height)+0})
    local sp = setOpacity(setAnchor(setSize(setPos(addSprite(self.temp, "logo.png"), {387, fixY(sz.height, 180)}), {433, 244}), {0.50, 0.50}), 255)
    local but = ui.newButton({image="start.png", text="", font="f1", size=18, delegate=self, callback=self.onBut, param=0, shadowColor={0, 0, 0}, color={255, 255, 255}})
    but:setContentSize(276, 106)
    setPos(addChild(self.temp, but.bg), {383, fixY(sz.height, 508)})
    local but = ui.newButton({image="ranking.png", text="", font="f1", size=18, delegate=self, callback=self.onBut, param=1, shadowColor={0, 0, 0}, color={255, 255, 255}})
    but:setContentSize(276, 106)
    setPos(addChild(self.temp, but.bg), {383, fixY(sz.height, 637)})
    local but = ui.newButton({image="rate.png", text="", font="f1", size=18, delegate=self, callback=self.onBut, param=2, shadowColor={0, 0, 0}, color={255, 255, 255}})
    but:setContentSize(276, 106)
    setPos(addChild(self.temp, but.bg), {383, fixY(sz.height, 765)})

    local bottom = addNode(self.bg)
    local sca = vs.width/sz.width
    local sp = setScale(setOpacity(setAnchor(setPos(addSprite(bottom, "intro.png"), {vs.width/2, 0}), {0.50, 0.0}), 255), sca)

    local butNode = addNode(self.bg)
    local but = ui.newButton({image="free.png", text="", font="f1", size=18, delegate=self, callback=self.onBut, param=3, shadowColor={0, 0, 0}, color={255, 255, 255}})
    but:setContentSize(123, 47)
    setPos(addChild(butNode, but.bg), {657, fixY(sz.height, 992)})
    rightBottomUI(butNode)

    centerNode(self.temp)
end
function BirdMenu:onBut(p)
    --start Game
    if p == 0 then
        global.director:popView()
        --self.scene.state = SCENE_STATE.FREE
        self.scene:startGame()
    elseif p == 1 then
    elseif p == 2 then
    elseif p == 3 then
        CCNative:openURL("https://play.google.com/store/apps/details?id=com.caesars.nozomi&hl=en")
    end
end
