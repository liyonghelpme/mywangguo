Castle = class(FuncBuild)
function Castle:ctor(b)
    self.baseBuild = b
end
function Castle:initWorking()
    if self.par == nil then
        self.par = CCParticleSystemQuad:create("energy.plist")
        self.baseBuild.bg:addChild(self.par)
        self.par:setPositionType(2)
        setPos(self.par, {0, 240-17})
    end
end
