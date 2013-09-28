User = {}

local function initOver(data)
    local heros = data.heros
    local user = data.user
    User.strength = user.strength
    User.uid = user.uid
    User.gold = user.gold
    User.gem = user.gem
    User.level = user.level
    User.exp = user.exp
    HeroData:init(heros)
    Event:sendMsg(EVENT_TYPE.INITDATA)
end
function User:initUser()
    User.name = "xiaoming"
    Network.postData("login", initOver, {name=User.name})
end
function User:getValue(key)
    if User[key] == nil then
        return 0
    end
    return User[key]
end
