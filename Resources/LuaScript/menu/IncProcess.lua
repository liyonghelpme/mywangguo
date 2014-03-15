IncProcess = class()
function IncProcess:ctor(kind)
    local vs = getVS()
    self.bg = CCNode:create()
    local sz = {width=1024, height=768}
    self.temp = setPos(addNode(self.bg), {0, fixY(sz.height, 0+sz.height)+0})
    local sp = setOpacity(setAnchor(setSize(setPos(addSprite(self.temp, "sdialoga.png"), {512, fixY(sz.height, 396)}), {633, 427}), {0.50, 0.50}), 255)
    local sp = setOpacity(setAnchor(setSize(setPos(addSprite(self.temp, "smallDialogb.png"), {512, fixY(sz.height, 403)}), {588, 246}), {0.50, 0.50}), 255)
    local but = ui.newButton({image="butc.png", text="确定", font="f1", size=27, delegate=self, callback=self.onBut, shadowColor={0, 0, 0}, color={255, 255, 255}})
    but:setContentSize(158, 50)
    setPos(addChild(self.temp, but.bg), {509, fixY(sz.height, 551)})
    local sp = setOpacity(setAnchor(setSize(setPos(addSprite(self.temp, "dialogCat.png"), {749, fixY(sz.height, 500)}), {101, 157}), {0.50, 0.50}), 255)
    local sp = setOpacity(setAnchor(setSize(setPos(addSprite(self.temp, "dialogCat.png"), {335, fixY(sz.height, 401)}), {101, 157}), {0.50, 0.50}), 255)
    local words = {
        "步兵增强中",
        "弓箭手增强中",
        "魔法兵增强中",
        "骑兵增强中",
    }
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text=words[kind], size=25, color={10, 76, 176}, font="f1", shadowColor={0, 0, 0}})), {0.00, 0.50}), {482, fixY(sz.height, 356)})
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="兵力增强", size=35, color={10, 10, 10}, font="f1", shadowColor={0, 0, 0}})), {0.50, 0.50}), {516, fixY(sz.height, 231)})

    self.banner, self.pro = createFacBanner()
    setPos(self.banner, {486, fixY(sz.height, 402)})
    self.temp:addChild(self.banner) 
    setFacProNum(self.pro, 0, 10) 
    centerUI(self)
    self.needUpdate = true
    registerEnterOrExit(self)
    self.process = 0
end
function IncProcess:update(diff)
    self.process = self.process+diff
    setFacProNum(self.pro, self.process, 2)
    if self.process >= 2 then
        global.director:popView()
    end
end
