require "views.RoleName"
require "views.CastlePage"
require "views.MenuLayer"
require "views.BuildMenu"
require "views.DialogController"

CastleScene = class()
--CastleScene 和loading 页面
function CastleScene:ctor()
    self.bg = CCScene:create()
    self.ml = MenuLayer.new(self)
    self.mc = CastlePage.new(self)
    self.bg:addChild(self.mc.bg)
    self.bg:addChild(self.ml.bg)
    self.dialogController = DialogController.new(self)
    self.bg:addChild(self.dialogController.bg)

    registerEnterOrExit(self)
end
--User 发出信号的时候 未进入场景
--因此在进入场景的时候 需要 手动检测是否已经INITDATA 了
function CastleScene:enterScene()
    if global.user.initYet and self.initYet == nil then
        --首先获取 User 初始化 接着 INITDATA
        --但是popScene 的时候不要再初始化了
        self.initYet = true
        print("enterScene receive")
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
        print("receiveMsg initDataOver !!!!!!!!!!!!!!!!!!")
        if global.user:getValue("name") == "" then
            self.dialogController:addCmd({cmd="roleName"})
        end
        self.mc:initDataOver()
        self.ml:initDataOver()
    end
end
function CastleScene:beginBuild(id)
    local building = getData(GOODS_KIND.BUILD, id)
    self.ml:hideMenu()
    self.curBuild = self.mc:beginBuild(building)
    self.inBuild = true
    global.director:pushView(BuildMenu.new(self, {PLAN_KIND.PLAN_BUILDING, self.curBuild}), 0, 0)
end
function CastleScene:finishBuild()
    local other = self.mc.buildLayer:checkCollision(self.curBuild)
    if other ~= nil then
        return
    end

    local p = getPos(self.curBuild.bg)
    local now = client2Server(Timer.now)
    global.httpController:addRequest("finishBuild", dict({{"uid", global.user.uid}, {"bid", self.curBuild.bid}, {"kind", self.curBuild.kind}, {"px", p[1]}, {"py", p[2]}, {"dir", self.curBuild.dir}, {"color", self.curBuild.buildColor}, {'objectTime', math.floor(client2Server(Timer.now))}}), nil, nil, self)
        
    --建筑物使用 kind 代替原来的 id 
    local id = self.curBuild.kind
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
    self.inBuild = false
    self.curBuild = nil
    self.ml:showMenu()
    global.director:popView()
end
function CastleScene:setBuilding(build)
    if self.inBuild == true then
        if build == self.curBuild  then
            return 1
        end
        return 0
    end
    print("setBuilding", build.bid)
    if self.curBuild ~= nil then
        print("curBuild", self.curBuild.bid)
        print("colNow", self.curBuild.colNow)
    end
    if self.curBuild == build then
        return 1
    end
    if self.curBuild ~= nil and self.curBuild.colNow == 1 then
        return 0
    end
    if self.curBuild ~= nil then
        self.curBuild:finishBottom()
    end
    self.curBuild = build
    self.planView:setBuilding({PLAN_KIND.PLAN_BUILDING, build})
    return 1
end


function CastleScene:showGlobalMenu(build, callback, delegate)
    --既没有菜单建筑 也没有 建造建筑
    print("showGlobalMenu", build, callback, delegate)
    if self.curMenuBuild == nil and self.curBuild == nil then
        self.curMenuBuild = build
        self.ml:hideMenu()
        self.mc:moveToBuild(build)
        callback(delegate)
    end
end


function CastleScene:closeGlobalMenu(build)
    if self.curMenuBuild ~= nil then
        self.curMenuBuild:closeGlobalMenu()
        global.director:popView()
        self.curMenuBuild = nil
        self.ml:showMenu()
        self.mc:closeGlobalMenu()
    end
    self.ml:cancelAllMenu()
end
function CastleScene:doPlan()
    self.ml:hideMenu()
    self.Planing = 1
    self.mc.buildLayer:keepPos()
    self.planView = BuildMenu.new(self, nil)
    global.director:pushView(self.planView, 0, 0)
end

function CastleScene:finishPlan()
    if self.curBuild ~= nil and self.curBuild.colNow == 1 then
        return
    end
    self.mc.buildLayer:finishPlan()
    self:closePlan()
end
function CastleScene:cancelPlan()
    self.mc.buildLayer:restorePos()
    self:closePlan()
end
function CastleScene:closePlan()
    self.Planing = 0
    self.ml:showMenu()
    global.director:popView()
    self.planView = nil
    self.curBuild = nil
end
--进入战斗场景
function CastleScene:beginSwitch()
    
end
