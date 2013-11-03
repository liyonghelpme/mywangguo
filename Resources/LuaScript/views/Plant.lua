Plant = class()
--self data 不起作用了
function Plant:ctor(b, d, privateData)
    if privateData ~= nil then
        self.objectTime = privateData['objectTime']
    else
        self.objectTime = Time.now 
    end
    
    self.building = b
    --self.data = d
    self.id = privateData.objectId
    print("Plant id is", self.id)
    local sx = self.building.data["sx"]
    local sy = self.building.data["sy"]
    
    local bSize = self.building.bg:getContentSize()
    self.bg = setPos(setAnchor(CCSprite:create("p0.png"), {0.5, 0}), {0, 0})
    self.curState = 0
    self.acced = 0

    registerEnterOrExit(self)
end
function Plant:enterScene()
    registerUpdate(self)
    local now = Timer.now
    self.passTime = now-self.objectTime
    Event:registerEvent(EVENT_TYPE.MATURE_FARM, self)
end
function Plant:receiveMsg(name, msg)
    if name == EVENT_TYPE.MATURE_FARM then
        local needTime = math.floor(3600/self.building.data.production)
        self.passTime = needTime
    end
end

function Plant:update(diff)
    self.passTime = self.passTime+diff
    self:setState()
end
function Plant:setState()
    local needTime = math.floor(3600/self.building.data.production)
    local newState = math.floor(self.passTime*3/needTime)
    newState = math.min(MATURE, math.max(SOW, newState))

    if newState ~= self.curState then
        self.curState = newState;
        if self.curState == SOW or self.curState == SEED or  self.curState == ROT then
            setTexture(self.bg, "p"..self.curState..".png")
        else
            setTexture(self.bg, "p"..self.id.."_"..self.curState..".png")
        end
        if self.curState == MATURE or self.curState == ROT then
            self.building.funcBuild:setFlowBanner()
        end
    end
end

function Plant:exitScene()
    Event:unregisterEvent(EVENT_TYPE.MATURE_FARM, self)
end
function Plant:getLeftTime()
    local needTime = math.floor(3600/self.building.data.production)
    return needTime-self.passTime
end
function Plant:getStartTime()
    return client2Server(Timer.now-self.passTime)
end
function Plant:finish()
    local needTime = math.floor(3600/self.building.data.production)
    self.acced = 1
    self.passTime = needTime 
    self:setState()
end
function Plant:getAccCost()
    local leftTime = self:getLeftTime()
    return calAccCost(leftTime)
end
function Plant:getState()
    return self.curState
end



