FightMenu = class()
function FightMenu:ctor()
    self.bg = CCNode:create()
    local vs = getVS()
    local temp = setAnchor(setContentSize(addChild(self.bg, display.newScale9Sprite("tabback.jpg")), {vs.width, 150}), {0, 0})
    
    ----------------------
    local w = setPos(addChild(temp, ui.newTTFLabel({text="步卒", size=15, color={84,44,20}})), {vs.width/2, fixY(480, 361)})

    local banner = setSize(CCSprite:create("probg.png"), {100, 19})
    local pro = display.newScale9Sprite("pro.png")
    banner:addChild(pro)
    setAnchor(setPos(pro, {27, fixY(76, 40)}), {0, 0.5})
    setAnchor(setPos(addChild(temp, banner), {vs.width/2-40, fixY(480, 361)}), {1, 0.5})

    local banner = setSize(CCSprite:create("probg.png"), {100, 19})
    local pro = display.newScale9Sprite("pro.png")
    banner:addChild(pro)
    setAnchor(setPos(pro, {27, fixY(76, 40)}), {0, 0.5})
    setAnchor(setPos(addChild(temp, banner), {440, fixY(480, 361)}), {0, 0.5})

    local num = setAnchor(setPos(addChild(self.bg, ui.newBMFontLabel({text="1003", size=15, color={0, 0, 0}, font="fonts.fnt"})), {vs.width/2-fixX(400, 214), fixY(480, 361)}), {1, 0.5})
    local head = setSize(setAnchor(setPos(addSprite(temp, "king2.png"), {vs.width/2-fixX(400, 161), fixY(480, 361)}), {0.5, 0.5}), {30, 23})

    local num = setAnchor(setPos(addChild(self.bg, ui.newBMFontLabel({text="196", size=15, color={0, 0, 0}, font="fonts.fnt"})), {540, fixY(480, 361)}), {0, 0.5})
    local head = setAnchor(setPos(addSprite(temp, "king2.png"), {586, fixY(480, 361)}), {0.5, 0.5})
    setSize(head, {30, 23})

    ----------------------
    local w = setPos(addChild(temp, ui.newTTFLabel({text="弓队", size=15, color={84,44,20}})), {vs.width/2, fixY(480, 385)})

    local banner = setSize(CCSprite:create("probg.png"), {100, 19})
    local pro = display.newScale9Sprite("pro.png")
    banner:addChild(pro)
    setAnchor(setPos(pro, {27, fixY(76, 40)}), {0, 0.5})
    setAnchor(setPos(addChild(temp, banner), {vs.width/2-40, fixY(480, 385)}), {1, 0.5})

    local banner = setSize(CCSprite:create("probg.png"), {100, 19})
    local pro = display.newScale9Sprite("pro.png")
    banner:addChild(pro)
    setAnchor(setPos(pro, {27, fixY(76, 40)}), {0, 0.5})
    setAnchor(setPos(addChild(temp, banner), {440, fixY(480, 385)}), {0, 0.5})

    local num = setAnchor(setPos(addChild(self.bg, ui.newBMFontLabel({text="680", size=15, color={0, 0, 0}, font="fonts.fnt"})), {vs.width/2-fixX(400, 214), fixY(480, 385)}), {1, 0.5})
    local head = setAnchor(setPos(addSprite(temp, "king2.png"), {vs.width/2-fixX(400, 161), fixY(480, 385)}), {0.5, 0.5})
    setSize(head, {30, 23})

    local num = setAnchor(setPos(addChild(self.bg, ui.newBMFontLabel({text="393", size=15, color={0, 0, 0}, font="fonts.fnt"})), {540, fixY(480, 385)}), {0, 0.5})
    local head = setAnchor(setPos(addSprite(temp, "king2.png"), {586, fixY(480, 385)}), {0.5, 0.5})
    setSize(head, {30, 23})

    ----------------------
    local w = setPos(addChild(temp, ui.newTTFLabel({text="铁统", size=15, color={84,44,20}})), {vs.width/2, fixY(480, 411)})

    local banner = setSize(CCSprite:create("probg.png"), {100, 19})
    local pro = display.newScale9Sprite("pro.png")
    banner:addChild(pro)
    setAnchor(setPos(pro, {27, fixY(76, 40)}), {0, 0.5})
    setAnchor(setPos(addChild(temp, banner), {vs.width/2-40, fixY(480, 411)}), {1, 0.5})

    local banner = setSize(CCSprite:create("probg.png"), {100, 19})
    local pro = display.newScale9Sprite("pro.png")
    banner:addChild(pro)
    setAnchor(setPos(pro, {27, fixY(76, 40)}), {0, 0.5})
    setAnchor(setPos(addChild(temp, banner), {440, fixY(480, 411)}), {0, 0.5})

    local num = setAnchor(setPos(addChild(self.bg, ui.newBMFontLabel({text="61", size=15, color={0, 0, 0}, font="fonts.fnt"})), {vs.width/2-fixX(400, 214), fixY(480, 411)}), {1, 0.5})
    local head = setAnchor(setPos(addSprite(temp, "king2.png"), {vs.width/2-fixX(400, 161), fixY(480, 411)}), {0.5, 0.5})
    setSize(head, {30, 23})

    local num = setAnchor(setPos(addChild(self.bg, ui.newBMFontLabel({text="196", size=15, color={0, 0, 0}, font="fonts.fnt"})), {540, fixY(480, 411)}), {0, 0.5})
    local head = setAnchor(setPos(addSprite(temp, "king2.png"), {586, fixY(480, 411)}), {0.5, 0.5})
    setSize(head, {30, 23})
    
    ----------------------
    local w = setPos(addChild(temp, ui.newTTFLabel({text="铁骑", size=15, color={84,44,20}})), {vs.width/2, fixY(480, 437)})

    local banner = setSize(CCSprite:create("probg.png"), {100, 19})
    local pro = display.newScale9Sprite("pro.png")
    banner:addChild(pro)
    setAnchor(setPos(pro, {27, fixY(76, 40)}), {0, 0.5})
    setAnchor(setPos(addChild(temp, banner), {vs.width/2-40, fixY(480, 437)}), {1, 0.5})

    local banner = setSize(CCSprite:create("probg.png"), {100, 19})
    local pro = display.newScale9Sprite("pro.png")
    banner:addChild(pro)
    setAnchor(setPos(pro, {27, fixY(76, 40)}), {0, 0.5})
    setAnchor(setPos(addChild(temp, banner), {440, fixY(480, 437)}), {0, 0.5})

    local num = setAnchor(setPos(addChild(self.bg, ui.newBMFontLabel({text="65", size=15, color={0, 0, 0}, font="fonts.fnt"})), {vs.width/2-fixX(400, 214), fixY(480, 437)}), {1, 0.5})
    local head = setAnchor(setPos(addSprite(temp, "king2.png"), {vs.width/2-fixX(400, 161), fixY(480, 437)}), {0.5, 0.5})
    setSize(head, {30, 23})

    local num = setAnchor(setPos(addChild(self.bg, ui.newBMFontLabel({text="196", size=15, color={0, 0, 0}, font="fonts.fnt"})), {540, fixY(480, 437)}), {0, 0.5})
    local head = setAnchor(setPos(addSprite(temp, "king2.png"), {586, fixY(480, 437)}), {0.5, 0.5})
    setSize(head, {30, 23})

    ----------------------
    local head = setAnchor(setPos(addSprite(temp, "business_trader_1.png"), {44, fixY(480, 370)}), {0.5, 0.5})
    setSize(head, {30, 30})

    local banner = setSize(CCSprite:create("probg.png"), {50, 19})
    local pro = display.newScale9Sprite("pro.png")
    banner:addChild(pro)
    setAnchor(setPos(pro, {27, fixY(76, 40)}), {0, 0.5})
    setAnchor(setPos(addChild(temp, banner), {44, fixY(480, 392)}), {0.5, 0.5})
    
    local head = setAnchor(setPos(addSprite(temp, "business_trader_2.png"), {102, fixY(480, 370)}), {0.5, 0.5})
    setSize(head, {30, 30})

    local banner = setSize(CCSprite:create("probg.png"), {50, 19})
    local pro = display.newScale9Sprite("pro.png")
    banner:addChild(pro)
    setAnchor(setPos(pro, {27, fixY(76, 40)}), {0, 0.5})
    setAnchor(setPos(addChild(temp, banner), {102, fixY(480, 392)}), {0.5, 0.5})

    local head = setAnchor(setPos(addSprite(temp, "business_trader_3.png"), {44, fixY(480, 424)}), {0.5, 0.5})
    setSize(head, {30, 30})

    local banner = setSize(CCSprite:create("probg.png"), {50, 19})
    local pro = display.newScale9Sprite("pro.png")
    banner:addChild(pro)
    setAnchor(setPos(pro, {27, fixY(76, 40)}), {0, 0.5})
    setAnchor(setPos(addChild(temp, banner), {44, fixY(480, 445)}), {0.5, 0.5})

    local head = setAnchor(setPos(addSprite(temp, "business_trader_4.png"), {102, fixY(480, 424)}), {0.5, 0.5})
    setSize(head, {30, 30})

    local banner = setSize(CCSprite:create("probg.png"), {50, 19})
    local pro = display.newScale9Sprite("pro.png")
    banner:addChild(pro)
    setAnchor(setPos(pro, {27, fixY(76, 40)}), {0, 0.5})
    setAnchor(setPos(addChild(temp, banner), {102, fixY(480, 445)}), {0.5, 0.5})

    -------------
    local head = setAnchor(setPos(addSprite(temp, "business_trader_5.png"), {687, fixY(480, 370)}), {0.5, 0.5})
    setSize(head, {30, 30})

    local banner = setSize(CCSprite:create("probg.png"), {50, 19})
    local pro = display.newScale9Sprite("pro.png")
    banner:addChild(pro)
    setAnchor(setPos(pro, {27, fixY(76, 40)}), {0, 0.5})
    setAnchor(setPos(addChild(temp, banner), {687, fixY(480, 392)}), {0.5, 0.5})

    local head = setAnchor(setPos(addSprite(temp, "business_trader_6.png"), {748, fixY(480, 370)}), {0.5, 0.5})
    setSize(head, {30, 30})

    local banner = setSize(CCSprite:create("probg.png"), {50, 19})
    local pro = display.newScale9Sprite("pro.png")
    banner:addChild(pro)
    setAnchor(setPos(pro, {27, fixY(76, 40)}), {0, 0.5})
    setAnchor(setPos(addChild(temp, banner), {748, fixY(480, 392)}), {0.5, 0.5})


    local head = setAnchor(setPos(addSprite(temp, "business_trader_7.png"), {687, fixY(480, 415)}), {0.5, 0.5})
    setSize(head, {30, 30})

    local banner = setSize(CCSprite:create("probg.png"), {50, 19})
    local pro = display.newScale9Sprite("pro.png")
    banner:addChild(pro)
    setAnchor(setPos(pro, {27, fixY(76, 40)}), {0, 0.5})
    setAnchor(setPos(addChild(temp, banner), {687, fixY(480, 441)}), {0.5, 0.5})

    local head = setAnchor(setPos(addSprite(temp, "business_trader_8.png"), {748, fixY(480, 415)}), {0.5, 0.5})
    setSize(head, {30, 30})

    local banner = setSize(CCSprite:create("probg.png"), {50, 19})
    local pro = display.newScale9Sprite("pro.png")
    banner:addChild(pro)
    setAnchor(setPos(pro, {27, fixY(76, 40)}), {0, 0.5})
    setAnchor(setPos(addChild(temp, banner), {748, fixY(480, 441)}), {0.5, 0.5})
end
