HouseInfo = class()
function HouseInfo:ctor(b)
    self.build = b
    local vs = getVS()
    self.bg = CCNode:create()
    local temp = display.newScale9Sprite("tabback.jpg")
    temp:setContentSize(CCSizeMake(407, 280))
    setPos(temp, {vs.width/2, vs.height/2})
    addChild(self.bg, temp)
    self.temp = temp
    local sz = self.temp:getContentSize()
    local sp = setPos(addSprite(self.temp, "title.png"), {203, fixY(sz.height, 20)})
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="建筑情报", size=18, color={1, 1, 1}})), {0.5, 0.5}), {162, fixY(sz.height, 11)})
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="农家", size=18, color={1, 1, 1}})), {0.5, 0.5}), {101, fixY(sz.height, 47)})
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="维修费", size=18, color={1, 1, 1}})), {0.5, 0.5}), {288, fixY(sz.height, 46)})
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="2贯", size=18, color={1, 1, 1}})), {0.5, 0.5}), {369, fixY(sz.height, 47)})
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="居民", size=18, color={1, 1, 1}})), {0.5, 0.5}), {184, fixY(sz.height, 82)})
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="体力", size=18, color={1, 1, 1}})), {0.5, 0.5}), {182, fixY(sz.height, 115)})
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="攻击", size=18, color={1, 1, 1}})), {0.5, 0.5}), {180, fixY(sz.height, 143)})
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="小明", size=18, color={1, 1, 1}})), {0.5, 0.5}), {261, fixY(sz.height, 83)})
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="27", size=18, color={1, 1, 1}})), {0.5, 0.5}), {244, fixY(sz.height, 116)})
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="4", size=18, color={1, 1, 1}})), {0.5, 0.5}), {251, fixY(sz.height, 143)})
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="防御", size=14, color={0, 0, 0}})), {0.5, 0.5}), {290, fixY(sz.height, 144)})
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="0", size=14, color={0, 0, 0}})), {0.5, 0.5}), {364, fixY(sz.height, 145)})
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="回复力", size=14, color={0, 0, 0}})), {0.5, 0.5}), {204, fixY(sz.height, 186)})
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text=self.build.productNum, size=14, color={0, 0, 0}})), {0.5, 0.5}), {326, fixY(sz.height, 186)})
    local sp = setPos(addSprite(self.temp, "business_trader_1.png"), {84, fixY(sz.height, 145)})
    local but = ui.newButton({image="tabbut.png", text="查看居民情报", size=15, color={0, 0, 0}, callback=self.onBut, delegate=self})
    setPos(addChild(temp, but.bg), {sz.width/2, fixY(sz.height, 247)})
end
--村民一览 村民修习里面有 TrainNow 菜单
function HouseInfo:onBut()

end
