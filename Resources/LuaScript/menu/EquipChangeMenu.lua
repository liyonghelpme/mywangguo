require "menu.BuyMenu"
EquipChangeMenu = class()
function EquipChangeMenu:ctor(p, changeKind)
    self.people = p
    local vs = getVS()
    self.bg = CCNode:create()
    local sz = {width=1024, height=768}
    self.temp = setPos(addNode(self.bg), {-50, 3.5})
    local sp = setAnchor(setPos(addSprite(self.temp, "dialogA.png"), {538, fixY(sz.height, 387)}), {0.50, 0.50})
    local sp = setAnchor(setSize(setPos(addSprite(self.temp, "dialogC.png"), {537, fixY(sz.height, 400)}), {617, 396}), {0.50, 0.50})
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="准备后可自动回复15%的体力", size=26, color={32, 112, 220}, font="f1"})), {0.00, 0.50}), {394, fixY(sz.height, 626)})
    self.desWord = w

    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="装备变更1/4", size=34, color={102, 66, 42}, font="f1"})), {0.50, 0.50}), {556, fixY(sz.height, 154)})
    self.total = w
    local but = ui.newButton({image="newLeftArrow.png", text="", font="f1", size=18, delegate=self, callback=self.onLeft})
    but:setContentSize(90, 106)
    setPos(addChild(self.temp, but.bg), {143, fixY(sz.height, 388)})
    local but = ui.newButton({image="newRightArrow.png", text="", font="f1", size=18, delegate=self, callback=self.onRight})
    but:setContentSize(90, 106)
    setPos(addChild(self.temp, but.bg), {928, fixY(sz.height, 390)})

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
    --选择武器页面
    self.selNum = changeKind or 1
    self:setView()
    --self:updateTab()
    --self:setSel(1)
    --

    local sp = setAnchor(setSize(setPos(addSprite(self.temp, "scrollBack.png"), {820, fixY(sz.height, 398)}), {15, 260}), {0.50, 0.50})
    --背景图片高度是315 而不用管缩放的比例
    self.scrollBackHei = 315
    local pro = setAnchor(setSize(setPos(addSprite(sp, "scrollPro.png"), {0, fixY(315, 0)}), {17, 157}), {0, 1})
    self.scrollPro = pro
    local total = #self.data
    local sz = getContentSize(self.scrollPro)
    self.scrollHeight = math.max(math.min(6/total*315, 315), 10)
    sy = self.scrollHeight/(sz[2]-4)
    setScaleY(self.scrollPro, sy)

    --self:initWeaponView()
    centerUI(self)
end
function EquipChangeMenu:initWeaponView()
    local sz = {width=1024, height=768}
    local temp = CCNode:create()
    local w = setPos(setAnchor(addChild(temp, ui.newTTFLabel({text="+18", size=20, color={255, 255, 255}, font="f1"})), {1.00, 0.50}), {546, fixY(sz.height, 564)})
    self.attackNum = w
    local w = setPos(setAnchor(addChild(temp, ui.newTTFLabel({text="武器", size=25, color={32, 112, 220}, font="f1"})), {0.00, 0.50}), {333, fixY(sz.height, 240)})
    local w = setPos(setAnchor(addChild(temp, ui.newTTFLabel({text="攻击力", size=25, color={32, 112, 220}, font="f1"})), {0.00, 0.50}), {504, fixY(sz.height, 239)})

    local w = setPos(setAnchor(addChild(temp, ui.newTTFLabel({text="+18", size=20, color={255, 255, 255}, font="f1"})), {1.00, 0.50}), {742, fixY(sz.height, 564)})
    self.defNum = w
    local w = setPos(setAnchor(addChild(temp, ui.newTTFLabel({text="防御", size=25, color={32, 112, 220}, font="f1"})), {0.00, 0.50}), {631, fixY(sz.height, 564)})
    self.secAtt = w

    local w = setPos(setAnchor(addChild(temp, ui.newTTFLabel({text="剩余", size=25, color={32, 112, 220}, font="f1"})), {0.00, 0.50}), {692, fixY(sz.height, 240)})
    local w = setPos(setAnchor(addChild(temp, ui.newTTFLabel({text="刀", size=25, color={32, 112, 220}, font="f1"})), {0.00, 0.50}), {289, fixY(sz.height, 564)})
    self.ename = w
    local w = setPos(setAnchor(addChild(temp, ui.newTTFLabel({text="攻击", size=25, color={32, 112, 220}, font="f1"})), {0.00, 0.50}), {435, fixY(sz.height, 563)})
    self.temp:addChild(temp)
    self.selPage = temp
    return temp
end

function EquipChangeMenu:initSpeView()
    local sz = {width=1024, height=768}
    local temp = CCNode:create()
    local w = setPos(setAnchor(addChild(temp, ui.newTTFLabel({text="", size=20, color={255, 255, 255}, font="f1"})), {1.00, 0.50}), {546, fixY(sz.height, 564)})
    local w = setPos(setAnchor(addChild(temp, ui.newTTFLabel({text="特殊装备", size=25, color={32, 112, 220}, font="f1"})), {0.00, 0.50}), {333, fixY(sz.height, 240)})
    local w = setPos(setAnchor(addChild(temp, ui.newTTFLabel({text="", size=25, color={32, 112, 220}, font="f1"})), {0.00, 0.50}), {504, fixY(sz.height, 239)})
    local w = setPos(setAnchor(addChild(temp, ui.newTTFLabel({text="剩余", size=25, color={32, 112, 220}, font="f1"})), {0.00, 0.50}), {692, fixY(sz.height, 240)})
    local w = setPos(setAnchor(addChild(temp, ui.newTTFLabel({text="特殊", size=25, color={32, 112, 220}, font="f1"})), {0.00, 0.50}), {289, fixY(sz.height, 564)})
    local w = setPos(setAnchor(addChild(temp, ui.newTTFLabel({text="", size=25, color={32, 112, 220}, font="f1"})), {0.00, 0.50}), {435, fixY(sz.height, 563)})
    self.temp:addChild(temp)
    self.selPage = temp
    return temp
end

function EquipChangeMenu:initBodyView()
    local sz = {width=1024, height=768}
    local temp = CCNode:create()

    local w = setPos(setAnchor(addChild(temp, ui.newTTFLabel({text="体装备", size=25, color={32, 112, 220}, font="f1"})), {0.00, 0.50}), {333, fixY(sz.height, 240)})
    local w = setPos(setAnchor(addChild(temp, ui.newTTFLabel({text="防御力", size=25, color={32, 112, 220}, font="f1"})), {0.00, 0.50}), {504, fixY(sz.height, 239)})
    local w = setPos(setAnchor(addChild(temp, ui.newTTFLabel({text="剩余", size=25, color={32, 112, 220}, font="f1"})), {0.00, 0.50}), {692, fixY(sz.height, 240)})
    local w = setPos(setAnchor(addChild(temp, ui.newTTFLabel({text="刀", size=25, color={32, 112, 220}, font="f1"})), {0.00, 0.50}), {289, fixY(sz.height, 564)})
    self.ename = w

    local w = setPos(setAnchor(addChild(temp, ui.newTTFLabel({text="+18", size=20, color={255, 255, 255}, font="f1"})), {1.00, 0.50}), {546, fixY(sz.height, 564)})
    self.firNum = w
    local w = setPos(setAnchor(addChild(temp, ui.newTTFLabel({text="防御", size=25, color={32, 112, 220}, font="f1"})), {0.00, 0.50}), {435, fixY(sz.height, 563)})
    self.firAtt = w

    local w = setPos(setAnchor(addChild(temp, ui.newTTFLabel({text="防御", size=25, color={32, 112, 220}, font="f1"})), {0.00, 0.50}), {590, fixY(sz.height, 563)})
    self.secAtt = w
    local w = setPos(setAnchor(addChild(temp, ui.newTTFLabel({text="+18", size=20, color={255, 255, 255}, font="f1"})), {0.00, 0.50}), {664, fixY(sz.height, 564)})
    self.secNum = w

    self.temp:addChild(temp)
    self.selPage = temp
    return temp
end

function EquipChangeMenu:initHeadView()
    local sz = {width=1024, height=768}
    local temp = CCNode:create()

    local w = setPos(setAnchor(addChild(temp, ui.newTTFLabel({text="头装备", size=25, color={32, 112, 220}, font="f1"})), {0.00, 0.50}), {333, fixY(sz.height, 240)})
    local w = setPos(setAnchor(addChild(temp, ui.newTTFLabel({text="剩余", size=25, color={32, 112, 220}, font="f1"})), {0.00, 0.50}), {692, fixY(sz.height, 240)})
    local w = setPos(setAnchor(addChild(temp, ui.newTTFLabel({text="刀", size=25, color={32, 112, 220}, font="f1"})), {0.00, 0.50}), {289, fixY(sz.height, 564)})
    self.ename = w

    local w = setPos(setAnchor(addChild(temp, ui.newTTFLabel({text="攻击", size=25, color={32, 112, 220}, font="f1"})), {0.00, 0.50}), {434, fixY(sz.height, 563)})
    self.firAtt = w
    local w = setPos(setAnchor(addChild(temp, ui.newTTFLabel({text="+18", size=20, color={255, 255, 255}, font="f1"})), {0.00, 0.50}), {510, fixY(sz.height, 564)})
    self.firNum = w
    local w = setPos(setAnchor(addChild(temp, ui.newTTFLabel({text="防御", size=25, color={32, 112, 220}, font="f1"})), {0.00, 0.50}), {590, fixY(sz.height, 563)})
    self.secAtt = w
    local w = setPos(setAnchor(addChild(temp, ui.newTTFLabel({text="+18", size=20, color={255, 255, 255}, font="f1"})), {0.00, 0.50}), {664, fixY(sz.height, 564)})
    self.secNum = w

    self.temp:addChild(temp)
    self.selPage = temp
end


function EquipChangeMenu:setSel(s)
    --数据量太少
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
        setColor(word[2], {255, 255, 255})
        setColor(word[3], {255, 255, 255})
        setColor(word[4], {255, 255, 255})
        if self.selNum == 1 then
            self:setWeaponInfo()
        elseif self.selNum == 2 then
            self:setHeadInfo()
        elseif self.selNum == 3 then
            self:setBodyInfo()
        end
    end

    local edata = self.allData[self.selPanel]
    self.desWord:setString(edata.des)
end

--设定每种类型装备的 显示列表
function EquipChangeMenu:setView()
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
    self:updateTab()
    self.selPanel = nil
    self:setSel(1)
    self.total:setString("装备变更"..self.selNum..'/4')
    if self.scrollPro ~= nil then
        setPos(self.scrollPro, {0, 315})
    end
end

function EquipChangeMenu:onLeft()
    if self.selNum > 1 then
        self.selNum = self.selNum-1
    else
        self.selNum = 4
    end
    self:setView()
end
function EquipChangeMenu:onRight()
    if self.selNum < 4 then
        self.selNum = self.selNum+1
    else
        self.selNum = 1
    end
    self:setView()
end


function EquipChangeMenu:updateTab()
    removeSelf(self.flowNode)
    self.flowNode = addNode(self.cl)
    setPos(self.flowNode, {0, self.HEIGHT})
    self.flowHeight = 0

	local initX = 0
	local initY = -58
	local offX = 0
	local offY = 58
	self.data = {}
	local sz = {width=537, height=58}

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
	for k, v in ipairs(allData) do
        if Logic.researchEquip[v.id]  == true then
            table.insert(tempAllData, v)
            local row = math.floor((k-1)/rowWidth)
            local col = (k-1)%rowWidth

            local panel = setPos(addNode(self.flowNode), {initX+col*offX, initY-offY*row})
            panel:setTag(k)
            setContentSize(panel, {sz.width, sz.height})

            local back = setAnchor(setSize(setPos(addSprite(panel, "listB.png"), {297, fixY(sz.height, 30)}), {479, 52}), {0.50, 0.50})
            local sp = setAnchor(setSize(setPos(addSprite(panel, "weaponIcon.png"), {27, fixY(sz.height, 31)}), {54, 54}), {0.50, 0.50})
            local sp = setAnchor(setSize(setPos(addSprite(panel, "equip"..v.id..".png"), {24, fixY(sz.height, 26)}), {48, 53}), {0.50, 0.50})

            local w1 = setPos(setAnchor(addChild(panel, ui.newTTFLabel({text=v.name, size=20, color={240, 196, 92}, font="f1"})), {0.00, 0.50}), {75, fixY(sz.height, 30)})
            local w2
            --当前装备的装备 高亮显示
            --取消掉旧装备的高亮 增加新装备的高亮
            if self.selNum == 1 then
                print("self.people.weapon", self.people.weapon, v.id)
                if self.people.weapon == v.id then
                    setColor(back, {255, 255, 0})
                    self.oldEquipId = v.id
                    self.oldEquip = back
                    print("self.oldEquip", self.oldEquip)
                end
                w2 = setPos(setAnchor(addChild(panel, ui.newTTFLabel({text=v.attack, size=20, color={240, 196, 92}, font="f1"})), {0.00, 0.50}), {273, fixY(sz.height, 30)})
            elseif self.selNum == 2 then
                if self.people.head == v.id then
                    setColor(back, {255, 255, 0})
                    self.oldEquipId = v.id
                    self.oldEquip = back
                end

                local aname, anum = self:getFirstAtt(v)
                local w = setPos(setAnchor(addChild(panel, ui.newTTFLabel({text=aname, size=20, color={32, 112, 220}, font="f1"})), {0.00, 0.50}), {273, fixY(sz.height, 30)})
                w2 = setPos(setAnchor(addChild(panel, ui.newTTFLabel({text="+"..anum, size=20, color={255, 255, 255}, font="f1"})), {0.00, 0.50}), {322, fixY(sz.height, 30)})
            elseif self.selNum == 3 then
                if self.people.body == v.id then
                    setColor(back, {255, 255, 0})
                    self.oldEquipId = v.id
                    self.oldEquip = back
                end
                w2 = setPos(setAnchor(addChild(panel, ui.newTTFLabel({text=v.defense, size=20, color={240, 196, 92}, font="f1"})), {0.00, 0.50}), {273, fixY(sz.height, 30)})

            elseif self.selNum == 4 then
                if self.people.spe == v.id then
                    setColor(back, {255, 255, 0})
                    self.oldEquipId = v.id
                    self.oldEquip = back
                end
                w2 = setPos(setAnchor(addChild(panel, ui.newTTFLabel({text='', size=20, color={240, 196, 92}, font="f1"})), {0.00, 0.50}), {273, fixY(sz.height, 30)})

            end

            local w3 = setPos(setAnchor(addChild(panel, ui.newTTFLabel({text=(Logic.holdNum[v.id] or 0).."个", size=20, color={240, 196, 92}, font="f1"})), {1, 0.50}), {473, fixY(sz.height, 29)})

            table.insert(self.data, {back, w1, w2, w3, v.id})
            self.flowHeight = self.flowHeight+offY
        end
	end
    self.allData = tempAllData
end

function EquipChangeMenu:touchBegan(x, y)
    self.lastPoints = {x, y}
    self.accMove = 0
    self.curSel = nil
end

function EquipChangeMenu:moveBack(dify)
    local ox, oy = self.flowNode:getPosition()
    self.flowNode:setPosition(ccp(ox, oy+dify))

    local sxy = getPos(self.scrollPro)
    local total = #self.data
    local ny = math.max(math.min(sxy[2]+-dify*(self.scrollBackHei/self.flowHeight), self.scrollBackHei), self.scrollHeight)
    setPos(self.scrollPro, {sxy[1], ny})
end
function EquipChangeMenu:touchMoved(x, y)
    local oldPoints = self.lastPoints
    self.lastPoints = {x, y}
    local dify = self.lastPoints[2]-oldPoints[2]
    self.accMove = self.accMove+math.abs(dify)
    self:moveBack(dify)
end


function EquipChangeMenu:touchEnded(x, y)
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
                --放下装备
                if self.oldEquipId == eid then
                    changeEquip(eid, 1)
                    self.people:putEquip(eid)
                    self:refreshData()
                    addBanner(self.people.name.."卸下装备"..edata.name)
                    self.oldEquipId = nil
                    self.oldEquip = nil
                elseif Logic.holdNum[eid] ~= nil and Logic.holdNum[eid] > 0  then
                    changeEquip(eid, -1)
                    self.people:setEquip(eid)
                    addBanner(self.people.name.."装备"..edata.name..'成功')
                    self:refreshData()
                else
                    global.director:pushView(BuyMenu.new(self.people, self.allData[self.selPanel]), 1)
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
--重新设定装备剩余数量 和当前装备的高亮状态
--如果装备剩余数量大于0 则不用购买
function EquipChangeMenu:refreshData()
    self:setView()
end

require "menu.EquipChangeMenuStatic"
