Ready = class()
function Ready:ctor(s)
    self.scene = s
    local vs = getVS()
    self.bg = CCNode:create()
    local sz = {width=768, height=1024}
    self.sz = sz
    self.temp = setPos(addNode(self.bg), {0, fixY(sz.height, 0+sz.height)+0})
    --[[
    local sp = setOpacity(setPos(addChild(self.temp, createSprite("greenbirds1.png")), {218, fixY(sz.height, 494)}), 255)
    setAnchor(sp, {378/768, (1024-360)/1024})
    self.bird = sp
    self.bird:runAction(repeatForever(CCAnimate:create(getAnimation("birdAni"))))
    --]]



    local sp = setOpacity(setAnchor(setSize(setPos(addSprite(self.temp, "ready.png"), {407, fixY(sz.height, 284)}), {586, 127}), {0.50, 0.50}), 255)
    local sp = setOpacity(setAnchor(setSize(setPos(addSprite(self.temp, "readyOther.png"), {392, fixY(sz.height, 567)}), {164, 392}), {0.50, 0.50}), 255)
    --背后push的View RunView 而不是这个View
    --local sp = setOpacity(setAnchor(setSize(setPos(addSprite(self.temp, "计分数字初始.png"), {385, fixY(sz.height, 127)}), {67, 85}), {0.50, 0.50}), 255)
    self.needUpdate = true
    registerEnterOrExit(self)
    self.passTime = 0
    centerUI(self)

    self.touch = ui.newFullTouch({delegate=self, touchBegan=self.touchBegan, touchMoved=self.touchMoved, touchEnded = self.touchEnded})
    self.bg:addChild(self.touch.bg)
end

function Ready:update(diff)
    --[[
    self.passTime = self.passTime+diff
    local y = math.sin(self.passTime*3.14)*20+fixY(self.sz.height, 494) 
    local p = getPos(self.bird)
    setPos(self.bird, {p[1], y})
    --]]
end
function Ready:touchBegan()
end
function Ready:touchMoved()
end
function Ready:touchEnded()
    global.director:popView()
    self.scene.bird.tap = true
end
