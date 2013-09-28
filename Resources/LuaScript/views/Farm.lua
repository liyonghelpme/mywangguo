require "views.PlantChoose"
Farm = class(FuncBuild)
function Farm:ctor(b)
    self.baseBuild = b
end
function Farm:whenFree()
    global.director:pushView(PlantChoose.new(self.baseBuild), 0, 0)
    return 1
end
function Farm:getObjectId()
    if self.planting ~= nil then
        return self.planting.id
    end
    return -1
end
function Farm:whenBusy()
    if self.planting.getState() >= MATURE then
        self:harvestPlant()
        self.flowBanner:removeFromParentAndCleanup(true)
        self.flowBanner = nil
        return 1
    end
    return 0
end
function Farm:setFlowBanner()
    if self.flowBanner == nil then
        local sz = self.baseBuild.bg:getContentSize() 
        self.flowBanner = setAnchor(setPos(addSprite(self.baseBuild.bg, "images/flowBanner.png"), {64, sz.height+11}), {0.5, 0})
        local pl = setPos(setAnchor(addSprite(self.flowBanner, 'images/Wplant'..self.planting.id..'.png'), {0.5, 0.5}), {33, 20})
        local sca = strictSca(pl, {52, 31})
        pl:setScale(sca)
        self.flowBanner:runAction(sequence({delaytime(math.random()*2), repeatForever(sequence({moveby(0.5, 0, -20), delaytime(0.3), moveby(0.5, 0, 20)}))}))
    end
end
function Farm:initWorking(data)
        if data == nil then
            return
        end
        if self.baseBuild.state ~= getParam("buildWork") then
            return
        end

        local id = data["objectId"]
        local plant = getData(GOODS_KIND.PLANT, id)
        
        local startTime = data["objectTime"]
        startTime = server2Client(startTime) 
        
        local privateData = dict({{"objectTime", startTime}})
        self.planting = Plant.new(self.baseBuild, plant, privateData)
        self.baseBuild.bg:addChild(planting.bg)
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
function Farm:doHarvest()
    self.baseBuild.state = getParam('buildFree')
    removeSelf(self.planting)
    local rate = getDefault(self.baseBuild.data, "rate", 1)
    local gain = getGain(GOODS_KIND.PLANT, self.planting.id)
    
    if self.planting:getState() == ROT  then
        gain = dict({{"exp", gain["exp"]}})
    end
    for k, v in pairs(gain) do
        v = v*rate
        gain[k] = v
    end

    global.director.curScene.bg:addChild(FlyObject.new(self.baseBuild.bg, gain, self.harvestOver, self).bg)
    planting = nil
    global.user:updateBuilding(self.baseBuild)
end
function Farm:harvestPlant()
    global.httpController:addRequest("harvestPlant", dict({{"uid", global.user.uid}, {"bid", self.baseBuild.bid}}), self.doHarvest, nil, self)
end
function Farm:harvestOver()
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


