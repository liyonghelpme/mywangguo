Factory = class(FuncBuild)
function Factory:setWorker(b)
    self.worker = b
end
function Factory:clearWorker(b)
    self.worker = nil
end


Store = class(FuncBuild)
