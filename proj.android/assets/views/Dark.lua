Dark = class()
function Dark:ctor(auto)
    self.autoPop = auto
    self.bg = CCLayer:create()
    local sp = CCSprite:create("images/black.png")
    sp:setColor(ccc3(0, 0, 0))
    sp:setOpacity(0.5)
    setSize(sp, global.director.disSize)
    registerEnterOrExit(self)
    registerTouch(self)
end

function Dark:touchBegan(x, y)
    return true
end
function Dark:touchMoved(x, y)
end
function Dark:touchEnded(x, y)
    if self.autoPop then
        global.director.popView()
    end
end

function Dark:enterScene()

end
function Dark:exitScene()
end

