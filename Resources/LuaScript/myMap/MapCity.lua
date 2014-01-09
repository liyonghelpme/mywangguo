MapCity = class()
function MapCity:ctor(s, data, cid)
    self.scene = s
    self.cid = cid
    self.data = data
    self.bg = CCNode:create()
    self.changeDirNode = CCSprite:create("myCity.png")
    addChild(self.bg, self.changeDirNode)
    local sz = getContentSize(self.scene.bg) 
    setScale(setPos(self.bg, {data[1], sz[2]-data[2]}), 0.5)

    print('myCity', simple.encode(data))
    local sz = {78, 51}
    self.touch = ui.newTouchLayer({size=sz, delegate=self, touchBegan=self.touchBegan, touchMoved=self.touchMoved, touchEnded=self.touchEnded})
    self.changeDirNode:addChild(self.touch.bg)
end
function MapCity:touchBegan(x, y)
    print("touch City")
end
function MapCity:touchMoved(x, y)
end
function MapCity:touchEnded(x, y)
    self.scene:sendCat(self)
end
