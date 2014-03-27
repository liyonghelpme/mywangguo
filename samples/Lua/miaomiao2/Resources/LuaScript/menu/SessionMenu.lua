SessionMenu = class()
function SessionMenu:ctor(word, callback, del, okBut)
    self.callback = callback
    self.del = del
    self.okBut = okBut
    local vs = getVS()
    self.bg = CCNode:create()
    local sz = {width=1024, height=768}
    self.temp = setPos(addNode(self.bg), {0, fixY(sz.height, 0+sz.height)+0})
    local sp = setOpacity(setAnchor(setSize(setPos(addSprite(self.temp, "sdialoga.png"), {512, fixY(sz.height, 396)}), {633, 427}), {0.50, 0.50}), 255)
    local sp = setOpacity(setAnchor(setSize(setPos(addSprite(self.temp, "smallDialogb.png"), {512, fixY(sz.height, 403)}), {588, 246}), {0.50, 0.50}), 255)
    local but = ui.newButton({image="newClose.png", text="", font="f1", size=18, delegate=self, callback=closeDialog, shadowColor={0, 0, 0}, color={255, 255, 255}})
    but:setContentSize(80, 82)
    setPos(addChild(self.temp, but.bg), {813, fixY(sz.height, 196)})


    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text=word, dimensions=CCSizeMake(1024, 768), align=ui.TEXT_ALIGN_LEFT, valign=ui.TEXT_VALIGN_TOP, size=28, color={255, 255, 255}, font="f1", shadowColor={0, 0, 0}})), {0.00, 1.00}), {255, fixY(sz.height, 325)})
    local sp = setOpacity(setAnchor(setSize(setPos(addSprite(self.temp, "dialogCat.png"), {740, fixY(sz.height, 500)}), {101, 157}), {0.50, 0.50}), 255)
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="忍者喵", size=26, color={32, 112, 220}, font="f2", shadowColor={255, 255, 255}})), {0.00, 0.50}), {603, fixY(sz.height, 546)})
    local sp = setOpacity(setAnchor(setSize(setPos(addSprite(self.temp, "sessionTitle.png"), {523, fixY(sz.height, 233)}), {194, 38}), {0.50, 0.50}), 255)

    --[[
    if self.okBut then
        local but = ui.newButton({image="butc.png", })
    end
    --]]
    centerUI(self)
    registerEnterOrExit(self)
end
function SessionMenu:exitScene()
    if self.callback ~= nil then
        self.callback(self.del)
    end
end

