MapCity = class()
function MapCity:ctor(s, data, cid)
    self.scene = s
    --0 竞技场
    self.kind = data[4] 
    self.cid = cid
    self.data = data
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
function MapCity:touchBegan(x, y)
    print("touch City")
end
function MapCity:touchMoved(x, y)
end
function MapCity:touchEnded(x, y)
    --非主城
    if self.kind ~= 3 then
        self.scene:sendCat(self)
    end
end
