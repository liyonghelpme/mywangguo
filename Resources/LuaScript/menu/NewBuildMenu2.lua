NewBuildMenu2 = class()
function NewBuildMenu2:ctor()
    local vs = getVS()
    self.bg = CCNode:create()
    local sz = {width=752, height=601}
    self.temp = setPos(addNode(self.bg), {192, fixY(vs.height, 66+sz.height)})

    local sp = setAnchor(setSize(setPos(addSprite(self.temp, "taba.png"), {711, fixY(sz.height, 426)}), {82, 126}), {0.5, 0.5})
    local sp = setAnchor(setSize(setPos(addSprite(self.temp, "taba.png"), {711, fixY(sz.height, 291)}), {82, 126}), {0.5, 0.5})
    local sp = setAnchor(setSize(setPos(addSprite(self.temp, "dialogA.png"), {338, fixY(sz.height, 316)}), {677, 569}), {0.5, 0.5})
    local sp = setAnchor(setSize(setPos(addSprite(self.temp, "dialogB.png"), {338, fixY(sz.height, 329)}), {617, 396}), {0.5, 0.5})
    local sp = setAnchor(setSize(setPos(addSprite(self.temp, "tabb.png"), {711, fixY(sz.height, 156)}), {82, 126}), {0.5, 0.5})
    self.envTab = sp

    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="商店", size=34, color={102, 4, 554}})), {0.50, 0.50}), {329, fixY(sz.height, 87)})

    local but = ui.newButton({image="taba.png", delegate=self, touchBegan=self.onTab, param=3})
    setPos(addChild(self.temp, but.bg), {711, fixY(sz.height, 426)})
    self.storeTab = but
    local sp = setAnchor(setSize(setPos(addSprite(but.bg, "storeIcon.png"), {33-82/2, fixY(126, 63)-126/2}), {54, 51}), {0.50, 0.50})

    local but = ui.newButton({image="taba.png", delegate=self, param=2, touchBegan=self.onTab })
    setPos(addChild(self.temp, but.bg), {711, fixY(sz.height, 291)})
    self.laborTab = but
    local sp = setAnchor(setSize(setPos(addSprite(but.bg, "laborIcon.png"), {33-82/2, fixY(126, 63)-126/2}), {54, 51}), {0.50, 0.50})

    local but = ui.newButton({image="tabb.png", delegate=self, param=1, touchBegan=self.onTab})
    setPos(addChild(self.temp, but.bg), {711, fixY(sz.height, 156)})
    self.envTab = but
    local sp = setAnchor(setSize(setPos(addSprite(self.envTab.bg, "envIcon.png"), {33-82/2, fixY(126, 63)-126/2}), {54, 51}), {0.50, 0.50})
    self.tabs = {self.envTab, self.laborTab, self.storeTab}

    local but = ui.newButton({image="newClose.png", delegate=self, callback = self.onClose})
    setPos(addChild(self.temp, but.bg), {677, fixY(sz.height, 40)})

    self.HEIGHT = 368
    
    self.cl = Scissor:create()
    self.temp:addChild(self.cl)
    self.cl:setPosition(ccp(144-184/2, fixY(sz.height, 422+183/2)))
    self.cl:setContentSize(CCSizeMake(580, self.HEIGHT))

    self.flowNode = addNode(self.cl)
    setPos(self.flowNode, {0, self.HEIGHT})

    self.touch = ui.newTouchLayer({size={580, self.HEIGHT}, delegate=self, touchBegan=self.touchBegan, touchMoved=self.touchMoved, touchEnded=self.touchEnded})
    self.cl:addChild(self.touch.bg)
    setPos(self.touch.bg, {0, 0})

    self.flowHeight = 0
    self:updateTab()

    registerEnterOrExit(self)

    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="饮料店", size=24, color={0, 255, 255}})), {0.00, 0.50}), {58, fixY(sz.height, 556)})
    self.name = w
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="10000", size=24, color={0, 255, 255}})), {0.00, 0.50}), {188, fixY(sz.height, 556)})
    self.price = w
    local sp = setAnchor(setSize(setPos(addSprite(self.temp, "silverIcon.png"), {165, fixY(sz.height, 556)}), {34, 34}), {0.50, 0.50})
    self.icon = sp
    self:setSelect(1)
    self:setSel(1)
end
function NewBuildMenu2:setSel(s)
    if self.selBuild ~= s then
        print("self.", self.selBuild)
        if self.selBuild ~= nil then
            self.data[self.selBuild][1]:stopAllActions()
            self.data[self.selBuild][2]:stopAllActions()
            self.data[self.selBuild][1]:runAction(fadein(0.5))
            self.data[self.selBuild][2]:runAction(fadein(0.5))
        end
        self.selBuild = s
        self.data[self.selBuild][1]:runAction(repeatForever(sequence({fadeout(0.5), fadein(0.5)})))
        self.data[self.selBuild][2]:runAction(repeatForever(sequence({fadeout(0.5), fadein(0.5)})))
        local n = Logic.buildList[self.selBuild].name
        local p = Logic.buildList[self.selBuild].silver
        --global.director.curScene.menu.infoWord:setString(n.." "..p.."贯")
    end
end

function NewBuildMenu2:onTab(p)
    if self.curSel ~= p then
        self:setSelect(p)
    end
end

function NewBuildMenu2:setSelect(s)
    if self.curSel ~= nil then
        setTexture(self.tabs[self.curSel].sp, "taba.png")
    end
    self.curSel = s
    setTexture(self.tabs[self.curSel].sp, "tabb.png")
end
function NewBuildMenu2:enterScene()
    registerUpdate(self)
end
function NewBuildMenu2:update(diff)
end

function NewBuildMenu2:updateTab()
    local initX = 92
    local initY = -91
    local offX = 198
    local offY = 185
    self.data = {}
    print("updateTab", #Logic.buildList)
    local sz = {width=184, height=183}
    for k, v in ipairs(Logic.buildList) do
        local row = math.floor((k-1)/3)
        local col = (k-1)%3
        local sp = CCSprite:create("singleGoods.png")
        self.flowNode:addChild(sp)
        setPos(sp, {initX+col*offX, initY-offY*row})
        print("updateTab", row, col)
        sp:setTag(k)

        local build = CCSprite:create("build"..v.id..".png")
        sp:addChild(build)
        setPos(build, {92, fixY(183, 67)})
        local sca = getSca(build, {134, 100})
        setScale(build, sca)

        local w = setPos(setAnchor(addChild(sp, ui.newTTFLabel({text=v.name, size=18, color={0, 255, 255}})), {0.5, 0.5}), {92, fixY(sz.height, 146)})

        table.insert(self.data, {sp, build})
    end
    local row = math.floor((#Logic.buildList-1)/3)+1
    self.flowHeight = self.flowHeight+offY*row

end

--点击对齐网格
function NewBuildMenu2:touchBegan(x, y)
    self.lastPoints = {x, y}
    self.accMove = 0
    self.curSel = nil
end

function NewBuildMenu2:moveBack(dify)
    local ox, oy = self.flowNode:getPosition()
    self.flowNode:setPosition(ccp(ox, oy+dify))
end
function NewBuildMenu2:touchMoved(x, y)
    local oldPoints = self.lastPoints
    self.lastPoints = {x, y}
    local dify = self.lastPoints[2]-oldPoints[2]
    self.accMove = self.accMove+math.abs(dify)
    self:moveBack(dify)
end
function NewBuildMenu2:touchEnded(x, y)
    local newPos = {x, y}
    if self.accMove < 10 then
        local child = checkInChild(self.flowNode, newPos)
        if child ~= nil then
            print("touch child", child:getTag())
            local t = child:getTag()
            if self.selBuild ~= t then
                self:setSel(t)
            else
                local p = Logic.buildList[self.selBuild].silver
                if Logic.resource.silver < p then
                    addBanner("金钱不足!")
                else
                    global.director:popView() 
                    self.scene.menu:clearMenu()
                    self.btype = t            
                    if Logic.inNew and not Logic.newBuildYet then
                        Logic.newBuildYet = true
                        local w = Welcome2.new(self.onHouse, self)
                        w:updateWord("请拖拽画面选择建筑场所，点击建筑物可以进行微调。")
                        global.director:pushView(w, 1, 0)
                        return
                    end

                    self.scene.page:beginBuild('build', t)
                    return 
                end
            end
        end
    end


    if self.flowHeight < self.HEIGHT then
        self.minPos = 0
    else
        self.minPos = self.flowHeight-self.HEIGHT
    end


    local oldPos = getPos(self.flowNode)
    oldPos[2] = oldPos[2]-self.HEIGHT
    oldPos[2] = math.max(0, math.min(self.minPos, oldPos[2]))
    self.flowNode:setPosition(ccp(oldPos[1], oldPos[2]+self.HEIGHT))
    print("flowHeight ", self.flowHeight, self.minPos, self.HEIGHT, oldPos[2])
end

function NewBuildMenu2:onClose()
    global.director:popView()
end
