MapCity = class()
function MapCity:ctor(s, data, cid)
    self.scene = s
    --0 竞技场
    self.kind = data[4] 
    --inkscape 中的id位置
    self.cid = cid
    self.data = data
    --gimp 中城堡的编号 用于获取城堡的 数据
    self.realId = data[5]
    print('city data', self.realId)
    if self.realId ~= nil then
        self.cityData = CityData[self.realId]
        print(simple.encode(self.cityData))
    end
    --col == 0 我的
    self.bg = CCNode:create()
    if self.kind == 0 then
        self.changeDirNode = CCSprite:create("fightPoint.png")
    elseif self.kind == 1 then 
        self.changeDirNode = CCSprite:create("castle.png")
    elseif self.kind == 2 then
        self.changeDirNode = CCSprite:create("village.png")
    --main city
    elseif self.kind == 3 then
        self.changeDirNode = CCSprite:create("village.png")
    end

    if Logic.ownCity[self.cid] then
        self:setColor(0)
    end
        
    addChild(self.bg, self.changeDirNode)
    --修正坐标 为正常的坐标
    local sz = getContentSize(self.scene.bg) 
    setPos(self.bg, {data[1], data[2]})

    print('myCity', simple.encode(data))
    local sz = {78, 51}
    self.touch = ui.newTouchLayer({size=sz, delegate=self, touchBegan=self.touchBegan, touchMoved=self.touchMoved, touchEnded=self.touchEnded})
    self.changeDirNode:addChild(self.touch.bg)

    self.stateLabel = ui.newBMFontLabel({text=self.cid, size=30, color={128, 0, 0}, font='bound.fnt'})
    setPos(addChild(self.bg, self.stateLabel), {0, 40})
end
function MapCity:setColor(c)
    self.color = c
    if self.color == 0 then
        setColor(self.changeDirNode, {0, 255, 0})
    end
end
function MapCity:touchBegan(x, y)
    print("touch City")
end
function MapCity:touchMoved(x, y)
end
function MapCity:touchEnded(x, y)
    --非主城
    if self.kind ~= 3 and self.color ~= 0 then
        global.director.curScene.menu:showCityInfo(self)
        --self.scene:sendCat(self)
    end
end
