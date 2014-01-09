StoreMenu2 = class()
function StoreMenu2:ctor()

    local vs = getVS()
    self.bg = CCNode:create()
    local sz = {width=1024, height=768}
    self.temp = setPos(addNode(self.bg), {-30.0, 3.5})
    local sp = setAnchor(setPos(addSprite(self.temp, "dialogA.png"), {538, fixY(sz.height, 387)}), {0.50, 0.50})
    local sp = setAnchor(setSize(setPos(addSprite(self.temp, "dialogC.png"), {537, fixY(sz.height, 400)}), {617, 396}), {0.50, 0.50})
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="全部", size=25, color={32, 112, 220}, font="f1"})), {0.00, 0.50}), {332, fixY(sz.height, 240)})
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="所持", size=25, color={32, 112, 220}, font="f1"})), {0.00, 0.50}), {510, fixY(sz.height, 240)})
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="价格", size=25, color={32, 112, 220}, font="f1"})), {0.00, 0.50}), {691, fixY(sz.height, 240)})
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="刀", size=25, color={32, 112, 220}, font="f1"})), {0.00, 0.50}), {289, fixY(sz.height, 564)})
    self.ename = w
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="攻击", size=25, color={32, 112, 220}, font="f1"})), {0.00, 0.50}), {435, fixY(sz.height, 563)})
    self.firAtt = w
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="+18", size=20, color={255, 255, 255}, font="f1"})), {0.00, 0.50}), {510, fixY(sz.height, 564)})
    self.firNum = w

    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="防御", size=25, color={32, 112, 220}, font="f1"})), {0.00, 0.50}), {630, fixY(sz.height, 563)})
    self.secAtt = w
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="+18", size=20, color={255, 255, 255}, font="f1"})), {1.00, 0.50}), {740, fixY(sz.height, 564)})
    self.secNum = w

    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="准备后可自动回复15%的体力", size=26, color={32, 112, 220}, font="f1"})), {0.50, 0.50}), {538, fixY(sz.height, 626)})
    self.desWord = w

    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="商人家", size=34, color={102, 66, 42}, font="f1"})), {0.50, 0.50}), {542, fixY(sz.height, 153)})


    local listSize = {width=537, height=269}
    self.listSize = listSize
    self.HEIGHT = 269
    self.cl = Scissor:create()
    self.temp:addChild(self.cl)
    setPos(self.cl, {258, fixY(sz.height, 263+listSize.height)})
    setContentSize(self.cl, {listSize.width, listSize.height})
    self.flowNode = addNode(self.cl)
    setPos(self.flowNode, {0, self.HEIGHT})
    self.touch = ui.newTouchLayer({size={listSize.width, self.HEIGHT}, delegate=self, touchBegan=self.touchBegan, touchMoved=self.touchMoved, touchEnded=self.touchEnded})
    self.cl:addChild(self.touch.bg)
    setPos(self.touch.bg, {0, 0})
    self.flowHeight = 0
    self:updateTab()

    local sp = setAnchor(setSize(setPos(addSprite(self.temp, "scrollBack.png"), {820, fixY(sz.height, 398)}), {15, 260}), {0.50, 0.50})
    local pro = setAnchor(setSize(setPos(addSprite(sp, "scrollPro.png"), {0, fixY(315, 0)}), {17, 157}), {0, 1})
    self.scrollPro = pro
    local total = #self.data
    local sz = getContentSize(self.scrollPro)
    self.scrollHeight = math.max(math.min(6/total*315, 315), 10)
    self.scrollBackHei = 315
    sy = self.scrollHeight/(sz[2]-4)
    setScaleY(self.scrollPro, sy)
    self:setSel(1)

    centerUI(self)
end

function StoreMenu2:setSel(s)
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
        setColor(word[2], {255, 255, 255})
        setColor(word[3], {255, 255, 255})
        setColor(word[4], {255, 255, 255})

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
function StoreMenu2:getAllAtt(edata)
    local allAtt = {'defense', 'attack', 'health', 'brawn', 'labor', 'shoot'}
    local allCn = {'防御', '攻击', '体力', '腕力', '劳动', '远程'}
    self.ename:setString(edata.name)

    local fir = true
    local two = false
    self.firAtt:setString('')
    self.firNum:setString('')
    self.secAtt:setString('')
    self.secNum:setString('')
    for k, v in ipairs(allAtt) do
        if edata[v] ~= nil and edata[v] > 0 then
            if fir then
                fir = false
                self.firAtt:setString(allCn[k])
                if edata[v] > 0 then
                    self.firNum:setString('+'..edata[v])
                else
                    self.firNum:setString(edata[v])
                end
            else
                two = true
                self.secAtt:setString(allCn[k])
                if edata[v] > 0 then
                    self.secNum:setString('+'..edata[v])
                else
                    self.secNum:setString(edata[v])
                end
            end
        end
    end
    self.desWord:setString(edata.des)
end

function StoreMenu2:updateTab()
	local initX = 0
	local initY = -58
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
            local listback = setAnchor(setSize(setPos(addSprite(panel, "listB.png"), {297, fixY(sz.height, 30)}), {479, 52}), {0.50, 0.50})
            local sp = setAnchor(setSize(setPos(addSprite(panel, "weaponIcon.png"), {27, fixY(sz.height, 31)}), {54, 54}), {0.50, 0.50})
            
            local sp = setAnchor(setSize(setPos(addSprite(panel, head..v.id..".png"), {24, fixY(sz.height, 26)}), {48, 53}), {0.50, 0.50})

            local w1 = setPos(setAnchor(addChild(panel, ui.newTTFLabel({text=v.name, size=20, color={240, 196, 92}, font="f1"})), {0.00, 0.50}), {75, fixY(sz.height, 30)})
            local w2 = setPos(setAnchor(addChild(panel, ui.newTTFLabel({text=num, size=20, color={240, 196, 92}, font="f1"})), {0.00, 0.50}), {273, fixY(sz.height, 30)})
            local w3 = setPos(setAnchor(addChild(panel, ui.newTTFLabel({text=price.."银币", size=20, color={240, 196, 92}, font="f1"})), {1.00, 0.50}), {512, fixY(sz.height, 30)})
            panel:setTag(dataNum)
            setContentSize(panel, {sz.width, sz.height})
            dataNum = dataNum+1

            table.insert(self.data, {listback, w1, w2, w3, k})
            self.flowHeight = self.flowHeight+offY
        end
	end
end


function StoreMenu2:touchBegan(x, y)
    self.lastPoints = {x, y}
    self.accMove = 0
    self.curSel = nil
end

function StoreMenu2:moveBack(dify)
    local ox, oy = self.flowNode:getPosition()
    self.flowNode:setPosition(ccp(ox, oy+dify))

    local sxy = getPos(self.scrollPro)
    local total = #self.data
    local ny = math.max(math.min(sxy[2]+-dify*(self.scrollBackHei/self.flowHeight), self.scrollBackHei), self.scrollHeight)
    setPos(self.scrollPro, {sxy[1], ny})
end
function StoreMenu2:touchMoved(x, y)
    local oldPoints = self.lastPoints
    self.lastPoints = {x, y}
    local dify = self.lastPoints[2]-oldPoints[2]
    self.accMove = self.accMove+math.abs(dify)
    self:moveBack(dify)
end


function StoreMenu2:touchEnded(x, y)
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
