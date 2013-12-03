ResearchMenu = class()
function ResearchMenu:ctor()
    local vs = getVS()

    self.bg = CCNode:create()
    local temp = display.newScale9Sprite("tabback.jpg")
    temp:setContentSize(CCSizeMake(526, 370))
    self.bg:addChild(temp)
    setPos(temp, {vs.width/2, vs.height/2})
    self.temp = temp

    local tit = setPos(addSprite(temp, "title.png"), {263, fixY(370, 31)})
    local w = ui.newTTFLabel({text="标题", font="msyhbd.ttf", size=15, color={0,0,0}})
    temp:addChild(w)
    setAnchor(setPos(w, {263, fixY(370, 31)}), {0.5, 0.5})
    self.title = w
end
