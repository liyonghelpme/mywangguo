ChatDialog = class()
function ChatDialog:ctor()
    self:initView() 
end
function ChatDialog:initView()
    self.bg = CCLayer:create()
	local temp
	local menu
	local vs = CCDirector:sharedDirector():getVisibleSize()
	temp = CCSprite:create("chatBack.png")
	temp:setPosition(ccp(233, 42))
	temp:setAnchorPoint(ccp(0.50, 0.50))
	self.bg:addChild(temp)
	temp = ui.newButton({image="chatButton.png", delegate=self, callback=self.onChatbutton})
	temp.bg:setPosition(ccp(40, 30))
    temp:setAnchor(0.5, 0.5)
    self.bg:addChild(temp.bg)

    temp = colorWordsNode("[NAME:]大家好啊", 21, {255, 255, 255}, {0, 255, 0})
    --temp = CCLabelTTF:create("[NAME:]大家好啊", "", 21, CCSizeMake(363, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentBottom)

    temp:setAnchorPoint(ccp(0.00, 1.00))
	temp:setPosition(ccp(91, 71))
    self.bg:addChild(temp)
    self.word = temp


end
function ChatDialog:onChatbutton()
end

function ChatDialog:receiveMsg(name, msg)
    if name == EVENT_TYPE.RECEIVE_MSG then
    end
end


