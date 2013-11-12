ChatModel = {}
ChatModel.chatMessage = {
}
ChatModel.receiveYet = false
--每次登陆 聊天的次数 每次奖励随机的10个 银币或者水晶
ChatModel.chatNum = 0
local function receiveChat(rep, param)
    print('receiveChat', simple.encode(rep))
    if rep ~= nil then
        local maxTime = 0
        for k, v in ipairs(rep.messages) do
            --[[
            local uid = v[1]
            local name = v[2]
            local text = v[3]
            local kind = v[5]
            --]]
            local tme = v[4]
            maxTime = tme
            print("msg ", simple.encode(v))
            table.insert(ChatModel.chatMessage, v)
        end
        ChatModel.beginTime = maxTime
        Event:sendMsg(EVENT_TYPE.UPDATE_MSG)
    end
    global.httpController:chatRequest('recv', dict({{"uid", global.user.uid}, {"cid", 0}, {"since", ChatModel.beginTime}}), receiveChat)
end

ChatModel.beginTime = 0
function ChatModel.startReceive()
    if not ChatModel.receiveYet then
        ChatModel.receiveYet = true
        global.httpController:chatRequest('recv', dict({{"uid", global.user.uid}, {"cid", 0}, {"since", ChatModel.beginTime}}), receiveChat)
    end
end
function ChatModel.sendMsg(msg)
    global.httpController:chatRequest('send', dict({{'uid', global.user.uid}, {'name', global.user:getValue('name')}, {'cid', 0}, {'text', msg}}))
end

ChatDialog = class()
function ChatDialog:ctor(s)
    self.scene = s
    self.bg = CCNode:create()
    local temp = display.newScale9Sprite("leftBack.png")
    self.bg:addChild(temp)
    setAnchor(temp, {0, 0})
    local vs = getVS()
    temp:setContentSize(CCSizeMake(vs.width, vs.height)) 
    
    local eb = ui.newEditBox({image="roleNameDia.png", imagePress="roleNameDia.png", imageDisabled="roleNameDia.png",  size={500, 42}})
    self.bg:addChild(eb)
    setPos(eb, {288, fixY(nil, designToRealY(436))})
    self.editBox = eb

    local but = ui.newButton({image="roleNameBut0.png", text=getStr("send"), size=24, conSize={100, 40}, callback=self.onSend, delegate=self})
    but:setAnchor(0.5, 0.5)
    self.bg:addChild(but.bg)
    setPos(but.bg, {620, fixY(nil, designToRealY(436))})

    local but = ui.newButton({image="closeBut.png", callback=self.onClose, delegate=self})
    but:setAnchor(0.5, 0.5)
    self.bg:addChild(but.bg)
    setPos(but.bg, {fixX(748), fixY(nil, 38)})

    local title = ui.newTTFLabel({text=getStr("feedback"), size=20, color={89, 125, 206}})
    self.bg:addChild(title)
    setAnchor(title, {0.5, 0.5})
    setPos(title, {vs.width/2, fixY(nil, 58)})

    local but = ui.newButton({text=getStr("fbNow"), size=20, image="blueButton.png", conSize={100, 40}, callback=self.onFeed, delegate=self})
    but:setAnchor(0.5, 0.5)
    self.bg:addChild(but.bg)
    setPos(but.bg, {620, fixY(nil, 58)})

    
    self:initMsg()
    registerEnterOrExit(self)
    MyPlugins:getInstance():sendCmd("hideAds", "")
end
function ChatDialog:onFeed()
    MyPlugins:getInstance():sendCmd("feedback", "")
end
function ChatDialog:enterScene()
    Event:registerEvent(EVENT_TYPE.UPDATE_MSG, self)
    ChatModel.startReceive()
end
function ChatDialog:exitScene()
    Event:unregisterEvent(EVENT_TYPE.UPDATE_MSG, self)
end
function ChatDialog:receiveMsg(name, msg)
    if name == EVENT_TYPE.UPDATE_MSG then
        self:appendMsg()
    end
end
--先整体向上移动一下 再fadeoutmsg
--或者整体向上移动很多个再fadeout 几句话
function ChatDialog:appendMsg()
    local myLen = #self.messages
    local totalLen = #ChatModel.chatMessage
    local vs = getVS()
    local dt = 0
    for i=myLen+1, totalLen, 1 do
        local v = ChatModel.chatMessage[i]
        local name = v[2]
        local text = v[3]
        local temp = ui.newTTFLabel({text=name..": ", size=25, color={52, 101, 36}})
        setAnchor(temp, {0, 1})
        local sz = temp:getContentSize()
        local con = ui.newTTFLabel({text=text, size=25, color={20, 12, 28}, dimensions={vs.width-200-sz.width, 0}})
        local hei = con:getContentSize()
        setAnchor(con, {0, 1})
        self.flowNode:addChild(temp)
        setPos(temp, {0, -self.flowHeight})
        self.flowNode:addChild(con)
        setPos(con, {sz.width, -self.flowHeight})

        self.flowHeight = self.flowHeight+hei.height

        local msg = {temp, con, hei.height}
        --等待移动上去之后
        temp:runAction(sequence({fadeout(0), delaytime(0.3+dt), fadein(0.2)}))
        con:runAction(sequence({fadeout(0), delaytime(0.3+dt), fadein(0.2)}))
        table.insert(self.messages, msg)
        dt = dt+0.2
    end
    self.flowNode:runAction(expout(moveto(0.3, 0, self.flowHeight)))
end
--chatModel 可以缓存flowNode 存储聊天信息 或者ChatModel 存储整个Dialog
function ChatDialog:initMsg()
    self.cl = Scissor:create()
    self.bg:addChild(self.cl)
    setPos(self.cl, {50, 100})
    local vs = getVS()
    setContentSize(self.cl, {vs.width-100, vs.height-200})
    self.HEIGHT = vs.height-200
    
    --只显示一个屏幕的聊天内容多余的 不显示哦
    self.flowNode = CCNode:create()
    self.cl:addChild(self.flowNode)
    self.flowHeight = 0 

    self.messages = {}

    local total = #ChatModel.chatMessage
    --留下余量的margin
    for k, v in ipairs(ChatModel.chatMessage) do
        local name = v[2]
        local text = v[3]
        local temp
        local con
        local hei
        --在用户拖动上去的时候显示
        if total > 20 and k < total-20 then
            hei = {width=0, height=0}
        else
            temp = ui.newTTFLabel({text=name..":", size=25, color={52, 101, 36}})
            setAnchor(temp, {0, 1})
            local sz = temp:getContentSize()
            con = ui.newTTFLabel({text=text, size=25, color={20, 12, 28}, dimensions={vs.width-100-sz.width, 0}})
            hei = con:getContentSize()
            setAnchor(con, {0, 1})
            self.flowNode:addChild(temp)
            setPos(temp, {0, -self.flowHeight})
            self.flowNode:addChild(con)
            setPos(con, {sz.width, -self.flowHeight})
        end

        self.flowHeight = self.flowHeight+hei.height
        
        setPos(self.flowNode, {0, self.flowHeight})

        local msg = {temp, con, hei.height}
        table.insert(self.messages, msg)
    end

    self.touch = ui.newTouchLayer({size={vs.width-100, vs.height-200}, delegate=self, touchBegan=self.touchBegan, touchMoved=self.touchMoved, touchEnded=self.touchEnded})
    self.bg:addChild(self.touch.bg)
    setPos(self.touch.bg, {50, 100})
end
function ChatDialog:touchBegan(x, y)
    self.lastPoints = {x, y}
    self.accMove = 0
end
function ChatDialog:moveBack(dify)
    local ox, oy = self.flowNode:getPosition()
    self.flowNode:setPosition(ccp(ox, oy+dify))
end
function ChatDialog:touchMoved(x, y)
    local oldPoints = self.lastPoints
    self.lastPoints = {x, y}
    local dify = self.lastPoints[2]-oldPoints[2]
    self.accMove = self.accMove+math.abs(dify)
    self:moveBack(dify)
end
function ChatDialog:touchEnded(x, y)
    local oldPos = getPos(self.flowNode)
    local minH = self.flowHeight
    if self.flowHeight > self.HEIGHT then
        minH = self.HEIGHT
    end
    oldPos[2] = math.max(minH, math.min(self.flowHeight, oldPos[2]))
    self.flowNode:setPosition(ccp(oldPos[1], oldPos[2]))

end

function ChatDialog:onSend()
    local msg = self.editBox:getText()
    if msg == "" then
        addBanner(getStr("emptyMsg"))
    else
        self.editBox:setText("")
        ChatModel.sendMsg(msg)
        ChatModel.chatNum = ChatModel.chatNum+1
        if ChatModel.chatNum < 100 then
            local r = math.random(2)
            local reward = {}
            if r == 1 then
                reward.silver = 10
                addBanner(getStr("silverReward", {"[NUM]", str(10)}))
            else 
                reward.crystal = 10
                addBanner(getStr("crystalReward", {"[NUM]", str(10)}))
            end
            sendReq("killMonster", dict({{"uid", global.user.uid}, {"gain", reward}}))
            global.user:doAdd(reward)
        end
    end
end

function ChatDialog:onClose()
    global.director:popView()
    --MyPlugins:getInstance():sendCmd("showAds", "")
end
