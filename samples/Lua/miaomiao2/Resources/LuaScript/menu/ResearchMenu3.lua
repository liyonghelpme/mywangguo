ResearchMenu3 = class()
function ResearchMenu3:ctor()
    local vs = getVS()
    self.bg = CCNode:create()
    local sz = {width=1024, height=768}
    self.temp = setPos(addNode(self.bg), {-13.5, fixY(sz.height, 0+sz.height)+4.0})
    local sp = setOpacity(setAnchor(setSize(setPos(addSprite(self.temp, "dialogA.png"), {525, fixY(sz.height, 388)}), {693, 588}), {0.50, 0.50}), 255)
    local sp = setOpacity(setAnchor(setSize(setPos(addSprite(self.temp, "dialogB.png"), {523, fixY(sz.height, 423)}), {626, 358}), {0.50, 0.50}), 255)
    local but = ui.newButton({image="newClose.png", text="", font="f1", size=18, callback=closeDialog, shadowColor={0, 0, 0}, color={255, 255, 255}})
    but:setContentSize(80, 82)
    setPos(addChild(self.temp, but.bg), {848, fixY(sz.height, 112)})
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="木刀攻击力+10防御力+20", size=26, color={32, 112, 220}, font="f2", shadowColor={255, 255, 255}})), {0.50, 0.50}), {533, fixY(sz.height, 625)})
    self.desWord = w
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="费用", size=26, color={32, 112, 220}, font="f2", shadowColor={255, 255, 255}})), {0.00, 0.50}), {705, fixY(sz.height, 215)})
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="劳动", size=26, color={32, 112, 220}, font="f2", shadowColor={255, 255, 255}})), {0.00, 0.50}), {325, fixY(sz.height, 215)})
    local sp = setOpacity(setAnchor(setSize(setPos(addSprite(self.temp, "researchTitle.png"), {530, fixY(sz.height, 148)}), {97, 42}), {0.50, 0.50}), 255)


    self.scrollPro = createScroll(self.temp, sz)

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

    self:setSel(1)
    centerUI(self)
end

function ResearchMenu3:setSel(s)
    if #self.data < s then
        self:getAllAtt(nil)
        return
    end
    if self.selPanel ~= s then
        if self.selPanel ~= nil then
            setTexture(self.data[self.selPanel][1], "listB.png")
            local word = self.data[self.selPanel] 
            setColor(word[2], {240, 196, 92})
            setColor(word[3], {240, 196, 92})
        end
        self.selPanel = s
        setTexture(self.data[self.selPanel][1], "listA.png")
        local word = self.data[self.selPanel] 
        setColor(word[2], {206, 78, 255})
        setColor(word[3], {206, 78, 255})

        local rdata = Logic.researchGoods[self.selPanel]
        local edata 
        if rdata[1] == 0 then
            edata = Logic.allEquip[rdata[2]]
        elseif rdata[1] == 1 then
            edata = GoodsName[rdata[2]]
        end
        self:getAllAtt(edata)
    end
end
function ResearchMenu3:getAllAtt(edata)
    if edata == nil then
        --self.ename:setString('')
        self.desWord:setString('')
        --[[
        self.firAtt:setString('')
        self.firNum:setString('')
        self.secAtt:setString('')
        self.secNum:setString('')
        --]]
        return
    end
    --self.ename:setString(edata.name)
    --装备 商店贩卖商品的信息
    if edata.attack ~= nil then
        self.desWord:setString(edata.name.." "..str(edata.attribute))
    --其它物品
    else
        self.desWord:setString(edata.name.." "..str(edata.des))
    end
    --[[
    local allAtt = {'defense', 'attack', 'health', 'brawn', 'labor', 'shoot', 'food', 'wood', 'stone'}
    local allCn = {'防御', '攻击', '体力', '腕力', '劳动', '远程', '食材', '木材', '石头'}
    local showPlus = {true, true,true,true,true,true,false, false, false}
    
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
                    if showPlus[k] then
                        self.firNum:setString('+'..edata[v])
                    else
                        self.firNum:setString(edata[v])
                    end
                else
                    self.firNum:setString(edata[v])
                end
            else
                two = true
                self.secAtt:setString(allCn[k])
                if edata[v] > 0 then
                    if showPlus[k] then
                        self.secNum:setString('+'..edata[v])
                    else
                        self.secNum:setString(edata[v])
                    end
                else
                    self.secNum:setString(edata[v])
                end
                break
            end
        end
    end
    --]]
end

function ResearchMenu3:updateTab()
	local initX = 0
	local initY = -58
	local offX = 0
	local offY = 52
	self.data = {}
	--local sz = {width=537, height=58}
    local sz = {width=546, height=52}
	local rowWidth = 1
	for k, v in ipairs(Logic.researchGoods) do
		local row = math.floor((k-1)/rowWidth)
		local col = (k-1)%rowWidth

        --当前只有装备可以研究
        local picname = 'equip' 
        if v[1] == 0 then
            v = Logic.allEquip[v[2]]
        elseif v[1] == 1 then
            v = GoodsName[v[2]]
            picname = 'storeGoods'
        end

        local panel = setPos(addNode(self.flowNode), {initX+col*offX, initY-offY*row})
        local listback = setOpacity(setAnchor(setSize(setPos(addSprite(panel, "listB.png"), {306, fixY(sz.height, 26)}), {479, 52}), {0.50, 0.50}), 255)
        local sp = setOpacity(setAnchor(setSize(setPos(addSprite(panel, "headBoard.png"), {28, fixY(sz.height, 26)}), {57, 52}), {0.50, 0.50}), 255)
        local sp = setAnchor(setPos(addSprite(panel, picname..v.id..".png"), {28, fixY(sz.height, 26)}), {0.50, 0.50})

        local w1 = setPos(setAnchor(addChild(panel, ui.newTTFLabel({text=v.name, size=24, color={240, 196, 92}, font="f1", shadowColor={0, 0, 0}})), {0.00, 0.50}), {97, fixY(sz.height, 24)})
        local w2 = setPos(setAnchor(addChild(panel, ui.newTTFLabel({text=v.researchCost..'银币', size=24, color={240, 196, 92}, font="f1", shadowColor={0, 0, 0}})), {1.00, 0.50}), {537, fixY(sz.height, 24)})
        panel:setTag(k)
        setContentSize(panel, {sz.width, sz.height})
        
        --[[
        local panel = setPos(addNode(self.flowNode), {initX+col*offX, initY-offY*row})
        local listback = setAnchor(setSize(setPos(addSprite(panel, "listB.png"), {297, fixY(sz.height, 30)}), {479, 52}), {0.50, 0.50})
        local sp = setAnchor(setSize(setPos(addSprite(panel, "weaponIcon.png"), {27, fixY(sz.height, 31)}), {54, 54}), {0.50, 0.50})
        local sp = setAnchor(setSize(setPos(addSprite(panel, picname..v.id..".png"), {24, fixY(sz.height, 26)}), {48, 53}), {0.50, 0.50})

        local w1 = setPos(setAnchor(addChild(panel, ui.newTTFLabel({text=v.name, size=20, color={240, 196, 92}, font="f1"})), {0.00, 0.50}), {75, fixY(sz.height, 30)})
        local w2 = setPos(setAnchor(addChild(panel, ui.newTTFLabel({text=v.researchCost.."银币", size=20, color={240, 196, 92}, font="f1"})), {1.00, 0.50}), {485, fixY(sz.height, 30)})
        --]]
        panel:setTag(k)
        setContentSize(panel, {sz.width, sz.height})

		table.insert(self.data, {listback, w1, w2})
		self.flowHeight = self.flowHeight+offY
	end
end


function ResearchMenu3:touchBegan(x, y)
    self.lastPoints = {x, y}
    self.accMove = 0
    self.curSel = nil
end

function ResearchMenu3:moveBack(dify)
    local ox, oy = self.flowNode:getPosition()
    self.flowNode:setPosition(ccp(ox, oy+dify))


    if self.flowHeight < self.HEIGHT then
    else
        local dx = self.flowHeight-self.HEIGHT
        print("moveBack", oy, dify, dx)
        self.scrollPro:moveScroll((oy+dify-self.HEIGHT)/dx)
    end
end
function ResearchMenu3:touchMoved(x, y)
    local oldPoints = self.lastPoints
    self.lastPoints = {x, y}
    local dify = self.lastPoints[2]-oldPoints[2]
    self.accMove = self.accMove+math.abs(dify)
    self:moveBack(dify)
end


function ResearchMenu3:touchEnded(x, y)
    local newPos = {x, y}
    if self.accMove < 10 then
        local child = checkInChild(self.flowNode, newPos)
        if child ~= nil then
            print("touch child", child:getTag())
            local t = child:getTag()
            if self.selPanel ~= t then
                self:setSel(t)
            else
                local rd = Logic.researchGoods[self.selPanel]
                local edata 
                if rd[1] == 0 then
                    edata = Logic.allEquip[rd[2]]
                elseif rd[1] == 1 then
                    edata = GoodsName[rd[2]]
                end
                local s = edata.researchCost
                if not checkCost(s) then
                    addBanner("银币不足")
                else
                    doCost(s)
                    --changeEquip(edata.id, 1)
                    --累计研究时间
                    Logic.inResearch = {self.selPanel, 0}
                    addBanner(edata.name.."开始研究")
                    --self.data[self.selPanel][3]:setString(Logic.holdNum[edata.id])
                    global.director:popView()
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

