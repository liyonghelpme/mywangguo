MapCity = class()
function MapCity:ctor(s, data, cid, isV)
    self.scene = s
    --x y isCity kind
    --0 竞技场
    self.kind = data[4] 
    --inkscape 中的id位置
    self.cid = cid
    self.data = data
    self.isVillage = isV
    if isV then
        self.kind = 4
    end
    --gimp 中城堡的编号 用于获取城堡的 数据
    self.realId = data[5]
    print('city data', self.realId)
    if self.realId ~= nil then
        self.cityData = CityData[self.realId]
        print(simple.encode(self.cityData))
    end

    --村落士兵数量
    if self.kind ==  4 then
        --x y vid
        --self.realId = data[3]
        self.cityData = Logic.MapVillagePower[math.min(#Logic.MapVillagePower, self.realId)]
    end

    --col == 0 我的
    self.bg = CCNode:create()
    --竞技场
    if self.kind == 0 then
        self.changeDirNode = createSprite("fightPoint.png")
        --self.top = createSprite("castleTop.png")
    --城堡
    elseif self.kind == 1 then 
        self.changeDirNode = createSprite("castle.png")
        self.top = createSprite("castleTop.png")
    --废弃了
    elseif self.kind == 2 then
        self.changeDirNode = createSprite("village.png")
        self.top = createSprite("villageTop.png")
    --main city 主城
    elseif self.kind == 3 then
        self.changeDirNode = createSprite("village.png")
        self.top = createSprite("villageTop.png")
    --村落
    elseif self.kind == 4 then
        self.changeDirNode = createSprite("village.png")
        self.top = createSprite("villageTop.png")
    end
    
    addChild(self.bg, self.changeDirNode)
    if self.top ~= nil then
        addChild(self.bg, self.top)
        setVisible(self.top, false)
    end

    --占林城堡的编号
    print("city cid ownCity data", self.cid, simple.encode(Logic.ownCity))
    if Logic.ownCity[self.cid] then
        self:setColor(0)
    else
        self:setColor(1)
    end

    --占领村落使用 村落id 
    if self.kind == 4 then
        if Logic.ownVillage[self.realId] then
            self:setColor(0)
        else
            self:setColor(1)
        end
    end
    if self.kind == 3 then
        self:setColor(0)
    end
        

    --修正坐标 为正常的坐标
    --local sz = getContentSize(self.scene.bg) 
    setPos(self.bg, {data[1], data[2]})

    print('myCity', simple.encode(data))
    --local sz = getContentSize(self.changeDirNode)
    --self.touch = ui.newTouchLayer({size=sz, delegate=self, touchBegan=self.touchBegan, touchMoved=self.touchMoved, touchEnded=self.touchEnded})
    --self.changeDirNode:addChild(self.touch.bg)

    self.stateLabel = ui.newBMFontLabel({text=str(self.realId), size=30, color={128, 0, 0}, font='bound.fnt'})
    setPos(addChild(self.bg, self.stateLabel), {0, 40})
end

--castle 房顶正常是 红色的 表示未占领
--village的 房顶 正常是黄色的 表示已经占领了 颜色注意了
function MapCity:setColor(c)
    print("setColor", c)
    self.color = c
    if self.color == 0 then
        --setColor(self.changeDirNode, {0, 255, 0})
        if self.kind == 1 then
            setVisible(self.top, true)
        elseif self.kind == 3 or self.kind == 4 then
            setVisible(self.top, false)
        end
    else
        if self.kind == 3 or self.kind == 4 then
            setVisible(self.top, true)
        elseif self.kind == 1 then
            setVisible(self.top, false)
        end
    end
end

function MapCity:touchBegan(x, y)
    print("touch City")
end
function MapCity:touchMoved(x, y)
end
function MapCity:touchEnded(x, y)
    print("touch Castle Ended", self.kind, self.cid, self.realId, self.acc)
    --不可见
    if not self.acc then
        return
    end

    --非主城
    print("158 color", self.kind, self.color, self.cid, self.realId)
    if self.kind == 0 then
        global.director.curScene.menu:showArenaInfo(self)
    elseif self.kind == 4 and self.color ~= 0 then
        global.director.curScene.menu:showVillageInfo(self)
    elseif self.kind == 1 and self.color ~= 0 then
        global.director.curScene.menu:showCityInfo(self)
    elseif self.kind ~= 3 and self.color ~= 0 then
        global.director.curScene.menu:showCityInfo(self)
        --self.scene:sendCat(self)
    end
end

--因为邻居可能是路径点 或者 竞技场
function MapCity:checkAccess()
    if self.scene.accessCity[self.cid] then
        self.acc = true
        setVisible(self.bg, true)
        setVisible(self.lightNode, true)
        --显示自己的村落
        --村落没有独立的node 适合城堡相连的
        --if self.village == nil then
        --    self.village = MapCity.new(self.scene, )
        --end
        self.village = self.scene.allVillage[self.realId]
        --普通城堡16 有两个 village 相连接
        if self.realId == 16 then
            print("self realId", self.realId)
            self.village = {16, 25}
            print("allVillage", self.scene.allVillage[25])
            for k, v in ipairs(self.village) do
                if self.color == 0 then
                    setVisible(self.scene.allVillage[v].bg, true)
                    setVisible(self.scene.allVillage[v].lightNode, true)
                    self.village.acc = true
                else
                    setVisible(self.scene.allVillage[v].bg, false)
                    self.village.acc = false
                    setVisible(self.scene.allVillage[v].lightNode, false)
                end
            end
        elseif self.village ~= nil then
            if self.color == 0 then
                setVisible(self.village.bg, true)
                self.village.acc = true
                setVisible(self.village.lightNode, true)
            else
                setVisible(self.village.bg, false)
                self.village.acc = false
                setVisible(self.village.lightNode, false)
            end
        end

    else
        setVisible(self.bg, false)
        self.acc = false
        --是否驱散周围雾气
        setVisible(self.lightNode, false)
        
        self.village = self.scene.allVillage[self.realId]
        --16 有两个village
        if self.realId == 16 then
            print("self realId", 16)
            self.village = {16, 25}
            --print("allVillage", self.scene.allVillage[25])
            for k, v in ipairs(self.village) do
                setVisible(self.scene.allVillage[v].bg, false)
                setVisible(self.scene.allVillage[v].lightNode, false)
                self.village.acc = false
            end
        elseif self.village ~= nil then
            setVisible(self.village.bg, false)
            self.village.acc = false
            setVisible(self.village.lightNode, false)
        end
    end
end

function MapCity:showSword()
    print("showSword")
    local ofy = 60
    if self.kind == 4 then
        ofy = 30
    end
    local sword = setPos(createSprite("sword.png"), {25, ofy})
    sword:runAction(repeatForever(sequence({bounceout(rotateby(0.5, -45)), sinein(rotateby(0.5, 45))})))
    local s2 = setPos(createSprite("sword.png"), {-25, ofy})
    s2:runAction(repeatForever(sequence({bounceout(rotateby(0.5, 45)), sinein(rotateby(0.5, -45))})))
    self.bg:addChild(sword)
    self.bg:addChild(s2)

    self.sword =sword
    self.s2 = s2
end
function MapCity:removeSword()
    if self.sword ~= nil then
        removeSelf(self.sword)
        removeSelf(self.s2)
        self.sword = nil
    end
end
