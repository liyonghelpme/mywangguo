Dark = class()
function Dark:ctor(auto, showDark)
    self.autoPop = auto
    self.bg = CCLayer:create()
    if showDark == 1 then
        local sp = CCSprite:create("black.png")
        sp:setOpacity(255*0.4)
        setPos(sp, {global.director.disSize[1]/2, global.director.disSize[2]/2})
        setSize(sp, global.director.disSize)
        self.bg:addChild(sp)
    end
    --[[
    local sp = CCSprite:create("images/black.png")
    --sp:setColor(ccc3(0, 0, 0))
    --sp:setOpacity(0.5)
    sp:setOpacity(255)
    sp:setColor(ccc3(255, 255, 255))
    setPos(sp, {global.director.disSize[1]/2, global.director.disSize[2]/2})
    setSize(sp, global.director.disSize)
    self.bg:addChild(sp)
    --]]
    registerEnterOrExit(self)
    registerTouch(self)
end

function Dark:touchBegan(x, y)
    return true
end
function Dark:touchMoved(x, y)
end
function Dark:touchEnded(x, y)
    if self.autoPop == 1 then
        global.director.popView()
    end
end

function Dark:enterScene()

end
function Dark:exitScene()
end

