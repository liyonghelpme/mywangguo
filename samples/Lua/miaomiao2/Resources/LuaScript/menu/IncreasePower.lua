IncreasePower = class()
function IncreasePower:ctor()
    local vs = getVS()

    self.bg = CCNode:create()
    local temp = display.newScale9Sprite("tabback.jpg")
    temp:setContentSize(CCSizeMake(480, 240))
    self.bg:addChild(temp)
    setPos(temp, {vs.width/2, vs.height/2})
    self.temp = temp
    local sz = temp:getContentSize()

    local tit = setPos(addSprite(temp, "title.png"), {sz.width/2, fixY(sz.height, 31)})
    local w = ui.newTTFLabel({text="兵力的增强", font="msyhbd.ttf", size=15, color={0,0,0}})
    temp:addChild(w)
    setAnchor(setPos(w, {sz.width/2, fixY(sz.height, 31)}), {0.5, 0.5})
    self.title = w

    local head = setPos(addSprite(temp, "business_trader_3.png"), {79, 130})
    local w = ui.newTTFLabel({text="步卒", font="msyhbd.ttf", size=15, color={0,0,0}})
    temp:addChild(w)
    setAnchor(setPos(w, {211, fixY(sz.height, 90)}), {1, 0.5})

    local but = ui.newButton({image="psel.png", callback=self.onSol, delegate=self, param=1})
    addChild(temp, setPos(but.bg, {347, fixY(sz.height, 90)}))

    local w = ui.newTTFLabel({text="999", font="msyhbd.ttf", size=15, color={8,10,176}})
    temp:addChild(w)
    setAnchor(setPos(w, {267, fixY(sz.height, 90)}), {1, 0.5})


    local w = ui.newTTFLabel({text="弓队", font="msyhbd.ttf", size=15, color={0,0,0}})
    temp:addChild(w)
    setAnchor(setPos(w, {211, fixY(sz.height, 120)}), {1, 0.5})

    local but = ui.newButton({image="psel.png", callback=self.onSol, delegate=self, param=2})
    addChild(temp, setPos(but.bg, {347, fixY(sz.height, 120)}))

    local w = ui.newTTFLabel({text="700", font="msyhbd.ttf", size=15, color={8,10,176}})
    temp:addChild(w)
    setAnchor(setPos(w, {267, fixY(sz.height, 120)}), {1, 0.5})

    local w = ui.newTTFLabel({text="铁统", font="msyhbd.ttf", size=15, color={0,0,0}})
    temp:addChild(w)
    setAnchor(setPos(w, {211, fixY(sz.height, 154)}), {1, 0.5})

    local but = ui.newButton({image="psel.png", callback=self.onSol, delegate=self, param=3})
    addChild(temp, setPos(but.bg, {347, fixY(sz.height, 154)}))

    local w = ui.newTTFLabel({text="61", font="msyhbd.ttf", size=15, color={8,10,176}})
    temp:addChild(w)
    setAnchor(setPos(w, {267, fixY(sz.height, 154)}), {1, 0.5})

    local w = ui.newTTFLabel({text="铁骑", font="msyhbd.ttf", size=15, color={128,128,128}})
    temp:addChild(w)
    setAnchor(setPos(w, {211, fixY(sz.height, 184)}), {1, 0.5})

    local but = ui.newButton({image="psel.png", callback=self.onSol, delegate=self, param=4})
    addChild(temp, setPos(but.bg, {347, fixY(sz.height, 184)}))

    local w = ui.newTTFLabel({text="无法运用", font="msyhbd.ttf", size=15, color={128,128,128}})
    temp:addChild(w)
    setAnchor(setPos(w, {431, fixY(sz.height, 184)}), {1, 0.5})

end
function IncreasePower:onSol(p)

end
