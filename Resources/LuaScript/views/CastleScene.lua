require "views.Hint"
require "views.NewDialog"
require "views.RoleName"
require "views.CastlePage"
require "views.MenuLayer"
require "views.BuildMenu"
require "views.DialogController"
require "views.UseGold"
require "views.SynGold"

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
    self.initScene = false
    print("init CastleScene", self.initScene)
    registerEnterOrExit(self)
end
--User 发出信号的时候 未进入场景
--因此在进入场景的时候 需要 手动检测是否已经INITDATA 了
function CastleScene:enterScene()
    if global.user.initYet and self.initScene == false then
        --首先获取 User 初始化 接着 INITDATA
        --但是popScene 的时候不要再初始化了
        print("enterScene receive", self.initScene)
        self.initScene = true
        self:receiveMsg(EVENT_TYPE.INITDATA)
    else
        Event:registerEvent(EVENT_TYPE.INITDATA, self)
    end
    print("sendCmd showAds")
    MyPlugins:getInstance():sendCmd("showAds", "");
end
function CastleScene:exitScene()
    self.initScene = true
    Event:unregisterEvent(EVENT_TYPE.INITDATA, self)
    print("sendCmd hideAds")
    MyPlugins:getInstance():sendCmd("hideAds", "");
end
function CastleScene:receiveMsg(name, msg)
    if name == EVENT_TYPE.INITDATA then
        print("receiveMsg initDataOver !!!!!!!!!!!!!!!!!!")

        local tempName = global.user:getValue("name")
        print("global user name ", tempName)
        if tempName == "" or tempName == 0 then
            self.dialogController:addCmd({cmd="roleName"})
        end

        if not CCUserDefault:sharedUserDefault():getBoolForKey("firstGame") then
            self.dialogController:addCmd({cmd="firstGame"})
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
--是否使用金币购买
function CastleScene:realFinishBuild(gold)
    local p = getPos(self.curBuild.bg)
    local now = client2Server(Timer.now)
    local id = self.curBuild.kind
    local cost = getCost(GOODS_KIND.BUILD, id)
    if gold then
        cost = calGold(cost)
        local buyable = global.user:checkCost(cost)
        if buyable.ok == 0 then
            --金币不足 不用购买了
            print("first cancel")
            self:cancelBuild()
            
            print("then push")
            addBanner(getStr("goldNot"))
            --金币数量为0 打开同步一下数据
            local gold = global.user:getValue('gold')
            if gold == 0 then
                global.director:pushView(SynGold.new(), 1, 0)
            end
            return
        else
            MyPlugins:getInstance():sendCmd("setUid", str(global.user.uid))
            MyPlugins:getInstance():sendCmd("spendGold", str(cost.gold))
        end
        print("use gold num", temp.gold)
    end

    global.httpController:addRequest("finishBuild", dict({{"uid", global.user.uid}, {"bid", self.curBuild.bid}, {"kind", self.curBuild.kind}, {"px", p[1]}, {"py", p[2]}, {"dir", self.curBuild.dir}, {"color", self.curBuild.buildColor}, {'objectTime', math.floor(client2Server(Timer.now))}, {'cost', simple.encode(cost)}}), nil, nil, self)
        
    --建筑物使用 kind 代替原来的 id 
    local gain = getGain(GOODS_KIND.BUILD, id)
    local showData = cost2Minus(cost)
    updateTable(showData, gain)
    showMultiPopBanner(showData)

    --应该在buyBuilding 消耗资源之后再finishBuild
    --可能消耗的是金币因此由这里计算花费
    global.user:buyBuilding(self.curBuild, cost)
    self.mc:finishBuild()
    self:closeBuild()

    NewLogic.triggerEvent(NEW_STEP.HARVEST)
end

function CastleScene:finishBuild()
    local other = self.mc.buildLayer:checkCollision(self.curBuild)
    if other ~= nil then
        return
    end
    local function useGoldFin(p)
        if p then
            self:realFinishBuild(true)
        else
            self:cancelBuild()
        end
    end
    local p = getPos(self.curBuild.bg)
    local now = client2Server(Timer.now)
    local id = self.curBuild.kind
    local cost = getCost(GOODS_KIND.BUILD, id)
    local buyable = global.user:checkCost(cost)
    if buyable.ok == 0 then
        local gold = calGold(cost)
        global.director:pushView(UseGold.new(useGoldFin, gold), 1, 0)
        return
    end
    self:realFinishBuild(false)
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
    print("showGlobalMenu", build, callback, delegate, self.curMenuBuild)
    if self.curMenuBuild == nil and self.curBuild == nil then
        self.curMenuBuild = build
        self.ml:hideMenu()
        --显示菜单不要缩放
        --self.mc:moveToBuild(build)
        callback(delegate)
    else
        self:closeGlobalMenu(self) 
    end
end


function CastleScene:closeGlobalMenu(build)
    print("closeGlobalMenu", build)
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
