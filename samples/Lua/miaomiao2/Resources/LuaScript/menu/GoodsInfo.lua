GoodsInfo = class()
function GoodsInfo:ctor(b)
    self.build = b

    local vs = getVS()
    self.bg = CCNode:create()
    local temp = display.newScale9Sprite("tabback.jpg")
    temp:setContentSize(CCSizeMake(407, 280))
    setPos(temp, {vs.width/2, vs.height/2})
    addChild(self.bg, temp)
    self.temp = temp
    local sz = self.temp:getContentSize()
    local sp = setPos(addSprite(self.temp, "title.png"), {213, fixY(sz.height, 19)})
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="商品一览", size=18, color={0, 0, 0}})), {0.5, 0.5}), {170, fixY(sz.height, 8)})
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="材料", size=18, color={0, 0, 0}})), {0.5, 0.5}), {257, fixY(sz.height, 46)})
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="价格", size=18, color={0, 0, 0}})), {0.5, 0.5}), {350, fixY(sz.height, 45)})
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="材料 ", size=18, color={0, 0, 0}})), {0.5, 0.5}), {43, fixY(sz.height, 225)})
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="食材 1个", size=18, color={0, 0, 0}})), {0.5, 0.5}), {199, fixY(sz.height, 228)})
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="浊酒", size=18, color={0, 0, 0}})), {0.5, 0.5}), {60, fixY(sz.height, 80)})
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="白酒", size=18, color={0, 0, 0}})), {0.5, 0.5}), {58, fixY(sz.height, 118)})
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="素酒", size=18, color={0, 0, 0}})), {0.5, 0.5}), {58, fixY(sz.height, 160)})
    local sp = setSize(setPos(addSprite(self.temp, "herb7.png"), {264, fixY(sz.height, 83)}), {30, 30})
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="6贯", size=18, color={0, 0, 0}})), {0.5, 0.5}), {350, fixY(sz.height, 75)})
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="13贯", size=18, color={0, 0, 0}})), {0.5, 0.5}), {345, fixY(sz.height, 118)})
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="37贯", size=18, color={0, 0, 0}})), {0.5, 0.5}), {344, fixY(sz.height, 159)})
    
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text=GoodsName[1].food, size=18, color={0, 0, 0}})), {0.5, 0.5}), {267, fixY(sz.height, 86)})
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text=GoodsName[2].food, size=18, color={0, 0, 0}})), {0.5, 0.5}), {262, fixY(sz.height, 120)})
    local sp = setPos(addSprite(self.temp, "herb7.png"), {258, fixY(sz.height, 122)})

    local sp = setPos(addSprite(self.temp, "herb7.png"), {242, fixY(sz.height, 168)})
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text=GoodsName[3].food, size=18, color={0, 0, 0}})), {0.5, 0.5}), {248, fixY(sz.height, 172)})
    local sp = setPos(addSprite(self.temp, "herb109.png"), {280, fixY(sz.height, 172)})
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text=GoodsName[3].stone, size=18, color={0, 0, 0}})), {0.5, 0.5}), {283, fixY(sz.height, 173)})

    self.but = {}
    local but = ui.newButton({image="psel.png", conSize={328, 27}, delegate=self, callback=self.onGoods, param=1})
    setPos(addChild(temp, but.bg), {220, fixY(sz.height, 90)})
    setVisible(but.sp, false)
    table.insert(self.but, but)
    local but = ui.newButton({image="psel.png", conSize={328, 27}, delegate=self, callback=self.onGoods, param=2})
    setPos(addChild(temp, but.bg), {220, fixY(sz.height, 127)})
    setVisible(but.sp, false)
    table.insert(self.but, but)
    local but = ui.newButton({image="psel.png", conSize={328, 27}, delegate=self, callback=self.onGoods, param=3})
    setPos(addChild(temp, but.bg), {220, fixY(sz.height, 168)})
    setVisible(but.sp, false)
    table.insert(self.but, but)

    self.curSel = self.build.goodsKind
    setVisible(self.but[self.curSel].sp, true)
end
function GoodsInfo:onGoods(param)
    if param == self.curSel then
        global.director:popView()
        global.director.curScene.menu:clearMenu()
        self.build:setGoodsKind(self.curSel)
        return
    end
    setVisible(self.but[self.curSel].sp, false)
    setVisible(self.but[param].sp, true)
    self.curSel = param
end
