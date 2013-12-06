require "menu.GoodsInfo"
StoreInfo = class()
function StoreInfo:ctor(b)
    self.build = b

    local vs = getVS()
    self.bg = CCNode:create()
    local temp = display.newScale9Sprite("tabback.jpg")
    temp:setContentSize(CCSizeMake(407, 280))
    setPos(temp, {vs.width/2, vs.height/2})
    addChild(self.bg, temp)
    self.temp = temp
    local sz = self.temp:getContentSize()
    local sp = setPos(addSprite(self.temp, "title.png"), {213, fixY(sz.height, 21)})
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="建筑情报", size=18, color={1, 1, 1}})), {0.5, 0.5}), {159, fixY(sz.height, 9)})
    local sp = setPos(addSprite(self.temp, "build13.png"), {82, fixY(sz.height, 144)})
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="在库", size=18, color={1, 1, 1}})), {0.5, 0.5}), {187, fixY(sz.height, 82)})
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="维修费", size=18, color={1, 1, 1}})), {0.5, 0.5}), {274, fixY(sz.height, 43)})
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="2贯", size=18, color={1, 1, 1}})), {0.5, 0.5}), {344, fixY(sz.height, 44)})
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="商品", size=18, color={1, 1, 1}})), {0.5, 0.5}), {214, fixY(sz.height, 119)})
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="价格", size=18, color={1, 1, 1}})), {0.5, 0.5}), {317, fixY(sz.height, 117)})
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text=GoodsName[self.build.goodsKind].name, size=18, color={1, 1, 1}})), {0.5, 0.5}), {213, fixY(sz.height, 142)})
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text=GoodsName[self.build.goodsKind].price.."贯", size=18, color={1, 1, 1}})), {0.5, 0.5}), {318, fixY(sz.height, 143)})
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="贩卖力", size=18, color={1, 1, 1}})), {0.5, 0.5}), {210, fixY(sz.height, 185)})
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="20", size=18, color={1, 1, 1}})), {0.5, 0.5}), {322, fixY(sz.height, 186)})

    local banner = setSize(CCSprite:create("probg.png"), {100, 27})
    local pro = display.newScale9Sprite("pro1.png")
    banner:addChild(pro)
    setAnchor(setPos(pro, {27, fixY(76, 40)}), {0, 0.5})
    setPos(banner, {278, fixY(sz.height, 92)})
    addChild(self.temp, banner)

    setProNum(pro, self.build.workNum, self.build.maxNum)

    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="0 个", size=18, color={1, 1, 1}})), {0.5, 0.5}), {340, fixY(sz.height, 83)})
    local but = ui.newButton({image="tabbut.png", text="更改商品", size=15, color={10, 10, 10}, callback=self.onChange, delegate=self})
    setPos(addChild(temp, but.bg), {209, fixY(sz.height, 247)})
end
function StoreInfo:onChange()
    global.director:popView()
    global.director:pushView(GoodsInfo.new(), 1, 0)
end
