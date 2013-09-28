ChatData = {}
ChatData.messages = {
    {0, "xiaoming", "lai la a chi fan le ma ??", 0, 0},
    {0, "xiaoming", "lai la a chi fan le ma ??", 0, 0},
    {0, "xiaoming", "lai la a chi fan le ma ??", 0, 0},
    {0, "xiaoming", "lai la a chi fan le ma ??", 0, 0},
    {0, "xiaoming", "lai la a chi fan le ma ??", 0, 0},
}
ChatData.since = 0

function ChatData:init()
    Event:registerEvent(EVENT_TYPE.INITDATA, self)
end
function ChatData:receiveMsg(name, msg)
    if name == EVENT_TYPE.INITDATA then
        local function receive(data)
            if data ~= nil then
                local msg = data['messages']
                for k, v in ipairs(msg) do
                    table.insert(ChatData.messages, v)
                    ChatData.since = v[4]
                end
                Event:sendMsg(EVENT_TYPE.RECEIVE_MSG)
            end
            Network.getData('recv', receive, {uid=User.uid, cid=0, since=ChatData.since}, true)
        end

        Network.getData('recv', receive, {uid=User.uid, cid=0, since=ChatData.since}, true)
    end
end
function ChatData:send(msg)
    local function onSend(data)
    end
    Network.getData('send', onSend, {uid=User.uid, name=User.name, cid=0, text=msg}, true)
end
