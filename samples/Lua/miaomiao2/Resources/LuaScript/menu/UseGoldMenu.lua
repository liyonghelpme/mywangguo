UseGoldMenu = class()
function UseGoldMenu:ctor()
    local vs = getVS()
    self.bg = CCNode:create()
    local sz = {width=1024, height=768}
    self.temp = setPos(addNode(self.bg), {30.0, fixY(vs.height, 0+sz.height)+-4.5})
    local sp = setAnchor(setSize(setPos(addSprite(self.temp, "sdialoga.png"), {485, fixY(sz.height, 379)}), {619, 381}), {0.50, 0.50})
    local w = colorLine({text="可使用<f8b551xxx金币>直接购买，\n是否确认？", color={255, 255, 255}, size=28, font="f1", anchor={0.5, 1}})
    local cs = w:getContentSize()
    print("label height", cs.width, cs.height)
    setPos(setAnchor(addChild(self.temp, w), {0.0, 0.00}), {489, fixY(sz.height, 348)})

    local but = ui.newButton({image="butb.png", text="取消", font="f1 ", size=25, delegate=self, callback=self.onBut, param=2})
    but:setContentSize(117, 43)
    setPos(addChild(self.temp, but.bg), {574, fixY(sz.height, 528)})
    local but = ui.newButton({image="butd.png", text="确定", font="f1 ", size=25, delegate=self, callback=self.onBut, param=1})
    but:setContentSize(117, 43)
    setPos(addChild(self.temp, but.bg), {411, fixY(sz.height, 528)})
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="银币不足？", size=34, color={102, 66, 42}, font="f1"})), {0.50, 0.50}), {482, fixY(sz.height, 246)})
end
function UseGoldMenu:onBut(p)
    if p == 1 then

    elseif p == 2 then
    end
end
