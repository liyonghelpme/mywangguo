local simple = require "dkjson"
HttpController = class()
function HttpController:ctor()
    self.baseUrl = CCUserDefault:sharedUserDefault():getStringForKey("netUrl")
    self.chatUrl = CCUserDefault:sharedUserDefault():getStringForKey("chatUrl")
    --configure 文件没有配置的话
    if self.chatUrl == nil or self.chatUrl == "" then
        self.chatUrl = 'http://112.124.41.186:8009/'
    end
    self.requestList = {}
    self.busy = false
end
function HttpController:addRequest(req, postData, handler, param, delegate)
    table.insert(self.requestList, {req, handler, postData, param, delegate})
    self:doRequest()
end
--递归调用请求就会叠加太深了
function HttpController:doRequest()
    if #self.requestList > 0 and self.busy == false then
        self.busy = true
        local req = table.remove(self.requestList, 1)
        local url = req[1]
        local callback = req[2]
        local data = req[3]
        local param = req[4]
        local delegate = req[5]

        local request
        local function httpCallback(isSuc)
            local rep
            --超时失败
            if not isSuc then
                print('issuc', isSuc)
                rep = nil
            else
                --print("url data", url, simple.encode(data), request:getResponseString())
                rep = simple.decode(request:getResponseString())
            end

            request:release()    
            if callback ~= nil then
                if delegate ~= nil then
                    callback(delegate, rep, param)
                else
                    callback(rep, param)
                end
            end
            self.busy = false
            --进行下一次请求测试
            self:doRequest()
        end
        request = CCHttpRequest:create(httpCallback, self.baseUrl..url, false)
        print("httpRequest", self.baseUrl, url, simple.encode(data))
        
        for k, v in pairs(data) do
            if type(v) == 'string' then
                request:addPostValue(k, v)
            else
                request:addPostValue(k, simple.encode(v))
            end
        end
        request:start(false)
    end
end

local function urlencode(str)
   if (str) then
      str = string.gsub (str, "\n", "\r\n")
      str = string.gsub (str, "([^%w ])",
         function (c) return string.format ("%%%02X", string.byte(c)) end)
      str = string.gsub (str, " ", "+")
   end
   return str    
end

--使用get 需要urlEncode 请求字符串
--chat是阻塞式的long poll
function HttpController:chatRequest(url, data, callback, param, delegate, setting)
    local request
    local function httpCallback(isSuc)
        local rep
        --超时失败
        if not isSuc then
            print('issuc', isSuc)
            rep = nil
        else
            print("chat url data", url, simple.encode(data), request:getResponseString())
            rep = simple.decode(request:getResponseString())
        end

        request:release()    
        if callback ~= nil then
            if delegate ~= nil then
                callback(delegate, rep, param)
            else
                callback(rep, param)
            end
        end
    end
     
    url = url..'?' 
    local n = 0
    for k, v in pairs(data) do
        if n == 0 then
            url = url..urlencode(k)..'='..urlencode(v)
        else
            url = url..'&'..urlencode(k)..'='..urlencode(v)
        end
        n = n+1
    end

    request = CCHttpRequest:create(httpCallback, self.chatUrl..url, true)
    print("chatRequest", self.chatUrl, url, simple.encode(data))
    request:start(false)
    return request
end
