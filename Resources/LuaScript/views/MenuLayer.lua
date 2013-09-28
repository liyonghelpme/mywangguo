
MenuLayer = class()
function MenuLayer:ctor(sc)
    self.scene = sc
    self.menus = {nil, nil}
    self.showChildMenu = false
    self.MainMenuFunc = {
    [0]={"map", "rank", "plan", "setting"},
    [1]={"role", "store", "friend", "mail"},
    }
    self:initView()
end
function MenuLayer:initView()
    self.bg = CCLayer:create()
    self.banner = setSca(setPos(setAnchor(addSprite(self.bg, "images/menu_back.png"), {0, 0}), {0, 0}), global.director.disSize[1]/global.director.designSize[1])

    local temp = setPos(setAnchor(addSprite(self.banner, "images/menuFeather.png"), {0, 0}), {107, fixY(global.director.disSize[2], 367, 59)})
    
    self.taskButton = ui.newButton({image="images/task.png", delegate=self, callback=self.onTask}) 
    setPos(self.taskButton.bg, {12, fixY(nil, 395, 82)})
    self.banner:addChild(self.taskButton.bg)
    
    self.taskFin = setPos(setAnchor(addSprite(self.banner, "images/taskFin0.png"), {0, 0}), {83, fixY(nil, 402, 27)})
    self.finNum = setColor(setPos(setAnchor(addLabel(self.banner, getStr("99+", nil), "", 18), {0.5, 0.5}), {96, fixY(nil, 416, 0, 0.5)}), {255, 255, 255})
    
    self.expfiller = setAnchor(addSprite(self.banner, "images/exp_filler.png"), {0, 0})
    setPos(self.expfiller, {133, fixY(nil, 419, getHeight(self.expfiller))})

    self.expBack = setPos(setAnchor(addSprite(self.banner, "images/level0.png"), {0, 0}), {120, fixY(nil, 406, 36)})
    
    local expSize = self.expBack:getContentSize()
    self.levelLabel = setPos(setAnchor(addNode(self.expBack), {0.5, 0.5}), {expSize.width/2, expSize.height/2})
    
    self.expBanner = setVisible(setPos(setAnchor(CCSprite:create("images/expBanner.png"), {0, 0}), {123, fixY(nil, 432, 50)}), false)
    self.banner:addChild(self.expBanner)

    self.expWord = ShadowWords.new(getStr("expToLev", nil), "", 17, nil, {255, 255, 255})
    setPos(setAnchor(self.expWord.bg, {0.5, 0.5}), {75, 28})
    self.expBanner:addChild(self.expWord.bg)

    self.collectionButton = ui.newButton({image="images/mainRank.png", delegate=self, callback=self.onRank})
    setPos(self.collectionButton.bg, {229, fixY(nil, 445, 34)})
    self.banner:addChild(self.collectionButton.bg)

    self.chargeButton = ui.newButton({image="images/recharge.png", delegate=self, callback=self.openCharge})
    setAnchor(setPos(self.chargeButton.bg, {439, fixY(nil, 444, 35)}), {0, 0})
    self.banner:addChild(self.chargeButton.bg)

    self.menuButton = ui.newButton({image="images/menu_button.png", delegate=self, callback=self.onClicked, param=0})
    setPos(setAnchor(self.menuButton.bg, {0, 0}), {685, fixY(nil, 380, 106)})
    self.banner:addChild(self.menuButton.bg)

    self:initText() 
end
function MenuLayer:initText()
    self.silverText = setColor(setPos(setAnchor(addLabel(self.banner, getStr("1", nil), "", 23), {0, 0.5}), {333, fixY(nil, 461, nil, 0.5)}), {255, 255, 255})
    self.goldText = setColor(setPos(setAnchor(addLabel(self.banner, getStr("2", nil), "", 23), {0, 0.5}), {588, fixY(nil, 461, nil, 0.5)}), {255, 255, 255})
    local w = ''..global.user.rankOrder
    if global.user.rankOrder > 999 then
        w = '999+'
    end
    self.gloryLevText = setColor(setPos(setAnchor(addLabel(self.banner, w, "", 16), {0.5, 0.5}), {169, fixY(nil, 461, nil, 0.5)}), {255, 255, 255})

end

function MenuLayer:onTask()
end

function MenuLayer:onRank()
end

function MenuLayer:openCharge()
end

function MenuLayer:onClicked()
    if not self.showChildMenu then
        self:drawAllMenu()
    else
        self:cancelAllMenu()
    end
end

function MenuLayer:updateRightMenu()
end
function MenuLayer:drawFunc(index, funcs)
    self:updateRightMenu()
    --先移除旧的菜单再显示新的菜单
    --因为菜单可能正在移除过程中
    if self.menus[index] ~= nil then
        self.menus[index].bg:removeFromParentAndCleanup(true)
    end
    self.menus[index] = ChildMenuLayer.new(index, funcs, self.scene, self.MainMenuFunc[1-index], self)
    self.bg:addChild(self.menus[index].bg, -1)
end
--action 正在进行时 需要等待action结束么?
function MenuLayer:drawAllMenu()
    self.showChildMenu= true
    self:drawFunc(0, {"map", "rank", "plan", "setting"})
    self:drawFunc(1, {"soldier", "store", "friend", "mail"})
end
function MenuLayer:cancelFunc(index)
    self.menus[index]:removeSelf()
end

function MenuLayer:cancelAllMenu()
    if self.showChildMenu then
        self.showChildMenu = false
        self:cancelFunc(0)
        self:cancelFunc(1)
    end
end
--关闭并且隐藏菜单 visible false 
--左右子菜单 隐藏下方banner
function MenuLayer:hideMenu(t)
    self:cancelAllMenu()
    self.banner:stopAllActions()
    self.banner:runAction(expout(moveby(0.3, 0, -100))) 
    --runAction(self.bg, sequence(fadeout(), callfunc(self:beg)))
end

function MenuLayer:showMenu()
    self.banner:stopAllActions()
    self.banner:runAction(expin(moveby(0.3, 0, 100)))
end



