Loading = class()
function Loading:ctor()
    self.bg = CCLayer:create()
    setDesignScale(self.bg)

    registerTouch(self)
    registerUpdate(self)
    registerEnterOrExit(self)

    local temp = setColor(setSize(setPos(setAnchor(addSprite(self.bg, "loadMain.png"), {0, 0}), {0, 0}), global.director.disSize), {255, 255, 255, 255})


    setSize(setPos(setAnchor(addSprite(self.bg, "wangguoLogo.png"), {0, 0}), {19,  fixY(480, 4, 116)}), {184, 116})
    addAction(setSize(setPos(setAnchor(addSprite(self.bg, "loadingCircle.png"), {0.5, 0.5}), {763, fixY(480, 37, 0)}), {50, 57}), repeatForever(rotateby(2000, 360)))
    setSize(setPos(setAnchor(addSprite(self.bg, "loadingWord.png"), {0, 0}), {607, fixY(480, 23, 29)}), {129, 29}) 
    addAction(setAnchor(setPos(addSprite(self.bg, nil), {0, 0}), {0, 0}), repeatForever(animate(1500, frames("lighting%d.png", 0, 6))))
    
    self.processNum = altasWord('red', '0%')
    self.bg:addChild(self.processNum)
    local sz = self.processNum:getContentSize()
    setPos(setAnchor(self.processNum, {0.5, 0.5}), {400, fixY(480, 394, sz.height)})

    self.passTime = 0
    self.curProcess = 0
    self.hopeProcess = 0

    --print("enterScene")
    Event:registerEvent(EVENT_TYPE.INITDATA, self)
end
function Loading:touchBegan(x, y)
    return true
end
function Loading:touchMoved(x, y)
end
function Loading:touchEnded(x, y)
end
function Loading:update(diff)
    self.passTime = self.passTime+diff
    if self.passTime > 0.5 then
        if self.curProcess < 100 then
            self.curProcess = self.curProcess + 1
            self.processNum:removeFromParentAndCleanup(true)
            self.processNum = altasWord("red", ''..self.curProcess..'%')
            self.bg:addChild(self.processNum)
            local sz = self.processNum:getContentSize()
            setPos(setAnchor(self.processNum, {0.5, 0.5}), {400, fixY(480, 394, sz.height)})
        elseif self.hopeProcess == 100 then
            --可能在loading的过程中出现新的对话框么 不能出现必须loading结束
            --sendMsg 检测场景
            global.director:popView()
            --removeSelf(self.bg)
            Event:unregisterEvent(EVENT_TYPE.INITDATA, self)
        end
        self.passTime = 0
    end
end
function Loading:enterScene()

end
function Loading:exitScene()

end
function Loading:receiveMsg(name, msg)
    print('receiveMsg')
    if name == EVENT_TYPE.INITDATA then
        --self.curProcess = 100
        self.curProcess = 99
        self.hopeProcess = 100
    end
end
