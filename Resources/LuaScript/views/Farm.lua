require "views.PlantChoose"
require "views.Plant"
require "views.FlyObject"
Farm = class(FuncBuild)
function Farm:ctor(b)
    self.baseBuild = b
    self.inHarvest = false
end
function Farm:whenFree()
    --global.director:pushView(PlantChoose.new(self.baseBuild), 0, 0)
    --return 1
    return 0
end
function Farm:getObjectId()
    if self.planting ~= nil then
        return self.planting.id
    end
    return -1
end
function Farm:whenBusy()
    print("whenBusy")
    --没有被收获
    if self.planting:getState() >= MATURE and self.flowBanner ~= nil then
        self:harvestPlant()
        self.flowBanner:removeFromParentAndCleanup(true)
        self.flowBanner = nil
        NewLogic.triggerEvent(NEW_STEP.TRAIN_SOL)
        return 1
    end
    return 0
end
function Farm:setFlowBanner()
    if self.flowBanner == nil then
        print("showFlowBanner", self.flowBanner)
        local sz = self.baseBuild.bg:getContentSize() 
        self.flowBanner = setAnchor(setPos(addSprite(self.baseBuild.bg, "flowBanner.png"), {0, sz.height+11}), {0.5, 0})
        local pl = setPos(setAnchor(addSprite(self.flowBanner, 'Wplant'..self.planting.id..'.png'), {0.5, 0.5}), {34, 30})
        local sca = strictSca(pl, {52, 38})
        pl:setScale(sca)
        self.flowBanner:runAction(repeatForever(sequence({spawn({moveby(0.5, 0, -20), scaleto(0.5, 0.8, 0.8)}), delaytime(0.1), spawn({moveby(0.5, 0, 20), scaleto(0.5, 1.2, 1.2)})})))
        self.flowBanner.pl = pl
    end
end
function Farm:initWorking(data)
    if data == nil then
        return
    end
    --设定工作时间 
    self.baseBuild:setState(getParam("buildWork"))

    local id = data["objectId"]
    local plant = getData(GOODS_KIND.PLANT, id)
    print("initWorking", id)
    
    local startTime = data["objectTime"]
    startTime = server2Client(startTime) 
    
    local privateData = dict({{"objectTime", startTime}, {"objectId", id}})
    self.planting = Plant.new(self.baseBuild, plant, privateData)
    self.baseBuild.bg:addChild(self.planting.bg)
end
function Farm:getAccCost()
    if self.planting ~= nil then
        return self.planting:getAccCost()
    end
    return 0
end
function Farm:beginPlant(id)
    self.baseBuild:setState(getParam("buildWork"))
    local plant = getData(GOODS_KIND.PLANT, id)
    self.planting = Plant.new(self.baseBuild, plant, nil)
    self.baseBuild.bg:addChild(self.planting.bg)
    global.user:updateBuilding(self.baseBuild)
end
--每小时 200  3600s  3600/200 = 18s  18s 收集到1点
function Farm:doHarvest()
    self.baseBuild.state = getParam('buildFree')
    removeSelf(self.planting.bg)
    local gain = self:calGain()
    
    global.user:doAdd(gain)
    global.director.curScene.bg:addChild(FlyObject.new(self.baseBuild.bg, gain, self.harvestOver, self).bg)
    print("FlyObject new")
    planting = nil
    global.user:updateBuilding(self.baseBuild)
    self.inHarvest = false
end

--经验和 银币数量一致即可
function Farm:calGain()
    local now = Timer.now
    local passTime = now-self.planting.objectTime
    passTime = math.min(3600, passTime)
    local gv = math.floor(passTime/3600*self.baseBuild.data.production)
    return {silver=gv, exp=gv}
end

function Farm:harvestPlant()
    local gain = self:calGain()
    if not self.inHarvest then
        self.inHarvest = true
        self.npid = math.random(20)-1
        global.httpController:addRequest("harvestPlant", dict({{"uid", global.user.uid}, {"bid", self.baseBuild.bid}, {'pid', self.npid}, {'gain', simple.encode(gain)}}), self.doHarvest, nil, self)
    end
end
function Farm:harvestOver()
    print("harvestOver")
    local data = {objectTime=client2Server(Timer.now), objectId=self.npid}
    self:initWorking(data)
end
function Farm:getLeftTime()
    if self.baseBuild.state == getParam("buildWork") and self.planting ~= nil then
        return self.planting:getLeftTime()
    end
    return 0
end
function Farm:getStartTime()
    if self.planting ~= nil then
        return self.planting:getStartTime()
    end
    return 0
end
function Farm:doAcc()
    local cost = dict({{"gold", self.planting:getAccCost()}})
    global.user:doCost(cost)
    global.httpController:addRequest("accPlant", dict({{"uid", global.user.uid}, {"bid", self.baseBuild.bid}, {"gold", self.planting:getAccCost()}}), nil, nil)
    planting:finish()
    global.user:updateBuilding(self.baseBuild)

    local showData = cost
    showMultiPopBanner(cost2Minus(showData))
end


