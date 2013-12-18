require "Miao.PressMenu2"
TMXMenu2 = class()
function TMXMenu2:ctor(s)
    self.scene = s
    local vs = getVS()
    self.bg = CCNode:create()
    self.temp = addNode(self.bg)
    local temp = self.temp
    local sz = vs
    self.sz = sz

    local but = ui.newButton({image="buta.png", text="地图"})
    setPos(addChild(temp, but.bg), {62, fixY(768, 704)})
    self.leftBut = but
    local but = ui.newButton({image="buta.png", text="菜单", delegate=self, callback=self.onMenu})
    setScriptTouchPriority(but.bg, -256)
    setPos(addChild(temp, but.bg), {vs.width-fixX(1024, 961), fixY(768, 704)})
    self.mbut = but
    local sp = setSize(setPos(addSprite(self.temp, "numBack.png"), {110, fixY(sz.height, 72)}), {156, 30})
    local sp = setSize(setPos(addSprite(self.temp, "silverIcon.png"), {39, fixY(sz.height, 72)}), {50, 50})
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="10000", size=18, color={255, 255, 255}})), {0, 0.5}), {79, fixY(sz.height, 70)})
    self.silver = w

    local sp = setSize(setPos(addSprite(self.temp, "numBack.png"), {288, fixY(sz.height, 72)}), {156, 30})
    local sp = setSize(setPos(addSprite(self.temp, "chargeIcon.png"), {349, fixY(sz.height, 73)}), {33, 37})
    local sp = setSize(setPos(addSprite(self.temp, "goldIcon.png"), {217, fixY(sz.height, 73)}), {50, 50})
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="10000", size=18, color={255, 255, 255}})), {0, 0.5}), {257, fixY(sz.height, 70)})
    self.gold = w

    local w = colorWords({text="<57b7fd999><ffffff年><57b7fd12><ffffff月><57b7fd7><ffffff周>"})
    setPos(setAnchor(addChild(self.temp, w), {0, 0.5}), {210, fixY(sz.height, 24)})
    self.year = w


    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="最长的村落名字", size=24, color={255, 255, 255}})), {0, 0.5}), {16, fixY(sz.height, 25)})
    self.events = {EVENT_TYPE.SHOW_DIALOG, EVENT_TYPE.CLOSE_DIALOG}
    registerEnterOrExit(self)
end

function TMXMenu2:receiveMsg(msg, para)
    if msg == EVENT_TYPE.SHOW_DIALOG then
        self.mbut.text:setString("返回")
    elseif msg == EVENT_TYPE.CLOSE_DIALOG then
        self.mbut.text:setString("菜单")
    end
end
function TMXMenu2:onMenu()
    if self.inBuild then
        global.director.curScene.page:cancelBuild()
    elseif #global.director.stack == 0 then
        global.director:pushView(PressMenu2.new(), 1, 0)
    else
        global.director:popView()
    end
end
function TMXMenu2:beginBuild()
    self.mbut.text:setString("返回")
    self.leftBut.text:setString("旋转")
    self.inBuild = true
end

function TMXMenu2:finishBuild()
    self.mbut.text:setString("菜单")
    self.leftBut.text:setString("地图")
    self.inBuild = false
end

function TMXMenu2:initDataOver()
    self:updateText()
    self:updateYear()
end

function TMXMenu2:updateText()
    self.silver:setString(Logic.resource.silver.."贯")
end

function TMXMenu2:updateYear()
    local y, m, w = getDate()
    removeSelf(self.year)

    local word = colorWords({text=string.format("<57b7fd%d><ffffff年><57b7fd%d><ffffff月><57b7fd%d><ffffff周>", y, m, w)})
    setPos(setAnchor(addChild(self.temp, word), {0, 0.5}), {210, fixY(self.sz.height, 24)})
    self.year = word
end

function TMXMenu2:setMenu(m)
    self.menu = m
    self.mbut.text:setString("返回")
end