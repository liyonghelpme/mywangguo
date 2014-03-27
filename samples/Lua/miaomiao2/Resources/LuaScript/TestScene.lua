TestScene = class()
function TestScene:ctor()
    self.bg = CCScene:create()

    local tex = addETCImage("water.etc1")
    local sea = CCSprite:createWithTexture(tex)
    setPos(addChild(self.bg, sea), {100, 100})


    --local tex = CCTextureCache:sharedTextureCache():addImage("t.png")
    local tex = addETCImage("t.etc1")
    local p = CCSprite:createWithTexture(tex)
    setGLProgram(p, "etc", "Vert.h", "Frag.h")
    setScaleY(setPos(addChild(self.bg, p), {150, 150}), 0.5)

    --local sz = p:getContentSize()
    --sz.height = sz.height/2
    --p:setContentSize(sz)
end
