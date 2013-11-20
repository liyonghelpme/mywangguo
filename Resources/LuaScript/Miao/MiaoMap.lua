require "Miao.MiaoLayer"
require "Miao.BigMenu"
MiaoMap = class()
function MiaoMap:ctor()
    self.bg = CCScene:create()
    self.layer = MiaoLayer.new(self)
    self.bg:addChild(self.layer.bg)
    
    self.menu = BigMenu.new(self)
    self.bg:addChild(self.menu.bg)
end
