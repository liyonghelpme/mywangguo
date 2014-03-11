SessionMenu = class()
function SessionMenu:ctor(word, callback, del, param)
    self.callback = callback
    self.del = del
    self.param = param
    local vs = getVS()
    self.bg = CCNode:create()
    local sz = {width=1024, height=768}
    self.temp = setPos(addNode(self.bg), {0, fixY(sz.height, 0+sz.height)+0})
    local sp = setOpacity(setAnchor(setSize(setPos(addSprite(self.temp, "sdialoga.png"), {512, fixY(sz.height, 396)}), {633, 427}), {0.50, 0.50}), 255)
    local sp = setAnchor(setPos(addChild(self.temp, createSmallDialogb()), {512, fixY(sz.height, 403)}), {0.50, 0.50})

    if param == nil then
        local but = ui.newButton({image="newClose.png", text="", font="f1", size=18, delegate=self, callback=closeDialog, shadowColor={0, 0, 0}, color={255, 255, 255}})
        but:setContentSize(80, 82)
        setPos(addChild(self.temp, but.bg), {813, fixY(sz.height, 196)})
    end


    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text=word, dimensions=CCSizeMake(1024, 768), align=ui.TEXT_ALIGN_LEFT, valign=ui.TEXT_VALIGN_TOP, size=28, color={255, 255, 255}, font="f1", shadowColor={0, 0, 0}})), {0.00, 1.00}), {255, fixY(sz.height, 325)})
    local sp = setOpacity(setAnchor(setSize(setPos(addSprite(self.temp, "dialogCat.png"), {740, fixY(sz.height, 500)}), {101, 157}), {0.50, 0.50}), 255)
    if param == nil then
        local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="忍者喵", size=26, color={32, 112, 220}, font="f2", shadowColor={255, 255, 255}})), {0.00, 0.50}), {603, fixY(sz.height, 546)})
    end
    local sp = setOpacity(setAnchor(setSize(setPos(addSprite(self.temp, "sessionTitle.png"), {523, fixY(sz.height, 233)}), {194, 38}), {0.50, 0.50}), 255)

    if param ~= nil then
        if param.butOk then
            local but = ui.newButton({image="butc.png", text="确定", font="f1", size=27, delegate=self, callback=self.onBut, param=0, shadowColor={0, 0, 0}, color={255, 255, 255}})
            but:setContentSize(158, 50)
            setPos(addChild(self.temp, but.bg), {388, fixY(sz.height, 553)})
        end
        if param.butCancel then
            local but = ui.newButton({image="butc.png", text="取消", font="f1", size=27, delegate=self, callback=self.onBut, param=1, shadowColor={0, 0, 0}, color={255, 255, 255}})
            but:setContentSize(158, 50)
            setPos(addChild(self.temp, but.bg), {594, fixY(sz.height, 553)})
        end
    end


    centerUI(self)
    registerEnterOrExit(self)
end

function SessionMenu:onBut(p)
    closeDialog()
    if self.callback ~= nil then
        self.callback(self.del, p)
    end
end

function SessionMenu:exitScene()
    if self.param == nil then
        if self.callback ~= nil then
            self.callback(self.del)
        end
    end
end

