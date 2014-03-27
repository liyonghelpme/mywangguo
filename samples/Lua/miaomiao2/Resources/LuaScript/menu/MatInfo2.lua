MatInfo2 = class()
function MatInfo2:ctor()
    local vs = getVS()
    self.bg = CCNode:create()
    local sz = {width=1024, height=768}
    self.temp = setPos(addNode(self.bg), {-31.0, fixY(sz.height, 0+sz.height)+38.5})
    local sp = setAnchor(setPos(addSprite(self.temp, "dialogA.png"), {543, fixY(sz.height, 422)}), {0.50, 0.50})
    local sp = setAnchor(setSize(setPos(addSprite(self.temp, "dialogB.png"), {540, fixY(sz.height, 456)}), {617, 352}), {0.50, 0.50})
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="贩卖许可", size=25, color={32, 112, 220}, font="f1"})), {0.00, 0.50}), {626, fixY(sz.height, 253)})
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="在库", size=25, color={32, 112, 220}, font="f1"})), {0.00, 0.50}), {446, fixY(sz.height, 254)})
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="材料", size=25, color={32, 112, 220}, font="f1"})), {0.00, 0.50}), {338, fixY(sz.height, 253)})
    local sp = setOpacity(setAnchor(setSize(setPos(addSprite(self.temp, "matInfo.png"), {531, fixY(sz.height, 148)}), {212, 42}), {0.50, 0.50}), 255)
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="按左右键切换是否允许贩卖", size=26, color={32, 112, 220}, font="f1"})), {0.50, 0.50}), {559, fixY(sz.height, 657)})


    local mat = getAllMatNum()
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="食材", size=28, color={255, 255, 255}, font="f2"})), {0.00, 0.50}), {332, fixY(sz.height, 383)})
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text=mat.food.."个", size=28, color={255, 255, 255}, font="f2"})), {0.00, 0.50}), {443, fixY(sz.height, 383)})
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text=mat.wood.."个", size=28, color={255, 255, 255}, font="f2"})), {0.00, 0.50}), {443, fixY(sz.height, 450)})
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text=mat.stone.."个", size=28, color={255, 255, 255}, font="f2"})), {0.00, 0.50}), {443, fixY(sz.height, 514)})
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="木材", size=28, color={255, 255, 255}, font="f2"})), {0.00, 0.50}), {334, fixY(sz.height, 448)})
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="矿石", size=28, color={255, 255, 255}, font="f2"})), {0.00, 0.50}), {334, fixY(sz.height, 514)})
    local sp = setAnchor(setSize(setPos(addSprite(self.temp, "foodIcon.png"), {292, fixY(sz.height, 385)}), {38, 39}), {0.50, 0.50})
    local sp = setAnchor(setSize(setPos(addSprite(self.temp, "woodIcon.png"), {292, fixY(sz.height, 448)}), {37, 37}), {0.50, 0.50})
    local sp = setAnchor(setSize(setPos(addSprite(self.temp, "stoneIcon.png"), {292, fixY(sz.height, 513)}), {37, 38}), {0.50, 0.50})
    local but = ui.newButton({image="lefta.png", text="", font="f1", size=18, delegate=self, callback=self.onLeft, param=1})
    but:setContentSize(45, 51)
    setPos(addChild(self.temp, but.bg), {575, fixY(sz.height, 391)})
    local but = ui.newButton({image="righta.png", text="", font="f1", size=18, delegate=self, callback=self.onRight, param=1})
    but:setContentSize(45, 51)
    setPos(addChild(self.temp, but.bg), {795, fixY(sz.height, 389)})
    local sp = setAnchor(setSize(setPos(addSprite(self.temp, "listd.png"), {684, fixY(sz.height, 390)}), {170, 52}), {0.50, 0.50})
    local sp = setAnchor(setSize(setPos(addSprite(self.temp, "listd.png"), {684, fixY(sz.height, 453)}), {170, 52}), {0.50, 0.50})
    local sp = setAnchor(setSize(setPos(addSprite(self.temp, "listd.png"), {684, fixY(sz.height, 516)}), {170, 52}), {0.50, 0.50})
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="不进行", size=23, color={240, 196, 92}, font="f1"})), {0.50, 0.50}), {683, fixY(sz.height, 450)})
    self.woodW = w
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="不进行", size=23, color={240, 196, 92}, font="f1"})), {0.50, 0.50}), {683, fixY(sz.height, 514)})
    self.stoneW = w
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="不进行", size=23, color={240, 196, 92}, font="f1"})), {0.50, 0.50}), {683, fixY(sz.height, 389)})
    self.foodW = w
    local but = ui.newButton({image="righta.png", text="", font="f1", size=18, delegate=self, callback=self.onRight, param=2})
    but:setContentSize(45, 51)
    setPos(addChild(self.temp, but.bg), {795, fixY(sz.height, 454)})
    local but = ui.newButton({image="lefta.png", text="", font="f1", size=18, delegate=self, callback=self.onLeft, param=2})
    but:setContentSize(45, 51)
    setPos(addChild(self.temp, but.bg), {573, fixY(sz.height, 454)})

    local but = ui.newButton({image="righta.png", text="", font="f1", size=18, delegate=self, callback=self.onRight, param=3})
    but:setContentSize(45, 51)
    setPos(addChild(self.temp, but.bg), {797, fixY(sz.height, 518)})
    local but = ui.newButton({image="lefta.png", text="", font="f1", size=18, delegate=self, callback=self.onLeft, param=3})
    but:setContentSize(45, 51)
    setPos(addChild(self.temp, but.bg), {573, fixY(sz.height, 516)})
    self.allW = {self.foodW, self.woodW, self.stoneW}
    self:initSell()


    centerUI(self)
end
function MatInfo2:initSell()
    local key = {'food', 'wood', 'stone'}
    for k, v in ipairs(key) do
        if Logic.inSell[v] then
            self.allW[k]:setString('进行')
        else
            self.allW[k]:setString('不进行')
        end
    end
end
function MatInfo2:onLeft(p)
    local key = {'food', 'wood', 'stone'}
    Logic.inSell[key[p]] = not Logic.inSell[key[p]]
    if Logic.inSell[key[p]] then
        self.allW[p]:setString('进行')
    else
        self.allW[p]:setString('不进行')
    end
end
function MatInfo2:onRight(p)
    self:onLeft(p)
end

