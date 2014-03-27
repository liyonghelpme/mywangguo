Bridge = class(FuncBuild)
function Bridge:initView()
    setPos(self.baseBuild.changeDirNode, {0, SIZEY})
    setRotation(self.baseBuild.changeDirNode, 45)
end
