RemoveBuild = class(FuncBuild)
function RemoveBuild:handleTouchEnded()
    if type(self.baseBuild.otherBuild) == 'table' then
        print("removeBuilding", self.baseBuild.otherBuild, type(self.baseBuild.otherBuild))
        if self.baseBuild.lastColBuild == self.baseBuild.otherBuild then
            --self.baseBuild.map:removeBuilding(self.baseBuild.otherBuild)
            --只能移除 建筑物 和 道路
            if self.baseBuild.otherBuild.picName == 'build' or self.baseBuild.otherBuild.picName == 't' then
                self.baseBuild.otherBuild:removeSelf()
                self.baseBuild.lastColBuild = nil
                self.baseBuild.otherBuild = nil
            end
        else
            self.baseBuild.lastColBuild = self.baseBuild.otherBuild
        end
    end
end
