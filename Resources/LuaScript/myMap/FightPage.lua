require "mapData"
require "myMap.MapCity"
require "myMap.MapCat"
FightPage = class()
function FightPage:ctor()
    self.bg = CCLayer:create()
    local sp = CCSprite:create("bigMap.png")
    setAnchor(sp, {0, 0})
    addChild(self.bg, sp)
    local sz = getContentSize(sp)
    setContentSize(self.bg, sz)
    setAnchor(self.bg, {0, 0})

    self.touchDelegate = StandardTouchHandler.new()
    self.touchDelegate:setBg(self.bg)

    self.needUpdate = true
    registerEnterOrExit(self)
    registerMultiTouch(self)
    self:initData()
end
function FightPage:initData()
    if not MapDataInitYet then
        MapNode = tableToDict(MapNode)
        MapEdge = tableToDict(MapEdge)
    end
    self.allCity = {}
    for k, v in pairs(MapNode) do
        if v[3] == true then
            local ci = MapCity.new(self, v, k)
            self.bg:addChild(ci.bg)
            table.insert(self.allCity, ci)
        end
    end
end
function FightPage:sendCat(city)
    local target
    for k, v in ipairs(self.allCity) do
        if v ~= city then
            target = v
            break
        end
    end
    local cat = MapCat.new(self, city, target)
    self.bg:addChild(cat.bg)
end

function FightPage:touchesCanceled(touches)
    self.touchDelegate:tCanceled(touches)
end

function FightPage:touchesBegan(touches)
    self.touchDelegate:tBegan(touches)
end
function FightPage:touchesMoved(touches)
    self.touchDelegate:tMoved(touches)
end

function FightPage:update(diff)
    self.touchDelegate:update(diff)
end

function FightPage:touchesEnded(touches)
    self.touchDelegate:tEnded(touches)
end
