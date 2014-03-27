Welcome2 = class()
function Welcome2:ctor(cb, del)
    self.callback = cb
    self.delegate = del
    self.bg = CCNode:create()
    local vs = getVS()
    local temp = setPos(setContentSize(addChild(self.bg, display.newScale9Sprite("tabback.jpg")), {407, 240}), {vs.width/2, vs.height/2})
    self.temp = temp
    

    local but = ui.newButton({image="tabbut.png", text="确定", size=15, color={0, 0, 0}, callback=self.onOk, delegate=self})
    setPos(but.bg, {203, fixY(240, 216)})
    temp:addChild(but.bg)
    registerEnterOrExit(self)
end
function Welcome2:updateWord(w)
    if self.con ~= nil then
        removeSelf(self.con)
    end
    local con = colorLine({text=w, color={0, 0, 0}, size=15, width=341}) 
    setAnchor(setPos(addChild(self.temp, con), {27, fixY(240, 43)}), {0, 0})
    self.con = con
end
function Welcome2:onOk()
    global.director:popView()
    if self.callback ~= nil then
        self.callback(self.delegate)
    end
end
function Welcome2:enterScene()
    Logic.paused = true
end
function Welcome2:exitScene()
    Logic.paused = false
end
