require "Miao.FightLayer2"
require "Miao.FightMenu2"
FightScene = class()
function FightScene:ctor()
    self.soldiers = {{10, 10, 0, 0}, {10, 10, 0, 0}}
    self.maxSoldier = simple.decode(simple.encode(self.soldiers))

    self.bg = CCScene:create()
    self.layer = FightLayer2.new(self, self.soldiers[1], self.soldiers[2])
    self.bg:addChild(self.layer.bg)
    self.menu = FightMenu2.new(self)
    self.bg:addChild(self.menu.bg)

    self.dialogController = DialogController.new(self)
    self.bg:addChild(self.dialogController.bg)
end
