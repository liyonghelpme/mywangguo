MatInfo3 = class()
function MatInfo3:ctor()
    local vs = getVS()
    self.bg = CCNode:create()
    local sz = {width=1024, height=768}
    self.temp = setPos(addNode(self.bg), {-13.5, fixY(sz.height, 0+sz.height)+4})
    local sp = setOpacity(setAnchor(setSize(setPos(addSprite(self.temp, "dialogA.png"), {525, fixY(sz.height, 388)}), {693, 588}), {0.50, 0.50}), 255)
    local sp = setOpacity(setAnchor(setSize(setPos(addSprite(self.temp, "dialogB.png"), {523, fixY(sz.height, 423)}), {626, 358}), {0.50, 0.50}), 255)
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="按左右键切换是否允许贩卖", size=26, color={32, 112, 220}, font="f2", shadowColor={255, 255, 255}})), {0.50, 0.50}), {547, fixY(sz.height, 625)})

    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="允许贩卖", size=26, color={32, 112, 220}, font="f2", shadowColor={255, 255, 255}})), {0.00, 0.50}), {657, fixY(sz.height, 215)})
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="在库", size=26, color={32, 112, 220}, font="f2", shadowColor={255, 255, 255}})), {0.00, 0.50}), {432, fixY(sz.height, 215)})
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="材料", size=26, color={32, 112, 220}, font="f2", shadowColor={255, 255, 255}})), {0.00, 0.50}), {323, fixY(sz.height, 215)})
    local but = ui.newButton({image="newClose.png", text="", font="f1", size=18, delegate=self, callback=closeDialog, shadowColor={0, 0, 0}, color={255, 255, 255}})
    but:setContentSize(80, 82)
    setPos(addChild(self.temp, but.bg), {848, fixY(sz.height, 112)})
    local sp = setOpacity(setAnchor(setSize(setPos(addSprite(self.temp, "matInfo.png"), {531, fixY(sz.height, 148)}), {212, 42}), {0.50, 0.50}), 255)
    local sp = setOpacity(setAnchor(setSize(setPos(addSprite(self.temp, "foodIcon.png"), {287, fixY(sz.height, 356)}), {32, 37}), {0.50, 0.50}), 255)
    local sp = setOpacity(setAnchor(setSize(setPos(addSprite(self.temp, "woodIcon.png"), {286, fixY(sz.height, 419)}), {30, 38}), {0.50, 0.50}), 255)
    local sp = setOpacity(setAnchor(setSize(setPos(addSprite(self.temp, "stoneIcon.png"), {288, fixY(sz.height, 481)}), {39, 41}), {0.50, 0.50}), 255)


    local mat = getAllMatNum()
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text=mat.food.."个", size=28, color={255, 255, 255}, font="f2", shadowColor={0, 0, 0}})), {1.00, 0.50}), {490, fixY(sz.height, 353)})
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text=mat.wood.."个", size=28, color={255, 255, 255}, font="f2", shadowColor={0, 0, 0}})), {1.00, 0.50}), {490, fixY(sz.height, 420)})
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text=mat.stone.."个", size=28, color={255, 255, 255}, font="f2", shadowColor={0, 0, 0}})), {1.00, 0.50}), {490, fixY(sz.height, 484)})
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="食材", size=28, color={255, 255, 255}, font="f2", shadowColor={0, 0, 0}})), {0.00, 0.50}), {319, fixY(sz.height, 353)})
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="木材", size=28, color={255, 255, 255}, font="f2", shadowColor={0, 0, 0}})), {0.00, 0.50}), {321, fixY(sz.height, 418)})
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="矿石", size=28, color={255, 255, 255}, font="f2", shadowColor={0, 0, 0}})), {0.00, 0.50}), {321, fixY(sz.height, 484)})

    local sp1 = setOpacity(setAnchor(setSize(setPos(addSprite(self.temp, "listd.png"), {671, fixY(sz.height, 360)}), {172, 54}), {0.50, 0.50}), 255)
    local sp2 = setOpacity(setAnchor(setSize(setPos(addSprite(self.temp, "listd.png"), {671, fixY(sz.height, 423)}), {172, 53}), {0.50, 0.50}), 255)
    local sp3 = setOpacity(setAnchor(setSize(setPos(addSprite(self.temp, "listd.png"), {671, fixY(sz.height, 485)}), {172, 53}), {0.50, 0.50}), 255)
    self.sp = {sp1, sp2, sp3}

    local but = ui.newButton({image="lefta.png", text="", font="f1", param=1, size=18, delegate=self, callback=self.onLeft, shadowColor={0, 0, 0}, color={255, 255, 255}})
    but:setContentSize(45, 51)
    setPos(addChild(self.temp, but.bg), {562, fixY(sz.height, 361)})

    local but = ui.newButton({image="righta.png", text="", font="f1", param=1, size=18, delegate=self, callback=self.onRight, shadowColor={0, 0, 0}, color={255, 255, 255}})
    but:setContentSize(45, 51)
    setPos(addChild(self.temp, but.bg), {782, fixY(sz.height, 361)})

    local but = ui.newButton({image="lefta.png", text="", font="f1", param=2, size=18, delegate=self, callback=self.onLeft, shadowColor={0, 0, 0}, color={255, 255, 255}})
    but:setContentSize(45, 51)
    setPos(addChild(self.temp, but.bg), {562, fixY(sz.height, 423)})
    local but = ui.newButton({image="righta.png", text="", font="f1", param=2, size=18, delegate=self, callback=self.onRight, shadowColor={0, 0, 0}, color={255, 255, 255}})
    but:setContentSize(45, 51)
    setPos(addChild(self.temp, but.bg), {782, fixY(sz.height, 423)})

    local but = ui.newButton({image="lefta.png", text="", font="f1", param=3, size=18, delegate=self, callback=self.onLeft, shadowColor={0, 0, 0}, color={255, 255, 255}})
    but:setContentSize(45, 51)
    setPos(addChild(self.temp, but.bg), {562, fixY(sz.height, 485)})
    local but = ui.newButton({image="righta.png", text="", font="f1", param=3, size=18, delegate=self, callback=self.onRight, shadowColor={0, 0, 0}, color={255, 255, 255}})
    but:setContentSize(45, 51)
    setPos(addChild(self.temp, but.bg), {782, fixY(sz.height, 485)})


    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="不进行", size=23, color={240, 196, 92}, font="f1", shadowColor={0, 0, 0}})), {0.50, 0.50}), {670, fixY(sz.height, 420)})
    self.woodW = w
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="不进行", size=23, color={240, 196, 92}, font="f1", shadowColor={0, 0, 0}})), {0.50, 0.50}), {670, fixY(sz.height, 484)})
    self.stoneW = w
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="不进行", size=23, color={240, 196, 92}, font="f1", shadowColor={0, 0, 0}})), {0.50, 0.50}), {670, fixY(sz.height, 359)})
    self.foodW = w

    self.allW = {self.foodW, self.woodW, self.stoneW}
    self:initSell()

    centerUI(self)
end

function MatInfo3:onLeft(p)
    local key = {'food', 'wood', 'stone'}
    Logic.inSell[key[p]] = not Logic.inSell[key[p]]
    if Logic.inSell[key[p]] then
        self.allW[p]:setString('进行')
        setColor(self.allW[p], {206, 78, 0})
        setTexture(self.sp[p], "listc.png")
    else
        self.allW[p]:setString('不进行')
        setColor(self.allW[p], {240, 196, 92})
        setTexture(self.sp[p], "listd.png")
    end
end

function MatInfo3:onRight(p)
    self:onLeft(p)
end

function MatInfo3:initSell()
    local key = {'food', 'wood', 'stone'}
    for k, v in ipairs(key) do
        if Logic.inSell[v] then
            self.allW[k]:setString('进行')
            setColor(self.allW[k], {206, 78, 0})
            setTexture(self.sp[k], "listc.png")
        else
            self.allW[k]:setString('不进行')
        end
    end
end
