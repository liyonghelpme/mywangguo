MatInfo = class()
function MatInfo:ctor()
    local vs = getVS()

    self.bg = CCNode:create()
    local temp = display.newScale9Sprite("tabback.jpg")
    temp:setContentSize(CCSizeMake(407, 220))
    self.bg:addChild(temp)
    setPos(temp, {vs.width/2, vs.height/2})
    self.temp = temp

    local sz = temp:getContentSize()

    local tit = setPos(addSprite(temp, "title.png"), {sz.width/2, fixY(220, 31)})
    local w = ui.newTTFLabel({text="材料情报", font="msyhbd.ttf", size=15, color={0,0,0}})
    temp:addChild(w)
    setAnchor(setPos(w, {sz.width/2, fixY(220, 31)}), {0.5, 0.5})
    self.title = w

    local w = ui.newTTFLabel({text="材料", font="msyhbd.ttf", size=15, color={10,20,176}})
    temp:addChild(w)
    setAnchor(setPos(w, {61, fixY(220, 76)}), {0.5, 0.5})

    local w = ui.newTTFLabel({text="在库", font="msyhbd.ttf", size=15, color={10,20,176}})
    temp:addChild(w)
    setAnchor(setPos(w, {178, fixY(220, 76)}), {0.5, 0.5})

    local w = ui.newTTFLabel({text="贩卖许可", font="msyhbd.ttf", size=15, color={10,20,176}})
    temp:addChild(w)
    setAnchor(setPos(w, {309, fixY(220, 76)}), {0.5, 0.5})

    local w = ui.newTTFLabel({text="食材", font="msyhbd.ttf", size=15, color={10,10,10}})
    temp:addChild(w)
    setAnchor(setPos(w, {60, fixY(220, 108)}), {0.5, 0.5})

    local w = ui.newTTFLabel({text="木材", font="msyhbd.ttf", size=15, color={10,10,10}})
    temp:addChild(w)
    setAnchor(setPos(w, {60, fixY(220, 143)}), {0.5, 0.5})

    local w = ui.newTTFLabel({text="石头", font="msyhbd.ttf", size=15, color={10,10,10}})
    temp:addChild(w)
    setAnchor(setPos(w, {60, fixY(220, 180)}), {0.5, 0.5})

    local w = ui.newTTFLabel({text="31", font="msyhbd.ttf", size=15, color={10,10,10}})
    temp:addChild(w)
    setAnchor(setPos(w, {196, fixY(220, 108)}), {1, 0.5})

    local but = ui.newButton({image="tabbut.png", conSize={60, 20}, text="进行", color={0, 0, 0}, size=14, callback=self.onSell, delegate=self})
    setPos(addChild(temp, but.bg), {310, fixY(220, 108)})

    local w = ui.newTTFLabel({text="3", font="msyhbd.ttf", size=15, color={10,10,10}})
    temp:addChild(w)
    setAnchor(setPos(w, {196, fixY(220, 143)}), {1, 0.5})

    local but = ui.newButton({image="tabbut.png", conSize={60, 20}, text="进行", color={0, 0, 0}, size=14, callback=self.onSell, delegate=self})
    setPos(addChild(temp, but.bg), {310, fixY(220, 143)})

    local w = ui.newTTFLabel({text="26", font="msyhbd.ttf", size=15, color={10,10,10}})
    temp:addChild(w)
    setAnchor(setPos(w, {196, fixY(220, 180)}), {1, 0.5})

    local but = ui.newButton({image="tabbut.png", conSize={60, 20}, text="进行", color={0, 0, 0}, size=14, callback=self.onSell, delegate=self})
    setPos(addChild(temp, but.bg), {310, fixY(220, 180)})
end

