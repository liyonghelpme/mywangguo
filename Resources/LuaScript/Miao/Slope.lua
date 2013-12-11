Slope = class(FuncBuild)
function Slope:setPos()
    local p = getPos(self.baseBuild.bg)
    local ax, ay = newCartesianToAffine(p[1], p[2], self.baseBuild.map.scene.width, self.baseBuild.map.scene.height, MapWidth/2, FIX_HEIGHT)
    print("adjust Road Height !!!!!!!!!!!!!!!!!!!!!!!!!", ax, ay)
    local ad = adjustNewHeight(self.baseBuild.map.scene.mask2, self.baseBuild.map.scene.width, ax, ay)
    if ad then
        setPos(self.baseBuild.changeDirNode, {0, 90})
    else
        setPos(self.baseBuild.changeDirNode, {0, 0})
    end
end
