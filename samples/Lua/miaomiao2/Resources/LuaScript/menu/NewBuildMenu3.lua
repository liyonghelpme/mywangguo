NewBuildMenu3 = class()
--设计坐标转化成实际坐标
--cl 转换
function NewBuildMenu3:adjustPos()
    local vs = getVS()
    local ds = global.director.designSize
    local sca = math.min(vs.width/ds[1], vs.height/ds[2])
    local pos = getPos(self.temp)
    local cx, cy = ds[1]/2-pos[1], ds[2]/2-pos[2]
    local nx, ny = vs.width/2-cx*sca, vs.height/2-cy*sca

    setScale(self.temp, sca)
    setPos(self.temp, {nx, ny})

    --调整切割屏幕高度
    self.cl:setContentSize(CCSizeMake(580, self.HEIGHT*sca))
end
function NewBuildMenu3:onBut()
    global.director:popView()
end

function NewBuildMenu3:ctor()
    local vs = getVS()
    self.bg = CCNode:create()
    local sz = {width=1024, height=768}
    self.temp = setPos(addNode(self.bg), {0, fixY(sz.height, 0+sz.height)+0})
    local sp = setAnchor(setSize(setPos(addSprite(self.temp, "dialogA.png"), {525, fixY(sz.height, 388)}), {693, 588}), {0.50, 0.50})
    local sp = setAnchor(setSize(setPos(addSprite(self.temp, "dialogC.png"), {525, fixY(sz.height, 403)}), {625, 397}), {0.50, 0.50})

    local but = ui.newButton({image="newClose.png", text="", font="f1", size=18, delegate=self, callback=self.onBut, shadowColor={0, 0, 0}, color={255, 255, 255}})
    but:setContentSize(80, 82)
    setPos(addChild(self.temp, but.bg), {848, fixY(sz.height, 112)})
    local sp = setAnchor(setSize(setPos(addSprite(self.temp, "envTitle.png"), {529, fixY(sz.height, 148)}), {97, 42}), {0.50, 0.50})
    self.title = sp

    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="饮料店", size=26, color={0, 255, 255}, font="f2", shadowColor={0, 0, 0}})), {0.00, 0.50}), {247, fixY(sz.height, 624)})
    self.name = w
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="10000", size=26, color={0, 255, 255}, font="f2", shadowColor={0, 0, 0}})), {0.00, 0.50}), {411, fixY(sz.height, 625)})
    self.price = w
    local sp = setAnchor(setSize(setPos(addSprite(self.temp, "silverIcon.png"), {384, fixY(sz.height, 627)}), {31, 32}), {0.50, 0.50})
    self.icon = sp

    local but = ui.newButton({image="atttab.png", text="", font="f1", size=18, delegate=self, needScale=false, touchBegan=self.onTab, param=3, shadowColor={0, 0, 0}, color={255, 255, 255}})
    but:setContentSize(101, 127)
    local sp = setAnchor(setPos(addSprite(but.bg, "storeIcon.png"), {48-101/2, fixY(127, 68)-127/2}), {0.50, 0.50})
    local sp = setOpacity(setAnchor(addSprite(but.bg, "atttabdark.png"), {0.50, 0.50}), 128)
    but.attDark = sp
    setPos(addChild(self.temp, but.bg), {915, fixY(sz.height, 550)})
    self.storeTab = but
    but.bg:setZOrder(-1)

    local but = ui.newButton({image="atttab.png", text="", font="f1", size=18, delegate=self, needScale=false, touchBegan=self.onTab, param=2,shadowColor={0, 0, 0}, color={255, 255, 255}})
    but:setContentSize(101, 127)
    local sp = setAnchor(setPos(addSprite(but.bg, "laborIcon.png"), {48-101/2, fixY(127, 68)-127/2}), {0.50, 0.50})
    local sp = setOpacity(setAnchor(addSprite(but.bg, "atttabdark.png"), {0.50, 0.50}), 128)
    but.attDark = sp
    setPos(addChild(self.temp, but.bg), {915, fixY(sz.height, 401)})
    self.laborTab = but
    but.bg:setZOrder(-1)

    local but = ui.newButton({image="atttab.png", text="", font="f1", size=18, delegate=self, needScale=false, touchBegan=self.onTab, param=1, shadowColor={0, 0, 0}, color={255, 255, 255}})
    but:setContentSize(101, 127)
    setPos(addChild(self.temp, but.bg), {916, fixY(sz.height, 252)})
    self.envTab = but
    local sp = setAnchor(setPos(addSprite(but.bg, "envIcon.png"), {48-101/2, fixY(127, 68)-127/2}), {0.50, 0.50})
    local sp = setOpacity(setAnchor(addSprite(but.bg, "atttabdark.png"), {0.50, 0.50}), 128)
    but.attDark = sp
    self.tabs = {self.envTab, self.laborTab, self.storeTab}


    local listSize = {width=597, height=375}
    self.listSize = listSize
    self.HEIGHT = 375
    self.cl = Scissor:create()
    self.temp:addChild(self.cl)
    setPos(self.cl, {229, fixY(sz.height, 223+listSize.height)})
    setContentSize(self.cl, {listSize.width, listSize.height})
    self.flowNode = addNode(self.cl)
    setPos(self.flowNode, {0, self.HEIGHT})
    self.touch = ui.newTouchLayer({size={listSize.width, self.HEIGHT}, delegate=self, touchBegan=self.touchBegan, touchMoved=self.touchMoved, touchEnded=self.touchEnded})
    self.cl:addChild(self.touch.bg)
    setPos(self.touch.bg, {0, 0})
    self.flowHeight = 0

    registerEnterOrExit(self)
    self:setSelect(1)
    centerUI(self)
end
function NewBuildMenu3:setView(s)
    self:updateTab()
    self.selBuild = nil
    self:setSel(1)
    if self.scrollPro ~= nil then
        setPos(self.scrollPro, {0, 315})
    end
end

--点击开始
function NewBuildMenu3:setSel(s)
    --if self.selBuild ~= s then
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
        local bd = Logic.ownBuild[self.data[self.selBuild][3]]
        bd = Logic.buildings[bd]
        local n = bd.name
        local p = bd.silver
        self.name:setString(n)
        self.price:setString(p)
        --global.director.curScene.menu.infoWord:setString(n.." "..p.."贯")
    --end
end

function NewBuildMenu3:onTab(p)
    if self.curSel ~= p then
        self:setSelect(p)
    end
end

function NewBuildMenu3:setSelect(s)
    if self.selTab ~= nil then
        setVisible(self.tabs[self.selTab].attDark, true)
        self.tabs[self.selTab].bg:setZOrder(-1)
    end
    self.selTab = s
    setVisible(self.tabs[self.selTab].attDark, false)
    self.tabs[self.selTab].bg:setZOrder(0)
    local name = {'envTitle.png', 'laborTitle.png', 'storeTitle.png'}
    setTexOrDis(self.title, name[s])
    self:setView(s)
end
function NewBuildMenu3:enterScene()
    registerUpdate(self)
end
function NewBuildMenu3:update(diff)
end

function NewBuildMenu3:updateTab()
    removeSelf(self.flowNode)
    self.flowNode = addNode(self.cl)
    setPos(self.flowNode, {0, self.HEIGHT})
    self.flowHeight = 0

    local initX = 0
	local initY = -184
	local offX = 207
    local offY = 191 

    self.data = {}
    local sz = {width=184, height=183}
    local dataNum = 1
    print("building List")
    --for k, v in ipairs(Logic.buildList) do
    for k, bv in ipairs(Logic.ownBuild) do
        local v = Logic.buildings[bv]
        if v.tab == self.selTab-1 then
            local row = math.floor((dataNum-1)/3)
            local col = (dataNum-1)%3

            local panel = setPos(addNode(self.flowNode), {initX+col*offX, initY-offY*row})
            local sp = setAnchor(setSize(setPos(addSprite(panel, "singleGoods.png"), {92, fixY(sz.height, 91)}), {184, 183}), {0.50, 0.50})
            local build = setAnchor(setPos(addChild(panel, CCSprite:create("build"..v.id..".png")), {86, fixY(sz.height, 67)}), {0.50, 0.50})
            local sca = getSca(build, {130, 100})
            setScale(build, sca)
            local w = setPos(setAnchor(addChild(panel, ui.newTTFLabel({text=v.name, size=18, color={0, 255, 255}, font="f2", shadowColor={255, 255, 255}})), {0.50, 0.50}), {88, fixY(sz.height, 140)})
            panel:setTag(dataNum)
            setContentSize(panel, {sz.width, sz.height})
            dataNum = dataNum+1

            if v.countNum == 1 then
                local w = setPos(setAnchor(addChild(panel, ui.newBMFontLabel({text="X"..(getAvaBuildNum(v.id)), font='bound.fnt', size=18, color={0, 255, 255}})), {0, 0.5}), {122, fixY(sz.height, 36)})
            end
            table.insert(self.data, {sp, build, k})
            if col == 0 then
		        self.flowHeight = self.flowHeight+offY
            end
        end
    end
end

--点击对齐网格
function NewBuildMenu3:touchBegan(x, y)
    self.lastPoints = {x, y}
    self.accMove = 0
    self.curSel = nil
end

function NewBuildMenu3:moveBack(dify)
    local ox, oy = self.flowNode:getPosition()
    self.flowNode:setPosition(ccp(ox, oy+dify))
end
function NewBuildMenu3:touchMoved(x, y)
    local oldPoints = self.lastPoints
    self.lastPoints = {x, y}
    local dify = self.lastPoints[2]-oldPoints[2]
    self.accMove = self.accMove+math.abs(dify)
    self:moveBack(dify)
end
function NewBuildMenu3:touchEnded(x, y)
    local newPos = {x, y}
    if self.accMove < 10 then
        local child = checkInChild(self.flowNode, newPos)
        if child ~= nil then
            print("touch child", child:getTag())
            local t = child:getTag()
            if self.selBuild ~= t then
                self:setSel(t)
            else
                local buildData = Logic.ownBuild[self.data[self.selBuild][3]]
                buildData = Logic.buildings[buildData]
                local p = buildData.silver
                local countOk = true
                if buildData.countNum == 1 then
                    local count = getAvaBuildNum(buildData.id)
                    if count <= 0 then
                        addBanner("剩余数量不足，请去商店购买")
                        countOk = false
                    end
                end
                if countOk then
                    if Logic.resource.silver < p then
                        addBanner("金钱不足!")
                    else
                        global.director:popView() 
                        self.btype = t            
                        if Logic.inNew and not Logic.newBuildYet then
                            Logic.newBuildYet = true
                            local w = Welcome2.new(self.onHouse, self)
                            w:updateWord("请拖拽画面选择建筑场所，点击建筑物可以进行微调。")
                            global.director:pushView(w, 1, 0)
                            return
                        end

                        global.director.curScene.page:beginBuild('build', buildData.id)
                        return 
                    end
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

function NewBuildMenu3:onClose()
    global.director:popView()
end
