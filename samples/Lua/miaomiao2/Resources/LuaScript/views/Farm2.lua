Farm = class(FuncBuild)
function Farm:ctor(b)
    self.baseBuild = b
end
--登陆初始化
--建造完成 
--开始工作

--检测当前的工作时间
function Farm:initWorking(data)
    if data == nil then
        return
    end
    --设定工作时间 
    self.baseBuild:setState(getParam("buildWork"))

    local id = data["objectId"]
    local plant = getData(GOODS_KIND.PLANT, id)
    
    local startTime = data["objectTime"]
    startTime = server2Client(startTime) 
    
    local privateData = dict({{"objectTime", startTime}})
    self.planting = Plant.new(self.baseBuild, plant, privateData)
    self.baseBuild.bg:addChild(planting.bg)
end
