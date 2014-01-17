--inkScape 导出的路径信息
require "mapData"
require "myMap.MapCity"
require "myMap.MapCat"
--gimp 导出的城堡位置
require "MapCoord"
--CityData 每个城堡的 士兵初始数据 
require 'cityData'

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
        MapDataInitYet = true
        local sz = getContentSize(self.bg)
        MapNode = tableToDict(MapNode)
        for k, v in pairs(MapNode) do
            print("MapNode is", k, v)
            v[2] = sz[2]-v[2] 
            --x y  city or path  kind(mainCity village fightPoint)
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
                --realId cityData 中使用的Id
                v[5] = minNode[3] 
            end
        end
        print("allNode")
        print(simple.encode(MapNode))
        MapEdge = tableToDict(MapEdge)
    end
    self.allCity = {}
    --根据城堡id 查找城堡对象
    self.cidToCity = {}
    for k, v in pairs(MapNode) do
        if v[3] == true then
            local ci = MapCity.new(self, v, k)
            self.bg:addChild(ci.bg)
            table.insert(self.allCity, ci)
            if ci.kind == 3 then
                self.mainCity = ci
            end
            self.cidToCity[ci.cid] = ci
        end
    end
    if Logic.catData ~= nil then
        self:sendCat(self.cidToCity[Logic.catData.cid])
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
    local cat = MapCat.new(self, self.mainCity, city, false)
    self.cat = cat
    self.bg:addChild(cat.bg)
end

function FightPage:touchesCanceled(touches)
    self.touchDelegate:tCanceled(touches)
end

function FightPage:touchesBegan(touches)
    self.touchDelegate:tBegan(touches)
    global.director.curScene.menu:closeMenu()
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
