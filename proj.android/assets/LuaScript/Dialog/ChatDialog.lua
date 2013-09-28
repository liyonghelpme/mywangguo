ChatDialog = class()
function ChatDialog:ctor()
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
--当前没有在touch 状态的下 可以调整高度
--否则等待释放touch的时候再调整高度 增加新的message
function ChatDialog:adjustPos()
    local px, py = self.labels:getPosition()
    --py = math.max(math.min(0, py), 319-self.labels.height)
    py = 319-self.labels.height
    self.labels:setPosition(ccp(px, py))
end
function ChatDialog:receiveMsg(name, msg)
    if name == EVENT_TYPE.RECEIVE_MSG then
        local ml = #self.allMessages --old length
        local nl = #ChatData.messages
        n = ml
        for i=ml+1, nl, 1 do
            local v = ChatData.messages[i]
            local label = ui.newTTFLabel({text=v[2].."说:"..v[3], valign=ui.TEXT_VALIGN_BOTTOM})
            label:setAnchorPoint(ccp(0, 0))
            table.insert(self.allMessages, label)
            self.labels:addChild(label)
            label:setPosition(ccp(10, 52*n+5))
            self.labels.height = self.labels.height+52
            n = n+1
        end
    end
    self:adjustPos()
end
--label 的内容 位置
function ChatDialog:initMessages()
    local n = 0
    self.labels.height = 0
    for k, v in ipairs(ChatData.messages) do
        local label = ui.newTTFLabel({text=v[2].."说:"..v[3], valign=ui.TEXT_VALIGN_BOTTOM}) 
        label:setAnchorPoint(ccp(0, 0))
        table.insert(self.allMessages, label)
        self.labels:addChild(label)
        label:setPosition(ccp(10, 52*n+5))
        self.labels.height = self.labels.height+52 
        n = n+1
    end
    self:adjustPos()
end
--增加一条新的message
function ChatDialog:addNewMessage(msg)
end

function ChatDialog:initView()
    self.bg = CCLayer:create()
    self.bg:addChild(FullScreen.new().bg)
    
local vs = CCDirector:sharedDirector():getVisibleSize()
temp = CCSprite:create("images/user.png")
temp:setPosition(ccp(-232+vs.width/2, 3+vs.height/2))
self.bg:addChild(temp)

--滚动内容条
--sci.height
temp = CCSprite:create("images/content.png")
temp:setPosition(ccp(122+vs.width/2, 22+vs.height/2))
self.bg:addChild(temp)

local sz = temp:getContentSize()
local sci = Scissor:create()
sci:setContentSize(CCSizeMake(357, 319))
sci:setPosition(ccp(122-sz.width/2+vs.width/2, 22-sz.height/2+vs.height/2))
self.bg:addChild(sci)
local labels = CCNode:create()
sci:addChild(labels)
self.labels = labels

local touchScroll = {}
touchScroll.content = self.labels
function touchScroll:onTouchBegan(x, y)
    self.lastPoint = {x, y}
    local sz = self.bg:getContentSize()
    local cp = self.bg:convertToNodeSpace(ccp(x, y))
    print("onTouchScroll", cp.x, cp.y, sz.width, sz.height)
    if cp.x > 0 and cp.x < sz.width and cp.y > 0 and cp.y < sz.height then
        return true
    end
    return false
end
function touchScroll:onTouchMoved(x, y)
    local dify = y-self.lastPoint[2]
    local px, py = self.content:getPosition()
    self.lastPoint = {x, y}
    print("touchScroll", x, y)
    self.content:setPosition(ccp(px, py+dify))
end
function touchScroll:onTouchEnded(x, y)
    local px, py = self.content:getPosition()
    py = math.max(math.min(0, py), 319-self.content.height)
    self.content:setPosition(ccp(px, py))
end

local touchLayer = CCLayer:create()
--touchLayer:setTouchEnabled(true)
touchLayer:setContentSize(CCSizeMake(357, 319))
touchLayer:setPosition(ccp(122-sz.width/2+vs.width/2, 22-sz.height/2+vs.height/2))
touchLayer:setAnchorPoint(ccp(0, 0))
touchScroll.bg = touchLayer
--touchLayer:setTouchPriority(-129)
registerTouch(touchScroll)


self.bg:addChild(touchScroll.bg)
print("addChild", touchScroll.bg)


self.allMessages = {}

temp = CCMenuItemImage:create("images/send.png", "images/sendOn.png")
temp:setPosition(ccp(269+vs.width/2, -183+vs.height/2))
local send = temp
local editBox
local function onButton()
    ChatData:send(editBox:getText())
    editBox:setText("")
end
send:registerScriptTapHandler(onButton)

--temp = CCSprite:create("images/word.png")
--temp:setPosition(ccp(71+vs.width/2, -180+vs.height/2))
--self.bg:addChild(temp)

local listener = {}
function listener:onEditBoxBegan(object)
    print("enter Edit")
end
function listener:onEditBoxEnded(object)
    print("end edit")
end
function listener:onEditBoxReturn(object)
    print("return edit")
end
function listener:onEditBoxChanged(object)
    print("change edit")
end

editBox = ui.newEditBox({
        image="images/word.png", 
        imagePressed="images/wordOn.png", 
        imageDisabled="images/wordDisable.png", 
        listener=listener, listenerType="table",
        size=CCSizeMake(285, 60)})
editBox:setPosition(ccp(71+vs.width/2, -180+vs.height/2))
editBox:setFontSize(18)
editBox:setFontColor(ccc3(255, 0, 0))
editBox:setPlaceHolder("Word")
editBox:setReturnType(kKeyboardReturnTypeDone)
self.bg:addChild(editBox)
editBox:setTouchPriority(kCCMenuHandlerPriority)


temp = CCMenuItemImage:create("images/close.png", "images/closeOn.png")
temp:setPosition(ccp(vs.width-52, vs.height-27))
local function onButton()
    self.bg:removeFromParentAndCleanup(true)
end
temp:registerScriptTapHandler(onButton)
local close = temp

local menu = CCMenu:create()
self.bg:addChild(menu)
menu:setPosition(ccp(0, 0))
menu:addChild(send)
menu:addChild(close)

end
