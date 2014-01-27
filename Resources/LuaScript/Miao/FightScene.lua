require "Miao.FightLayer2"
require "Miao.FightMenu2"
FightScene = class()
function FightScene:ctor()
    initCityData()
    --local testData = CityData[17]
    local ms = Logic.soldiers 
    --self.soldiers = {{ms[1][2], ms[2][2], ms[3][2], ms[4][2]}, copyTable(Logic.challengeNum)}
    --self.soldiers = {{testData[1], testData[2]-5, testData[3], testData[4]}, testData}
    --self.soldiers = {{10, 0, 0, 0}, {10, 0, 0, 0}}
    --找到一排的感觉
    --self.soldiers = {{25, 0, 0, 0}, {25, 0, 0, 0}}
    --self.soldiers = {{0, 5, 0, 0}, {0, 5, 0, 0}}
    --self.soldiers = {testData, testData}
    --self.soldiers = {{10, 40, 0, 0}, {15, 5, 0, 0}}
    --self.soldiers = {{50, 40, 0, 0}, {40, 50, 0, 0}}
    --self.soldiers = {{50, 40, 0, 0}, {40, 50, 0, 0}}
    --是因为左右使用了相同的数据修改的数组导致的问题
    --self.soldiers = {copyTable(testData), copyTable(testData)}
    
    --[[
    self.soldiers = {{5, 0, 0, 0}, {5, 0, 0, 0}}
    self.soldiers = {{25, 0, 0, 0}, {25, 0, 0, 0}}
    --self.soldiers = {{50, 0, 0, 0}, {50, 0, 0, 0}}
    self.soldiers = {{50, 0, 0, 0}, {25, 20, 0, 0}}
    self.soldiers = {{140, 0, 0, 0}, {50, 50, 0, 0}}
    self.soldiers = {copyTable(testData), copyTable(testData)}
    self.soldiers = {{15, 10, 0, 0}, {10, 18, 0, 0}}
    --]]

    self.soldiers = {{ms[1][2], ms[2][2], ms[3][2], ms[4][2]}, copyTable(Logic.challengeNum)}

    self.maxSoldier = simple.decode(simple.encode(self.soldiers))

    self.bg = CCScene:create()
    self.layer = FightLayer2.new(self, self.soldiers[1], self.soldiers[2])
    self.bg:addChild(self.layer.bg)
    self.menu = FightMenu2.new(self)
    self.bg:addChild(self.menu.bg)

    self.dialogController = DialogController.new(self)
    self.bg:addChild(self.dialogController.bg)
end
