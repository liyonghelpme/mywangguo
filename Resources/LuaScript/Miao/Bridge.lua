Bridge = class(FuncBuild)
--根据桥梁方向决定flipX 方向
function Bridge:initView()
    setPos(setAnchor(self.baseBuild.changeDirNode, {444/1024, (768-559)/768}), {0, SIZEY})
end
