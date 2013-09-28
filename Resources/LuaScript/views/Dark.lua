Dark = class()
function Dark:ctor(auto, gray, bigDark)
    self.autoPop = auto
    self.bg = CCLayer:create()
    print("Dark ctor", auto, gray)
    if gray == 1 then
        local sp = CCSprite:create("black.png")
        sp:setOpacity(255)
        sp:setColor(ccc3(255, 255, 255))
        setPos(sp, {global.director.disSize[1]/2, global.director.disSize[2]/2})
        setSize(sp, global.director.disSize)
        self.bg:addChild(sp)
    elseif bigDark == 1 then
        local sp = CCSprite:create("bigDark.png")
        sp:setOpacity(255)
        sp:setColor(ccc3(255, 255, 255))
        setPos(sp, {global.director.disSize[1]/2, global.director.disSize[2]/2})
        setSize(sp, global.director.disSize)
        self.bg:addChild(sp)
    end
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
        global.director:popView()
    end
end

function Dark:enterScene()

end
function Dark:exitScene()
end

