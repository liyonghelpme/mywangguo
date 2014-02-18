require "Miao.PressMenu3"
require "myMap.FightMap"
TMXMenu2 = class()
function TMXMenu2:adjustPos()
end
function TMXMenu2:ctor(s)
    self.scene = s
    local vs = getVS()
    self.bg = CCNode:create()
    self.temp = addNode(self.bg)
    local temp = self.temp
    local sz = {width=1024, height=768}
    self.sz = sz

    local stateLabel = ui.newBMFontLabel({text="state", size=15, font="bound.fnt"})
    self.bg:addChild(stateLabel)
    setAnchor(setPos(stateLabel, {vs.width-200, vs.height-10}), {0, 1})
    self.stateLabel = stateLabel
    if not DEBUG then
        setVisible(self.stateLabel, false)
    end

    self.left = addNode(self.bg)
    local but = ui.newButton({image="buta.png", text="地图", font="f2", size=30, delegate=self, callback=self.onLeft, color=hexToDec('ce4e00'),  shadowColor={255, 255, 255}})
    but:setContentSize(107, 113)
    setPos(addChild(self.left, but.bg), {76, fixY(sz.height, 706)})
    self.leftBut = but
    leftBottomUI(self.left)
    

    self.right = addNode(self.bg)
    local but = ui.newButton({image="buta.png", text="菜单", font="f2", size=30, shadowColor={255, 255, 255}, color=hexToDec('ce4e00'), delegate=self, callback=self.onMenu})
    but:setContentSize(107, 113)
    setScriptTouchPriority(but.bg, -256)
    setPos(addChild(self.right, but.bg), {945, fixY(sz.height, 706)})
    self.mbut = but
    rightBottomUI(self.right)

    self.top = addNode(self.temp)

    local sz = {width=1024, height=768} 
    self.sz = sz
    local sp = setAnchor(setSize(setPos(addSprite(self.top, "numBack.png"), {818, fixY(sz.height, 32)}), {155, 30}), {0.50, 0.50})
    local but = ui.newButton({image="chargeIcon.png", delegate=self, callback=self.onCharge})
    setPos(addChild(self.top, but.bg), {902, fixY(sz.height, 33)})
    local sp = setAnchor(setSize(setPos(addSprite(self.top, "goldIcon.png"), {748, fixY(sz.height, 35)}), {54, 55}), {0.50, 0.50})
    local w = setPos(setAnchor(addChild(self.top, ui.newTTFLabel({text="10000", size=25, color={255, 255, 255}, font="f2"})), {0.50, 0.50}), {830, fixY(sz.height, 31)})
    self.gold = w
    local sp = setAnchor(setSize(setPos(addSprite(self.top, "numBack.png"), {606, fixY(sz.height, 32)}), {155, 30}), {0.50, 0.50})
    local sp = setAnchor(setSize(setPos(addSprite(self.top, "silverIcon.png"), {536, fixY(sz.height, 34)}), {54, 55}), {0.50, 0.50})
    local w = setPos(setAnchor(addChild(self.top, ui.newTTFLabel({text="10000", size=25, color={255, 255, 255}, font="f2"})), {0.50, 0.50}), {618, fixY(sz.height, 31)})
    self.silver = w

    local w = setPos(setAnchor(addChild(self.top, ui.newTTFLabel({text="喵喵村喵喵村", size=25, color={255, 255, 255}, font="f2"})), {0.00, 0.50}), {92, fixY(sz.height, 31)})
    self.events = {EVENT_TYPE.SHOW_DIALOG, EVENT_TYPE.CLOSE_DIALOG, EVENT_TYPE.UPDATE_RESOURCE}

    centerTop(self.top)
    
    self.leftTop = addNode(self.bg)
    self.battleLabel = ui.newButton({image="info.png", conSize={250, 50}, text="距离合战开始还有1周", color={0, 0, 0}, size=18, spr=false})
    addChild(self.leftTop, self.battleLabel.bg)
    setPos(self.battleLabel.bg, {133, fixY(sz.height, 96)})
    leftTopUI(self.leftTop)
    setVisible(self.battleLabel.bg, false)


    registerEnterOrExit(self)
    self.needUpdate = true
    self.passTime = 0
end

function TMXMenu2:update(diff)
    if not Logic.paused then
        self.passTime = self.passTime + diff
        if self.passTime > 1 then
            self.passTime = 0
            self:updateYear()
            if Logic.catData ~= nil then
                setVisible(self.battleLabel.bg, true)
                local tt = math.ceil(getLeftTime())
                --local y, m, w = convertTimeToWeek(tt)
                print("update battle data", tt, y, m, w)
                self.battleLabel.text:setString(string.format("距离合战开始还有%d秒", tt))
            else
                setVisible(self.battleLabel.bg, false)
            end
        end
    end
end

function TMXMenu2:onLeft()
    print("onLeft", self.inBuild)
    if self.inBuild then
        global.director.curScene.page.curBuild:doSwitch()
    else
        if Logic.showMapYet then
            if global.director.curScene.name == "TMXScene" then
                global.director:pushScene(FightMap.new())
            end
        end
    end
end

function TMXMenu2:receiveMsg(msg, para)
    if msg == EVENT_TYPE.UPDATE_RESOURCE then
        self:updateText()
    elseif msg == EVENT_TYPE.SHOW_DIALOG then
        self.mbut.text:setString("返回")
        setVisible(self.leftBut.bg, false)
        self.mbut.shadowWord:setString("返回")
    elseif msg == EVENT_TYPE.CLOSE_DIALOG then
        self.mbut.text:setString("菜单")
        setVisible(self.leftBut.bg, true)
        self.mbut.shadowWord:setString("菜单")
    end
end
function TMXMenu2:onMenu()
    if self.inBuild then
        global.director.curScene.page:cancelBuild()
    elseif #global.director.stack == 0 then
        global.director:pushView(PressMenu3.new(), 1, 0)
    else
        global.director:popView()
    end
end
function TMXMenu2:beginBuild()
    self.mbut.text:setString("返回")
    self.mbut.shadowWord:setString("返回")
    self.leftBut.text:setString("旋转")
    self.leftBut.shadowWord:setString("旋转")
    self.inBuild = true
    self:adjustLeftShow()
end

function TMXMenu2:finishBuild()
    self.mbut.text:setString("菜单")
    self.mbut.shadowWord:setString("菜单")
    self.leftBut.text:setString("地图")
    self.leftBut.shadowWord:setString("地图")
    self.inBuild = false
    self:adjustLeftShow()
end

function TMXMenu2:adjustLeftShow()
    if not Logic.showMapYet then
        setVisible(self.leftBut.bg, false)
    else
        setVisible(self.leftBut.bg, true)
    end
end
function TMXMenu2:initDataOver()
    self:updateText()
    self:updateYear()
    self:adjustLeftShow()
end

function TMXMenu2:updateText()
    self.silver:setString(Logic.resource.silver)
    self.gold:setString(Logic.resource.gold)
end

function TMXMenu2:updateYear()
    local y, m, w = getDate()
    if self.year ~= nil then
        removeSelf(self.year)
    end

    local word = colorWords({text=string.format("<68c8ff%d><ffffff年><68c8ff%d><ffffff月><68c8ff%d><ffffff周>", y, m, w), size=25, font='f2'})
    setPos(setAnchor(addChild(self.top, word), {0, 0.5}), {300, fixY(self.sz.height, 31)})
    self.year = word
end

function TMXMenu2:setMenu(m)
    self.menu = m
    self.mbut.text:setString("返回")
    self.mbut.shadowWord:setString("返回")
end
