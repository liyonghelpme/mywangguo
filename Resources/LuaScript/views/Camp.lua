require "views.SoldierStore"

CampWorkNode = class()
function CampWorkNode:ctor(f)
    self.func = f
    self.bg = CCNode:create()
    self.passTime = 0
    registerUpdate(self)
    registerEnterOrExit(self)
end
function CampWorkNode:update(diff)
    local solId 
    local sid
    local newName
    self.passTime = self.passTime+diff
    --判断第一个士兵的 生产时间
    if #self.func.baseBuild.objectList > 0 and self.passTime > 1 then
        self.passTime = 0
        local leftTime = self.func:getRealLeftTime() 
        local needTime = leftTime[2]
        leftTime = leftTime[1]
        local objectList = self.func.baseBuild.objectList
        --收获该士兵 
        --建筑更新 objectList objectTime
        --用户更新 新的士兵
        --print("leftTime", leftTime, needTime)
        if leftTime <= 0 then
            solId = objectList[1]
            table.remove(objectList, 1)
            self.func.objectTime = self.func.objectTime+needTime
            sendReq("harvestSoldier", dict({{"uid", global.user.uid}, {"bid", self.func.baseBuild.bid}, {"kind", solId}, {"time", client2Server(self.func.objectTime)}}))
            global.user:addSoldier(solId)
            global.user:updateBuilding(self.func.baseBuild)
            Event:sendMsg(EVENT_TYPE.HARVEST_SOLDIER, {self.func.baseBuild.bid, solId})
        end
    end
end



Camp = class(FuncBuild)
function Camp:ctor(b)
    self.baseBuild = b
    self.workNode = CampWorkNode.new(self)
    self.baseBuild.bg:addChild(self.workNode.bg)
end
--弹出兵营对话框
function Camp:whenFree()
    global.director:pushView(SoldierStore.new(self.baseBuild), 1, 0)
    return 1
end
function Camp:whenBusy()
    global.director:pushView(SoldierStore.new(self.baseBuild), 1, 0)
    return 1
end
--生产新的士兵的时候 更新当前的工作时间
function Camp:initWorking(data)
    if data == nil then
        return
    end
    self.baseBuild:setState(getParam("buildWork"))
    self.objectId = 0
    self.objectTime = server2Client(data.objectTime)
    print("initWorking", self.objectTime, data.objectTime, global.user.serverTime, global.user.clientTime)
end
function Camp:getRealLeftTime()
    if #self.baseBuild.objectList > 0 then
        --存放[id]
        --objectTime 是兵营总的开始时间 objectTime 每次收获一个都要调整
        local sol = self.baseBuild.objectList[1]
        local needTime = getData(GOODS_KIND.SOLDIER, sol).time
        local now = Timer.now
        local passTime = now - self.objectTime 

        --print("realLeftTime", self.objectTime, passTime, needTime, now)
        return {math.max(needTime-passTime, 0), needTime}
    end
    return {0, 0}
end


