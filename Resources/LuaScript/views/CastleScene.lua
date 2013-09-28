require "views.CastlePage"
require "views.MenuLayer"
require "views.BuildMenu"

CastleScene = class()
--CastleScene 和loading 页面
function CastleScene:ctor()
    self.bg = CCScene:create()
    self.ml = MenuLayer.new(self)
    self.mc = CastlePage.new(self)
    self.bg:addChild(self.mc.bg)
    self.bg:addChild(self.ml.bg)

    registerEnterOrExit(self)
end
--User 发出信号的时候 未进入场景
--因此在进入场景的时候 需要 手动检测是否已经INITDATA 了
function CastleScene:enterScene()
    if global.user.initYet then
        self:receiveMsg(EVENT_TYPE.INITDATA)
    else
        Event:registerEvent(EVENT_TYPE.INITDATA, self)
    end
end
function CastleScene:exitScene()
    Event:unregisterEvent(EVENT_TYPE.INITDATA, self)
end
function CastleScene:receiveMsg(name, msg)
    if name == EVENT_TYPE.INITDATA then
        self.mc:initDataOver()
    end
end
function CastleScene:beginBuild(id)
    local building = getData(GOODS_KIND.BUILD, id)
    self.ml:hideMenu()
    self.curBuild = self.mc:beginBuild(building)
    global.director:pushView(BuildMenu.new(self, {PLAN_KIND.PLAN_BUILDING, self.curBuild}), 0, 0)
end
function CastleScene:finishBuild()
    local other = self.mc.buildLayer:checkCollision(self.curBuild)
    if other ~= nil then
        return
    end

    local p = getPos(self.curBuild.bg)

    global.httpController:addRequest("buildingC/finishBuild", dict({{"uid", global.user.uid}, {"bid", self.curBuild.bid}, {"kind", self.curBuild.id}, {"px", p[1]}, {"py", p[2]}, {"dir", self.curBuild.dir}, {"color", self.curBuild.buildColor}}), nil, nil, self)
    
    local id = self.curBuild.id
    local cost = getCost(GOODS_KIND.BUILD, id)
    local gain = getGain(GOODS_KIND.BUILD, id)
    local showData = cost2Minus(cost)
    updateTable(showData, gain)
    showMultiPopBanner(showData)

    self.mc:finishBuild()
    global.user:buyBuilding(self.curBuild)
    self:closeBuild()
end
function CastleScene:cancelBuild()
    self.mc:cancelBuild()
    self:closeBuild()
end
 
function CastleScene:closeBuild()
    self.curBuild = nil
    self.ml:showMenu()
    global.director:popView()
end
function CastleScene:setBuilding(build)
    if self.curBuild ~= nil and self.curBuild.colNow == 1 then
        return 0
    end
    if self.curBuild ~= nil then
        self.curBuild:finishBottom()
    end
    self.curBuild = build
    self.planView:setBuilding(p)
    return 1
end
