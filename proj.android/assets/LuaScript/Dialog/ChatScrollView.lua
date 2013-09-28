ChatScrollView = class()
--sci 剪切区域
--touchLayer touch 区域
--contentLayer 内容区域 高度
--touch区域 调整 content区域
--文字 切分 时间 频道 名字 内容 
function ChatScrollView:ctor()
    self.allMessages = {}
    self:initView()
    self:initMessages()
    registerTouch(self)
    registerUpdate(self)
    registerEnterOrExit(self) 
end
function ChatScrollView:update(diff)
end

function ChatScrollView:onEnter()
    Event:registerEvent(EVENT_TYPE.RECEIVE_MSG, self)
end
function ChatScrollView:onExit()
    Event:unregisterEvent(EVENT_TYPE.RECEIVE_MSG, self)
end

function ChatScrollView:receiveMsg(name, msg)
    if name == EVENT_TYPE.RECEIVE_MSG then
        local ml = #self.allMessages --old length
        local nl = #ChatData.messages
        for i=ml+1, nl, 1 do
            local v = ChatData.messages[i]
            local word = self:createOneWord(v)
            local wordSz = word:getContentSize()
            
            table.insert(self.allMessages, word)
            word:setPosition(ccp(20, -self.content.height))
            self.content.height = self.content.height+wordSz.height
            self.content:addChild(word)
        end

        self:adjustPos()
    end
end

function ChatScrollView:adjustPos()
    local px, py = self.content:getPosition()
    --py = math.max(math.min(0, py), 319-self.labels.height)
    --py = self.height-self.content.height
    py = self.content.height
    self.content:setPosition(ccp(px, py))
end
function ChatScrollView:createOneWord(v)
    local word = CCNode:create()

    local name = ui.newTTFLabel({text=v[2]..":", align=ui.TEXT_ALIGN_LEFT, valign=ui.TEXT_VALIGN_BOTTOM, color=ccc3(0, 137, 194), size=24})
    local nameSz = name:getContentSize()
    local contentWidth = self.width-nameSz.width
    local content = ui.newTTFLabel({text=v[3], align=ui.TEXT_ALIGN_LEFT, valign=ui.TEXT_VALIGN_BOTTOM, dimensions=CCSizeMake(contentWidth, 0), color=ccc3(213, 212, 197), size=24})
    local csz = content:getContentSize()

    word:setContentSize(CCSizeMake(self.width, csz.height))
    word:addChild(name)
    name:setPosition(ccp(0, csz.height-nameSz.height))
    name:setContentSize(CCSizeMake(0, 0))

    word:addChild(content)
    content:setPosition(ccp(nameSz.width, 0))
    content:setAnchorPoint(ccp(0, 0))

    return word
end
function ChatScrollView:initMessages()
    self.content.height = 0
    for k, v in ipairs(ChatData.messages) do
        local word = self:createOneWord(v)
        local wordSz = word:getContentSize()
        --[[
        local word = CCNode:create()

        local name = ui.newTTFLabel({text=v[2]..":", align=ui.TEXT_ALIGN_LEFT, valign=ui.TEXT_VALIGN_BOTTOM, color=ccc3(0, 137, 194), size=24})
        local nameSz = name:getContentSize()
        local contentWidth = self.width-nameSz.width
        local content = ui.newTTFLabel({text=v[3], align=ui.TEXT_ALIGN_LEFT, valign=ui.TEXT_VALIGN_BOTTOM, dimensions=CCSizeMake(contentWidth, 0), color=ccc3(213, 212, 197), size=24})
        local csz = content:getContentSize()

        word:setContentSize(CCSizeMake(self.width, csz.height))
        word:addChild(name)
        name:setPosition(ccp(0, csz.height-nameSz.height))
        name:setContentSize(CCSizeMake(0, 0))

        word:addChild(content)
        content:setPosition(ccp(nameSz.width, 0))
        content:setAnchorPoint(ccp(0, 0))
        --]]

        table.insert(self.allMessages, word)
        word:setPosition(ccp(20, -self.content.height))
        self.content.height = self.content.height+wordSz.height
        self.content:addChild(word)

    end
    self:adjustPos()
end

--因为对话框在800*480 上面缩放了一下
function ChatScrollView:initView()
    self.bg = CCLayer:create()
    local sci = Scissor:create()
    local vs = CCDirector:sharedDirector():getVisibleSize()
    self.width = 808
    self.height = 388
    --[[
    local fullScreen = FullScreen.new()
    fullScreen.bg:setScaleX(808*800/1024/vs.width)
    fullScreen.bg:setScaleY(528*800/1024/vs.height)

    self.bg:addChild(fullScreen.bg)
    --]]

    self.bg:addChild(sci)
    sci:setPosition(ccp(11, 75))
    sci:setContentSize(CCSizeMake(808*800/1024, 388*800/1024))
    self.sci = sci


    self.content =  CCLayer:create()
    self.sci:addChild(self.content)
    self.bg:setTouchPriority(kCCMenuHandlerPriority)
end
function ChatScrollView:onTouchBegan(x, y)
    self.lastPoint = {x, y}
    local sz = self.sci:getContentSize()
    local cp = self.sci:convertToNodeSpace(ccp(x, y))
    print("onTouchScroll", cp.x, cp.y, sz.width, sz.height)
    if cp.x > 0 and cp.x < sz.width and cp.y > 0 and cp.y < sz.height then
        return true
    end
    return false
end
function ChatScrollView:onTouchMoved(x, y)
    local dify = y-self.lastPoint[2]
    local px, py = self.content:getPosition()
    self.lastPoint = {x, y}
    print("touchScroll", x, y)
    self.content:setPosition(ccp(px, py+dify))
end
function ChatScrollView:onTouchEnded(x, y)
    local px, py = self.content:getPosition()
    py = math.max(math.min(0, py), self.height-self.content.height)
    self.content:setPosition(ccp(px, py))
end

