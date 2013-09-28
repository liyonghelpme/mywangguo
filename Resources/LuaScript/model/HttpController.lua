local simple = require "dkjson"
HttpController = class()
function HttpController:ctor()
    self.baseUrl = CCUserDefault:sharedUserDefault():getStringForKey("netUrl")
    self.requestList = {}
    self.busy = false
end
function HttpController:addRequest(req, postData, handler, param, delegate)
    table.insert(self.requestList, {req, handler, postData, param, delegate})
    self:doRequest()
end
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
                print("url data", url, simple.encode(data), request:getResponseString())
                rep = simple.decode(request:getResponseString())
            end

            request:release()    
            if callback ~= nil then
                callback(delegate, rep, param)
            end
            self.busy = false
            --进行下一次请求测试
            self:doRequest()
        end
        request = CCHttpRequest:create(httpCallback, self.baseUrl..url, false)
        
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
