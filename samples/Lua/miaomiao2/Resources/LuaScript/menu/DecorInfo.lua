DecorInfo = class()
function DecorInfo:ctor(b)
    self.build = b
    
    local vs = getVS()
    self.bg = CCNode:create()
    local sz = {width=1024, height=768}
    self.temp = setPos(addNode(self.bg), {-13.5, fixY(sz.height, 0+sz.height)+4})
    local sp = setOpacity(setAnchor(setSize(setPos(addSprite(self.temp, "dialogA.png"), {525, fixY(sz.height, 388)}), {693, 588}), {0.50, 0.50}), 255)
    local sp = setOpacity(setAnchor(setSize(setPos(addSprite(self.temp, "dialogB.png"), {525, fixY(sz.height, 418)}), {626, 358}), {0.50, 0.50}), 255)
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text=self.build.data.name, size=26, color={32, 112, 220}, font="f2", shadowColor={255, 255, 255}})), {0.50, 0.50}), {529, fixY(sz.height, 219)})
    --[[
    local but = ui.newButton({image="newClose.png", text="", font="f1", size=18, delegate=self, callback=closeDialog, shadowColor={0, 0, 0}, color={255, 255, 255}})
    but:setContentSize(80, 82)
    setPos(addChild(self.temp, but.bg), {848, fixY(sz.height, 112)})
    --]]

    local but = ui.newButton({image="butc.png", text="确定", font="f1", size=27, delegate=self, callback=closeDialog, shadowColor={0, 0, 0}, color={255, 255, 255}})
    but:setContentSize(158, 50)
    setPos(addChild(self.temp, but.bg), {525, fixY(sz.height, 625)})
    local sp = setOpacity(setAnchor(setSize(setPos(addSprite(self.temp, "buildInfo.png"), {531, fixY(sz.height, 148)}), {212, 42}), {0.50, 0.50}), 255)
    local sp = setOpacity(setAnchor(setPos(addSprite(self.temp, "#build"..self.build.id..".png"), {525, fixY(sz.height, 415)}), {0.50, 0.50}), 255)
    setBox(sp, {240, 240})

    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text=self.build.data.des, size=26, color={255, 255, 255}, font="f2", shadowColor={0, 0, 0}})), {0.50, 0.50}), {525, fixY(sz.height, 550)})

    centerUI(self)
end
