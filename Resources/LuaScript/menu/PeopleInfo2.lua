PeopleInfo2 = class()
function PeopleInfo2:ctor(p, attribute)
    self.selPeople = p
    self.attribute = attribute

    local vs = getVS()
    self.bg = CCNode:create()
    local sz = {width=1024, height=768}
    self.temp = setPos(addNode(self.bg), {-13.5, fixY(sz.height, 0+sz.height)+4})
    local sp = setOpacity(setAnchor(setSize(setPos(addSprite(self.temp, "dialogA.png"), {525, fixY(sz.height, 388)}), {693, 588}), {0.50, 0.50}), 255)
    local sp = setOpacity(setAnchor(setSize(setPos(addSprite(self.temp, "dialogB.png"), {523, fixY(sz.height, 418)}), {626, 358}), {0.50, 0.50}), 255)
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="Lv.", size=26, color={32, 112, 220}, font="f2", shadowColor={255, 255, 255}})), {0.00, 0.50}), {682, fixY(sz.height, 216)})
    self.level = w
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="name", size=26, color={32, 112, 220}, font="f2", shadowColor={255, 255, 255}})), {0.00, 0.50}), {259, fixY(sz.height, 215)})
    self.name = w

    local but = ui.newButton({image="newClose.png", text="", font="f1", size=18, delegate=self, callback=closeDialog, shadowColor={0, 0, 0}, color={255, 255, 255}})
    but:setContentSize(80, 82)
    setPos(addChild(self.temp, but.bg), {848, fixY(sz.height, 112)})
    local but = ui.newButton({image="newLeftArrow.png", text="", font="f1", size=18, delegate=self, callback=self.onLeft, shadowColor={0, 0, 0}, color={255, 255, 255}})
    but:setContentSize(90, 106)
    setPos(addChild(self.temp, but.bg), {131, fixY(sz.height, 388)})
    local but = ui.newButton({image="newRightArrow.png", text="", font="f1", size=18, delegate=self, callback=self.onRight, shadowColor={0, 0, 0}, color={255, 255, 255}})
    but:setContentSize(90, 106)
    setPos(addChild(self.temp, but.bg), {923, fixY(sz.height, 390)})
    --local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="点击更换装备", size=26, color={32, 112, 220}, font="f2", shadowColor={255, 255, 255}})), {0.50, 0.50}), {528, fixY(sz.height, 624)})
    local sp = setOpacity(setAnchor(setSize(setPos(addSprite(self.temp, "infoTitle.png"), {531, fixY(sz.height, 148)}), {212, 42}), {0.50, 0.50}), 255)

    --local sp = setOpacity(setAnchor(setSize(setPos(addSprite(self.temp, "heroAttr.png"), {396, fixY(sz.height, 442)}), {181, 239}), {0.50, 0.50}), 255)
    local but = ui.newButton({image="heroAttr.png", delegate=self, callback=self.onAtt, needScale=false})
    addChild(self.temp, setPos(but.bg, {396, fixY(sz.height, 442)}))

    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="长刀", size=24, color={255, 255, 255}, font="f1", shadowColor={0, 0, 0}})), {0.50, 0.50}), {410, fixY(sz.height, 345)})
    self.weapon = w
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="头巾", size=24, color={240, 196, 92}, font="f1", shadowColor={0, 0, 0}})), {0.50, 0.50}), {410, fixY(sz.height, 392)})
    self.head = w
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="桶甲", size=24, color={240, 196, 92}, font="f1", shadowColor={0, 0, 0}})), {0.50, 0.50}), {410, fixY(sz.height, 443)})
    self.body = w
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="草药", size=24, color={240, 196, 92}, font="f1", shadowColor={0, 0, 0}})), {0.50, 0.50}), {411, fixY(sz.height, 488)})
    self.spe = w
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="物资搬运", size=24, color={240, 196, 92}, font="f1", shadowColor={0, 0, 0}})), {0.50, 0.50}), {416, fixY(sz.height, 538)})
    self.skill = w

    local sp = setOpacity(setAnchor(setSize(setPos(addSprite(self.temp, "weaponIcon.png"), {333, fixY(sz.height, 347)}), {40, 40}), {0.50, 0.50}), 255)
    self.weaponIcon = setPos(addSprite(sp, "equip1.png"), {22, 25})
    local sp = setOpacity(setAnchor(setSize(setPos(addSprite(self.temp, "weaponIcon.png"), {333, fixY(sz.height, 396)}), {40, 40}), {0.50, 0.50}), 255)
    self.headIcon = setPos(addSprite(sp, "equip1.png"), {22, 25})
    local sp = setOpacity(setAnchor(setSize(setPos(addSprite(self.temp, "weaponIcon.png"), {333, fixY(sz.height, 445)}), {40, 40}), {0.50, 0.50}), 255)
    self.bodyIcon = setPos(addSprite(sp, "equip1.png"), {22, 25})
    local sp = setOpacity(setAnchor(setSize(setPos(addSprite(self.temp, "weaponIcon.png"), {333, fixY(sz.height, 492)}), {40, 40}), {0.50, 0.50}), 255)
    self.speIcon = setPos(addSprite(sp, "equip1.png"), {22, 25})
    local sp = setOpacity(setAnchor(setSize(setPos(addSprite(self.temp, "weaponIcon.png"), {333, fixY(sz.height, 540)}), {40, 40}), {0.50, 0.50}), 255)
    self.skillIcon = setAnchor(setPos(addSprite(sp, "skill1.png"), {22, 25}), {76/128, 54/128})

    local w = setPos(setAnchor(addChild(sp, ui.newBMFontLabel({text='', size=17, color={255, 255, 255}, font="fonts.fnt", shadowColor={0, 0, 0}})), {0.00, 0.50}), {1, 8})
    self.skillLevel = w

    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="武", size=28, color={255, 255, 255}, font="f2", shadowColor={0, 0, 0}})), {0.00, 0.50}), {261, fixY(sz.height, 344)})
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="头", size=28, color={255, 255, 255}, font="f2", shadowColor={0, 0, 0}})), {0.00, 0.50}), {262, fixY(sz.height, 391)})
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="体", size=28, color={255, 255, 255}, font="f2", shadowColor={0, 0, 0}})), {0.00, 0.50}), {259, fixY(sz.height, 441)})
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="特", size=28, color={255, 255, 255}, font="f2", shadowColor={0, 0, 0}})), {0.00, 0.50}), {260, fixY(sz.height, 488)})
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="技", size=28, color={255, 255, 255}, font="f2", shadowColor={0, 0, 0}})), {0.00, 0.50}), {260, fixY(sz.height, 537)})
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="攻击", size=28, color={255, 255, 255}, font="f2", shadowColor={0, 0, 0}})), {0.00, 0.50}), {524, fixY(sz.height, 279)})
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="a9999", size=25, color={248, 181, 81}, font="f2", shadowColor={0, 0, 0}})), {1.00, 0.50}), {797, fixY(sz.height, 280)})
    self.attack = w
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="防御", size=28, color={255, 255, 255}, font="f2", shadowColor={0, 0, 0}})), {0.00, 0.50}), {525, fixY(sz.height, 326)})
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="d9999", size=25, color={248, 181, 81}, font="f2", shadowColor={0, 0, 0}})), {1.00, 0.50}), {797, fixY(sz.height, 327)})
    self.defense = w
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="体力", size=28, color={255, 255, 255}, font="f2", shadowColor={0, 0, 0}})), {0.00, 0.50}), {523, fixY(sz.height, 374)})
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="d9999", size=25, color={248, 181, 81}, font="f2", shadowColor={0, 0, 0}})), {1.00, 0.50}), {797, fixY(sz.height, 374)})
    self.health = w
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="腕力", size=28, color={255, 255, 255}, font="f2", shadowColor={0, 0, 0}})), {0.00, 0.50}), {524, fixY(sz.height, 425)})
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="d9999", size=25, color={248, 181, 81}, font="f2", shadowColor={0, 0, 0}})), {1.00, 0.50}), {797, fixY(sz.height, 425)})
    self.brawn = w
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="射击", size=28, color={255, 255, 255}, font="f2", shadowColor={0, 0, 0}})), {0.00, 0.50}), {524, fixY(sz.height, 472)})
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="d9999", size=25, color={248, 181, 81}, font="f2", shadowColor={0, 0, 0}})), {1.00, 0.50}), {797, fixY(sz.height, 472)})
    self.shoot = w
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="劳动", size=28, color={255, 255, 255}, font="f2", shadowColor={0, 0, 0}})), {0.00, 0.50}), {524, fixY(sz.height, 521)})
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="d9999", size=25, color={248, 181, 81}, font="f2", shadowColor={0, 0, 0}})), {1.00, 0.50}), {797, fixY(sz.height, 521)})
    self.labor = w
    local sp = setOpacity(setAnchor(setSize(setPos(addSprite(self.temp, "headBoard.png"), {287, fixY(sz.height, 289)}), {57, 52}), {0.50, 0.50}), 255)
    local sp = setOpacity(setAnchor(setPos(addSprite(self.temp, "catHead3.png"), {287, fixY(sz.height, 287)}), {0.50, 0.50}), 255)
    self.catHead = sp


    local b, p = createInfoPro()
    addChild(self.temp, setPos(b, {661, fixY(sz.height, 280)}))
    self.attackBar = p

    local b, p = createInfoPro()
    addChild(self.temp, setPos(b, {661, fixY(sz.height, 327)}))
    self.defenseBar = p

    local b, p = createInfoPro()
    addChild(self.temp, setPos(b, {661, fixY(sz.height, 374)}))
    self.healthBar = p

    local b, p = createInfoPro()
    addChild(self.temp, setPos(b, {661, fixY(sz.height, 425)}))
    self.brawnBar = p

    local b, p = createInfoPro()
    addChild(self.temp, setPos(b, {661, fixY(sz.height, 472)}))
    self.shootBar = p

    local b, p = createInfoPro()
    addChild(self.temp, setPos(b, {661, fixY(sz.height, 521)}))
    self.laborBar = p

    if not self.attribute then
        local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="费用", size=28, color={255, 255, 255}, font="f2"})), {0.00, 0.50}), {524, fixY(sz.height, 567)})
        local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="9999银币", size=25, color={248, 181, 81}, font="f2"})), {1.00, 0.50}), {797, fixY(sz.height, 568)})
        self.silver = w

        local but = ui.newButton({image="butc.png", text="进行升级", font="f1", size=27, delegate=self, callback=self.onLevel})
        but:setContentSize(152, 38)
        setPos(addChild(self.temp, but.bg), {543, fixY(sz.height, 626)})
    end

    self:setPeople()
    centerUI(self)
end

function PeopleInfo2:onAtt()
    global.director:pushView(EquipChangeMenu2.new(Logic.farmPeople[self.selPeople]), 1)
end
function PeopleInfo2:onLeft()
    if self.selPeople > 1 then
        self.selPeople = self.selPeople-1
    else
        self.selPeople = #Logic.farmPeople
    end
    self:setPeople()
end
function PeopleInfo2:onRight()
    if self.selPeople < #Logic.farmPeople then
        self.selPeople = self.selPeople+1
    else
        self.selPeople = 1
    end
    self:setPeople()
end

function createInfoPro()
    local sz = {width=140, height=29}
    local pro = {lw=8, rw=8, cw=6}

    local banner = setSize(createSprite("prob.png"), {140, 29})
    local tex = CCTextureCache:sharedTextureCache():addImage("proa.png")
    local tsz = tex:getContentSize()

    local ca = CCSpriteFrameCache:sharedSpriteFrameCache()
    local r = CCRectMake(0, 0, pro.lw, tsz.height)
    local left = createSpriteFrame(tex, r, 'infoproLeft')
    local r = CCRectMake(tsz.width-pro.rw, 0, pro.rw, tsz.height)
    local right = createSpriteFrame(tex, r, 'infoproRight')
    local r = CCRectMake(pro.lw, 0, tsz.width-pro.lw-pro.rw, tsz.height)
    local center = createSpriteFrame(tex, r, 'infoproMiddle')

    pro.bg = CCSpriteBatchNode:create("proa.png")
    pro.left = createSprite("infoproLeft")
    addChild(pro.bg, pro.left)
    setAnchor(pro.left, {0, 0.5})
    setPos(pro.left, {0, 0})
    pro.right = createSprite("infoproRight")
    addChild(pro.bg, pro.right)
    setAnchor(pro.right, {0, 0.5})
    setPos(pro.right, {pro.lw+pro.cw, 0})
    pro.center = createSprite("infoproMiddle")
    addChild(pro.bg, pro.center)
    setAnchor(pro.center, {0, 0.5})
    setPos(pro.center, {pro.lw, 0})

    banner:addChild(pro.bg)
    setAnchor(setPos(pro.bg, {4, fixY(sz.height, 14)}), {0, 0.5})
    function pro:setProNum(n, max)
        if n <= 0 then
            pro.bg:setVisible(false)
        else
            pro.bg:setVisible(true)
            local wid = math.floor((n/max)*tsz.width)
            wid = math.max(pro.lw+pro.rw, wid)
            local cw = wid-pro.lw-pro.rw
            local r = CCRectMake(pro.lw, 0, cw, tsz.height)
            pro.center:setTextureRect(r, false, r.size)
            setPos(pro.right, {wid-pro.rw, 0})
        end
    end
    return banner, pro
end

function PeopleInfo2:setPeople()
    local total = #Logic.farmPeople
    local pdata = Logic.farmPeople[self.selPeople]
    self.name:setString(pdata.data.name)
    local att = calAttr(pdata.id, pdata.level, pdata)
    self.attack:setString(att.attack)
    self.defense:setString(att.defense)
    self.health:setString(att.health)
    self.brawn:setString(att.brawn)
    self.shoot:setString(att.shoot)
    self.labor:setString(att.labor)
    setDisplayFrame(self.catHead, "catHead"..pdata.id..".png")
    
    self.level:setString('Lv.'..(pdata.level+1))
    if pdata.weapon ~= nil then
        self.weapon:setString(Logic.equip[pdata.weapon].name)
        setDisplayFrame(self.weaponIcon, "equip"..pdata.weapon..'.png')
        setVisible(self.weaponIcon, true)
    else
        setVisible(self.weaponIcon, false)
        self.weapon:setString('')
    end

    if pdata.head ~= nil then
        self.head:setString(Logic.equip[pdata.head].name)
        setDisplayFrame(self.headIcon, "equip"..pdata.head..'.png')
        setVisible(self.headIcon, true)
    else
        setVisible(self.headIcon, false)
        self.head:setString('')
    end
    if pdata.body ~= nil then
        self.body:setString(Logic.equip[pdata.body].name)
        setDisplayFrame(self.bodyIcon, "equip"..pdata.body..'.png')
        setVisible(self.bodyIcon, true)
    else
        setVisible(self.bodyIcon, false)
        self.body:setString('')
    end
    if pdata.spe ~= nil then
        self.spe:setString(Logic.equip[pdata.spe].name)
        setDisplayFrame(self.speIcon, "equip"..pdata.spe..'.png')
        setVisible(self.speIcon, true)
    else
        setVisible(self.speIcon, false)
        self.spe:setString('')
    end
    local sid = getPeopleSkill(pdata.id, pdata.level)
    if sid == 0 then
        setVisible(self.skillIcon, false)
        self.skill:setString('')
    else
        local sdata = Logic.allSkill[sid] 
        self.skill:setString(sdata.name)
        setDisplayFrame(self.skillIcon, "skill"..getSkillIcon(sid)..'.png')
        setVisible(self.skillIcon, true)
        if sdata.hasLevel > 0 then
            self.skillLevel:setString(sdata.hasLevel)
        else
            self.skillLevel:setString('')
        end
    end

    if not self.attribute then
        self.silver:setString(Logic.LevelCost[pdata.level+1+1].."银币")
        self.level:setString('Lv '..pdata.level+1)
    end

    self.attackBar:setProNum(att.attack, 300)
    self.defenseBar:setProNum(att.defense, 300)
    self.healthBar:setProNum(att.health, 300)
    self.brawnBar:setProNum(att.brawn, 300)
    self.shootBar:setProNum(att.shoot, 300)
    self.laborBar:setProNum(att.labor, 300)

end

function PeopleInfo2:onLevel()
    local people = Logic.farmPeople[self.selPeople] 
    local silver = Logic.LevelCost[people.level+1+1]
    print("LevelCost is ", people.level, silver)
    if not checkCost(silver) then
        addBanner("银币不足")
    else
        doCost(silver)
        people:updateLevel()
        global.director:popView()
    end
end

function PeopleInfo2:refreshData()
    self:setPeople()
end
