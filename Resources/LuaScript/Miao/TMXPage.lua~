--require "Miao.TestBuild"
require "model.MapGridController"
require "Miao.MiaoPeople"
require "Miao.MiaoBuild"

TMXPage = class(MoveMap)
function TMXPage:ctor(s)
    self.scene = s
    self.bg = CCLayer:create()
    setContentSize(self.bg, {MapWidth, MapHeight})
    self.moveZone = {{0, 0, MapWidth, MapHeight}}
    self.buildZone = {{0, 0, MapWidth, MapHeight}}

    self.staticObstacle = {}
    self.gridLayer = CCLayer:create()
    self.bg:addChild(self.gridLayer)

    self.backpg = CCSpriteBatchNode:create("sea.png")
    self.bg:addChild(self.backpg)
    local col = math.ceil(MapWidth/64)
    local row = math.ceil(MapHeight/32)+1
    for i=0, row-1, 1 do
        local initx = 0
        if i%2 == 1 then
            initx = 64 
        end
        for j=0, col-1, 1 do
            local s = CCSprite:create("sea.png")
            self.backpg:addChild(s)
            setPos(s, {j*64+initx, i*32})
        end
    end
    

    self.tileMap = CCTMXTiledMap:create("nolayer.tmx")
    self.bg:addChild(self.tileMap)
    setPos(self.tileMap, {200, -100})


    self.touchDelegate = StandardTouchHandler.new()
    self.touchDelegate.bg = self.bg

    self.buildLayer = addCLayer(self.bg) 

    self.mapGridController = MapGridController.new(self)

    registerEnterOrExit(self)
    registerMultiTouch(self)

end

function TMXPage:initDataOver()
end
function TMXPage:touchesBegan(touches)
    self.touchBuild = nil
    self.lastPos = convertMultiToArr(touches)
    if self.lastPos.count == 1 then
        local tp = self.bg:convertToNodeSpace(ccp(self.lastPos[0][1], self.lastPos[0][2]))
        tp.y = tp.y-SIZEY
        local allCell = self.mapGridController.mapDict
        local map = getPosMapFloat(1, 1, tp.x, tp.y)
        local key = getMapKey(map[3], map[4])
        --点击到某个建筑物
        if allCell[key] ~= nil then
            self.touchBuild = allCell[key][#allCell[key]][1]
            self.touchBuild:touchesBegan(touches)
        end
    end
    if self.touchBuild == nil then
        self.touchDelegate:tBegan(touches)
    end
end
function TMXPage:touchesMoved(touches)
    if self.touchBuild then
        self.touchBuild:touchesMoved(touches)
    end
    if self.touchBuild == nil then
        self.touchDelegate:tMoved(touches)
    end
end
function TMXPage:touchesEnded(touches)
    if self.touchBuild then
        self.touchBuild:touchesEnded(touches)
    end
    if self.touchBuild == nil then
        self.touchDelegate:tEnded(touches)
    end
end

--[[
function TMXPage:addBuilding()
    local b = MiaoBuild.new(self, {picName='build', id=8})
    local vs = getVS()
    local p = self.bg:convertToNodeSpace(ccp(vs.width/2, vs.height/2))
    local p = normalizePos({p.x, p.y-SIZEY}, 1, 1)
    b:setPos(p)
    self.buildLayer:addChild(b.bg)
    self.mapGridController:updateMap(b)
end
--]]

function TMXPage:beginBuild(kind, id)
    if self.curBuild == nil then
        local vs = getVS()
        --先确定位置 再加入到 buildLayer里面
        self.curBuild = MiaoBuild.new(self, {picName=kind, id=id, bid=getBid()}) 
        local p = self.bg:convertToNodeSpace(ccp(vs.width/2, vs.height/2))
        p = normalizePos({p.x, p.y}, 1, 1)
        self.curBuild:setPos(p)
        self.curBuild:setColPos()
        self.curBuild:setState(BUILD_STATE.MOVE)
        self.buildLayer:addChild(self.curBuild.bg, MAX_BUILD_ZORD)
        --调整bottom 冲突状态
        self.mapGridController:updateMap(self.curBuild)
        
        Logic.paused = true
    end
    return self.curBuild
end

function TMXPage:finishBuild()
    if self.curBuild ~= nil then
        print("finishBuild", self.curBuild.picName, self.curBuild.id)
        if self.curBuild.picName == 'move' then
            if self.curBuild.moveTarget == nil then
                self.curBuild:removeSelf()
                self.curBuild = nil
            --取消移动
            else
                self.curBuild:removeSelf()
                self.curBuild = nil
            end
        --道路和 斜坡冲突 斜坡不能移动
        elseif self.curBuild.picName == 't' then
            if self.curBuild.colNow == 0 then
                self.curBuild:finishBuild()
                self.curBuild = nil
            else
                if type(self.curBuild.otherBuild) == 'table' then
                    local ob = self.curBuild.otherBuild
                    --斜坡
                    if ob.picName == 'build' and ob.data.kind == 1 then
                        self.curBuild:finishBuild()
                        self.curBuild = nil
                    else
                        addBanner("道路不能修建在这里！")
                    end
                end
            end
        --矿坑
        elseif self.curBuild.picName == 'build' and self.curBuild.id == 11 then
            if self.curBuild.colNow == 0 then
                addBanner("必须建造到斜坡上面！")
            else
                local ret = false
                if type(self.curBuild.otherBuild) == 'table' then
                    local ob = self.curBuild.otherBuild
                    if ob.picName == 'build' and ob.data.kind == 1 then
                        ret = true
                        self.curBuild:finishBuild()
                        self.curBuild = nil
                    end
                end
                if not ret then
                    addBanner("必须建造到斜坡上面！")
                end
            end
        elseif self.curBuild.picName == 'build' and self.curBuild.id == 3 then
            --桥梁没有冲突
            if self.curBuild.colNow == 0 then
                self.curBuild:finishBuild()
                self.curBuild = nil
            else
                if type(self.curBuild.otherBuild) == 'table' then
                    --地形河流
                    if self.curBuild.otherBuild.picName == 's' then
                        self.curBuild:finishBuild()
                        self.curBuild = nil
                    else
                        addBanner("和其它建筑物冲突啦！")
                    end
                end
            end
        elseif self.curBuild.picName == 'remove' then
            self.curBuild:removeSelf()
            self.curBuild = nil
        elseif self.curBuild.colNow == 0  then
            self.curBuild:finishBuild()
            self.curBuild = nil
        else
            addBanner("和其它建筑物冲突啦！")
        end
        Logic.paused = false
    end
end

function TMXPage:addPeople()
    local p = MiaoPeople.new(self, {id=3})
    self.buildLayer:addChild(p.bg, MAX_BUILD_ZORD)

    local vs = getVS()
    local pos = self.bg:convertToNodeSpace(ccp(vs.width/2, vs.height/2))
    pos = normalizePos({pos.x, pos.y}, 1, 1)
    setPos(p.bg, pos)
    p:setZord()
    self.mapGridController:addSoldier(p)
end

function TMXPage:setBuilding(b)
    print("setBuilding", self.curBuild, b)
    if b == self.curBuild then
        return 1
    end
    return 0
end
