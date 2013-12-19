FindPeople2 = class()
function FindPeople2:adjustPos()
    local vs = getVS()
    local ds = global.director.designSize
    local sca = math.min(vs.width/ds[1], vs.height/ds[2])
    local pos = getPos(self.temp)
    local cx, cy = ds[1]/2-pos[1], ds[2]/2-pos[2]
    local nx, ny = vs.width/2-cx*sca, vs.height/2-cy*sca

    setScale(self.temp, sca)
    setPos(self.temp, {nx, ny})

    --调整切割屏幕高度
end
function FindPeople2:ctor()
    local vs = getVS()
    self.bg = CCNode:create()
    local sz = {width=715, height=601}
    local ds = global.director.designSize
    self.temp = setPos(addNode(self.bg), {192, fixY(ds[2], 66+sz.height)})
    self:adjustPos()

    local sp = setAnchor(setSize(setPos(addSprite(self.temp, "dialogA.png"), {338, fixY(sz.height, 316)}), {677, 569}), {0.50, 0.50})
    local sp = setAnchor(setSize(setPos(addSprite(self.temp, "dialogB.png"), {340, fixY(sz.height, 355)}), {603, 354}), {0.50, 0.50})
    --local but = ui.newButton({image="newClose.png"})
    --setPos(addChild(self.temp, but.bg), {677, fixY(sz.height, 40)})
    local but = ui.newButton({image="butc.png", text="进行启用", font="f1", size=34, callback=self.onPeople, delegate=self, conSize={152, 38}})
    setPos(addChild(self.temp, but.bg), {331, fixY(sz.height, 560)})
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="林雨皮之助", size=30, color={32, 7, 220}, font="f1"})), {0.00, 0.50}), {138, fixY(sz.height, 150)})
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="Lv3", size=40, color=hexToDec('f8b551'), font="f2"})), {0.00, 0.50}), {511, fixY(sz.height, 147)})
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="人才启用1/3", size=34, color={102, 4, 554}, font="f1"})), {0.50, 0.50}), {357, fixY(sz.height, 86)})

    

    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="体力", size=28, color={255, 255, 255}, font="f2"})), {0.50, 0.50}), {308, fixY(sz.height, 258)})
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="腕力", size=28, color={255, 255, 255}, font="f2"})), {0.50, 0.50}), {308, fixY(sz.height, 309)})
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="射击", size=28, color={255, 255, 255}, font="f2"})), {0.50, 0.50}), {308, fixY(sz.height, 360)})
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="劳动", size=28, color={255, 255, 255}, font="f2"})), {0.50, 0.50}), {308, fixY(sz.height, 411)})

    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="启用费用", size=28, color={255, 255, 255}, font="f2"})), {0.00, 0.50}), {199, fixY(sz.height, 459)})
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="9999", size=25, color=hexToDec('f8b551'), font="f2"})), {1.00, 0.50}), {590, fixY(sz.height, 258)})
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="9999银币", size=25, color=hexToDec('f8b551'), font="f2"})), {1.00, 0.50}), {508, fixY(sz.height, 461)})
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="9999", size=25, color=hexToDec('f8b551'), font="f2"})), {1.00, 0.50}), {590, fixY(sz.height, 309)})
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="222", size=25, color=hexToDec('f8b551'), font="f2"})), {1.00, 0.50}), {590, fixY(sz.height, 360)})
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="555", size=25, color=hexToDec('f8b551'), font="f2"})), {1.00, 0.50}), {590, fixY(sz.height, 411)})
    local sp = setAnchor(setSize(setPos(addSprite(self.temp, "peopBoard.png"), {171, fixY(sz.height, 336)}), {184, 183}), {0.50, 0.50})
    local sp = setAnchor(setSize(setPos(addSprite(self.temp, "role.png"), {167, fixY(sz.height, 332)}), {162, 161}), {0.50, 0.50})
    local sp = setAnchor(setSize(setPos(addSprite(self.temp, "prob.png"), {434, fixY(sz.height, 262)}), {191, 29}), {0.50, 0.50})
    local sp = setAnchor(setSize(setPos(addSprite(self.temp, "proa.png"), {434, fixY(sz.height, 262)}), {183, 20}), {0.50, 0.50})
    local sp = setAnchor(setSize(setPos(addSprite(self.temp, "prob.png"), {434, fixY(sz.height, 307)}), {191, 29}), {0.50, 0.50})
    local sp = setAnchor(setSize(setPos(addSprite(self.temp, "proa.png"), {434, fixY(sz.height, 307)}), {183, 20}), {0.50, 0.50})
    local sp = setAnchor(setSize(setPos(addSprite(self.temp, "prob.png"), {434, fixY(sz.height, 357)}), {191, 29}), {0.50, 0.50})
    local sp = setAnchor(setSize(setPos(addSprite(self.temp, "proa.png"), {434, fixY(sz.height, 357)}), {183, 20}), {0.50, 0.50})
    local sp = setAnchor(setSize(setPos(addSprite(self.temp, "prob.png"), {434, fixY(sz.height, 405)}), {191, 29}), {0.50, 0.50})
    local sp = setAnchor(setSize(setPos(addSprite(self.temp, "proa.png"), {434, fixY(sz.height, 405)}), {183, 20}), {0.50, 0.50})
end
function FindPeople2:onPeople()
    global.director:popView()
    global.director.curScene.page:addPeople(4)
end
