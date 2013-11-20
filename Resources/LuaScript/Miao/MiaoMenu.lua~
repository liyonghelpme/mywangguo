require "Miao.PressMenu"
MiaoMenu = class()
function MiaoMenu:ctor(s)
    self.scene = s
    self.bg = CCNode:create()
    setPos(self.bg, {0, 0})
    local but = ui.newButton({image="roleNameBut0.png", conSize={100, 50}, callback=self.onBuild, delegate=self, text="道路", size=20})
    setPos(but.bg, {50, 50})
    but:setAnchor(0.5, 0.5)
    self.bg:addChild(but.bg)

    local but = ui.newButton({image="roleNameBut0.png", conSize={100, 50}, callback=self.onOk, delegate=self, text="确定", size=20})
    setPos(but.bg, {150, 50})
    but:setAnchor(0.5, 0.5)
    self.bg:addChild(but.bg)

    local but = ui.newButton({image="roleNameBut0.png", conSize={100, 50}, callback=self.onPeople, delegate=self, text="人物", size=20, param=1})
    setPos(but.bg, {250, 50})
    but:setAnchor(0.5, 0.5)
    self.bg:addChild(but.bg)
    
    local but = ui.newButton({image="roleNameBut0.png", conSize={100, 50}, callback=self.onPeople, delegate=self, text="商人", size=20, param=2})
    setPos(but.bg, {350, 50})
    but:setAnchor(0.5, 0.5)
    self.bg:addChild(but.bg)

    local but = ui.newButton({image="roleNameBut0.png", conSize={100, 50}, callback=self.onCat, delegate=self, text="猫咪", size=20, param=3})
    setPos(but.bg, {550, 100})
    but:setAnchor(0.5, 0.5)
    self.bg:addChild(but.bg)


    --拆除道路和 建筑物
    local but = ui.newButton({image="roleNameBut0.png", conSize={100, 50}, callback=self.onRemove, delegate=self, text="拆除", size=20, param=2})
    setPos(but.bg, {450, 50})
    but:setAnchor(0.5, 0.5)
    self.bg:addChild(but.bg)

    local but = ui.newButton({image="roleNameBut0.png", conSize={100, 50}, callback=self.onMove, delegate=self, text="移动", size=20, param=2})
    setPos(but.bg, {550, 50})
    but:setAnchor(0.5, 0.5)
    self.bg:addChild(but.bg)


    self.menu = nil
    local but = ui.newButton({image="roleNameBut0.png", conSize={100, 50}, callback=self.onMenu, delegate=self, text="菜单", size=20, param=2, priority=-127})
    setPos(but.bg, {vs.width-60, 100})
    but:setAnchor(0.5, 0.5)
    self.bg:addChild(but.bg)
    self.mbut = but
    --在进入场景之前 否则需要disable touch enabletouch

    local but = ui.newButton({image="roleNameBut0.png", conSize={100, 50}, callback=self.onSave, delegate=self, text="保存", size=20, param=2, priority=-127})
    setPos(but.bg, {vs.width-60, 50})
    but:setAnchor(0.5, 0.5)
    self.bg:addChild(but.bg)

    local vs = getVS()
    local stateLabel = ui.newBMFontLabel({text="state", size=15, font="bound.fnt"})
    self.bg:addChild(stateLabel)
    setAnchor(setPos(stateLabel, {vs.width-200, vs.height-10}), {0, 1})
    self.stateLabel = stateLabel
end
function MiaoMenu:onSave()
    self.scene:saveGame()
end
function MiaoMenu:onMenu()
    if self.menu == nil then
        self.menu = PressMenu.new(self.scene)
        global.director:pushView(self.menu, 1, 0)

        print("priority 没办法调整啊 script的 Touch Entry 优先级")
        local function adp()
            setScriptTouchPriority(self.mbut.bg, -256)
        end
        --调整touch 优先级需要在touch处理结束之后 进行 touch中调整没有效果
        delayCall(1, adp)
        self.mbut.text:setString("返回")
    else
        self.menu = nil
        global.director:popView()
        self.mbut.text:setString("菜单")
    end
end
function MiaoMenu:clearMenu()
    self.menu = nil
    self.mbut.text:setString("菜单")
end
function MiaoMenu:onCat()
    self.scene.page.buildLayer:addCat()
end
function MiaoMenu:initDataOver()
    local initX = 50
    local initY = 100
    local offX = 100
    local offY = 70
    local col = 5
    local n = 0
    for k, v in ipairs(Logic.buildList) do
        local r = math.floor(n/col)
        local c = n%col

        local but = ui.newButton({image="roleNameBut0.png", conSize={100, 50}, callback=self.onHouse, delegate=self, text=v.name, size=20, param=v.id})
        setPos(but.bg, {initX+offX*c, initY+offY*r})
        but:setAnchor(0.5, 0.5)
        self.bg:addChild(but.bg)
        n = n+1
    end
    
end
function MiaoMenu:onBuild()
    self.scene.page:beginBuild('t', 0)
end
function MiaoMenu:onOk()
    self.scene.page:finishBuild()
end
function MiaoMenu:onHouse(param)
    self.scene.page:beginBuild('build', param)
end
function MiaoMenu:onPeople(param)
    self.scene.page:addPeople(param)
end
function MiaoMenu:onRemove()
    self.scene.page:onRemove()
end
function MiaoMenu:onMove()
    self.scene.page:onMove()
end
