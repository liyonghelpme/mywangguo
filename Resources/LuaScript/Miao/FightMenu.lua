FightMenu = class()
function FightMenu:ctor()
    self.bg = CCNode:create()
    local vs = getVS()
    local temp = setAnchor(setContentSize(addChild(self.bg, display.newScale9Sprite("tabback.jpg")), {vs.width, 150}), {0, 0})
    
    local w = setPos(addChild(temp, ui.newTTFLabel({text="步卒", size=15, color={0, 0,0}})), {vs.width/2, fixY(480, 361)})

    local banner = setSize(CCSprite:create("probg.png"), {100, 19})
    local pro = display.newScale9Sprite("pro.png")
    banner:addChild(pro)
    setAnchor(setPos(pro, {27, fixY(76, 40)}), {0, 0.5})
    addChild(temp, banner )
    local head = setPos(addSprite(temp, "king2.png"), {})
end
