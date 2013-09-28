require "model.MapGridController"
require "views.Building"
BuildLayer = class(MoveMap)
function BuildLayer:ctor(scene)
    self.scene = scene
    self.bg = CCLayer:create()
    self.mapGridController = MapGridController.new(self)
    self.gridLayer = CCLayer:create()
    self.bg:addChild(self.gridLayer)
end

function BuildLayer:initBuilding()
    local item = global.user.buildings
    for k, v in pairs(item) do
        local bid = k
        local bdata = v
        local data = getData(GOODS_KIND.BUILD, bdata["id"]) 
        local build = Building.new(self, data, bdata)
        build:setBid(bid)

        self.bg:addChild(build.bg, MAX_BUILD_ZORD)
        build:setPos(normalizePos({bdata["px"], bdata["py"]}, data["sx"], data["sy"]))
        self.mapGridController:addBuilding(build)
    end
    --[[
    local temp = CCSprite:create("images/loadingCircle.png")
    temp:setPosition(ccp(992, 320))
    self.bg:addChild(temp)
    temp:setScale(0.2)
    --]]
end
function BuildLayer:initDataOver()
    self:initBuilding()
end

