local simple = require "SimpleJson"
Network = {}
Network.baseUrl = 'http://192.168.3.111:8080/'
Network.chatUrl = 'http://192.168.3.111:8004/'
function Network.httpRequest(url, callback)
    local request = nil
    --callback 之后release资源
    local function httpCallback(isSuc)
        print("requestRetainCount", request:retainCount())
        print("isSuc", isSuc)
        print("code", request:getResponseStatusCode())
        print("data", request:getResponseString())
        request:release()
        print("requestRetainCount check", request:retainCount())
    end
    --create 的时候自动retain
    request = CCHttpRequest:create(httpCallback, "http://www.baidu.com", true)

    
    request:start(false)
end

function Network.getData(url, callback, data, forChat)
    local request = nil
    print("Network.getData", url, simple:encode(data))
    local function httpCallback(isSuc)
        local rep
        if not isSuc then
            rep = nil
        else
            rep = simple:decode(request:getResponseString())
        end
        request:release()    
        callback(rep)
    end
    local first = true
    for k, v in pairs(data) do
        if first then
            url = url..'?'
            first = false
        else
            url = url..'&'
        end
        url = url..string.urlencode(k)..'='..string.urlencode(v)
    end
    print("getData", url)
    if not forChat then
        request = CCHttpRequest:create(httpCallback, Network.baseUrl..url, true)
    else
        request = CCHttpRequest:create(httpCallback, Network.chatUrl..url, true)
    end
    request:start(false)
end

--key str
--value simple.encode()
--避免客户端同时发送多个请求的方法就是队列化所有request请求
function Network.postData(url, delegate, callback, data, params)
    local request = nil
    print("url data", url, simple:encode(data))
    local function httpCallback(isSuc)
        local rep
        --超时失败
        if not isSuc then
            print('issuc', isSuc)
            rep = nil
        else
            print("url data", url, simple:encode(data), request:getResponseString())
            rep = simple:decode(request:getResponseString())
        end

        request:release()    
        callback(delegate, rep, params)
    end
    request = CCHttpRequest:create(httpCallback, Network.baseUrl..url, false)
    --后台需要把post过去的值全部decode 一下才能使用啊
    for k, v in pairs(data) do
        if type(v) == 'string' then
            request:addPostValue(k, v)
        else
            request:addPostValue(k, simple:encode(v))
        end
    end
    request:start(false)
end
