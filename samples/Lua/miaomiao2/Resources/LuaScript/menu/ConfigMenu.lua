require "menu.ChooseMenu"
require "menu.ArmyMenu"
ConfigMenu = class()
function ConfigMenu:ctor(ct)
    self.city = ct

    local vs = getVS()
    self.bg = CCNode:create()
    local sz = {width=1024, height=768}
    self.temp = setPos(addNode(self.bg), {0, fixY(sz.height, 0+sz.height)+0})
    local sp = setOpacity(setAnchor(setSize(setPos(addSprite(self.temp, "dialogA.png"), {525, fixY(sz.height, 388)}), {693, 588}), {0.50, 0.50}), 255)
    local sp = setOpacity(setAnchor(setSize(setPos(addSprite(self.temp, "dialogB.png"), {524, fixY(sz.height, 409)}), {626, 340}), {0.50, 0.50}), 255)
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="参战费用", size=26, color={32, 112, 220}, font="f2", shadowColor={255, 255, 255}})), {0.00, 0.50}), {258, fixY(sz.height, 215)})
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="(野外村落仅限英雄出战)", size=26, color={247, 5, 39}, font="f2", shadowColor={255, 255, 255}})), {0.00, 0.50}), {514, fixY(sz.height, 215)})
    local but = ui.newButton({image="newClose.png", text="", font="f1", size=18, delegate=self, callback=closeDialog, shadowColor={0, 0, 0}, color={255, 255, 255}})
    but:setContentSize(80, 82)
    setPos(addChild(self.temp, but.bg), {848, fixY(sz.height, 112)})
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="+34", size=18, color={248, 181, 81}, font="f1", shadowColor={0, 0, 0}})), {0.50, 0.50}), {364, fixY(sz.height, 531)})
    self.footW = w
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="+35", size=18, color={248, 181, 81}, font="f1", shadowColor={0, 0, 0}})), {0.50, 0.50}), {469, fixY(sz.height, 531)})
    self.arrowW = w
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="+36", size=18, color={248, 181, 81}, font="f1", shadowColor={0, 0, 0}})), {0.50, 0.50}), {574, fixY(sz.height, 531)})
    self.magicW = w
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="+37", size=18, color={248, 181, 81}, font="f1", shadowColor={0, 0, 0}})), {0.50, 0.50}), {677, fixY(sz.height, 531)})
    self.cavalryW = w
     
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="步兵", size=18, color={255, 255, 255}, font="f1", shadowColor={0, 0, 0}})), {0.50, 0.50}), {364, fixY(sz.height, 493)})
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="弓箭", size=18, color={255, 255, 255}, font="f1", shadowColor={0, 0, 0}})), {0.50, 0.50}), {469, fixY(sz.height, 494)})
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="魔法", size=18, color={255, 255, 255}, font="f1", shadowColor={0, 0, 0}})), {0.50, 0.50}), {574, fixY(sz.height, 493)})
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="骑兵", size=18, color={255, 255, 255}, font="f1", shadowColor={0, 0, 0}})), {0.50, 0.50}), {677, fixY(sz.height, 493)})
    local but = ui.newButton({image="butc.png", text="配置调整", font="f1", size=27, delegate=self, callback=self.onBut, param=1, shadowColor={0, 0, 0}, color={206, 78, 0}})
    but:setContentSize(158, 50)
    setPos(addChild(self.temp, but.bg), {528, fixY(sz.height, 615)})
    local but = ui.newButton({image="butd.png", text="出战!", font="f1", size=27, delegate=self, callback=self.onBut, param=3, shadowColor={0, 0, 0}, color={255, 255, 255}})
    but:setContentSize(158, 50)
    setPos(addChild(self.temp, but.bg), {712, fixY(sz.height, 615)})
    local but = ui.newButton({image="butc.png", text="参加者", font="f1", size=27, delegate=self, callback=self.onBut, param=2, param=2, shadowColor={0, 0, 0}, color={206, 78, 0}})
    but:setContentSize(159, 50)
    setPos(addChild(self.temp, but.bg), {342, fixY(sz.height, 614)})
    local sp = setOpacity(setAnchor(setSize(setPos(addSprite(self.temp, "picBefore.png"), {523, fixY(sz.height, 365)}), {519, 176}), {0.50, 0.50}), 255)
    local sp = setOpacity(setAnchor(setSize(setPos(addSprite(self.temp, "configTitle.png"), {533, fixY(sz.height, 147)}), {212, 41}), {0.50, 0.50}), 255)

    centerUI(self)
    
    self:initHero()
end

function ConfigMenu:initHero()
    local n = Logic.fightNum
    local en = Logic.attendHero

    --补全 英雄
    if #en < n then
        local inAtt = {}
        for k, v in ipairs(en) do
            inAtt[v] = true 
        end
        local left = n-#en
        --没有在farmPeople 中
        for k, v in ipairs(Logic.farmPeople) do
            if not inAtt[k] then
                table.insert(en, {id=k, pos=0})
                left = left-1
            end
            if left <= 0 then
                break
            end
        end
    end
    self:adjustAttend() 
end

function ConfigMenu:adjustAttend()
    if self.hNode ~= nil then
        removeSelf(self.hNode)
    end
    self.hNode = addNode(self.temp)
    local initX = 140
    local initY = 176-128
    local offX = 80
    local offY = 60
    local bsize = {519, 176}
    local bpos = {523, fixY(768, 365)}

    print("initHero", simple.encode(Logic.attendHero))

    local foot = 0
    local arrow = 0
    local magic = 0
    local cavalry = 0
    for k, v in ipairs(Logic.attendHero) do
        local row = math.floor((k-1)/4)
        local col = (k-1)%4
        local pData = Logic.farmPeople[v.id]
        local sp = createSprite("cat_"..pData.id.."_rb_0.png")
        setAnchor(setPos(setScale(sp, 0.5), {bpos[1]-bsize[1]/2+initX+col*offX, bpos[2]-bsize[2]/2+initY+row*offY}), {257/512, (512-374)/512})
        addChild(self.hNode, sp)
        sp:setZOrder(10-row)

        local equip = pData
        local weapKind = 0 
        local ride = false
        if equip.weapon ~= nil then
            local edata = Logic.equip[equip.weapon]
            --兵器
            if edata.kind == 0 then
                --近战 远战
                if edata.subKind == 0 or edata.subKind == 1 or edata.subKind == 4 then
                    weapKind = 0
                elseif edata.subKind == 2 then
                    weapKind = 1
                elseif edata.subKind == 3 then
                    weapKind = 2
                end
            end
        end
        if equip.spe ~= nil then
            local edata = Logic.equip[equip.spe]
            ride = edata.ride == 1
        end
        if ride then
            cavalry = cavalry+1
        elseif weapKind == 0 then
            foot = foot+1
        elseif weapKind == 1 then
            arrow = arrow+1
        elseif weapKind == 2 then
            magic = magic+1
        end
    end
    if foot > 0 then
        self.footW:setString('+'..foot)
    else
        self.footW:setString('')
    end
    if arrow > 0 then
        self.arrowW:setString('+'..arrow)
    else
        self.arrowW:setString('')
    end
    if magic > 0 then
        self.magicW:setString('+'..magic)
    else
        self.magicW:setString('')
    end
    if cavalry > 0 then
        self.cavalryW:setString('+'..cavalry)
    else
        self.cavalryW:setString('')
    end
end

--调整参战英雄数量
function ConfigMenu:refreshData()
    print("refresh ConfigMenu")
    self:adjustAttend()
end

function ConfigMenu:onArena()
    global.director:pushScene(FightScene.new())
end

function ConfigMenu:onVillage()
    global.director:pushScene(FightScene.new())
end

function ConfigMenu:onBut(p)
    if p == 1 then
        global.director:pushView(ArmyMenu.new(), 1)
    elseif p == 2 then
        global.director:pushView(ChooseMenu.new(), 1, 0)
    elseif p == 3 then
        if #Logic.attendHero == 0 then
            addBanner("至少选择一个村民参战!")
            return
        end
        --挑战 新手村
        if self.city == nil then
            Logic.newVillage = true
            global.director:popView()
            global.director:pushView(SessionMenu.new("开始攻略村落", self.onVillage, self), 1, 0)
        --挑战竞技场
        elseif self.city.kind == 0 then
            global.director:popView()
            Logic.challengeCity = self.city
            global.director:pushView(SessionMenu.new("虽然是模拟战但也不可以粗心大意哦！", self.onArena, self), 1, 0)
        --挑战 城堡 realId 或者 kind = 4 challengeCity challengeKind
        elseif self.city.kind == 1 then
            print("fight menu city")
            global.director.curScene.page:sendCat(self.city)
            global.director:popView()
            global.director:pushView(SessionMenu.new("那么现在开始向\n战场出发!!"), 1, 0)
        elseif self.city.kind == 4 then
            print("fight menu city")
            global.director.curScene.page:sendCatToVillage(self.city)
            global.director:popView()
            global.director:pushView(SessionMenu.new("那么现在开始向\n战场出发!!"), 1, 0)
        end
    end
end


