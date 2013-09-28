require "Mock.ChatDialog"
MainMap = class()
function MainMap:ctor()
    self.bg = CCLayer:create()
    local temp = addSprite(self.bg, "mapBack.png")
    ui.adjustMid(temp)
    
    self.chatDialog = ChatDialog.new()
    self.bg:addChild(self.chatDialog.bg)
end

