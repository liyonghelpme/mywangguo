Castle = class(FuncBuild)
function Castle:ctor(b)
    self.baseBuild = b
end
function Castle:initWorking()
    if self.energy == nil then
        self.energy = CCParticleSystemQuad:create("energy.plist")
        self.baseBuild.bg:addChild(self.energy)
        self.energy:setPositionType(2)
        setPos(self.energy, {0, 240-17})
    end
end
