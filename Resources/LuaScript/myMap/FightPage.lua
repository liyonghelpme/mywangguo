require "mapData"
require "myMap.MapCity"
require "myMap.MapCat"
require "MapCoord"
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

    self.debugNode = addNode(self.bg)

    self.needUpdate = true
    registerEnterOrExit(self)
    registerMultiTouch(self)
    self:initData()
end
function FightPage:initData()
    if not MapDataInitYet then
        local sz = getContentSize(self.bg)
        MapNode = tableToDict(MapNode)
        for k, v in pairs(MapNode) do
            v[2] = sz[2]-v[2] 
            if v[4] ~= nil then
                local md = 9999
                local minNode
                for ck, cv in ipairs(MapCoord) do
                    local dis = math.abs(v[1]-cv[1])+math.abs(v[2]-cv[2])
                    if dis < md then
                        md = dis
                        minNode = cv
                    end
                end
                v[1] = minNode[1]
                v[2] = minNode[2]
            end
        end
        print("allNode")
        print(simple.encode(MapNode))
        MapEdge = tableToDict(MapEdge)
    end
    self.allCity = {}
    for k, v in pairs(MapNode) do
        if v[3] == true then
            local ci = MapCity.new(self, v, k)
            self.bg:addChild(ci.bg)
            table.insert(self.allCity, ci)
            if ci.kind == 3 then
                self.mainCity = ci
            end
        end
    end
end
function FightPage:updateDebugNode(p)
    removeSelf(self.debugNode)
    self.debugNode = addNode(self.bg)
    for k, v in ipairs(p) do
        local n = ui.newBMFontLabel({text=v, size=18, color={128, 128, 128}, font='bound.fnt'})
        local xy = {MapNode[v][1], MapNode[v][2]}
        setPos(n, xy)
        addChild(self.debugNode, n)
    end
end
--从主城到其它城市
function FightPage:sendCat(city)
    local target
    --[[
    for k, v in ipairs(self.allCity) do
        if v ~= city then
            target = v
            break
        end
    end
    --]]
    local cat = MapCat.new(self, self.mainCity, city, false)
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
