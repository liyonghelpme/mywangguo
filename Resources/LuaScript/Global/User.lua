User = class()
function User:ctor()
    self.papayaName = "liyong"
    self.papayaId = "liyong"
    self.initYet = false
    self.rankOrder = 99
    self.lastColor = 0


    self.resource = {}
    --id ----> buildingData
    self.buildings = {
        [1]={id=0, px=1000, py=300, state=1, dir=0, objectId=0},
    }
    self.soldiers = {}
    self.drugs = {}
    self.equips = {}
    self.herbs = {}
    self.treasureStone = {}
    self.maxBid = 0
    self.starNum = {
        {3, 3, 3, 3, 3, 3, 3},
        {3, 3, 3, 3, 3, 3, 3},
        {3, 3, 3, 3, 3, 3, 3},
        {3, 3, 3, 3, 3, 3, 3},
        {3, 3, 3, 3, 3, 3, 3},
    }
end
function User:initDataOver(data, param)
    if data ~= nil then
        self.serverTime = 0
        self.clientTime = Timer.now

        self.uid = data.uid
        print("sendMsg")
        self.initYet = true
        Event:sendMsg(EVENT_TYPE.INITDATA)
    end
end
function User:initData()
   --Network.postData("login", self, self.initDataOver, {papayaId=self.papayaId, papayaName=self.papayaName})
   self:initDataOver({uid=1234})
end

function User:getNewBid()
    self.maxBid = self.maxBid+1
    return self.maxBid
end

function User:updateBuilding(build)
    if build.bid == -1 then
        return
    end
    --trace("updateBuilding", build, build.id, build.bid, build.getPos(), build.state, build.dir, build.getObjectId(), build.getStartTime());
    self.buildings[build.bid] = dict({{"id", build.id}, {"px", build:getPos()[1]}, {"py", build:getPos()[2]}, {"state", build.state}, {"dir", build.dir}, {"objectId", build:getObjectId()}, {"objectTime", build:getStartTime()}, {"level", build.buildLevel}, {"color", build.buildColor}, {"objectList", build.objectList}})
end
function User:getValue(key)
    return getDefault(self.resource, key, 0)
end
function User:changeValue(key, add)
    local v = getDefault(self.resource, key, 0)
    v = v+add
    if key == "exp" then
        local addV = add
        local level = self:getValue("level")
        local oldLevel = level
        while true do
            local needExp = getLevelUpNeedExp(level)
            if v >= needExp then
                v = v-needExp
                level = level+1
            else 
                break
            end
        end
        self:setValue("level", level)

        if level ~= oldLevel then
            global.msgCenter:sendMsg(EVENT_TYPE.LEVEL_UP)
            global.httpController:addRequest("levelUp", dict({{"uid", uid}, {"exp", v}, {"level", level}, {"rew", dict()}}), nil, nil)
            addV = 0
        end
    end

    self:setValue(key, v)
    if key == "exp" then
        global.msgCenter:sendMsg(EVENT_TYPE.UPDATE_EXP, addV)
    end
end

function User:doCost(cost)
    for k, v in pairs(cost) do
        self:changeValue(k, -v)
    end
end
function User:doAdd(gain)
    for k, v in pairs(gain) do
        self:changeValue(k, v)
    end
end
function User:getLastColor()
    self.lastColor = self.lastColor+ 1
    self.lastColor = self.lastColor % 3
    return self.lastColor
end

function User:buyBuilding(build)
    local cost = getCost(GOODS_KIND.BUILD, build.id);
    self:doCost(cost)
    local gain = getGain(GOODS_KIND.BUILD, build.id);
    self:doAdd(gain)
    self:updateBuilding(build)
end
function User:setValue(key, value)
    self.resource[key] = value
    Event:sendMsg(EVENT_TYPE.UPDATE_RESOURCE)
end
function User:checkCost(cost)
    local buyable = dict({{"ok", 1}})
    for k, v in pairs(cost) do
        local cur = self:getValue(k)
        if cur < v then
            buyable['ok'] = 0
            buyable[k] = v-cur
        end
    end
    return buyable
end
