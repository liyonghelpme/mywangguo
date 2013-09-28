require "views.CastlePage"

CastleScene = class()
--CastleScene 和loading 页面
function CastleScene:ctor()
    self.bg = CCScene:create()
    --self.ml = MenuLayer.new(self)
    self.mc = CastlePage.new(self)
    self.bg:addChild(self.mc.bg)
    --self.bg:addChild(self.ml.bg)

    registerEnterOrExit(self)
end
function CastleScene:enterScene()
    Event:registerEvent(EVENT_TYPE.INITDATA, self)
end
function CastleScene:exitScene()
    Event:unregisterEvent(EVENT_TYPE.INITDATA, self)
end
function CastleScene:receiveMsg(name, msg)
    if name == EVENT_TYPE.INITDATA then

    end
end

