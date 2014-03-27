Slope = class(FuncBuild)
--自身高度+51 就是斜坡高度
function Slope:finishBuild()
    self.baseBuild.height = 0
    local lx, ly = self.baseBuild.privData.ax, self.baseBuild.privData.ay
    local hei = adjustNewHeight(self.baseBuild.map.scene.mask, self.baseBuild.map.scene.width, lx, ly)
    self.baseBuild.height = hei*103+51
end
