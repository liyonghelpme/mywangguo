TestMenu = class()
function TestMenu:ctor()
    self.bg = CCScene:create()
    local temp = CCSprite:create("testMenu.png")
    addChild(self.bg, temp)
    local vs = getVS()
    setPos(temp, {vs.width/2, vs.height/2})
end
