require "model.BusinessModel"
Mine = class(FuncBuild)
function Mine:ctor(b)
    self.baseBuild = b
    self.planting = nil
    self.flowBanner = nil
    self.par = nil
end
function Mine:getLeftTime()
    if self.planting ~= nil then
        return self.planting:getLeftTime()
    end
    return 0
end
function Mine:setFlowBanner()
    if self.flowBanner == nil then
        local sz = self.baseBuild.bg:getContentSize() 
        self.flowBanner = setAnchor(setPos(addSprite(self.baseBuild.bg, "flowBanner.png"), {0, sz.height+11}), {0.5, 0})
        local pl = setPos(setAnchor(addSprite(self.flowBanner, 'crystalBig.png'), {0.5, 0.5}), {34, 30})
        local sca = strictSca(pl, {63, 42})
        pl:setScale(sca)
        self.flowBanner:runAction(repeatForever(sequence({spawn({moveby(0.5, 0, -20), scaleto(0.5, 0.8, 0.8)}), delaytime(0.1), spawn({moveby(0.5, 0, 20), scaleto(0.5, 1.2, 1.2)})})))
        self.flowBanner.pl = pl
        --removeSelf(self.par)
    end
end
function Mine:whenFree()
    return 0
end
function Mine:calGain()
    local now = Timer.now
    local passTime = now - self.planting.objectTime 
    passTime = math.min(3600, passTime)
    local gv = math.floor(passTime/3600*self.baseBuild.data.production)
    return {crystal=gv, exp=gv}
end
function Mine:whenBusy()
    if self.planting.curState == 1 then
        self.baseBuild.state = getParam('buildFree')
        local gain = self:calGain()
        sendReq("harvestMine", dict({{"uid", global.user.uid}, {"bid", self.baseBuild.bid}, {"gain", simple.encode(gain)}}), nil, nil) 
        global.user:doAdd(gain)
        removeSelf(self.flowBanner)
        self.flowBanner = nil
        removeSelf(self.planting.bg)
        self.planting = nil
        addFly(self.baseBuild.bg, gain, self.harvestOver, self) 
        return 1
    end
    return 0
end
function Mine:harvestOver()
    local data = {objectTime=client2Server(Timer.now), objectId=0}
    self:initWorking(data)
end
function Mine:initWorking(data)
    if data == nil then
        return
    end
    self.baseBuild:setState(getParam("buildWork"))
    
    local startTime = data["objectTime"]
    startTime = server2Client(startTime) 
    print("startTime", startTime)
    
    local privateData = dict({{"objectTime", startTime}})
    self.planting = MinePlant.new(self.baseBuild, privateData)
    self.baseBuild.bg:addChild(self.planting.bg)
    if self.par == nil then
        self.par = addSprite(self.baseBuild.bg, "build300_l.png")
        self.par:setPosition(ccp(-40, 44))
        setColor(self.par, {238, 221, 130})
        self.par:runAction(repeatForever(sequence({fadein(0.3), fadeout(0.3)})))
    end
end

MinePlant = class()
function MinePlant:ctor(b, d)
    self.building = b
    self.objectTime = d["objectTime"]
    print("initial objectTime", self.objectTime)
    self.bg = CCNode:create()
    self.curState = 0
    self.needTime = math.floor(3600/self.building.data.production)
    registerEnterOrExit(self)
end
function MinePlant:getLeftTime()
    local leftTime = self.needTime-self.passTime
    return leftTime
end
function MinePlant:enterScene()
    local now = Timer.now
    print("now objectTime needTime", now, self.objectTime, self.needTime)
    if now - self.objectTime > self.needTime then
        self.passTime = self.needTime
    else
        self.passTime = now-self.objectTime
    end
    registerUpdate(self)
end
function MinePlant:update(diff)
    self.passTime = self.passTime+diff
    if self.passTime >= self.needTime and self.curState == 0 then
        self.curState = 1
        self.building.funcBuild:setFlowBanner()
    end
end
function MinePlant:exitScene()

end




