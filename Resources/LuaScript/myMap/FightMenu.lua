require "menu.ConfigMenu"
require "menu.SessionMenu"
require "menu.ArmyMenu"
FightMenu = class()
function FightMenu:ctor()
    local vs = getVS()
    self.bg = CCNode:create()
    local sz = {width=1024, height=768}
    self.temp = setPos(addNode(self.bg), {0, fixY(sz.height, 0+sz.height)+0})
    self.rightBottom = addNode(self.temp)
    local but = ui.newButton({image="buta.png", text="返回", font="f2", size=30, delegate=self, callback=self.onBut, param=0, shadowColor={255, 255, 255}, color={206, 78, 0}})

    setScriptTouchPriority(but.bg, -256)
    but:setContentSize(107, 113)
    setPos(addChild(self.rightBottom, but.bg), {945, fixY(sz.height, 706)})
    rightBottomUI(self.rightBottom)


    self.leftCenter = setPos(addNode(self.bg), {0, fixY(sz.height, 0+sz.height)+0})

    local sp = setOpacity(setAnchor(setSize(setPos(addSprite(self.leftCenter, "mapInfoBoard.png"), {139, fixY(sz.height, 385)}), {278, 399}), {0.50, 0.50}), 255)
    self.lm = sp
    local but = ui.newButton({image="mainBa.png", text="进攻!", font="f2", size=24, delegate=self, callback=self.onBut, param=1, shadowColor={255, 255, 255}, color={252, 13, 1}})
    but:setContentSize(190, 68)
    setPos(addChild(self.leftCenter, but.bg), {128, fixY(sz.height, 512)})
    local w = setPos(setAnchor(addChild(self.leftCenter, ui.newTTFLabel({text="喵喵喵喵喵喵喵", size=28, color={255, 255, 255}, font="f2", shadowColor={0, 0, 0}})), {0.50, 0.50}), {121, fixY(sz.height, 219)})

    local w = setPos(setAnchor(addChild(self.leftCenter, ui.newTTFLabel({text="步兵:", size=24, color={240, 196, 92}, font="f2", shadowColor={0, 0, 0}})), {0.00, 0.50}), {12, fixY(sz.height, 287)})
    local w = setPos(setAnchor(addChild(self.leftCenter, ui.newTTFLabel({text="bu999", size=23, color={255, 241, 0}, font="f2", shadowColor={0, 0, 0}})), {0.00, 0.50}), {77, fixY(sz.height, 287)})
    self.buw = w
    local w = setPos(setAnchor(addChild(self.leftCenter, ui.newTTFLabel({text="弓箭:", size=24, color={240, 196, 92}, font="f2", shadowColor={0, 0, 0}})), {0.00, 0.50}), {133, fixY(sz.height, 286)})
    local w = setPos(setAnchor(addChild(self.leftCenter, ui.newTTFLabel({text="弓箭999", size=23, color={255, 241, 0}, font="f2", shadowColor={0, 0, 0}})), {0.00, 0.50}), {196, fixY(sz.height, 286)})
    self.gongw = w
    local w = setPos(setAnchor(addChild(self.leftCenter, ui.newTTFLabel({text="魔法:", size=24, color={240, 196, 92}, font="f2", shadowColor={0, 0, 0}})), {0.00, 0.50}), {11, fixY(sz.height, 319)})
    local w = setPos(setAnchor(addChild(self.leftCenter, ui.newTTFLabel({text="财宝:", size=24, color={240, 196, 92}, font="f2", shadowColor={0, 0, 0}})), {0.00, 0.50}), {11, fixY(sz.height, 365)})
    self.coldTime = w

    local w = setPos(setAnchor(addChild(self.leftCenter, ui.newTTFLabel({text="ma999", size=23, color={255, 241, 0}, font="f2", shadowColor={0, 0, 0}})), {0.00, 0.50}), {77, fixY(sz.height, 319)})
    self.maw = w
    local w = setPos(setAnchor(addChild(self.leftCenter, ui.newTTFLabel({text="土地产权证", size=23, color={255, 241, 0}, font="f2", shadowColor={0, 0, 0}})), {0.00, 0.50}), {66, fixY(sz.height, 403)})
    self.goods1 = w
    local w = setPos(setAnchor(addChild(self.leftCenter, ui.newTTFLabel({text="铠甲技术", size=23, color={255, 241, 0}, font="f2", shadowColor={0, 0, 0}})), {0.00, 0.50}), {66, fixY(sz.height, 447)})
    self.goods2 = w

    local w = setPos(setAnchor(addChild(self.leftCenter, ui.newTTFLabel({text="骑兵:", size=24, color={240, 196, 92}, font="f2", shadowColor={0, 0, 0}})), {0.00, 0.50}), {130, fixY(sz.height, 318)})
    local w = setPos(setAnchor(addChild(self.leftCenter, ui.newTTFLabel({text="qi2820", size=23, color={255, 241, 0}, font="f2", shadowColor={0, 0, 0}})), {0.00, 0.50}), {196, fixY(sz.height, 318)})
    self.qiw = w
    local sp = setOpacity(setAnchor(setSize(setPos(addSprite(self.leftCenter, "iconBack.png"), {34, fixY(sz.height, 405)}), {42, 36}), {0.50, 0.50}), 255)
    self.ib1 = sp
    self.g1 = setPos(addSprite(sp, "equip1.png"), {21, 18})
    local sp = setOpacity(setAnchor(setSize(setPos(addSprite(self.leftCenter, "iconBack.png"), {34, fixY(sz.height, 448)}), {42, 36}), {0.50, 0.50}), 255)
    self.ib2 = sp
    self.g2 = setPos(addSprite(sp, "equip2.png"), {21, 18})

    leftCenterUI(self.leftCenter)
    setVisible(self.leftCenter, false)
    self.finAni = true
    local p = getPos(self.leftCenter)
    local sca = getScale(self.leftCenter)
    local sz = self.lm:getContentSize()
    setPos(self.leftCenter, {-sz.width, p[2]})
end
function FightMenu:onBut(p)
    if p == 0 then
        if #global.director.stack == 0 then
            global.director:popScene()
        else
            global.director:popView()
        end
    --攻击按钮
    elseif p == 1 then
        if Logic.catData ~= nil then
            addBanner("已经派出部队啦！")
        else
            if self.city.kind == 0 then
                if self.arenaIncold then
                    addBanner("竞技场正在冷却")
                else
                    global.director:pushView(ConfigMenu.new(self.city), 1, 0)
                    self:closeMenu()
                end
            elseif self.city ~= nil then
                global.director:pushView(ConfigMenu.new(self.city), 1, 0)
                self:closeMenu()
            end
        end
    end
end

--显示竞技场数据
--竞技场的士兵数量 自己增长
function FightMenu:showArenaInfo(city)
    if self.city == nil and self.finAni then
        self.city = city
        setVisible(self.leftCenter, true)
        local sca = getScale(self.leftCenter)
        local sz = self.lm:getContentSize()
        local p = getPos(self.leftCenter)
        setPos(self.leftCenter, {-sz.width, p[2]})
        self.leftCenter:runAction(expout(moveto(0.5, 0, p[2])))

        local cityData = Logic.arena[math.min(#Logic.arena, Logic.arenaLevel)]
        self.buw:setString(cityData[1])
        self.gongw:setString(cityData[2])
        self.maw:setString(cityData[3])
        self.qiw:setString(cityData[4])
        --显示报酬多少
        
        local rew = Logic.arenaReward[Logic.arenaLevel]
        local gid = 1
        local t = Logic.date-Logic.lastArenaTime
        self.arenaIncold = false
        local leftTime = 50-t
        if t >= 50 then
            if rew ~= nil then
                local v = rew[2]
                if rew[1] == 'equip' then
                    local edata = Logic.equip[v]
                    self['goods'..gid]:setString(edata.name)
                    setDisplayFrame(self['g'..gid], 'equip'..edata.id..'.png')
                    setScale(self['g'..gid], 1)
                    gid = gid+1
                elseif rew[1] == 'goods' then
                    local edata = GoodsName[v]
                    self['goods'..gid]:setString(edata.name)
                    setDisplayFrame(self['g'..gid], 'storeGoods'..edata.id..'.png')
                    setScale(self['g'..gid], 1)
                    gid = gid+1
                elseif rew[1] == 'build' then
                    local edata = Logic.buildings[v]
                    self['goods'..gid]:setString(edata.name)
                    setTexOrDis(self['g'..gid], '#build'..edata.id..'.png')
                    local sca = getSca(self['g'..gid], {40, 40})
                    setScale(self['g'..gid], sca)
                    gid = gid+1
                elseif rew[1] == 'gold' then
                    self['goods'..gid]:setString(rew[3])
                    setTexOrDis(self['g'..gid], '#silverIcon.png')
                    local sca = getSca(self['g'..gid], {21, 18})
                    setScale(self['g'..gid], sca)
                    gid = gid+1
                end

            end
        else
            self.arenaIncold = true
            self.coldTime:setString("冷却时间:"..math.floor(leftTime).."s")
        end

        for i=1, gid-1, 1 do
            setVisible(self['goods'..i], true)
            setVisible(self['g'..i], true)
            setVisible(self['ib'..i], true)
        end
        print("gid is what", gid)
        for i=gid, 2, 1 do
            setVisible(self['goods'..i], false)
            setVisible(self['g'..i], false)
            setVisible(self['ib'..i], false)
        end
    end
end

--显示村落信息
--村落兵力不会增加
function FightMenu:showVillageInfo(city)
    if self.city == nil and self.finAni then
        self.city = city
        setVisible(self.leftCenter, true)
        local sca = getScale(self.leftCenter)
        local sz = self.lm:getContentSize()
        local p = getPos(self.leftCenter)
        setPos(self.leftCenter, {-sz.width, p[2]})
        self.leftCenter:runAction(expout(moveto(0.5, 0, p[2])))

        local ownNum = #Logic.ownVillage
        --每占领城堡对应兵力增加
        local bn = city.cityData[1]
        self.buw:setString(bn)
        local gn = city.cityData[2]
        self.gongw:setString(gn)
        local mn = city.cityData[3]
        self.maw:setString(mn)
        local qn = city.cityData[4]
        self.qiw:setString(qn)

        --奖励技术 奖励 装饰 奖励马匹
        local cg = Logic.villageGoods[city.realId]
        if cg ~= nil then
            cg = cg.goods
            print("village goods", simple.encode(cg))
            local gid = 1
            for k, v in ipairs(cg.equip) do
                if gid >= 3 then
                    break
                end
                local edata = Logic.equip[v]
                self['goods'..gid]:setString(edata.name)
                setDisplayFrame(self['g'..gid], 'equip'..edata.id..'.png')
                setScale(self['g'..gid], 1)
                gid = gid+1
            end
            print("gid", gid)
            for k, v in ipairs(cg.goods) do
                if gid >= 3 then
                    break
                end
                print("goods is what? 148")
                local edata = GoodsName[v]
                self['goods'..gid]:setString(edata.name)
                setDisplayFrame(self['g'..gid], 'storeGoods'..edata.id..'.png')
                setScale(self['g'..gid], 1)
                gid = gid+1
            end
            print("gid", gid)
            for k, v in ipairs(cg.build) do
                if gid >= 3 then
                    break
                end
                local edata = Logic.buildings[v]
                self['goods'..gid]:setString(edata.name)
                setTexOrDis(self['g'..gid], '#build'..edata.id..'.png')
                local sca = getSca(self['g'..gid], {40, 40})
                setScale(self['g'..gid], sca)
                gid = gid+1
                print("build set Scale is", sca)
            end
            for i=1, gid-1, 1 do
                setVisible(self['goods'..i], true)
                setVisible(self['g'..i], true)
                setVisible(self['ib'..i], true)
            end
            print("gid is what", gid)
            for i=gid, 2, 1 do
                setVisible(self['goods'..i], false)
                setVisible(self['g'..i], false)
                setVisible(self['ib'..i], false)
            end
        end

    end
end

--城堡的数量根据ownCity 来增长
--村落 和 城堡有什么关系呢？村落是基于事件而出现的 而城堡是本身就会出现的
--攻击下一个 城堡之后 对应的野外村落就会开启了
function FightMenu:showCityInfo(city)
    --无相关城堡数据
    print("city info", city, self.finAni, city.cityData)
    if self.city == nil and self.finAni and city.cityData ~= nil then
        self.city = city
        setVisible(self.leftCenter, true)
        local sca = getScale(self.leftCenter)
        local sz = self.lm:getContentSize()
        local p = getPos(self.leftCenter)
        setPos(self.leftCenter, {-sz.width, p[2]})
        self.leftCenter:runAction(expout(moveto(0.5, 0, p[2])))

        local ownNum = #Logic.ownCity
        --每占领城堡对应兵力增加
        local bn = math.floor(city.cityData[1]*math.pow(1.1, ownNum))
        self.buw:setString(bn)
        local gn = math.floor(city.cityData[2]*math.pow(1.1, ownNum))
        self.gongw:setString(gn)
        local mn = math.floor(city.cityData[3]*math.pow(1.1, ownNum))
        self.maw:setString(mn)
        local qn = math.floor(city.cityData[4]*math.pow(1.1, ownNum))
        self.qiw:setString(qn)
        
        --奖励技术 奖励 装饰 奖励马匹
        local cg = Logic.cityGoods[city.realId]
        if cg ~= nil then
            cg = cg.goods
            print("city goods", simple.encode(cg))
            local gid = 1
            for k, v in ipairs(cg.equip) do
                if gid >= 3 then
                    break
                end
                local edata = Logic.equip[v]
                self['goods'..gid]:setString(edata.name)
                setDisplayFrame(self['g'..gid], 'equip'..edata.id..'.png')
                setScale(self['g'..gid], 1)
                gid = gid+1
            end
            print("gid", gid)
            for k, v in ipairs(cg.goods) do
                if gid >= 3 then
                    break
                end
                print("goods is what? 148")
                local edata = GoodsName[v]
                self['goods'..gid]:setString(edata.name)
                setDisplayFrame(self['g'..gid], 'storeGoods'..edata.id..'.png')
                setScale(self['g'..gid], 1)
                gid = gid+1
            end
            print("gid", gid)
            for k, v in ipairs(cg.build) do
                if gid >= 3 then
                    break
                end
                local edata = Logic.buildings[v]
                self['goods'..gid]:setString(edata.name)
                setTexOrDis(self['g'..gid], '#build'..edata.id..'.png')
                local sca = getSca(self['g'..gid], {40, 40})
                setScale(self['g'..gid], sca)
                gid = gid+1
                print("build set Scale is", sca)
            end
            for i=1, gid-1, 1 do
                setVisible(self['goods'..i], true)
                setVisible(self['g'..i], true)
                setVisible(self['ib'..i], true)
            end
            print("gid is what", gid)
            for i=gid, 2, 1 do
                setVisible(self['goods'..i], false)
                setVisible(self['g'..i], false)
                setVisible(self['ib'..i], false)
            end
        end
        


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
