Fence = class(FuncBuild)
function Fence:setPos()
    setPos(self.baseBuild.changeDirNode, {0, SIZEY})
end
