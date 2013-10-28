Hint = class()
function Hint:ctor()
    self.bg = CCParticleSystemQuad:create("hint.plist")
    local function reset()
        self.bg:resetSystem()
    end
    self.bg:runAction(repeatForever(sequence({delaytime(0.5), callfunc(nil, reset)})))
    registerEnterOrExit(self)
end
function Hint:exitScene()
    self.bg = nil
end
