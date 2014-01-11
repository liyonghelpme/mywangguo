require "Miao.FightLayer2"
require "Miao.FightMenu"
FightScene = class()
function FightScene:ctor()
    self.bg = CCScene:create()
    self.layer = FightLayer2.new(self, {1, 0, 0, 0}, {1, 0, 0, 0})
    self.bg:addChild(self.layer.bg)
    self.menu = FightMenu.new(self)
    self.bg:addChild(self.menu.bg)

    self.dialogController = DialogController.new(self)
    self.bg:addChild(self.dialogController.bg)
end
