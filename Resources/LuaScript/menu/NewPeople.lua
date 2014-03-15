NewPeople = class()
function NewPeople:ctor(pid)
    print("NewPeople", pid)
    local vs = getVS()
    self.bg = CCNode:create()
    local sz = {width=1024, height=768}
    self.temp = setPos(addNode(self.bg), {0, fixY(sz.height, 0+sz.height)+0})
    local sp = setOpacity(setAnchor(setSize(setPos(addSprite(self.temp, "sdialoga.png"), {512, fixY(sz.height, 396)}), {633, 427}), {0.50, 0.50}), 255)
    
    print("small", createSmallDialogb)
    local sp = createSmallDialogb()
    local sp = setAnchor(setPos(addChild(self.temp, sp), {512, fixY(sz.height, 403)}), {0.50, 0.50})

    local but = ui.newButton({image="butc.png", text="确定", font="f1", size=27, delegate=self, callback=closeDialog, shadowColor={0, 0, 0}, color={255, 255, 255}})
    but:setContentSize(158, 50)
    setPos(addChild(self.temp, but.bg), {509, fixY(sz.height, 551)})
    local sp = setOpacity(setAnchor(setSize(setPos(addSprite(self.temp, "dialogCat.png"), {749, fixY(sz.height, 500)}), {101, 157}), {0.50, 0.50}), 255)

    local pdata = Logic.people[pid]
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="新村民 "..pdata.name, size=35, color={10, 10, 10}, font="f1", shadowColor={0, 0, 0}})), {0.50, 0.50}), {516, fixY(sz.height, 231)})

    local sf = CCSpriteFrameCache:sharedSpriteFrameCache()
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    sf:addSpriteFramesWithFile(string.format("cat_%d_walk.plist", pid))
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    local rbMove = createAnimation(string.format("people%d_rb", pid), "cat_"..pid.."_rb_%d.png", 0, 9, 2, 1, true)
    local sp = setBox(setOpacity(setAnchor(setPos(addSprite(self.temp, "cat_"..pid.."_rb_0.png"), {510, fixY(sz.height, 366)}), {0.50, 0.50}), 255), {200, 200})
    sp:runAction(repeatForever(CCAnimate:create(rbMove)))
    
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="在村民菜单中招募该村民", size=25, color={10, 76, 176}, font="f1", shadowColor={0, 0, 0}})), {0.50, 0.50}), {511, fixY(sz.height, 488)})

    centerUI(self)
end
function NewPeople:onBut()

end
