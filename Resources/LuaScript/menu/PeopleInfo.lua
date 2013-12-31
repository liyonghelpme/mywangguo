PeopleInfo = class()
function PeopleInfo:adjustPos()
    centerUI(self)
end
function PeopleInfo:ctor(p, attribute)
    self.selPeople = p
    self.attribute = attribute

    local vs = getVS()
    self.bg = CCNode:create()
    local sz = {width=1024, height=768}
    self.temp = setPos(addNode(self.bg), {-33, 0})

    local sp = setAnchor(setPos(addSprite(self.temp, "dialogA.png"), {539, fixY(sz.height, 387)}), {0.50, 0.50})
    local sp = setAnchor(setSize(setPos(addSprite(self.temp, "dialogB.png"), {536, fixY(sz.height, 421)}), {617, 352}), {0.50, 0.50})
    local sp = setAnchor(setSize(setPos(addSprite(self.temp, "heroAttr.png"), {403, fixY(sz.height, 447)}), {181, 239}), {0.50, 0.50})
    local but = ui.newButton({image="heroAttr.png", delegate=self, callback=self.onAtt})
    addChild(self.temp, setPos(but.bg, {403, fixY(sz.height, 447)}))

    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="林雨披之助", size=25, color={32, 112, 220}, font="f1"})), {0.00, 0.50}), {358, fixY(sz.height, 219)})
    self.name = w
    local w1 = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="长刀", size=24, color={255, 255, 255}, font="f1"})), {0.00, 0.50}), {390, fixY(sz.height, 350)})
    self.weapon = w1

    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="头巾", size=24, color={240, 196, 92}, font="f1"})), {0.00, 0.50}), {390, fixY(sz.height, 397)})
    self.head = w
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="桶甲", size=24, color={240, 196, 92}, font="f1"})), {0.00, 0.50}), {389, fixY(sz.height, 448)})
    self.body = w
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="草药", size=24, color={240, 196, 92}, font="f1"})), {0.00, 0.50}), {389, fixY(sz.height, 493)})
    self.spe = w
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="物资搬运", size=24, color={240, 196, 92}, font="f1"})), {0.00, 0.50}), {376, fixY(sz.height, 543)})
    self.skill = w
    local sp = setAnchor(setSize(setPos(addSprite(self.temp, "goodsIcon.png"), {341, fixY(sz.height, 349)}), {32, 35}), {0.50, 0.50})
    self.weaponIcon = sp
    local sp = setAnchor(setSize(setPos(addSprite(self.temp, "goodsIcon.png"), {341, fixY(sz.height, 398)}), {32, 35}), {0.50, 0.50})
    self.headIcon = sp
    local sp = setAnchor(setSize(setPos(addSprite(self.temp, "goodsIcon.png"), {341, fixY(sz.height, 446)}), {32, 35}), {0.50, 0.50})
    self.bodyIcon = sp
    local sp = setAnchor(setSize(setPos(addSprite(self.temp, "goodsIcon.png"), {341, fixY(sz.height, 495)}), {32, 35}), {0.50, 0.50})
    self.speIcon = sp
    local sp = setAnchor(setSize(setPos(addSprite(self.temp, "goodsIcon.png"), {341, fixY(sz.height, 542)}), {32, 35}), {0.50, 0.50})
    self.skillIcon = sp
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="武", size=28, color={255, 255, 255}, font="f2"})), {0.00, 0.50}), {268, fixY(sz.height, 349)})
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="头", size=28, color={255, 255, 255}, font="f2"})), {0.00, 0.50}), {269, fixY(sz.height, 396)})
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="体", size=28, color={255, 255, 255}, font="f2"})), {0.00, 0.50}), {266, fixY(sz.height, 446)})
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="特", size=28, color={255, 255, 255}, font="f2"})), {0.00, 0.50}), {267, fixY(sz.height, 493)})
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="技", size=28, color={255, 255, 255}, font="f2"})), {0.00, 0.50}), {267, fixY(sz.height, 542)})
    --local sp = setAnchor(setSize(setPos(addSprite(self.temp, "prob.png"), {668, fixY(sz.height, 285)}), {140, 29}), {0.50, 0.50})
    --local sp = setAnchor(setSize(setPos(addSprite(self.temp, "proa.png"), {668, fixY(sz.height, 285)}), {132, 20}), {0.50, 0.50})

    local banner = setAnchor(setSize(setPos(addSprite(self.temp, "prob.png"), {668, fixY(sz.height, 285)}), {140, 29}), {0.50, 0.50})
    local pro = setAnchor(setSize(setPos(addSprite(banner, "proa.png"), {4, 4.5}), {183, 20}), {0.0, 0})
    self.attackBar = pro

    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="攻击", size=28, color={255, 255, 255}, font="f2"})), {0.00, 0.50}), {531, fixY(sz.height, 284)})
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="9999", size=25, color={248, 181, 81}, font="f2"})), {0.00, 0.50}), {747, fixY(sz.height, 285)})
    self.attack = w

    local sp = setAnchor(setSize(setPos(addSprite(self.temp, "prob.png"), {668, fixY(sz.height, 332)}), {140, 29}), {0.50, 0.50})
    local sp = setAnchor(setSize(setPos(addSprite(self.temp, "proa.png"), {668, fixY(sz.height, 332)}), {132, 20}), {0.50, 0.50})

    local banner = setAnchor(setSize(setPos(addSprite(self.temp, "prob.png"), {668, fixY(sz.height, 332)}), {140, 29}), {0.50, 0.50})
    local pro = setAnchor(setSize(setPos(addSprite(banner, "proa.png"), {4, 4.5}), {183, 20}), {0.0, 0})
    self.defenseBar = pro

    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="防御", size=28, color={255, 255, 255}, font="f2"})), {0.00, 0.50}), {532, fixY(sz.height, 331)})
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="9999", size=25, color={248, 181, 81}, font="f2"})), {0.00, 0.50}), {747, fixY(sz.height, 332)})
    self.defense = w

    local banner = setAnchor(setSize(setPos(addSprite(self.temp, "prob.png"), {668, fixY(sz.height, 379)}), {140, 29}), {0.50, 0.50})
    local pro = setAnchor(setSize(setPos(addSprite(banner, "proa.png"), {4, 4.5}), {183, 20}), {0.0, 0})
    self.healthBar = pro

    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="9999", size=25, color={248, 181, 81}, font="f2"})), {0.00, 0.50}), {747, fixY(sz.height, 379)})
    self.health = w

    local banner = setAnchor(setSize(setPos(addSprite(self.temp, "prob.png"), {668, fixY(sz.height, 426)}), {140, 29}), {0.50, 0.50})
    local pro = setAnchor(setSize(setPos(addSprite(banner, "proa.png"), {4, 4.5}), {183, 20}), {0.0, 0})
    self.brawnBar = pro
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="9999", size=25, color={248, 181, 81}, font="f2"})), {0.00, 0.50}), {747, fixY(sz.height, 426)})
    self.brawn = w

    local banner = setAnchor(setSize(setPos(addSprite(self.temp, "prob.png"), {668, fixY(sz.height, 473)}), {140, 29}), {0.50, 0.50})
    local pro = setAnchor(setSize(setPos(addSprite(banner, "proa.png"), {4, 4.5}), {183, 20}), {0.0, 0})
    self.shootBar = pro
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="9999", size=25, color={248, 181, 81}, font="f2"})), {0.00, 0.50}), {747, fixY(sz.height, 473)})
    self.shoot = w

    local banner = setAnchor(setSize(setPos(addSprite(self.temp, "prob.png"), {668, fixY(sz.height, 520)}), {140, 29}), {0.50, 0.50})
    local pro = setAnchor(setSize(setPos(addSprite(banner, "proa.png"), {4, 4.5}), {183, 20}), {0.0, 0})
    self.laborBar = pro
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="9999", size=25, color={248, 181, 81}, font="f2"})), {0.00, 0.50}), {747, fixY(sz.height, 520)})
    self.labor = w

    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="体力", size=28, color={255, 255, 255}, font="f2"})), {0.00, 0.50}), {530, fixY(sz.height, 379)})
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="腕力", size=28, color={255, 255, 255}, font="f2"})), {0.00, 0.50}), {531, fixY(sz.height, 430)})
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="射击", size=28, color={255, 255, 255}, font="f2"})), {0.00, 0.50}), {531, fixY(sz.height, 477)})
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="劳动", size=28, color={255, 255, 255}, font="f2"})), {0.00, 0.50}), {531, fixY(sz.height, 526)})
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="Lv3", size=28, color={248, 181, 81}, font="f2"})), {0.00, 0.50}), {682, fixY(sz.height, 217)})
    self.level = w

    local but = ui.newButton({image="newLeftArrow.png", delegate=self, callback=self.onLeft})
    setPos(addChild(self.temp, but.bg), {144, fixY(sz.height, 388)})

    local but = ui.newButton({image="newRightArrow.png", delegate=self, callback=self.onRight})
    setPos(addChild(self.temp, but.bg), {929, fixY(sz.height, 388)})
    


    local sp = setAnchor(setSize(setPos(addSprite(self.temp, "headIcon.png"), {292, fixY(sz.height, 292)}), {50, 50}), {0.50, 0.50})
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="角色升级1/10", size=34, color={102, 66, 42}, font="f1"})), {0.50, 0.50}), {545, fixY(sz.height, 153)})
    self.title = w

    if not self.attribute then
        local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="费用", size=28, color={255, 255, 255}, font="f2"})), {0.00, 0.50}), {532, fixY(sz.height, 567)})
        local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="9999银币", size=25, color={248, 181, 81}, font="f2"})), {0.00, 0.50}), {699, fixY(sz.height, 568)})
        self.silver = w

        local but = ui.newButton({image="butc.png", text="进行升级", font="f1", size=27, delegate=self, callback=self.onLevel})
        but:setContentSize(152, 38)
        setPos(addChild(self.temp, but.bg), {543, fixY(sz.height, 626)})
    end

    self:setPeople()

    self:adjustPos()
end
function PeopleInfo:onAtt()
    global.director:pushView(EquipChangeMenu.new(Logic.farmPeople[self.selPeople]), 1)
end
function PeopleInfo:setPeople()
    local total = #Logic.farmPeople
    local pdata = Logic.farmPeople[self.selPeople]
    self.title:setString("角色升级"..self.selPeople..'/'..total)
    self.name:setString(pdata.data.name)
    local att = calAttr(pdata.id, pdata.level, pdata)
    self.attack:setString(att.attack)
    self.defense:setString(att.defense)
    self.health:setString(att.health)
    self.brawn:setString(att.brawn)
    self.shoot:setString(att.shoot)
    self.labor:setString(att.labor)

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
    if pdata.data.skillName ~= nil and pdata.data.skillName ~= '' then
        self.skill:setString(pdata.data.skillName)
        setDisplayFrame(self.skillIcon, "skill"..pdata.data.skill..'.png')
        setVisible(self.skillIcon, true)
    else
        setVisible(self.skillIcon, false)
        self.skill:setString('')
    end


    if not self.attribute then
        self.silver:setString(Logic.LevelCost[pdata.level+1+1].."银币")
        self.level:setString('Lv '..pdata.level+1)
    end

    newProNum(self.attackBar, att.attack, 300)
    newProNum(self.defenseBar, att.defense, 300)
    newProNum(self.healthBar, att.health, 300)
    newProNum(self.brawnBar, att.brawn, 300)
    newProNum(self.shootBar, att.shoot, 300)
    newProNum(self.laborBar, att.labor, 300)

end

function PeopleInfo:onLeft()
    if self.selPeople > 1 then
        self.selPeople = self.selPeople-1
    else
        self.selPeople = #Logic.farmPeople
    end
    self:setPeople()
end
function PeopleInfo:onRight()
    if self.selPeople < #Logic.farmPeople then
        self.selPeople = self.selPeople+1
    else
        self.selPeople = #Logic.farmPeople
    end
    self:setPeople()
end
function PeopleInfo:onLevel()
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

function PeopleInfo:refreshData()
    self:setPeople()
end
