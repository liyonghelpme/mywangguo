require "LuaScript.Dialog.ChatScrollView"
ChatDialog = class()

function ChatDialog:ctor(scene)
    self.scene = scene
    self:initView()
    registerEnterOrExit(self) 
    registerUpdate(self, 1)
    self:initMessages()
end

function ChatDialog:update(diff)
end
function ChatDialog:onEnter()
    Event:registerEvent(EVENT_TYPE.RECEIVE_MSG, self)
end
function ChatDialog:onExit()
    Event:unregisterEvent(EVENT_TYPE.RECEIVE_MSG, self)
end
function ChatDialog:receiveMsg(name, msg)
end
function ChatDialog:initMessages()
end

function ChatDialog:initView()

self.bg = CCLayer:create()
self.bg:setScale(800/1024)
self.bg:setAnchorPoint(ccp(0, 0))
local temp
local menu
local vs = CCDirector:sharedDirector():getVisibleSize()
temp = CCSprite:create("images/chatBack2.png")
temp:setPosition(ccp(414, 260))
self.bg:addChild(temp)
local listener = {}
                    function listener:onEditBoxBegan(object)
                    end
                    function listener:onEditBoxEnded(object)
                    end
                    function listener:onEditBoxReturn(object)
                    end
                    function listener:onEditBoxChanged(object)
                    end
                    
temp = ui.newEditBox({
                        image="images/inputBox.png",
                        imagePressed="images/inputBox.png",
                        imageDisabled="images/inputBox.png",
                        listener=listener, listenerType="table",
                        size=CCSizeMake(791, 40)
                    })
                    
temp:setPosition(ccp(418, 39))
temp:setFontSize(18)
temp:setFontColor(ccc3(61, 56, 50))
temp:setReturnType(kKeyboardReturnTypeDone)
temp:setTouchPriority(kCCMenuHandlerPriority)
self.bg:addChild(temp)
local inputBox = temp

temp = CCMenuItemImage:create("images/chatBut2.png", "images/chatBut2.png")
temp:setPosition(ccp(765, 39))
local chatBut = temp
local label = CCLabelTTF:create("发送", "", 21, CCSizeMake(0, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
label:setAnchorPoint(ccp(0.5, 0.5))
label:setPosition(ccp(52, 27))
temp:addChild(label)
local function onChatbut()
    ChatData:send(inputBox:getText())
    inputBox:setText("")
end
chatBut:registerScriptTapHandler(onChatbut)
temp = CCMenuItemImage:create("images/chatClose.png", "images/chatClose.png")
temp:setPosition(ccp(797, 485))
local chatClose = temp
local label = CCLabelTTF:create("", "", 18, CCSizeMake(0, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
label:setAnchorPoint(ccp(0.5, 0.5))
label:setPosition(ccp(20, 21))
temp:addChild(label)
local function onChatclose()
    self.bg:removeFromParentAndCleanup(true) 
end
chatClose:registerScriptTapHandler(onChatclose)
menu = CCMenu:create()
menu:setPosition(ccp(0, 0))
self.bg:addChild(menu)
menu:addChild(chatBut)
menu:addChild(chatClose)

self.chatScrollView = ChatScrollView.new()
self.bg:addChild(self.chatScrollView.bg)

end
