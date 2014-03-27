StoreMenu3 = class()
function StoreMenu3:ctor()
    local vs = getVS()
    self.bg = CCNode:create()
    local sz = {width=1024, height=768}
    self.temp = setPos(addNode(self.bg), {-13.5, fixY(sz.height, 0+sz.height)+4.0})
    local sp = setOpacity(setAnchor(setSize(setPos(addSprite(self.temp, "dialogA.png"), {525, fixY(sz.height, 388)}), {693, 588}), {0.50, 0.50}), 255)
    local sp = setOpacity(setAnchor(setSize(setPos(addSprite(self.temp, "dialogB.png"), {523, fixY(sz.height, 423)}), {626, 358}), {0.50, 0.50}), 255)
    local but = ui.newButton({image="newClose.png", text="", font="f1", size=18, delegate=self, callback=closeDialog, shadowColor={0, 0, 0}, color={255, 255, 255}})
    but:setContentSize(80, 82)
    setPos(addChild(self.temp, but.bg), {848, fixY(sz.height, 112)})
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="点击查看详情", size=26, color={32, 112, 220}, font="f2", shadowColor={255, 255, 255}})), {0.50, 0.50}), {533, fixY(sz.height, 625)})
    self.desWord = w
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="价格", size=26, color={32, 112, 220}, font="f2", shadowColor={255, 255, 255}})), {0.00, 0.50}), {705, fixY(sz.height, 215)})
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="所持", size=26, color={32, 112, 220}, font="f2", shadowColor={255, 255, 255}})), {0.00, 0.50}), {515, fixY(sz.height, 215)})
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="全部", size=26, color={32, 112, 220}, font="f2", shadowColor={255, 255, 255}})), {0.00, 0.50}), {325, fixY(sz.height, 215)})
    local sp = setOpacity(setAnchor(setSize(setPos(addSprite(self.temp, "goodsTitle.png"), {530, fixY(sz.height, 148)}), {97, 42}), {0.50, 0.50}), 255)


    local listSize = {width=546, height=319}
    self.listSize = listSize
    self.HEIGHT = 319
    self.cl = Scissor:create()
    self.temp:addChild(self.cl)
    setPos(self.cl, {228, fixY(sz.height, 263+listSize.height)})
    setContentSize(self.cl, {listSize.width, listSize.height})
    self.flowNode = addNode(self.cl)
    setPos(self.flowNode, {0, self.HEIGHT})
    self.touch = ui.newTouchLayer({size={listSize.width, self.HEIGHT}, delegate=self, touchBegan=self.touchBegan, touchMoved=self.touchMoved, touchEnded=self.touchEnded})
    self.cl:addChild(self.touch.bg)
    setPos(self.touch.bg, {0, 0})
    self.flowHeight = 0
    self:updateTab()

    self.scrollPro = createScroll(self.temp, sz)

    self:setSel(1)
    centerUI(self)
end

function StoreMenu3:setSel(s)
    if self.selPanel ~= s then
        if self.selPanel ~= nil then
            setTexture(self.data[self.selPanel][1], "listB.png")
            local word = self.data[self.selPanel] 
            setColor(word[2], {240, 196, 92})
            setColor(word[3], {240, 196, 92})
            setColor(word[4], {240, 196, 92})
        end
        self.selPanel = s
        setTexture(self.data[self.selPanel][1], "listA.png")
        local word = self.data[self.selPanel] 
        setColor(word[2], {206, 78, 0})
        setColor(word[3], {206, 78, 0})
        setColor(word[4], {206, 78, 0})

        local storeData = self.allData[self.data[self.selPanel][5]]
        local edata
        if storeData[1] == 0 then
            edata = Logic.equip[storeData[2]] 
        elseif storeData[1] == 2 then
            edata = Logic.buildings[storeData[2]]
        end
        print("storeData", simple.encode(storeData))
        self:getAllAtt(edata)
    end
end
function StoreMenu3:getAllAtt(edata)
    if edata.attribute ~= nil then
        self.desWord:setString(edata.name.." "..edata.attribute)
    else
        self.desWord:setString(edata.name.." "..edata.des)
    end
end

function StoreMenu3:updateTab()
	local initX = 0
	local initY = -60
	local offX = 0
	local offY = 52
	self.data = {}
	local sz = {width=537, height=58}
	--local test = {1, 1, 1, 1, 1, 1, 1}
	local rowWidth = 1
    local bb = getBuyableBuild()
    local allData = concateTable(Logic.ownGoods, bb)
    self.allData = allData
    local dataNum = 1
	for k, v in ipairs(allData) do
		local row = math.floor((dataNum-1)/rowWidth)
		local col = (dataNum-1)%rowWidth
        local find = false
        local head 
        local num
        local price
        if v[1] == 0 then
            v = Logic.equip[v[2]]
            find = true
            head = 'equip'
            num = Logic.holdNum[v.id] or 0
            price = v.silver
        elseif v[1] == 2 then
            v = Logic.buildings[v[2]]
            find = true
            --必须使用单张图片 而不用sprite
            head = '#build'
            num = getTotalBuildNum(v.id)
            price = getBuyPrice(v.id)
        end
        --v[1] == 1 商店卖出物品不要显示
        if find then
            local panel = setPos(addNode(self.flowNode), {initX+col*offX, initY-offY*row})
            --local listback = setAnchor(setSize(setPos(addSprite(panel, "listB.png"), {297, fixY(sz.height, 30)}), {479, 52}), {0.50, 0.50})
            --local sp = setAnchor(setSize(setPos(addSprite(panel, "headBoard.png"), {27, fixY(sz.height, 31)}), {57, 52}), {0.50, 0.50})

            local listback = setOpacity(setAnchor(setSize(setPos(addSprite(panel, "listB.png"), {306, fixY(sz.height, 26)}), {479, 52}), {0.50, 0.50}), 255)
            local sp = setOpacity(setAnchor(setSize(setPos(addSprite(panel, "headBoard.png"), {28, fixY(sz.height, 26)}), {57, 52}), {0.50, 0.50}), 255)
            
            local sp = setAnchor(setPos(addSprite(panel, head..v.id..".png"), {24, fixY(sz.height, 26)}), {0.50, 0.50})
            local sca = getSca(sp, {57, 52})
            setScale(sp, sca)


            local w1 = setPos(setAnchor(addChild(panel, ui.newTTFLabel({text=v.name, size=24, color={240, 196, 92}, font="f1", shadowColor={0, 0, 0}})), {0.00, 0.50}), {97, fixY(sz.height, 24)})
            local w3 = setPos(setAnchor(addChild(panel, ui.newTTFLabel({text=price..'银币', size=24, color={240, 196, 92}, font="f1", shadowColor={0, 0, 0}})), {1.00, 0.50}), {537, fixY(sz.height, 24)})
            local w2 = setPos(setAnchor(addChild(panel, ui.newTTFLabel({text=num, size=24, color={240, 196, 92}, font="f1", shadowColor={0, 0, 0}})), {0.00, 0.50}), {298, fixY(sz.height, 23)})
            panel:setTag(dataNum)
            setContentSize(panel, {sz.width, sz.height})
            dataNum = dataNum+1

            table.insert(self.data, {listback, w1, w2, w3, k})
            self.flowHeight = self.flowHeight+offY
        end
	end
end


function StoreMenu3:touchBegan(x, y)
    self.lastPoints = {x, y}
    self.accMove = 0
    self.curSel = nil
end

function adjustFlow(obj, dify)
    local ox, oy = obj.flowNode:getPosition()
    obj.flowNode:setPosition(ccp(ox, oy+dify))

    if obj.flowHeight < obj.HEIGHT then
    else
        local dx = obj.flowHeight-obj.HEIGHT
        print("moveBack", oy, dify, dx)
        obj.scrollPro:moveScroll((oy+dify-obj.HEIGHT)/dx)
    end
end

function StoreMenu3:moveBack(dify)
    adjustFlow(self, dify)
    --[[
    local ox, oy = self.flowNode:getPosition()
    self.flowNode:setPosition(ccp(ox, oy+dify))

    if self.flowHeight < self.HEIGHT then
    else
        local dx = self.flowHeight-self.HEIGHT
        print("moveBack", oy, dify, dx)
        self.scrollPro:moveScroll((oy+dify-self.HEIGHT)/dx)
    end
    --]]
end
function StoreMenu3:touchMoved(x, y)
    local oldPoints = self.lastPoints
    self.lastPoints = {x, y}
    local dify = self.lastPoints[2]-oldPoints[2]
    self.accMove = self.accMove+math.abs(dify)
    self:moveBack(dify)
end


function StoreMenu3:touchEnded(x, y)
    local newPos = {x, y}
    if self.accMove < 10 then
        local child = checkInChild(self.flowNode, newPos)
        if child ~= nil then
            print("touch child", child:getTag())
            local t = child:getTag()
            if self.selPanel ~= t then
                self:setSel(t)
            else
                local storeData = self.allData[self.data[self.selPanel][5]]
                local edata
                local s
                if storeData[1] == 0 then
                    edata = Logic.equip[storeData[2]]
                    s = edata.silver
                elseif storeData[1] == 2 then
                    edata = Logic.buildings[storeData[2]]
                    s = getBuyPrice(edata.id)
                end
                print("edata", simple.encode(storeData))
                print('edata', simple.encode(edata))
                if not checkCost(s) then
                    addBanner("银币不足")
                else
                    doCost(s)
                    if storeData[1] == 0 then
                        changeEquip(edata.id, 1)
                        self.data[self.selPanel][3]:setString(Logic.holdNum[edata.id])
                        --once 不应该在商店显示
                        --changeBuyNum(edata.id, 1)
                    elseif storeData[1] == 2 then
                        changeBuildNum(edata.id, 1)
                        self.data[self.selPanel][3]:setString(getTotalBuildNum(edata.id))
                        self.data[self.selPanel][4]:setString(getBuyPrice(edata.id).."银币")
                    end

                    addBanner("购买"..edata.name.."成功")
                end
                --global.director:popView()
                --global.director:pushView(BuyMenu.new(self.people, self.allData[self.selPanel]), 1)
                --return
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
