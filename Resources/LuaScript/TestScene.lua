TestScene = class()
function TestScene:ctor()
    self.bg = CCScene:create()
    local sp = createSprite("near2.png")
    setPos(setAnchor(addChild(self.bg, sp), {0, 0}), {100, 100})
    setGLProgram(sp)

    --local sp = createSprite("near2.png")
    --setPos(setAnchor(addChild(self.bg, sp), {0, 0}), {100, 100})
end

