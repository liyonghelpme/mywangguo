require "Miao.FightInfo"
BigInfo = class()
function BigInfo:ctor(s)
    self.scene = s
    self.bg = CCNode:create()
    local temp = display.newScale9Sprite("tabback.jpg")
    self.bg:addChild(temp)
    local vs = getVS()
    setContentSize(setPos(temp, {vs.width/2, vs.height/2}), {500, 330})

    local tit = setPos(addSprite(temp, "title.png"), {250, fixY(330, 30)})
    setPos(addChild(temp, ui.newTTFLabel({text="今川家", size=15, color={10, 10, 10}})), {250, fixY(330, 33)})

    local but = ui.newButton({image="arrow_left.png", callback=self.onLeft, delegate=self})
    setPos(but.bg, {37, fixY(330, 36)})
    temp:addChild(but.bg)

    local but = ui.newButton({image="arrow_right.png", callback=self.onRight, delegate=self})
    setPos(but.bg, {466, fixY(330, 36)})
    temp:addChild(but.bg)
    
    local h1 = setPos(addSprite(temp, "business_trader_1.png"), {76, fixY(330, 127)})
    local w1 = setAnchor(setPos(addChild(temp, ui.newBMFontLabel({text="196", font="bound.fnt", size=15, color={210, 125, 44}})), {125, fixY(330, 185)}), {1, 0.5})

    local h1 = setPos(addSprite(temp, "business_trader_2.png"), {196, fixY(330, 127)})
    local w1 = setAnchor(setPos(addChild(temp, ui.newBMFontLabel({text="393", font="bound.fnt",size=15, color={210, 125, 44}})), {238, fixY(330, 185)}), {1, 0.5})

    local h1 = setPos(addSprite(temp, "business_trader_3.png"), {307, fixY(330, 127)})
    local w1 = setAnchor(setPos(addChild(temp, ui.newBMFontLabel({text="65", font="bound.fnt",size=15, color={210, 125, 44}})), {344, fixY(330, 185)}), {1, 0.5})

    local h1 = setPos(addSprite(temp, "business_trader_4.png"), {414, fixY(330, 127)})
    local w1 = setAnchor(setPos(addChild(temp, ui.newBMFontLabel({text="65", font="bound.fnt",size=15, color={210, 125, 44}})), {451, fixY(330, 185)}), {1, 0.5})


    local ban = setContentSize(setPos(addChild(temp, display.newScale9Sprite("input.png")), {250, fixY(330, 229)}), {400, 32})
    local w2 = setAnchor(addChild(temp, setPos(ui.newTTFLabel({text="店铺", size=15, color={10, 10, 10}}), {67, fixY(330, 229)})), {0, 0.5})
    local ban = setContentSize(setPos(addChild(temp, display.newScale9Sprite("input.png")), {250, fixY(330, 262)}), {400, 32})
    local w2 = setAnchor(addChild(temp, setPos(ui.newTTFLabel({text="财宝", size=15, color={10, 10, 10}}), {67, fixY(330, 262)})), {0, 0.5})

    local but = ui.newButton({image="tabbut.png", text="攻略建议", size=15, color={10, 10, 10}, callback=self.onGo, delegate=self})
    setPos(addChild(temp, but.bg), {250, fixY(330, 309)})
end
function BigInfo:onLeft()
end
function BigInfo:onRight()
end
function BigInfo:onGo()
    local fi = FightInfo.new(self.scene)
    global.director:popView()
    global.director:pushView(fi)
end
