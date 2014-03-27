Plant = class()
function Plant:ctor(b, d, privateData)
    if privateData ~= nil then
        self.objectTime = privateData['objectTime']
    else
        self.objectTime = Time.now 
    end
    
    self.building = b
    self.data = d
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
end

function Plant:update(diff)
    self.passTime = self.passTime+diff
    self:setState()
end
function Plant:setState()
    local needTime = self.data["time"]
    local newState = math.floor(self.passTime*3/needTime)
    newState = math.min(MATURE, math.max(SOW, newState))

    --[[
    if newState == MATURE and self.passTime >= 2*needTime and self.acced == 0 then
        newState = ROT 
    end
    --]]

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
end
function Plant:getLeftTime()
    return self.data['time']-self.passTime
end
function Plant:getStartTime()
    return client2Server(Timer.now-self.passTime)
end
function Plant:finish()
    self.acced = 1
    self.passTime = self.data["time"]
    self:setState()
end
function Plant:getAccCost()
    local leftTime = self:getLeftTime()
    return calAccCost(leftTime)
end
function Plant:getState()
    return self.curState
end



