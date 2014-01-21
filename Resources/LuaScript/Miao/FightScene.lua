require "Miao.FightLayer2"
require "Miao.FightMenu2"
FightScene = class()
function FightScene:ctor()
    initCityData()
    local testData = CityData[3]
    local ms = Logic.soldiers 
    --self.soldiers = {{ms[1][2], ms[2][2], ms[3][2], ms[4][2]}, copyTable(Logic.challengeNum)}
    self.soldiers = {{20, 0, 0, 0}, testData}

    self.maxSoldier = simple.decode(simple.encode(self.soldiers))

    self.bg = CCScene:create()
    self.layer = FightLayer2.new(self, self.soldiers[1], self.soldiers[2])
    self.bg:addChild(self.layer.bg)
    self.menu = FightMenu2.new(self)
    self.bg:addChild(self.menu.bg)

    self.dialogController = DialogController.new(self)
    self.bg:addChild(self.dialogController.bg)
end
