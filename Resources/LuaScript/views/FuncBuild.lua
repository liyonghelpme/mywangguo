FuncBuild = class()

function FuncBuild:ctor(b)
    self.baseBuild = b
end
function FuncBuild:whenFree()
    return 0
end
function FuncBuild:whenBusy()
    return 0
end
function FuncBuild:getObjectId()
    return 0
end
function FuncBuild:getLeftTime()
    return 0
end
function FuncBuild:doAcc()
end
function FuncBuild:getStartTime()
    return 0
end
function FuncBuild:initWorking(data)
end
function FuncBuild:getAccCost()
    return 0
end
function FuncBuild:setPos()
end

function FuncBuild:finishBuild()
end

function FuncBuild:removeBuild()
end
function FuncBuild:doBroken()
    if self.par ~= nil then
        removeSelf(self.par)
        self.par = nil
    end
end
function FuncBuild:doAttack()
end
