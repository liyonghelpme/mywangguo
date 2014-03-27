BigMenu = class()
function BigMenu:ctor(s)
    self.scene = s
    local vs = getVS()
    self.bg = CCNode:create()
    local temp = display.newScale9Sprite("bottom2.png")
    self.bg:addChild(temp)
    setAnchor(setPos(temp, {0, fixY(480, 431)}), {0, 0})
    setContentSize(temp, {vs.width, 50})
    local temp1 = temp

    local w = ui.newTTFLabel({text="步卒", size=14, color={8, 20, 176}})
    temp1:addChild(w)
    setAnchor(setPos(w, {19, 25}), {0, 0.5})

    local w = ui.newBMFontLabel({text="481", size=12, font="bound.fnt", color={10, 10, 10}})
    temp1:addChild(w)
    setAnchor(setPos(w, {77, 25}), {1, 0.5})

    local banner = setSize(CCSprite:create("probg.png"), {100, 19})
    local pro = display.newScale9Sprite("pro.png")
    banner:addChild(pro)
    setAnchor(setPos(pro, {27, fixY(76, 40)}), {0, 0.5})
    setAnchor(setPos(banner, {82, 25}), {0, 0.5})
    temp1:addChild(banner)

    local w = ui.newTTFLabel({text="弓箭", size=14, color={8, 20, 176}})
    temp1:addChild(w)
    setAnchor(setPos(w, {196, 25}), {0, 0.5})

    local w = ui.newBMFontLabel({text="161", size=12, font="bound.fnt", color={10, 10, 10}})
    temp1:addChild(w)
    setAnchor(setPos(w, {254, 25}), {1, 0.5})

    local banner = setSize(CCSprite:create("probg.png"), {100, 19})
    local pro = display.newScale9Sprite("pro.png")
    banner:addChild(pro)
    setAnchor(setPos(pro, {27, fixY(76, 40)}), {0, 0.5})
    setAnchor(setPos(banner, {250, 25}), {0, 0.5})
    temp1:addChild(banner)

    local w = ui.newTTFLabel({text="铁统", size=14, color={8, 20, 176}})
    temp1:addChild(w)
    setAnchor(setPos(w, {364, 25}), {0, 0.5})

    local w = ui.newBMFontLabel({text="80", size=12, font="bound.fnt", color={10, 10, 10}})
    temp1:addChild(w)
    setAnchor(setPos(w, {412, 25}), {1, 0.5})

    local banner = setSize(CCSprite:create("probg.png"), {100, 19})
    local pro = display.newScale9Sprite("pro.png")
    banner:addChild(pro)
    setAnchor(setPos(pro, {27, fixY(76, 40)}), {0, 0.5})
    setAnchor(setPos(banner, {420, 25}), {0, 0.5})
    temp1:addChild(banner)

    local w = ui.newTTFLabel({text="骑兵", size=14, color={8, 20, 176}})
    temp1:addChild(w)
    setAnchor(setPos(w, {530, 25}), {0, 0.5})

    local w = ui.newBMFontLabel({text="80", size=12, font="bound.fnt", color={10, 10, 10}})
    temp1:addChild(w)
    setAnchor(setPos(w, {591, 25}), {1, 0.5})

    local banner = setSize(CCSprite:create("probg.png"), {100, 19})
    local pro = display.newScale9Sprite("pro.png")
    banner:addChild(pro)
    setAnchor(setPos(pro, {27, fixY(76, 40)}), {0, 0.5})
    setAnchor(setPos(banner, {598, 25}), {0, 0.5})
    temp1:addChild(banner)
    
    local temp = display.newScale9Sprite("bottom2.png")
    self.bg:addChild(temp)
    setAnchor(setPos(temp, {0, fixY(480, 379)}), {0, 0})
    setContentSize(temp, {vs.width, 50})
    local temp2 = temp

    local head = CCSprite:create("business_trader_1.png")
    temp2:addChild(head)
    setPos(setSize(head, {60, 60}), {46, 25})
    

    local but = ui.newButton({image="tabbut.png", text="返回", size=15, color={10, 10, 10}, callback=self.onBack, delegate=self})
    setScriptTouchPriority(but.bg, -256)
    self.bg:addChild(but.bg)
    setPos(but.bg, {140, fixY(480, 453)})

    self.menu = nil
end
--延迟到下一frame执行
function BigMenu:onBack()
    if self.menu ~= nil then
        global.director:popView()
        local temp = self.menu
        self.menu = nil
        if temp.onClose ~= nil then
            temp:onClose()
        end
    else
        global.director:popScene()
    end
end
