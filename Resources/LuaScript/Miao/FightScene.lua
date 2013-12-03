require "Miao.FightLayer"
require "Miao.FightMenu"
FightScene = class()
function FightScene:ctor()
    self.bg = CCScene:create()
    self.layer = FightLayer.new(self)
    self.bg:addChild(self.layer.bg)
    self.menu = FightMenu.new(self)
    self.bg:addChild(self.menu.bg)

    self.dialogController = DialogController.new(self)
    self.bg:addChild(self.dialogController.bg)
end
