require "LuaScript.Dialog.ChatDialog2"
require "LuaScript.Dialog.HeroDialog"
MainScene = class()
function MainScene:ctor()
    self:initView()
    registerEnterOrExit(self)
    self:updateValue()
    self.showFunc = true
    self.showChat = false
end
function MainScene:onEnter()
    Event:registerEvent(EVENT_TYPE.INITDATA, self)
    Event:registerEvent(EVENT_TYPE.RECEIVE_MSG, self)
end
function MainScene:onExit()
    Event:unregisterEvent(EVENT_TYPE.INITDATA, self)
    Event.unregisterEvent(EVENT_TYPE.RECEIVE_MSG, self)
end
function MainScene:updateValue()
    self.lev:setString(""..User:getValue("level"))
    self.gem:setString(""..User:getValue("gem"))
    self.gold:setString(""..User:getValue("gold"))
    self.strength:setString(""..User:getValue("strength"))
end
function MainScene:updateWord()
    if #ChatData.messages > 0 then
        local v = ChatData.messages[#ChatData.messages]
        self.chatWord:setString(v[2].."说"..v[3]) 
    end
end
function MainScene:receiveMsg(name, msg)
    if name == EVENT_TYPE.INITDATA then
        self:updateValue()
        self:updateWord()
    elseif name == EVENT_TYPE.RECEIVE_MSG then
        self:updateWord()
    end
end

function MainScene:initView()

self.bg = CCLayer:create()
local temp
local menu
local vs = CCDirector:sharedDirector():getVisibleSize()

temp = CCMenuItemImage:create("images/chatBut.png", "images/chatBut.png")
temp:setPosition(ccp(40, 30))
local chat = temp



--正常menu的priority = 128
--新建的view 阻挡住下面的view
--按照view 的层次来做UI的点击时间
--加上一个全屏View 即可
local function onChat()
    local chatDialog = ChatDialog.new(self)
    self.bg:addChild(chatDialog.bg)
    --menu:setEnabled(false)
end
chat:registerScriptTapHandler(onChat)

temp = CCSprite:create("images/chatBack.png")
temp:setPosition(ccp(233, 42))
self.bg:addChild(temp)

temp = CCLabelTTF:create("", "", 21, CCSizeMake(363, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentBottom)
temp:setAnchorPoint(ccp(0, 0))
temp:setPosition(ccp(91, 12))
self.bg:addChild(temp)
self.chatWord = temp


local sci = Scissor:create()
local wid = 476-69+70
sci:setContentSize(CCSizeMake(wid, 800))
sci:setPosition(ccp(vs.width-476-35, 0))
self.bg:addChild(sci)

local rightMenu = CCMenu:create()
sci:addChild(rightMenu)
temp = CCMenuItemImage:create("images/block.png", "images/blockOn.png")
temp:setPosition(ccp(35, 49))
rightMenu:addChild(temp)
local hero = temp
local function onButton()
    local heroDialog = HeroDialog.new()
    self.bg:addChild(heroDialog.bg)
end
hero:registerScriptTapHandler(onButton)

temp = CCMenuItemImage:create("images/block.png", "images/blockOn.png")
temp:setPosition(ccp(35+76, 49))
rightMenu:addChild(temp)

temp = CCMenuItemImage:create("images/block.png", "images/blockOn.png")
temp:setPosition(ccp(35+76*2, 49))
rightMenu:addChild(temp)

temp = CCMenuItemImage:create("images/block.png", "images/blockOn.png")
temp:setPosition(ccp(35+76*3, 49))
rightMenu:addChild(temp)

temp = CCMenuItemImage:create("images/block.png", "images/blockOn.png")
temp:setPosition(ccp(35+76*4, 49))
rightMenu:addChild(temp)

temp = CCMenuItemImage:create("images/show.png", "images/showOn.png")
temp:setPosition(ccp(vs.width-69, 48))
self.show = temp

--禁止菜单的点击功能即可
local function onButton()
    local function onComplete()
        menu:setEnabled(true)
    end
    if self.showFunc then
        local arr = CCArray:create()
        arr:addObject(CCMoveTo:create(1.0, ccp(476-69, 0)))
        arr:addObject(CCCallFunc:create(onComplete))
        rightMenu:runAction(CCSequence:create(arr)
        )
        self.showFunc = false
        menu:setEnabled(false)
    else
        local arr = CCArray:create()
        arr:addObject(CCMoveTo:create(1.0, ccp(0, 0)))
        arr:addObject(CCCallFunc:create(onComplete))
        rightMenu:runAction(CCSequence:create(arr)
        )
        self.showFunc = true
        menu:setEnabled(false)
    end
end
temp:registerScriptTapHandler(onButton)
rightMenu:setPosition(ccp(0, 0))
--self.bg:addChild(rightMenu)

temp = CCLabelTTF:create("lev", "", 18)
temp:setAnchorPoint(ccp(0, 0))
temp:setPosition(ccp(vs.width-316, vs.height-42))
self.bg:addChild(temp)
self.lev = temp
temp = CCLabelTTF:create("gem", "", 18)
temp:setAnchorPoint(ccp(0, 0))
temp:setPosition(ccp(vs.width-230, vs.height-44))
self.bg:addChild(temp)
self.gem = temp
temp = CCLabelTTF:create("gold", "", 18)
temp:setAnchorPoint(ccp(0, 0))
temp:setPosition(ccp(vs.width-149, vs.height-44))
self.bg:addChild(temp)
self.gold = temp
temp = CCLabelTTF:create("strength", "", 18)
temp:setAnchorPoint(ccp(0, 0))
temp:setPosition(ccp(vs.width-68, vs.height-44))
self.bg:addChild(temp)
self.strength = temp


menu = CCMenu:create()
menu:setPosition(ccp(0, 0))
self.bg:addChild(menu)
menu:addChild(chat)
menu:addChild(self.show)
end

