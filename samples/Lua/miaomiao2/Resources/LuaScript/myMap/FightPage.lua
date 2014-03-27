--inkScape 导出的路径信息
require "mapData"
require "myMap.MapCity"
require "myMap.MapCat"
--gimp 导出的城堡位置
require "MapCoord"
--CityData 每个城堡的 士兵初始数据 
require 'cityData'
require "myMap.PagePath"

FightPage = class()
function FightPage:ctor()
    self.bg = CCLayer:create()
    --local sp = CCSprite:create("bigMap.png")
    local sp1 = CCSprite:create("bigMap1.png")
    setPos(setAnchor(sp1, {0, 0}), {0, 256})
    addChild(self.bg, sp1)
    local sp2 = CCSprite:create("bigMap2.png")
    setPos(setAnchor(sp2, {0, 0}), {2048, 256})
    addChild(self.bg, sp2)
    local sp3 = CCSprite:create("bigMap3.png")
    setPos(setAnchor(sp3, {0, 0}), {0, 0})
    addChild(self.bg, sp3)
    local sp4 = CCSprite:create("bigMap4.png")
    setPos(setAnchor(sp4, {0, 0}), {2048, 0})
    addChild(self.bg, sp4)

    --setAnchor(sp, {0, 0})
    --addChild(self.bg, sp)
    --local sz = getContentSize(sp)
    local sz = {3072, 2304}
    setContentSize(self.bg, sz)
    setAnchor(self.bg, {0, 0})

    self.touchDelegate = StandardTouchHandler.new()
    self.touchDelegate:setBg(self.bg)

    self.debugNode = addNode(self.bg)
    
    local vs = getVS()
    setPos(self.bg, {-1058+vs.width/2, -(2304-1086)+vs.height/2})

    self.needUpdate = true
    registerEnterOrExit(self)
    registerMultiTouch(self)
    self:initData()
end
function FightPage:initData()
    initCityData()
    --不联通的城市 不显示但是存在的
    self.allCity = {}
    --根据城堡id 查找城堡对象
    self.cidToCity = {}
    for k, v in pairs(MapNode) do
        --城堡 主城 竞技场 村落 初始化
        --kind == 4 是村落 村落不在这里初始化
        if v[3] == true and v[4] ~= 4 then
            print("v data", v[4])
            local ci = MapCity.new(self, v, k)
            self.bg:addChild(ci.bg)
            table.insert(self.allCity, ci)
            if ci.kind == 3 then
                self.mainCity = ci
            end
            self.cidToCity[ci.cid] = ci
        end
    end

    --初始化村落
    --vid to village
    self.allVillage = {}
    --cid 是 MapNode 中的编号 mapData 里面有
    for k, v in pairs(MapNode) do
        if v[3] == true and v[4] == 4 then
            print("addVillage", v[5])
            local vil = MapCity.new(self, v, k, true)
            self.bg:addChild(vil.bg)
            --realId
            self.allVillage[vil.realId] = vil
            self.cidToCity[vil.cid] = vil
        end
    end


    if Logic.catData ~= nil then
        local path = Logic.catData.path
        --传入城堡基本信息
        --或者新手村落
        self:sendCat(self.cidToCity[path[#path]])
    end
    self:checkConnection()
end

--确定可达的 城市
--不可达的城市隐藏即可
--Logic 里面可以缓存 可以到达的城市
--也可以每个城市检测是否和 已经own的城市相邻或者 相邻主城市 或者相邻竞技场
function FightPage:checkConnection()
    self.pagePath = PagePath.new(self)
    self.pagePath:init(self.mainCity.cid, nil)
    self.pagePath:update()
    self.accessCity = self.pagePath.accessCity 

    for k, v in ipairs(self.allCity) do
        v:checkAccess()
    end
end
function FightPage:showNewCity()
    self.pagePath:init(self.mainCity.cid, nil)
    self.pagePath:update()
    self.accessCity = self.pagePath.accessCity
    for k, v in ipairs(self.allCity) do
        v:checkAccess()
    end
end


function FightPage:updateDebugNode(p)
    if not DEBUG_FIGHT then
        return
    end
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

function FightPage:sendCatToVillage(city)
    local cat = MapCat.new(self, self.mainCity, city, false, true)
    self.cat = cat
    self.bg:addChild(cat.bg)
end

function FightPage:touchesCanceled(touches)
    self.touchDelegate:tCanceled(touches)
end

function FightPage:touchesBegan(touches)
    self.touchDelegate:tBegan(touches)
    --点到建筑物上面还关闭对话框么
    global.director.curScene.menu:closeMenu()
    self.touchBuild = nil
    if self.touchDelegate.touchValue.count == 1 and self.touchDelegate.touchValue[0] ~= nil then
        local tp = ccp(self.touchDelegate.touchValue[0][1], self.touchDelegate.touchValue[0][2])
        for k, v in ipairs(self.allCity) do
            local sz = v.changeDirNode:getContentSize()
            local tn = v.changeDirNode:convertToNodeSpace(tp) 
            if tn.x > 0 and tn.x < sz.width and tn.y > 0 and tn.y < sz.height then
                print("touch In Castle", v.cid)
                self.touchBuild = v
                break
            end
        end
        if self.touchBuild == nil then
            print("test allVillage", #self.allVillage)
            for k, v in pairs(self.allVillage) do
                local sz = v.changeDirNode:getContentSize()
                local tn = v.changeDirNode:convertToNodeSpace(tp) 
                if tn.x > 0 and tn.x < sz.width and tn.y > 0 and tn.y < sz.height then
                    print("touch In Castle", v.cid, v.realId)
                    self.touchBuild = v
                    break
                end
            end
        end

        if self.touchBuild ~= nil then
            self.touchBuild:touchBegan(touchBegan)
        end
    end
end
function FightPage:touchesMoved(touches)
    self.touchDelegate:tMoved(touches)
end

function FightPage:update(diff)
    self.touchDelegate:update(diff)
end

function FightPage:touchesEnded(touches)
    self.touchDelegate:tEnded(touches)
    if self.touchDelegate.accMove < 20 then
        if self.touchBuild ~= nil then
            self.touchBuild:touchEnded()
        end
    end
end
