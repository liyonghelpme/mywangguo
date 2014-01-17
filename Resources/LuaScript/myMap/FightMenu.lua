FightMenu = class()
function FightMenu:ctor()
    local vs = getVS()
    self.bg = CCNode:create()
    local sz = {width=1024, height=768}
    self.temp = setPos(addNode(self.bg), {0, fixY(sz.height, 0+sz.height)+0})
    self.rightBottom = addNode(self.temp)
    local but = ui.newButton({image="buta.png", text="返回", font="f2", size=30, delegate=self, callback=self.onBut, param=0, shadowColor={255, 255, 255}, color={206, 78, 0}})
    but:setContentSize(107, 113)
    setPos(addChild(self.rightBottom, but.bg), {945, fixY(sz.height, 706)})
    rightBottomUI(self.rightBottom)


    self.leftCenter = setPos(addNode(self.bg), {0, fixY(sz.height, 0+sz.height)+0})
    local sp = setAnchor(setSize(setPos(addSprite(self.leftCenter, "mapInfoBoard.png"), {118, fixY(sz.height, 388)}), {237, 404}), {0.50, 0.50})
    self.lm = sp
    local but = ui.newButton({image="mainMenuA3.png", text="进攻!", font="f2", size=24, delegate=self, callback=self.onBut, param=1, shadowColor={255, 255, 255}, color={252, 13, 1}})
    but:setContentSize(190, 68)
    setPos(addChild(self.leftCenter, but.bg), {101, fixY(sz.height, 506)})
    leftCenterUI(self.leftCenter)


    local w = setPos(setAnchor(addChild(self.leftCenter, ui.newTTFLabel({text="骑兵", size=24, color={240, 196, 92}, font="f2", shadowColor={0, 0, 0}})), {0.00, 0.50}), {37, fixY(sz.height, 435)})
    local w = setPos(setAnchor(addChild(self.leftCenter, ui.newTTFLabel({text="魔法", size=24, color={240, 196, 92}, font="f2", shadowColor={0, 0, 0}})), {0.00, 0.50}), {37, fixY(sz.height, 394)})
    local w = setPos(setAnchor(addChild(self.leftCenter, ui.newTTFLabel({text="弓兵", size=24, color={240, 196, 92}, font="f2", shadowColor={0, 0, 0}})), {0.00, 0.50}), {34, fixY(sz.height, 307)})
    local w = setPos(setAnchor(addChild(self.leftCenter, ui.newTTFLabel({text="步兵", size=24, color={240, 196, 92}, font="f2", shadowColor={0, 0, 0}})), {0.00, 0.50}), {36, fixY(sz.height, 351)})
    local w = setPos(setAnchor(addChild(self.leftCenter, ui.newTTFLabel({text="qibing2820", size=23, color={255, 241, 0}, font="f2", shadowColor={0, 0, 0}})), {0.00, 0.50}), {112, fixY(sz.height, 434)})
    self.qiw = w
    local w = setPos(setAnchor(addChild(self.leftCenter, ui.newTTFLabel({text="magic2820", size=23, color={255, 241, 0}, font="f2", shadowColor={0, 0, 0}})), {0.00, 0.50}), {112, fixY(sz.height, 393)})
    self.maw = w
    local w = setPos(setAnchor(addChild(self.leftCenter, ui.newTTFLabel({text="gong2820", size=23, color={255, 241, 0}, font="f2", shadowColor={0, 0, 0}})), {0.00, 0.50}), {112, fixY(sz.height, 350)})
    self.gongw = w
    local w = setPos(setAnchor(addChild(self.leftCenter, ui.newTTFLabel({text="bu2820", size=23, color={255, 241, 0}, font="f2", shadowColor={0, 0, 0}})), {0.00, 0.50}), {112, fixY(sz.height, 308)})
    self.buw = w
    local w = setPos(setAnchor(addChild(self.leftCenter, ui.newTTFLabel({text="喵喵喵喵喵喵喵", size=28, color={255, 255, 255}, font="f2", shadowColor={0, 0, 0}})), {0.00, 0.50}), {8, fixY(sz.height, 218)})

    setVisible(self.leftCenter, false)
    self.finAni = true
    local p = getPos(self.leftCenter)
    local sca = getScale(self.leftCenter)
    local sz = self.lm:getContentSize()
    setPos(self.leftCenter, {-sz.width, p[2]})
end
function FightMenu:onBut(p)
    if p == 0 then
        global.director:popScene()
    else
        if Logic.challengeCity ~= nil then
            addBanner("已经派出部队啦！")
        else
            if self.city ~= nil then
                global.director.curScene.page:sendCat(self.city)
                self:closeMenu()
            end
        end
    end
end
function FightMenu:showCityInfo(city)
    if self.city == nil and self.finAni and city.cityData ~= nil then
        self.city = city
        setVisible(self.leftCenter, true)
        local sca = getScale(self.leftCenter)
        local sz = self.lm:getContentSize()
        local p = getPos(self.leftCenter)
        setPos(self.leftCenter, {-sz.width, p[2]})
        self.leftCenter:runAction(expout(moveto(0.5, 0, p[2])))

        self.buw:setString(city.cityData[1])
        self.gongw:setString(city.cityData[2])
        self.maw:setString(city.cityData[3])
        self.qiw:setString(city.cityData[4])
    end
end
function FightMenu:closeMenu()
    if self.city ~= nil then
        self.city = nil
        local sca = getScale(self.leftCenter)
        local sz = self.lm:getContentSize()
        local p = getPos(self.leftCenter)
        self.finAni = false
        local function disa()
            self.finAni = true
            setVisible(self.leftCenter, false)
        end
        self.leftCenter:runAction(sequence({expout(moveto(0.5, -sz.width, p[2])), callfunc(nil, disa)}))
    end
end
