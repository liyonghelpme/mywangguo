require "menu.BuyMenu"
EquipChangeMenu2 = class()
function EquipChangeMenu2:ctor(p, changeKind)
    self.people = p
    print("people changeKind", p.name, changeKind)

    local vs = getVS()
    self.bg = CCNode:create()
    local sz = {width=1024, height=768}
    self.temp = setPos(addNode(self.bg), {-13.5, fixY(sz.height, 0+sz.height)+4})
    local sp = setOpacity(setAnchor(setSize(setPos(addSprite(self.temp, "dialogA.png"), {525, fixY(sz.height, 388)}), {693, 588}), {0.50, 0.50}), 255)
    local sp = setOpacity(setAnchor(setSize(setPos(addSprite(self.temp, "dialogB.png"), {523, fixY(sz.height, 423)}), {626, 358}), {0.50, 0.50}), 255)
    local but = ui.newButton({image="newClose.png", text="", font="f1", size=18, delegate=self, callback=closeDialog, shadowColor={0, 0, 0}, color={255, 255, 255}})
    but:setContentSize(80, 82)
    setPos(addChild(self.temp, but.bg), {848, fixY(sz.height, 112)})
    local but = ui.newButton({image="newLeftArrow.png", text="", font="f1", size=18, delegate=self, callback=self.onLeft, shadowColor={0, 0, 0}, color={255, 255, 255}})
    but:setContentSize(90, 106)
    setPos(addChild(self.temp, but.bg), {131, fixY(sz.height, 388)})
    local but = ui.newButton({image="newRightArrow.png", text="", font="f1", size=18, delegate=self, callback=self.onRight, shadowColor={0, 0, 0}, color={255, 255, 255}})
    but:setContentSize(90, 106)
    setPos(addChild(self.temp, but.bg), {923, fixY(sz.height, 390)})
    local sp = setOpacity(setAnchor(setSize(setPos(addSprite(self.temp, "equipCh1.png"), {549, fixY(sz.height, 147)}), {297, 43}), {0.50, 0.50}), 255)
    self.total = sp

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

    self.selNum = changeKind or 1
    self:setView()

    centerUI(self)
    --[[
    if true then
        return
    end
    --]]

    print("setView")
end
function EquipChangeMenu2:updateTab()
    removeSelf(self.flowNode)
    self.flowNode = addNode(self.cl)
    setPos(self.flowNode, {0, self.HEIGHT})
    self.flowHeight = 0

	local initX = 0
	local initY = -58
	local offX = 0
	local offY = 60
    local sz = {width=546, height=52}
    
	self.data = {}
	local rowWidth = 1
    local allData = {}
    if self.selNum == 1 then
        allData = Logic.allWeapon
    elseif self.selNum == 2 then
        allData = Logic.allHead
    elseif self.selNum == 3 then
        allData = Logic.allBody
    elseif self.selNum == 4 then
        allData = Logic.allSpe
    end


    self.allData = allData
    print("refresh View", self.selNum)
    self.oldEquipId = nil
    self.oldEquip = nil
    local tempAllData = {}
    local count = 1
	for k, v in ipairs(allData) do
        --装备研究过才能显示
        --hold的也显示
        if Logic.researchEquip[v.id] or Logic.holdNum[v.id] ~= nil then
            table.insert(tempAllData, v)
            local row = math.floor((count-1)/rowWidth)
            local col = (count-1)%rowWidth

            local panel = setPos(addNode(self.flowNode), {initX+col*offX, initY-offY*row})
            local back = setOpacity(setAnchor(setSize(setPos(addSprite(panel, "listB.png"), {306, fixY(sz.height, 26)}), {479, 52}), {0.50, 0.50}), 255)
            local w1 = setPos(setAnchor(addChild(panel, ui.newTTFLabel({text=v.name, size=24, color={240,196, 92}, font="f2", shadowColor={255, 255, 255}})), {0.00, 0.50}), {98, fixY(sz.height, 24)})
            local w2
        
            local hb = setOpacity(setAnchor(setSize(setPos(addSprite(panel, "headBoard.png"), {28, fixY(sz.height, 26)}), {57, 52}), {0.50, 0.50}), 255)
            local sp = setOpacity(setAnchor(setSize(setPos(addSprite(hb, "equip"..v.id..".png"), {28, fixY(sz.height, 26)}), {41, 36}), {0.50, 0.50}), 255)
            local eqw = setPos(setAnchor(addChild(hb, ui.newTTFLabel({text='E', size=18, color={206, 78, 0}, font="bound.fnt", shadowColor={255, 255, 255}})), {0.50, 0.50}), {44, fixY(52, 41)})
            setVisible(eqw, false)
            if self.selNum == 1 then
                print("eqw")
                if self.people.weapon == v.id then
                    setColor(back, {255, 255, 0})
                    self.oldEquipId = v.id
                    self.oldEquip = back
                    --print("self.oldEquip", self.oldEquip)
                    setVisible(eqw, true)
                end
                w2 = setPos(setAnchor(addChild(panel, ui.newTTFLabel({text=v.attack, size=24, color={240, 196, 92}, font="f2", shadowColor={255, 255, 255}})), {0.00, 0.50}), {279, fixY(sz.height, 24)})
            elseif self.selNum == 2  then
                if self.people.head == v.id then
                    setColor(back, {255, 255, 0})
                    self.oldEquipId = v.id
                    self.oldEquip = back
                    setVisible(eqw, true)
                end
                local aname, anum = self:getFirstAtt(v)
                w2 = setPos(setAnchor(addChild(panel, ui.newTTFLabel({text=aname..'+'..anum, size=24, color={240, 196, 92}, font="f2", shadowColor={255, 255, 255}})), {0.00, 0.50}), {279, fixY(sz.height, 24)})
            elseif self.selNum == 3 then
                if self.people.body == v.id then
                    setColor(back, {255, 255, 0})
                    self.oldEquipId = v.id
                    self.oldEquip = back
                    setVisible(eqw, true)
                end
                w2 = setPos(setAnchor(addChild(panel, ui.newTTFLabel({text=v.defense, size=24, color={240, 196, 92}, font="f2", shadowColor={255, 255, 255}})), {0.00, 0.50}), {279, fixY(sz.height, 24)})

            elseif self.selNum == 4 then
                if self.people.spe == v.id then
                    setColor(back, {255, 255, 0})
                    self.oldEquipId = v.id
                    self.oldEquip = back
                    setVisible(eqw, true)
                end
                w2 = setPos(setAnchor(addChild(panel, ui.newTTFLabel({text='', size=24, color={240, 196, 92}, font="f2", shadowColor={255, 255, 255}})), {0.00, 0.50}), {279, fixY(sz.height, 24)})
            end
            local w3 = setPos(setAnchor(addChild(panel, ui.newTTFLabel({text=(Logic.holdNum[v.id] or 0).."个", size=24, color={240, 196, 92}, font="f2", shadowColor={255, 255, 255}})), {1.00, 0.50}), {528, fixY(sz.height, 24)})
            panel:setTag(count)
            setContentSize(panel, {sz.width, sz.height})

            table.insert(self.data, {back, w1, w2, w3, v.id})
            self.flowHeight = self.flowHeight+offY

            count = count+1
        end
    end
    print("equip Num", #tempAllData, simple.encode(tempAllData))

    self.allData = tempAllData
end

function EquipChangeMenu2:setView()
    print("selPage", self.selPage, self.selNum)
    if self.selPage ~= nil then
        removeSelf(self.selPage)
    end

    if self.selNum == 1 then
        self:initWeaponView()
    elseif self.selNum == 2 then
        self:initHeadView()
    elseif self.selNum == 3 then
        self:initBodyView()
    elseif self.selNum == 4 then
        self:initSpeView()
    end
    print("updateTab now")
    self:updateTab()
    self.selPanel = nil
    self:setSel(1)
    setTexOrDis(self.total, "equipCh"..self.selNum..".png")
    if self.scrollPro ~= nil then
        print("resetScroll")
        self.scrollPro:resetScroll()
    end
    print("finish setView")
end

function EquipChangeMenu2:initWeaponView()
    local temp = CCNode:create()
    self.temp:addChild(temp)
    self.selPage = temp
    
    local sz = {width=1024, height=768}
    local w = setPos(setAnchor(addChild(temp, ui.newTTFLabel({text="点击查看详情", size=26, color={32, 112, 220}, font="f2", shadowColor={255, 255, 255}})), {0.50, 0.50}), {533, fixY(sz.height, 625)})
    self.desWord = w
    local w = setPos(setAnchor(addChild(temp, ui.newTTFLabel({text="剩余", size=26, color={32, 112, 220}, font="f2", shadowColor={255, 255, 255}})), {0.00, 0.50}), {705, fixY(sz.height, 215)})
    local w = setPos(setAnchor(addChild(temp, ui.newTTFLabel({text="攻击力", size=26, color={32, 112, 220}, font="f2", shadowColor={255, 255, 255}})), {0.00, 0.50}), {515, fixY(sz.height, 215)})
    local w = setPos(setAnchor(addChild(temp, ui.newTTFLabel({text="武器", size=26, color={32, 112, 220}, font="f2", shadowColor={255, 255, 255}})), {0.00, 0.50}), {324, fixY(sz.height, 215)})
end

function EquipChangeMenu2:initHeadView()
    --print("initHeadView")
    local temp = CCNode:create()
    self.temp:addChild(temp)
    self.selPage = temp
    --node 被替换成空node了
    local sz = {width=1024, height=768}
    local w = setPos(setAnchor(addChild(temp, ui.newTTFLabel({text="点击查看详情", size=26, color={32, 112, 220}, font="f2", shadowColor={255, 255, 255}})), {0.50, 0.50}), {533, fixY(sz.height, 625)})
    self.desWord = w
    local w = setPos(setAnchor(addChild(temp, ui.newTTFLabel({text="剩余", size=26, color={32, 112, 220}, font="f2", shadowColor={255, 255, 255}})), {0.00, 0.50}), {705, fixY(sz.height, 215)})
    local w = setPos(setAnchor(addChild(temp, ui.newTTFLabel({text="头装备", size=26, color={32, 112, 220}, font="f2", shadowColor={255, 255, 255}})), {0.00, 0.50}), {325, fixY(sz.height, 215)})
end
--node 循环 add 自身导致的问题
function EquipChangeMenu2:initBodyView()
    local temp = CCNode:create()
    self.temp:addChild(temp)
    self.selPage = temp

    local sz = {width=1024, height=768}
    local w = setPos(setAnchor(addChild(temp, ui.newTTFLabel({text="点击查看详情", size=26, color={32, 112, 220}, font="f2", shadowColor={255, 255, 255}})), {0.50, 0.50}), {533, fixY(sz.height, 625)})
    self.desWord = w
    local w = setPos(setAnchor(addChild(temp, ui.newTTFLabel({text="剩余", size=26, color={32, 112, 220}, font="f2", shadowColor={255, 255, 255}})), {0.00, 0.50}), {705, fixY(sz.height, 215)})
    local w = setPos(setAnchor(addChild(temp, ui.newTTFLabel({text="防御力", size=26, color={32, 112, 220}, font="f2", shadowColor={255, 255, 255}})), {0.00, 0.50}), {515, fixY(sz.height, 215)})
    local w = setPos(setAnchor(addChild(temp, ui.newTTFLabel({text="体装备", size=26, color={32, 112, 220}, font="f2", shadowColor={255, 255, 255}})), {0.00, 0.50}), {324, fixY(sz.height, 215)})
end
function EquipChangeMenu2:initSpeView()
    local temp = CCNode:create()
    self.temp:addChild(temp)
    self.selPage = temp

    local sz = {width=1024, height=768}
    local w = setPos(setAnchor(addChild(temp, ui.newTTFLabel({text="点击查看详情", size=26, color={32, 112, 220}, font="f2", shadowColor={255, 255, 255}})), {0.50, 0.50}), {533, fixY(sz.height, 625)})
    self.desWord = w
    local w = setPos(setAnchor(addChild(temp, ui.newTTFLabel({text="剩余", size=26, color={32, 112, 220}, font="f2", shadowColor={255, 255, 255}})), {0.00, 0.50}), {705, fixY(sz.height, 215)})
    local w = setPos(setAnchor(addChild(temp, ui.newTTFLabel({text="特殊装备", size=26, color={32, 112, 220}, font="f2", shadowColor={255, 255, 255}})), {0.00, 0.50}), {324, fixY(sz.height, 215)})
end
function EquipChangeMenu2:setSel(s)
    if #self.data < s then
        return
    end
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
        if self.selNum == 1 then
            self:setWeaponInfo()
        elseif self.selNum == 2 then
            self:setHeadInfo()
        elseif self.selNum == 3 then
            self:setBodyInfo()
        end
    end

    local edata = self.allData[self.selPanel]
    self.desWord:setString(edata.name.." "..edata.attribute)
end
function EquipChangeMenu2:setWeaponInfo()
end
function EquipChangeMenu2:setHeadInfo()
end
function EquipChangeMenu2:setBodyInfo()
end

function EquipChangeMenu2:onLeft()
    if self.selNum > 1 then
        self.selNum = self.selNum-1
    else
        self.selNum = 4
    end
    self:setView()
end
function EquipChangeMenu2:onRight()
    print("onRight")
    if self.selNum < 4 then
        self.selNum = self.selNum+1
    else
        self.selNum = 1
    end
    self:setView()
end

function EquipChangeMenu2:getFirstAtt(edata)
    local allAtt = {'defense', 'attack', 'health', 'brawn', 'labor', 'shoot'}
    local allCn = {'防御', '攻击', '体力', '腕力', '劳动', '远程'}
    
    for k, v in ipairs(allAtt) do
        if edata[v] > 0 then
            return allCn[k], edata[v]
        end
    end
end

function EquipChangeMenu2:touchBegan(x, y)
    self.lastPoints = {x, y}
    self.accMove = 0
    self.curSel = nil
end

function EquipChangeMenu2:moveBack(dify)
    adjustFlow(self, dify)
end
function EquipChangeMenu2:touchMoved(x, y)
    local oldPoints = self.lastPoints
    self.lastPoints = {x, y}
    local dify = self.lastPoints[2]-oldPoints[2]
    self.accMove = self.accMove+math.abs(dify)
    self:moveBack(dify)
end


function EquipChangeMenu2:touchEnded(x, y)
    local newPos = {x, y}
    if self.accMove < 10 then
        local child = checkInChild(self.flowNode, newPos)
        if child ~= nil then
            print("touch child", child:getTag())
            local t = child:getTag()
            if self.selPanel ~= t then
                self:setSel(t)
            else
                local edata = self.allData[self.selPanel]
                local eid = edata.id
                print("touchEnded", eid, simple.encode(edata))
                --放下装备
                if self.oldEquipId == eid then
                    changeEquip(eid, 1)
                    self.people:putEquip(eid)
                    self:refreshData()
                    addBanner(self.people.data.name.."卸下装备"..edata.name)
                    self.oldEquipId = nil
                    self.oldEquip = nil
                elseif Logic.holdNum[eid] ~= nil and Logic.holdNum[eid] > 0  then
                    changeEquip(eid, -1)
                    self.people:setEquip(eid)
                    addBanner(self.people.data.name.."装备"..edata.name..'成功')
                    self:refreshData()
                else
                    --研究过 商店可以购买
                    if Logic.researchEquip[eid] then
                        global.director:pushView(BuyMenu.new(self.people, self.allData[self.selPanel]), 1)
                    else
                        addBanner("该装备 剩余数量不足 商店不能购买")
                    end
                end
                return
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

function EquipChangeMenu2:refreshData()
    self:setView()
end
